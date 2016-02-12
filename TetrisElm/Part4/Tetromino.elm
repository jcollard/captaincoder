module Tetromino where

import Basics exposing (..)
import Block exposing (Block)
import Color exposing (Color)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import List

{- A Location is the row, col position on the Board -}
type alias Location = (Int, Int)
{- A Tetromino is a list of locations where a particular
   block is placed.
 -}                    
type alias Tetromino = { shape : List Location
                       , block : Block
                       , pivot : { r : Float, c : Float }
                       , rows : Int
                       , cols : Int
                       }

i : Tetromino
i = { shape = [ ( 1, 0)
              , ( 0, 0)
              , (-1, 0)
              , (-2, 0)]
    , block = Block Color.lightBlue
    , pivot = { r = -0.5, c = 0.5 }
    , rows = 4
    , cols = 1
    }

j : Tetromino
j = { shape = [         ( 1, 0),
                        ( 0, 0),
              (-1, -1), (-1, 0)
              ]                  
    , block = Block Color.blue
    , pivot = { r = 0.0, c = 0.0 }
    , rows = 3
    , cols = 2
    }

{- Converts a Tetromino to a Form that can be rendered -}
toForm : Tetromino -> Form
toForm { shape, block } =
  let form = Block.toForm block
      translate (row, col) = move ((toFloat col) * Block.size,
                                   (toFloat row) * Block.size) form
      forms = List.map translate shape
  in group forms

{- Takes a Tetromino and produces a dot at its pivot point -}     
drawPivot : Tetromino -> Form
drawPivot { pivot } =
  let dot = circle 5 |> filled Color.black
      translate = move (pivot.c * Block.size, pivot.r * Block.size)
  in translate dot

{- Given a Location, rotates it around a pivot some number of degrees. -}     
rotateLocation : { r : Float, c : Float } -> Float -> Location -> Location
rotateLocation pivot angle (row, col) =
  let rowOrigin = (toFloat row) - pivot.r
      colOrigin = (toFloat col) - pivot.c
      (s, c) = (sin(angle), cos(angle))
      rowRotated = rowOrigin * c - colOrigin * s
      colRotated = rowOrigin * s + colOrigin * c
  in (round <| rowRotated + pivot.r, round <| colRotated + pivot.c)

{- Rotates a Tetromino 90 degrees -}     
rotate : Tetromino -> Tetromino
rotate tetromino =
  let rotateHelper = rotateLocation tetromino.pivot (degrees 90)
      newShape = List.map rotateHelper tetromino.shape
  in { tetromino | shape = newShape
                 , rows = tetromino.cols
                 , cols = tetromino.rows
     }

tetromino = rotate i
            
main : Element
main = collage 400 400 [toForm tetromino, drawPivot tetromino]
