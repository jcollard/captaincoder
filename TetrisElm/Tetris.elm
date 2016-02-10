module Tetris where

import Basics exposing (..)

import Board exposing (Board, Location)
import Board as Board

import Block exposing (Block)
import Block as Block

import Char as Char

import Dict exposing (Dict)
import Dict as Dict

import Graphics.Element exposing (Element)
import Graphics.Element as Element

import Graphics.Collage exposing (Form)
import Graphics.Collage as Collage

import Keyboard as Keyboard

import Maybe as Maybe

import Random exposing (Generator, Seed)
import Random as Random

import Signal exposing (Signal)
import Signal as Signal

import Tetromino exposing (Tetromino)
import Tetromino as Tetromino

import Time as Time

initialSeed : Seed
initialSeed = Random.initialSeed 5

type alias Model = { board : Board
                   , tetromino : Tetromino
                   , preview : Tetromino
                   , bag : List Tetromino
                   , time : Float
                   , nextTick : Float
                   , tickDelay : Float
                   , seed : Seed
                   , linesCleared : Int
                   }

toForm : Model -> Form
toForm {board, tetromino, preview} =
  Board.add tetromino board |>
  Board.add preview |>
  Board.toForm

previewX : Int       
previewX = 17
           
previewY : Int           
previewY = 12
     
default : Model
default =
  let (bag, seed') = randomBag initialSeed
      bag' = List.drop 2 bag
      initPiece = Maybe.withDefault Tetromino.i (List.head bag)
      preview = Maybe.withDefault Tetromino.i (List.head (List.drop 1 bag))
  in
  { board = Board.new []
          , tetromino = Tetromino.shift (20, 4) initPiece
          , preview = Tetromino.shift (previewX, previewY) preview
          , bag = bag'
          , time = 0
          , nextTick = 1000
          , tickDelay = 1000
          , seed = seed'
          , linesCleared = 0
          }


randomBag : Seed -> (List Tetromino, Seed)
randomBag seed =
  let (weights, seed') =
        Random.generate (Random.list 7 (Random.float 0 1)) seed
      tetrominoes = [ Tetromino.i
                    , Tetromino.t
                    , Tetromino.o
                    , Tetromino.j
                    , Tetromino.l
                    , Tetromino.z
                    , Tetromino.s
                    ]
      weighted = List.map2 (,) weights tetrominoes
      asDict = Dict.fromList weighted
      sorted = Dict.values asDict
  in (sorted, seed')
  

width : Int
width = 800

height : Int
height = 600

view : Model -> Element
view m = Collage.collage width height [ toForm m ]

type Input = Rotate
           | Shift (Int, Int)
           | Time Float
           | Drop
           | NoOp

isValid : Model -> Bool
isValid model =
  let minC = 0
      maxC = Board.cols
      maxR = Board.rows
      pred (row, col) = row >= 0 && col >= 0 && col < maxC
      inBounds = List.all pred model.tetromino.shape
      pred' loc = not (Board.isOccupied loc model.board)
      doesNotOverlap = List.all pred' model.tetromino.shape
  in inBounds && doesNotOverlap

generate : Int -> List Int
generate = generate' []

generate' : List Int -> Int -> List Int
generate' acc n = if n == 0 then acc
                  else generate' (n::acc) (n-1)
     
kick : Model -> List Model
kick m =
  let wallKickWidth = m.tetromino.height // 2
      floorKickHeight = m.tetromino.width // 2
      wallKicks = generate wallKickWidth |>
                  List.map (\n -> [(0, n), (0, -n)]) |>
                  List.concat
      floorKicks = generate floorKickHeight |>
                   List.map (\n -> (n, 0))
      toModel s = { m | tetromino = Tetromino.shift s m.tetromino }
  in List.map toModel <| List.append wallKicks floorKicks
                    
       
rotate : Model -> Model
rotate m =
  let try = { m | tetromino = Tetromino.rotate m.tetromino }
      withKicks = List.filter isValid <| kick try
  in if isValid try then try
     else case List.head withKicks of
            Nothing -> m
            Just m' -> m'

stick : Model -> Model
stick model =
  let newBoard = Board.add model.tetromino model.board
      (newBag, newSeed) =
        if List.isEmpty model.bag then randomBag model.seed
        else (model.bag, model.seed)
      newTetromino = Tetromino.shift(20 - previewX, 4 - previewY) model.preview
      newPreview = 
        List.head newBag |>
        Maybe.withDefault Tetromino.i |>
        Tetromino.shift (previewX, previewY)
      newBag' = List.drop 1 newBag
  in { model | board = newBoard
             , tetromino = newTetromino
             , bag = newBag'
             , seed = newSeed
             , preview = newPreview
     }

clearLines' : Int -> Int -> Model -> Model
clearLines' currentRow totalCleared model =
  if currentRow > 20 then
    let linesCleared = model.linesCleared + totalCleared
        tickDelay = 1000/(toFloat (linesCleared // 10) + 1)
    in { model | linesCleared = linesCleared
               , tickDelay = tickDelay
       }
  else
    let row = Dict.filter (\(r, _) _ -> r == currentRow) model.board
        isComplete = Dict.size row == Board.cols
        board' = if not isComplete then model.board
                 else Dict.diff model.board row |>
                      Dict.foldr (\(r, c) block board ->
                                     let row' = if r >= currentRow then r-1 else r
                                     in Dict.insert (row', c) block board
                                 )
                                 Dict.empty                               
        nextRow = if isComplete then currentRow else currentRow+1
        cleared = if isComplete then totalCleared + 1 else totalCleared
    in clearLines' nextRow cleared { model | board = board' }
       
clearLines : Model -> Model
clearLines = clearLines' 0 0             
                 
moveDown : Model -> Model
moveDown model =
  let try = { model | tetromino = Tetromino.shift (-1, 0) model.tetromino }
  in if isValid try then try
     else clearLines << stick <| model

drop : Model -> Model
drop model =
  let try = { model | tetromino = Tetromino.shift (-1, 0) model.tetromino }
  in if isValid try then drop try
     else clearLines << stick <| model
                 
tick : Model -> Model
tick model =
  let model' = moveDown model
      nextTick' = model'.time + model'.tickDelay
  in { model' | nextTick = nextTick' }
     
control : Input -> Model -> Model
control input model =
  case input of
    Rotate -> rotate model
              
    Shift shift ->
      let try = { model | tetromino = Tetromino.shift shift model.tetromino }
          model' = if isValid try then try else model
      in model'

    Drop -> drop model

    Time delta ->
      let model' = { model | time = model.time + delta }
      in if model'.nextTick < model'.time then tick model'
         else model'
        
    _ -> model

arrows : { x : Int, y : Int } -> Input                   
arrows {x, y} =
  if y == 1 then
    Rotate
      
  else if x == -1 then
    Shift (0, -1)
          
  else if x == 1 then
    Shift (0, 1)
          
  else if y == -1 then
    Shift (-1, 0)
          
  else
    NoOp


keys : Char.KeyCode -> Input
keys code =
  if code == 32 then Drop else NoOp

keys' : Signal Input
keys' = Signal.map keys <| Keyboard.presses
       
space : Signal Input
space = Signal.sampleOn Keyboard.space (Signal.constant Drop)
      
arrows' : Signal Input
arrows' = Signal.map arrows Keyboard.arrows

time : Signal Input
time = Signal.map Time <| Time.fps 30

inputs : Signal Input
inputs = Signal.mergeMany [time, keys', arrows']

main : Signal Element      
main = Signal.map view <| Signal.foldp control default inputs
