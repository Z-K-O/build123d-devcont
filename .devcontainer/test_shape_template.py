# %%
from build123d import *
from ocp_vscode import show, set_defaults, Camera, ignore_camera_warnings
set_defaults(reset_camera=Camera.KEEP)
ignore_camera_warnings()

# %%
with BuildPart() as test_shape:
    Box(5, 10, 15)
show(test_shape)
