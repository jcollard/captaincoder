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

{- A standard Tetris Board is 10 columns wide -}
cols : Int
cols = 10

{- A standard Tetris Board is 20 rows tall -}
rows : Int
rows = 20

{- A black background for our Blocks to rest on -}
background : Form
background =
  let shape = rect ((toFloat cols) * Block.size) ((toFloat rows) * Block.size)
      border = outlined (solid Color.black) shape --Added later
  in group [border, filled Color.black shape]

{- Adds a block at the specified location to a form -}
addBlock : Location -> Block -> Form -> Form
addBlock (row, col) block form =
  let
    offSetX = -(toFloat (cols - 1) * Block.size)/2
    offSetY = -(toFloat (rows - 1) * Block.size)/2
    x = toFloat col * Block.size
    y = toFloat row * Block.size
    blockForm = Block.toForm block |> move (offSetX + x, offSetY + y)
  in group [form, blockForm]

{- Given a Board, produce a form of that board on a black background -}
toForm : Board -> Form
toForm board = Dict.foldr addBlock background board 

{- Given a List, returns a List of equal length that is
   the cumulative sum of the values in the list.
-}
cumulativeSum : List Int -> List Int
cumulativeSum toSum =
  let sum n (total, acc) = (n + total, (n + total) :: acc)
      (_, result) = List.foldl sum (0, []) toSum
  in List.reverse result

{- Given a row, block, and board, produces a board
   with the specified row filled completely with the
   specified block
-}
fillRow : Int -> Block -> Board -> Board
fillRow row block board =
  let cs = cumulativeSum (List.repeat cols 1) |>
           List.map (\x -> x - 1)
      rs = List.repeat cols row
      locations = List.map2 (,) rs cs
      blocks = List.repeat cols block
      asBoard = new <| List.map2 (,) locations blocks
  in Dict.union asBoard board

{- True if the specified row is completely filled with blocks
   and False otherwise.
-}
checkRow : Int -> Board -> Bool
checkRow row board =
  let blocks = Dict.filter (\(r,_) _ -> r == row) board
  in Dict.size blocks == cols

{- Given a row and a board, shifts all rows above the
   specified row down 1 row.
-}
clearRow : Int -> Board -> Board
clearRow row board =
  let shift (r, c) block newBoard =
        if (r < row) then (Dict.insert (r, c) block newBoard)
        else if (r > row) then (Dict.insert (r - 1, c) block newBoard)
        else newBoard
  in Dict.foldr shift Dict.empty board

{- Given a board, produces a pair where the first value
   is the number of rows which were complete in that board
   and the second value is a new board with each of those rows
   cleared
-}
clearLines : Board -> (Int, Board)
clearLines = clearLines' 0 0

-- Helper for clearLines
clearLines' : Int -> Int -> Board -> (Int, Board)
clearLines' row lines board =
  if (row >= rows) then (lines, board)
  else if (checkRow row board) then clearLines' row (lines + 1) (clearRow row board)
  else clearLines' (row + 1) lines board
     
testBoard : Board
testBoard = fillRow 0 (Block Color.blue) (new []) |>
            fillRow 1 (Block Color.red) |>
            fillRow 2 (Block Color.yellow)

main = show <| fst <| clearLines (new [])
--main = collage 600 600 [toForm testBoard]
