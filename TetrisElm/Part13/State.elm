module State where

import Basics exposing (..)
import Board exposing (Board)
import Controller exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (Element)
import Signal
import Tetromino exposing (Tetromino)
import Time exposing (Time)


{- A Record describing the state of our game -}
type alias State = { falling : Tetromino
                   , board : Board
                   , time : Time
                   , nextShift : Time
                   , shiftDelay : Time
                   }
{- Spot to shift new pieces to -}
startingShift : (Int, Int)
startingShift = (20, 5)
  
{- Our default starting state -}                 
defaultState : State                 
defaultState = { falling = Tetromino.shift startingShift Tetromino.j 
               , board = Board.new []
               , time = 0
               , nextShift = Time.second
               , shiftDelay = Time.second
               }

{- Given a state, create an Element that can be rendered to the screen. -}
view : State -> Element
view state =
  let
    screenWidth = 800
    screenHeight = 600
    boardForm = Board.addTetromino state.falling state.board |> Board.toForm
  in  collage screenWidth screenHeight [boardForm]

{- Checks to see if it is time to move the Tetromino down. -}
checkTick : State -> State
checkTick state =
  if (state.time < state.nextShift) then state
  else { state | falling = Tetromino.shift (-1, 0) state.falling
               , nextShift = state.time + state.shiftDelay
       }

{- Given a current and new state, checks to see if the new state
   is valid. If it is, the new state is returned otherwise
   the current state is returned.
-}    
useIfValid : State -> State -> State
useIfValid current new =
  if Board.isValid new.falling new.board then new
  else current

{- Tries to kick the nextState by the shifted amounts. The
   first shift that produces a valid state, is returned.
   If no shifts produce a valid state, the current state
   is returned
-}       
tryKicks : List (Int, Int) -> State -> State -> State
tryKicks shifts current nextState =
  case shifts of
    [] -> current
    (s :: rest) ->
      let shifted = Tetromino.shift s nextState.falling
      in if Board.isValid shifted nextState.board then { nextState | falling = shifted }
         else tryKicks rest current nextState

{- If possible, wall kicks the nextState. Otherwise, returns 
   the current state
-}
wallKick : State -> State -> State
wallKick current nextState =
  let range = nextState.falling.cols // 2
      shifts = [1 .. range] |> List.concatMap (\n -> [(0, n), (0, -n)])
  in tryKicks shifts current nextState

     
{- If possible, floor kicks the nextState. Otherwise, returns 
   the current state
-}
floorKick : State -> State -> State
floorKick current nextState =
  let range = nextState.falling.rows // 2
      shifts = [1 .. range] |> List.map (\n -> (n, 0))
  in tryKicks shifts current nextState
      
{- Given an Input and a State, produce the State that is a result of
   the input on the previous state. -}
update : Input -> State -> State
update input state =
  let useIfValid' = useIfValid state
  in case input of
        Rotate ->
          let rotated = { state | falling = Tetromino.rotate state.falling }
              nextState = useIfValid' rotated
              nextState' =
                if nextState == state then wallKick state rotated else nextState
              nextState'' =
                if nextState' == state then floorKick state rotated else nextState'
          in nextState''
        Shift amount -> useIfValid' { state | falling = Tetromino.shift amount state.falling }
        Tick delta -> useIfValid' <| checkTick { state | time = state.time + delta }

{- A Signal of states for our Game -}                    
states : Signal State
states = Signal.foldp update defaultState inputs

main : Signal Element
main = Signal.map view states
