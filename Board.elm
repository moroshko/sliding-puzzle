module Board (Model, init, Action(..), update, view) where

import Array exposing (Array)
import Graphics.Collage exposing (Form)
import Color
import Utils
import Row


-- MODEL

type alias Model =
  { gameWidth : Int
  , gameHeight : Int
  , squareSize : Int
  , squareSpacing : Int
  , emptySquareRow : Int
  , emptySquareColumn : Int
  , rows : Array Row.Model
  }


init : Int -> Int -> Int -> Int -> Model
init gameWidth gameHeight squareSize squareSpacing =
  let
    rows =
      Array.initialize gameHeight identity
        |> Array.map (Row.init gameWidth gameHeight squareSize squareSpacing (gameHeight - 1) (gameWidth - 1))
  in
    Model gameWidth gameHeight squareSize squareSpacing (gameHeight - 1) (gameWidth - 1) rows


-- UPDATE

type Action
  = MoveLeft
  | MoveRight


update : Action -> Model -> Model
update action model =
  case action of
    MoveLeft ->
      let
        rowToMove = Utils.getArrayItem model.emptySquareRow model.rows
        newRow = Row.update Row.MoveLeft rowToMove
        newRows = Array.set model.emptySquareRow newRow model.rows
      in
        { model |
            rows <- newRows
          , emptySquareColumn <- model.emptySquareColumn - 1
        }

    MoveRight ->
      let
        rowToMove = Utils.getArrayItem model.emptySquareRow model.rows
        newRow = Row.update Row.MoveRight rowToMove
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
