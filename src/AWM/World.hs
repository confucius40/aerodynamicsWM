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
  , hit
  , grab
  , drag
  , ungrab
  , view
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
  { wins    :: !(Map Window Win)
  , cam     :: !Cam
  , mouse   :: !Vec
  , grabbed :: !(Maybe Window)
  , panning :: !Bool
  } deriving (Show)

zero :: Vec
zero = Vec 0 0

empty :: World
empty =
  World
    { wins = Map.empty
    , cam = Cam zero 1
    , mouse = zero
    , grabbed = Nothing
    , panning = False
    }

add :: Win -> World -> World
add win state =
  state { wins = Map.insert (wid win) win (wins state) }

del :: Window -> World -> World
del win state =
  state
    { wins = Map.delete win (wins state)
    , grabbed = if grabbed state == Just win then Nothing else grabbed state
    }

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

hit :: Vec -> Win -> Bool
hit p win =
  vx p >= vx (pos win)
    && vy p >= vy (pos win)
    && vx p <= vx (pos win) + vx (size win)
    && vy p <= vy (pos win) + vy (size win)

grab :: Window -> Vec -> World -> World
grab win p state =
  state
    { grabbed = Just win
    , mouse = p
    }

drag :: Vec -> World -> World
drag p state =
  case grabbed state of
    Nothing ->
      state { mouse = p }

    Just win ->
      case Map.lookup win (wins state) of
        Nothing ->
          state
            { mouse = p
            , grabbed = Nothing
            }

        Just item ->
          let
            old = world (cam state) (mouse state)
            now = world (cam state) p
            delta = move now (Vec (-vx old) (-vy old))
            item' = item { pos = move (pos item) delta }
          in
            state
              { mouse = p
              , wins = Map.insert win item' (wins state)
              }

ungrab :: World -> World
ungrab state =
  state { grabbed = Nothing }

view :: Vec -> Vec -> World -> World
view old now state =
  let
    a = world (cam state) old
    b = world (cam state) now
    delta = move a (Vec (-vx b) (-vy b))
  in
    state
      { cam = (cam state)
          { cpos = move (cpos (cam state)) delta
          }
      , mouse = now
      }
