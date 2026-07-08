# build123d-devcont

A ready-to-use VS Code dev container for [build123d](https://github.com/gumyr/build123d) — code-driven CAD in Python with a live 3D viewer inside the editor. Clone it, open it in a container, and start modeling.

## Install

**Prerequisites**

- [Docker Desktop](https://www.docker.com/products/docker-desktop/), running. On Windows, use the WSL2 backend and make sure your distro is enabled under **Settings → Resources → WSL Integration**.
- [VS Code](https://code.visualstudio.com/) with the **Dev Containers** extension (`ms-vscode-remote.remote-containers`).

**Steps**

1. Clone the repo:
   ```bash
   git clone https://github.com/Z-K-O/build123d-devcont.git
   ```
2. Open the folder in VS Code.
3. Command Palette (`Ctrl+Shift+P`) → **Dev Containers: Reopen in Container**.
4. Wait for the build. The first build on a new machine pulls prebuilt layers from GitHub Container Registry (the image is public, so no login needed); later builds are near-instant. If the registry is unreachable, it falls back to building locally from the Dockerfile automatically.

That's it. On attach, the container opens a starter script (`CAD/test_shape.py`) and the 3D viewer connects on its own.

**Verify it works**

In the opened `CAD/test_shape.py`, run the first cell with `Shift+Enter`, then the second. A box should render in the OCP CAD Viewer panel.

## What's inside

- **Python 3.13** in an isolated `uv` virtual environment at `/opt/venv`.
- **build123d** + **ocp_vscode** (the live viewer bridge), with the OpenCascade system libraries the bindings need.
- VS Code extensions installed automatically: Python, Jupyter, and the OCP CAD Viewer.
- A viewer server on port **3939**, started by the OCP CAD Viewer extension.

## Working in it

The intended loop is cell-based, using VS Code's Jupyter Interactive Window rather than re-running the whole file each time:

- Cells are marked with `# %%`. Run one with `Shift+Enter`.
- Run the **setup cell once** per session (imports + viewer defaults) — this pays the one-time cost of loading the CAD libraries. After that, editing a geometry cell and re-running it updates the viewer near-instantly, since the kernel stays warm.
- The camera position is preserved across re-runs, so tweaking a dimension doesn't reset your view.

Keep geometry and its `show(...)` call in the same cell so a single `Shift+Enter` does edit → rebuild → redisplay in one step.

## Where your files go

The `CAD/` directory is scratch space for design files inside the container; its contents are gitignored (the folder's own README is kept). You're not limited to it — the project folder is bind-mounted from the host, so design files anywhere on your machine are usable from inside the container too. `CAD/test_shape.py` is scaffolded from a template on first attach.

## How it stays reproducible

- The image is built and pushed to `ghcr.io/Z-K-O/build123d-devcont` by a GitHub Actions workflow whenever the Dockerfile changes.
- `devcontainer.json` uses that image as a build cache (`cacheFrom`), so fresh machines pull prebuilt layers instead of compiling everything. If the registry can't be reached, it builds locally from the same Dockerfile — same result, just slower.
- `.gitattributes` pins shell scripts to LF line endings, so the container's bash scripts work correctly no matter what OS you clone on.

## Bumping the Python version

The base image is set in `.devcontainer/Dockerfile` (`FROM python:3.13-slim-bookworm`). 3.13 is currently the newest version with full prebuilt-wheel coverage across build123d and its OpenCascade dependency. Newer versions work once those wheels are published upstream; until then, a newer base risks slow source builds or missing dependencies.
