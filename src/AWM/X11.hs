module AWM.X11
  ( run
  ) where

import AWM.World
import Data.Bits ((.|.))
import Graphics.X11
import Graphics.X11.Xlib.Extras

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

    ConfigureRequestEvent
      { ev_window = win
      , ev_x = x
      , ev_y = y
      , ev_width = w
      , ev_height = h
      , ev_border_width = bw
      , ev_value_mask = vm
      } -> do
        let changes =
              WindowChanges
                { wc_x = x
                , wc_y = y
                , wc_width = w
                , wc_height = h
                , wc_border_width = bw
                , wc_sibling = 0
                , wc_stack_mode = 0
                }
        configureWindow dpy win vm changes
        sync dpy False
        loop dpy root world

    DestroyWindowEvent { ev_window = win } ->
      loop dpy root (del win world)

    _ ->
      loop dpy root world
