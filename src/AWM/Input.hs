module AWM.Input
  ( press
  , release
  , motion
  , scroll
  ) where

import AWM.World
import qualified Data.Map.Strict as Map

press :: World -> Int -> World
press state btn
  | btn == 1 =
      case filter (hit p . snd) (Map.toList (wins state)) of
        ((win, _):_) -> grab win (mouse state) state
        [] -> state
  | btn == 2 =
      state { panning = True }
  | otherwise =
      state
  where
    p = world (cam state) (mouse state)

release :: World -> Int -> World
release state btn
  | btn == 1 = ungrab state
  | btn == 2 = state { panning = False }
  | otherwise = state

motion :: World -> Vec -> World
motion state p
  | panning state = view (mouse state) p state
  | otherwise = drag p state

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
    next = old { czoom = z }
    after = world next p
    delta = move before (Vec (-vx after) (-vy after))
  in
    state
      { cam = next
          { cpos = move (cpos next) delta
          }
      }
