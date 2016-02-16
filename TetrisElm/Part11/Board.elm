module Board where

import Block exposing (Block)
import Color
import Dict exposing (Dict)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (show)
import List
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


checkRow : Int -> Board -> Bool
checkRow row board =
  let blocks = Dict.filter (\(r, _) _ -> r == row) board
  in Dict.size blocks == 10

clearRow : Int -> Board -> Board
clearRow row board =
  let shift (r, c) block newBoard =
        if (r < row) then (Dict.insert (r, c) block newBoard)
        else if (r > row) then (Dict.insert (r-1, c) block newBoard)
        else newBoard
  in Dict.foldr shift Dict.empty board
        
clearLines : Board -> (Int, Board)
clearLines = clearLines' 0 0

clearLines' : Int -> Int -> Board -> (Int, Board)
clearLines' row lines board =
  if row == 20 then (lines, board)
  else if not (checkRow row board) then clearLines' (row + 1) lines board
  else clearLines' row (lines + 1) (clearRow row board)

--Don't forget to import List and Graphics.Element.show
cumulativeSum : List Int -> List Int
cumulativeSum toSum =
  let sum n (total, acc) = (n + total, (n + total) :: acc)
      (_, result) = List.foldl sum (0, []) toSum
  in List.reverse result

fillRow : Int -> Block -> Board -> Board
fillRow row block board =
  let cs = cumulativeSum (List.repeat (cols + 1) 1) |>
           List.map (\x -> x - 1)
      rs = List.repeat rows row
      blocks = List.repeat cols block
      locations = List.map2 (,) rs cs
      asBoard = List.map2 (,) locations blocks |> new
  in Dict.union board asBoard

testBoard : Board
testBoard = new [] |>
            fillRow 0 (Block Color.red) |>
            fillRow 1 (Block Color.yellow) |>
            fillRow 2 (Block Color.purple) |>
            Dict.remove (1, 0)

main =
  let (cleared, board) = clearLines testBoard
  in collage 600 600 [toForm testBoard]
