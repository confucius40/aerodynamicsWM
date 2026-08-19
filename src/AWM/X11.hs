module AWM.X11
  ( run
  ) where

import AWM.World
import Data.Bits ((.|.))
import Graphics.X11
import Graphics.X11.Xlib.Extras
import Control.Monad (when)

run :: IO ()
run = do
  dpy <- openDisplay ""
  root <- rootWindow dpy (defaultScreen dpy)
  selectInput dpy root mask
  sync dpy False
  loop dpy root empty

mask :: EventMask
mask =
  substructureRedirectMask
  .|. substructureNotifyMask

loop :: Display -> Window -> World -> IO ()
loop dpy root world = do
  ev <- allocaXEvent $ \ptr -> do
    nextEvent dpy ptr
    getEvent ptr
  case ev of
    MapRequestEvent { ev_window = win } -> do
      mapWindow dpy win
      sync dpy False
      loop dpy root (add (Win win) world)

    DestroyWindowEvent { ev_window = win } ->
      loop dpy root (del win world)

    _ ->
      loop dpy root world
