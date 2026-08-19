module AWM.World
  ( World(..)
  , Win(..)
  , empty
  , add
  , del
  ) where

import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Graphics.X11 (Window)

data Win = Win
  { wid :: !Window
  } deriving (Eq, Show)

data World = World
  { wins :: !(Map Window Win)
  } deriving (Show)

empty :: World
empty = World Map.empty

add :: Win -> World -> World
add win world =
  world { wins = Map.insert (wid win) win (wins world) }

del :: Window -> World -> World
del win world =
  world { wins = Map.delete win (wins world) }
