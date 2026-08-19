module AWM.World
  ( Vec(..)
  , Win(..)
  , Cam(..)
  , World(..)
  , zero
  , empty
  , add
  , del
  , move
  , screen
  , world
  ) where

import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Graphics.X11 (Window)

data Vec = Vec
  { vx :: !Double
  , vy :: !Double
  } deriving (Eq, Show)

data Win = Win
  { wid  :: !Window
  , pos  :: !Vec
  , vel  :: !Vec
  , size :: !Vec
  } deriving (Eq, Show)

data Cam = Cam
  { cpos  :: !Vec
  , czoom :: !Double
  } deriving (Eq, Show)

data World = World
  { wins :: !(Map Window Win)
  , cam  :: !Cam
  } deriving (Show)

zero :: Vec
zero = Vec 0 0

empty :: World
empty =
  World
    { wins = Map.empty
    , cam = Cam zero 1
    }

add :: Win -> World -> World
add win state =
  state { wins = Map.insert (wid win) win (wins state) }

del :: Window -> World -> World
del win state =
  state { wins = Map.delete win (wins state) }

move :: Vec -> Vec -> Vec
move (Vec ax ay) (Vec bx by) =
  Vec (ax + bx) (ay + by)

screen :: Cam -> Vec -> Vec
screen camera p =
  Vec
    { vx = (vx p - vx (cpos camera)) * czoom camera
    , vy = (vy p - vy (cpos camera)) * czoom camera
    }

world :: Cam -> Vec -> Vec
world camera p =
  Vec
    { vx = vx p / czoom camera + vx (cpos camera)
    , vy = vy p / czoom camera + vy (cpos camera)
    }
