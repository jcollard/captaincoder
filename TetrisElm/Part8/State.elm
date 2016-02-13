module State where

import Basics exposing (..)
import Controller exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (Element)
import Signal
import Tetromino exposing (Tetromino)


{- A Record describing the state of our game -}
type alias State = { falling : Tetromino }

{- Our default starting state -}                 
defaultState : State                 
defaultState = { falling = Tetromino.j }

{- Given a state, create an Element that can be rendered to the screen. -}
view : State -> Element
view state =
  let
    screenWidth = 800
    screenHeight = 600
    fallingForm = Tetromino.toForm state.falling
  in  collage screenWidth screenHeight [fallingForm]

{- Given an Input and a State, produce the State that is a result of
   the input on the previous state. -}
update : Input -> State -> State
update input state =
  case input of
    Rotate -> { state | falling = Tetromino.rotate state.falling }
    Shift amount -> { state | falling = Tetromino.shift amount state.falling }

{- A Signal of states for our Game -}                    
states : Signal State
states = Signal.foldp update defaultState inputs

main : Signal Element
main = Signal.map view states
