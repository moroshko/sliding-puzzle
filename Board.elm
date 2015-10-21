module Board (Model, init, Action, update, view) where

import Array exposing (Array)
import Graphics.Collage exposing (Form)
import Color
import Row


-- MODEL

type alias Model =
  { gameWidth : Int
  , gameHeight : Int
  , squareSize : Int
  , rows : Array Row.Model
  }


init : Int -> Int -> Int -> Int -> Model
init gameWidth gameHeight squareSize squareSpacing =
  let
    rows =
      Array.initialize gameHeight identity
        |> Array.map (Row.init gameWidth gameHeight squareSize squareSpacing)
  in
    Model gameWidth gameHeight squareSize rows


-- UPDATE

type Action = NoOp


update : Action -> Model -> Model
update action model =
  model


-- VIEW

view : Model -> List Form
view model =
  let
    boardWidth = model.gameWidth * model.squareSize
    boardHeight = model.gameHeight * model.squareSize

    board =
      Graphics.Collage.rect (toFloat boardWidth) (toFloat boardHeight)
        |> Graphics.Collage.filled Color.lightGrey
    
    rows = model.rows
      |> Array.toList
      |> List.map Row.view
      |> List.concat
  in
    board :: rows
