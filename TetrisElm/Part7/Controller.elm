module Controller where

import Basics exposing (..)
import Graphics.Element exposing (Element, show)
import Keyboard exposing (arrows)
import Signal exposing (Signal)


{- The various inputs that change the State of a Tetris Game. -}
type Input = Rotate | Shift (Int, Int)

{- Converts a Record produced by Keyboard.arrows into an Input -}           
arrowsToInput : { x : Int, y : Int } -> Input
arrowsToInput {x, y} =
  if (y == 1) then Rotate else Shift (y, x)

{- A Signal of Inputs -}     
inputs : Signal Input
inputs = Signal.map arrowsToInput arrows

main : Signal Element         
main = Signal.map show inputs
