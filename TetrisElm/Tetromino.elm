module Tetromino where

import Basics exposing (..)

import Block exposing (Block)
import Block as Block

import Color exposing (Color)
import Color as Color

import Graphics.Element exposing (Element)
import Graphics.Element as Element

import Graphics.Collage exposing (Form)
import Graphics.Collage as Collage

import List as List

import Mouse as Mouse

import Signal exposing (Signal)
import Signal as Signal

type alias Location = (Int, Int)
type alias Tetromino = { shape : List Location
                       , pivot : (Float, Float)
                       , block : Block
                       , width : Int
                       , height : Int
                       }

i : Tetromino
i = { block = { color = Color.lightBlue }
    , shape = [ (-1, 0), (0, 0), (1, 0), (2, 0) ]
    , pivot = (0.5, 0.5)
    , width = 4
    , height = 1
    }

z : Tetromino
z = { block = { color = Color.red }
    , shape = [ (-1, 1), (0,  1),
                          (0, 0), (1, 0) ]
    , pivot = (0, 0)
    , width = 3
    , height = 2
    }

s : Tetromino
s = { block = { color = Color.green }
    , shape = [           (0,  1), (1, 1),
                (-1, 0), (0,  0)
              ]
    , pivot = (0, 0)
    , width = 3
    , height = 2
    }

t : Tetromino
t = { block = { color = Color.purple }
    , shape = [ (-1, 1), (0,  1), (1, 1),
                         (0,  0)
              ]
    , pivot = (0, 1)
    , width = 3
    , height = 2              
    }

l : Tetromino
l = { block = { color = Color.orange }
    , shape = [ (0,  1),
                (0,  0),
                (0, -1), (1, -1)
              ]
    , pivot = (0, 0)
    , width = 3
    , height = 2              
    }

j : Tetromino
j = { block = { color = Color.blue }
    , shape = [          (1,  1),
                         (1,  0),
                (0, -1), (1, -1)
              ]
    , pivot = (1, 0)
    , width = 2
    , height = 2              
    }

o : Tetromino
o = { block = { color = Color.yellow }
    , shape = [ (0, 1), (1, 1)
              , (0, 0), (1, 0)
              ]
    , pivot = (0.5, 0.5)
    , width = 2
    , height = 2              
    }

rotatePoint : (Float, Float) -> Float -> Location -> Location
rotatePoint (pivotR, pivotC) angle (row, col) =
  let rowF = toFloat row
      colF = toFloat col
      s = sin(angle)
      c = cos(angle)
      rowOrigin = rowF - pivotR
      colOrigin = colF - pivotC
      rowRotated = rowOrigin * c - colOrigin * s
      colRotated = rowOrigin * s + colOrigin * c
      newRow = round (rowRotated + pivotR)
      newCol = round (colRotated + pivotC)
  in (newRow, newCol)

rotate : Tetromino -> Tetromino
rotate tetromino =
  let rotate' = rotatePoint tetromino.pivot (degrees -90)
      newShape = List.map rotate' tetromino.shape
  in { tetromino | shape = newShape
                 , width = tetromino.height
                 , height = tetromino.width
     }

shift : (Int, Int) -> Tetromino -> Tetromino
shift (rows, cols) tetromino =
  let shifted = List.map (\(row, col) -> (row + rows, col + cols)) tetromino.shape
      (pivotR, pivotC) = tetromino.pivot
  in { tetromino | shape = shifted
                 , pivot = ((toFloat rows) + pivotR, (toFloat cols) + pivotC)
     }
  
                     
toForm : Tetromino -> Form
toForm { shape, block } =
  let form = Block.toForm block
      translate (row, col) = Collage.move ((toFloat row) * Block.width
                                          ,(toFloat col) * Block.height)
                                          form
      forms = List.map translate shape
  in Collage.group forms
                                            

drawPivot : Tetromino -> Form
drawPivot {pivot} =
  let (x, y) = pivot
  in Collage.filled Color.black (Collage.circle 5) |> Collage.move (x*25, y*25)


controller : () -> Tetromino -> Tetromino
controller () tetromino = rotate tetromino

view : Tetromino -> Element
view tetromino =
  Collage.collage 400 400 [toForm tetromino, drawPivot tetromino]
     
main : Signal Element                     
main = Signal.map view (Signal.foldp controller t Mouse.clicks)
