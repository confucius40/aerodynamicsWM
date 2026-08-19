#!/bin/sh

Xephyr :1 -screen 1280x720 &
exec env DISPLAY=:1 stack exec aerodynamics-wm
