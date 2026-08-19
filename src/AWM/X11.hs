module AWM.X11
  ( run
  ) where

import Data.Bits ((.|.))
import Graphics.X11
import Graphics.X11.Xlib.Extras
import Foreign.Marshal.Alloc (alloca)

run :: IO ()
run = do
  dpy <- openDisplay ""
  root <- rootWindow dpy (defaultScreen dpy)
  selectInput dpy root (structureNotifyMask .|. substructureRedirectMask)
  sync dpy False
  loop dpy

loop :: Display -> IO ()
loop dpy = do
  ev <- allocaXEvent $ \ptr -> do
    nextEvent dpy ptr
    getEvent ptr
  print ev
  loop dpy
