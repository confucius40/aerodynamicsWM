module AWM.Input
  ( button
  , release
  , motion
  , scroll
  ) where

import AWM.World
import qualified Data.Map.Strict as Map
import Graphics.X11

button :: Display -> World -> Window -> Int -> IO World
button _ state _ btn
  | btn == 2 = pure state { pan = True }
  | btn == 1 =
      pure state { drag = find state }
  | otherwise = pure state
  where
    find s =
      case filter (hit (world (cam s) (mouse s)) . snd) (Map.toList (wins s)) of
        ((w, _):_) -> Just w
        [] -> Nothing

release :: World -> Int -> World
release state btn
  | btn == 2 = state { pan = False }
  | btn == 1 = state { drag = Nothing }
  | otherwise = state

motion :: World -> Vec -> World
motion state p =
  state { mouse = p }

scroll :: World -> Int -> World
scroll state dir =
  let
    old = cam state
    factor
      | dir > 0 = 1.1
      | otherwise = 1 / 1.1
    p = mouse state
    before = world old p
    z = max 0.05 (min 20 (czoom old * factor))
    next = Cam (cpos old) z
    after = world next p
    delta = move before (Vec (-vx after) (-vy after))
  in
    state
      { cam = next { cpos = move (cpos next) delta }
      }
