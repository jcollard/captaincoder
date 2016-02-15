module Board where

import Block exposing (Block)
import Color
import Dict exposing (Dict)
import Graphics.Collage exposing (..)
import Tetromino exposing (Tetromino, Location)

type alias Board = Dict Location Block
                 
new : List (Location, Block) -> Board
new = Dict.fromList

cols : Int
cols = 10

rows : Int
rows = 20

background : Form
background =
  let shape = rect ((toFloat cols) * Block.size) ((toFloat rows) * Block.size)
      border = outlined (solid Color.black) shape --Added later
  in group [border, filled Color.black shape]

addBlock : Location -> Block -> Form -> Form
addBlock (row, col) block form =
  let
    offSetX = -(toFloat (cols - 1) * Block.size)/2
    offSetY = -(toFloat (rows - 1) * Block.size)/2
    x = toFloat col * Block.size
    y = toFloat row * Block.size
    blockForm = Block.toForm block |> move (offSetX + x, offSetY + y)
  in group [form, blockForm]

toForm : Board -> Form
toForm board = Dict.foldr addBlock background board 

testBoard : Board
testBoard = new [ ( (0,0), Block Color.blue )
                , ( (0,1), Block Color.yellow )
                , ( (1,0), Block Color.red )
                , ( (1,1), Block Color.green )
                ]


main = collage 600 600 [toForm testBoard]
