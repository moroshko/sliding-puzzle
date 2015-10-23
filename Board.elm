module Board (Model, init, Action(..), update, view) where

import Array exposing (Array)
import Graphics.Collage exposing (Form)
import Color
import Row


-- MODEL

type alias Model =
  { gameWidth : Int
  , gameHeight : Int
  , squareSize : Int
  , squareSpacing : Int
  , rows : Array Row.Model
  , emptySquareRow : Int
  , emptySquareColumn : Int
  }


init : Int -> Int -> Int -> Int -> Model
init gameWidth gameHeight squareSize squareSpacing =
  let
    rows =
      Array.initialize gameHeight identity
        |> Array.map (Row.init gameWidth gameHeight squareSize squareSpacing)
  in
    Model gameWidth gameHeight squareSize squareSpacing rows (gameHeight - 1) (gameWidth - 1)


-- UPDATE

type Action
  = MoveLeft
  | MoveRight


update : Action -> Model -> Model
update action model =
  case action of
    MoveLeft ->
      let
        maybeRow = Array.get model.emptySquareRow model.rows
        row = Maybe.withDefault (Row.empty model.gameWidth) maybeRow
        newRow = Row.update Row.MoveLeft row
        newRows = Array.set model.emptySquareRow newRow model.rows
      in
        { model |
            rows <- newRows
          , emptySquareColumn <- model.emptySquareColumn - 1
        }

    MoveRight ->
      let
        maybeRow = Array.get model.emptySquareRow model.rows
        row = Maybe.withDefault (Row.empty model.gameWidth) maybeRow
        newRow = Row.update Row.MoveRight row
        newRows = Array.set model.emptySquareRow newRow model.rows
      in
        { model |
            rows <- newRows
          , emptySquareColumn <- model.emptySquareColumn - 1
        }


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
