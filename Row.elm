module Row (Model, init, Action, update, view) where

import Array exposing (Array)
import Graphics.Collage exposing (Form)
import Square


-- MODEL

type alias Model =
  Array (Maybe Square.Model)


init : Int -> Int -> Int -> Int -> Int -> Model
init gameWidth gameHeight squareSize squareSpacing row =
  let
    name column =
      gameWidth * row + column + 1 |> toString

    squareCreator column =
      if row == gameHeight - 1 && column == gameWidth - 1
        then Nothing
        else Just (Square.init gameWidth gameHeight squareSize squareSpacing (name column) row column)
  in
    Array.initialize gameWidth squareCreator


-- UPDATE

type Action = NoOp


update : Action -> Model -> Model
update action model =
  model


-- VIEW

view : Model -> List Form
view model =
  model
    |> Array.toList
    |> List.filterMap identity
    |> List.map Square.view
    |> List.concat
