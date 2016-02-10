module Block where

import Basics exposing (..)
import Color exposing (Color)
import Color as Color

import Graphics.Element exposing (Element)
import Graphics.Element as Element

import Graphics.Collage exposing (Form)
import Graphics.Collage as Collage

type alias Block = { color : Color }

width : Float
width = 25

height : Float
height = 25

toForm : Block -> Form
toForm block =
  let shape = Collage.rect width height
  in Collage.group [ Collage.filled block.color shape
                   , Collage.outlined (Collage.solid Color.black) shape
                   ]  

main : Element
main = Collage.collage 400 400
       [(toForm (Block Color.green))]
