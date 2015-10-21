module Square (Model, init, Action, update, view) where

import Graphics.Collage exposing (Form)
import Text
import Color exposing (Color)


-- MODEL

type alias Model =
  { gameWidth : Int
  , gameHeight : Int
  , size : Int
  , spacing : Int
  , name : String
  , row : Int
  , column : Int
  }


init : Int -> Int -> Int -> Int -> String -> Int -> Int -> Model
init gameWidth gameHeight size spacing name row column =
  Model gameWidth gameHeight size spacing name row column


-- UPDATE

type Action = MoveLeft | MoveRight | MoveUp | MoveDown


update : Action -> Model -> Model
update action model =
  model
{--
  case action of
    MoveLeft ->
      { model | x <- model.x - 1 }

    MoveRight ->
      { model | x <- model.x + 1 }

    MoveUp ->
      { model | y <- model.y - 1 }

    MoveDown ->
      { model | y <- model.y + 1 }
--}


-- VIEW

view : Model -> List Form
view model =
  let
    size = model.size - 2 * model.spacing
    boardWidth = model.gameWidth * model.size
    boardHeight = model.gameHeight * model.size
    textSize = (model.size - 2 * model.spacing) // 2
    textOffset = textSize // 5

    dx = (size - boardWidth) // 2 + (model.column * model.size) + model.spacing
    dy = (boardHeight - size) // 2 - (model.row * model.size) - model.spacing
  in
    [ Graphics.Collage.square (toFloat size)
        |> Graphics.Collage.filled Color.grey
        |> Graphics.Collage.move (toFloat dx, toFloat dy),
      Text.fromString model.name
        |> Text.monospace
        |> Text.height (toFloat textSize)
        |> Graphics.Collage.text
        |> Graphics.Collage.move (toFloat dx, toFloat (dy + textOffset))
    ]
