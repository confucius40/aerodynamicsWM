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
loop dpy root state = do
  ev <- allocaXEvent $ \ptr -> do
    nextEvent dpy ptr
    getEvent ptr
  case ev of
    MapRequestEvent { ev_window = win } -> do
      attr <- getWindowAttributes dpy win
      let p = Vec
            { vx = fromIntegral (wa_x attr)
            , vy = fromIntegral (wa_y attr)
            }
          s = Vec
            { vx = fromIntegral (wa_width attr)
            , vy = fromIntegral (wa_height attr)
            }
          item = Win
            { wid = win
            , pos = p
            , vel = zero
            , size = s
            }
      mapWindow dpy win
      sync dpy False
      loop dpy root (add item state)

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
        loop dpy root state

    DestroyWindowEvent { ev_window = win } ->
      loop dpy root (del win state)

    _ ->
      loop dpy root state
