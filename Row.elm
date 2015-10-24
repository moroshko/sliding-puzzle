module Row (Model, init, Action(..), update, view) where

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

type Action
  = MoveLeft
  | MoveRight


moveLeft : List (Maybe Square.Model) -> List (Maybe Square.Model)
moveLeft list =
  case list of
    Nothing :: Just square :: rest ->
      let
        newSquare =
          square
            |> Square.update Square.MoveLeft
            |> Just
      in
        newSquare :: Nothing :: rest

    square :: rest ->
      square :: moveLeft rest


moveRight : List (Maybe Square.Model) -> List (Maybe Square.Model)
moveRight list =
  case list of
    Just square :: Nothing :: rest ->
      let
        newSquare =
          square
            |> Square.update Square.MoveRight
            |> Just
      in
        Nothing :: newSquare :: rest

    square :: rest ->
      square :: moveRight rest


update : Action -> Model -> Model
update action model =
  case action of
    MoveLeft ->
      model
        |> Array.toList
        |> moveLeft
        |> Array.fromList

    MoveRight ->
      model
        |> Array.toList
        |> moveRight
        |> Array.fromList


-- VIEW

view : Model -> List Form
view model =
  model
    |> Array.toList
    |> List.filterMap identity
    |> List.map Square.view
    |> List.concat
