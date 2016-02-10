module Board where

import Basics exposing (..)

import Block exposing (Block)
import Block as Block

import Color exposing (Color)
import Color as Color

import Dict exposing (Dict)
import Dict as Dict

import Graphics.Collage exposing (Form)
import Graphics.Collage as Collage

import Graphics.Element exposing (Element)
import Graphics.Element as Element

import List as List

import Tetromino exposing (Tetromino)

type alias Location = (Int, Int)
type alias Board = Dict Location Block

rows : Int      
rows = 20

cols : Int
cols = 10

new : List (Location, Block) -> Board
new blocks = Dict.fromList blocks

isOccupied : Location -> Board -> Bool
isOccupied loc board = Dict.member loc board
             
add : Tetromino -> Board -> Board
add tetromino board =
  let helper location board = Dict.insert location tetromino.block board
  in List.foldr helper board tetromino.shape

toFormHelper : (Int, Int) -> Block -> List Form -> List Form
toFormHelper (row, col) block forms =
  let form = Block.toForm block
      moved = Collage.move ( (toFloat col) * Block.height
                           , (toFloat row) * Block.width ) form
  in moved :: forms
                       
                 
toForm : Board -> Form
toForm board =
  let blockOffset = (-(toFloat (cols - 1)) * Block.height/2
                    ,-(toFloat (rows - 1))*Block.width/2)
      blocks = Dict.foldr toFormHelper [] board |>
               Collage.group |>
               Collage.move blockOffset               
      bgShape = Collage.rect ((toFloat cols) * Block.height)
                             ((toFloat rows) * Block.width)
                               
      background = Collage.filled Color.black bgShape
      outline = Collage.outlined (Collage.solid Color.black) bgShape
  in Collage.group [background, blocks, outline]

testBoard : Board
testBoard = new [ ( (0, 0), Block Color.yellow )
                , ( (0, 1), Block Color.red )
                , ( (1, 0), Block Color.blue )
                ]
            
main : Element               
main = Collage.collage 800 600 [toForm testBoard]
