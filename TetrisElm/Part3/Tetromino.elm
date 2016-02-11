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
                       }

{- Converts a Tetromino to a Form that can be rendered -}
toForm : Tetromino -> Form
toForm { shape, block } =
  let form = Block.toForm block
      translate (row, col) = move ((toFloat col) * Block.size,
                                   (toFloat row) * Block.size) form
      forms = List.map translate shape
  in group forms

i : Tetromino
i = { shape = [ ( 1, 0)
              , ( 0, 0)
              , (-1, 0)
              , (-2, 0)]
    , block = Block Color.lightBlue
    }

j : Tetromino
j = { shape = [         ( 1, 0),
                        ( 0, 0),
              (-1, -1), (-1, 0)
              ]                  
    , block = Block Color.blue
    }

tetromino = j
  
main : Element
main = collage 400 400 [toForm tetromino]
