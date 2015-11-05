module Game where

import Html exposing (Html, div, button, text)
import Graphics.Element exposing (Element)
import Graphics.Collage
import Keyboard
import Random
import Window
import Touch
import Board


-- MODEL

type alias Model =
  Board.Model


initialModel : Model
initialModel =
  Board.init initialSeed 3 3 100 1
    |> Board.update (Board.Shuffle 100)


-- UPDATE

type Action
  = NoOp
  | ArrowLeft
  | ArrowRight
  | ArrowUp
  | ArrowDown
  | Click (Int, Int) (Int, Int)


update : Action -> Model -> Model
update action ({ boardWidth, boardHeight, tileSize } as model) =
  case action of
    ArrowLeft ->
      model |> Board.update (Board.Move Board.Left)

    ArrowRight ->
      model |> Board.update (Board.Move Board.Right)

    ArrowUp ->
      model |> Board.update (Board.Move Board.Up)

    ArrowDown ->
      model |> Board.update (Board.Move Board.Down)

    Click (clickX, clickY) (windowWidth, windowHeight) ->
      let
        boardTopLeftX = (windowWidth - boardWidth * tileSize) // 2
        boardTopLeftY = (windowHeight - boardHeight * tileSize) // 2

        dx = clickX - boardTopLeftX
        dy = clickY - boardTopLeftY

        row = dy // tileSize
        column = dx // tileSize
      in
        if dx < 0 || row >= boardHeight || dy < 0 || column >= boardWidth
          then model
          else model |> Board.update (Board.MoveTile (row, column))
    
    _ ->
      model


-- VIEW

view : (Int, Int) -> Model -> Element
view (windowWidth, windowHeight) model =
  Board.view model
    |> Graphics.Collage.collage windowWidth windowHeight


-- PORTS

port initialSeed : Int


-- SIGNALS

clicks : Signal Action
clicks =
  let
    createClick { x, y } dimensions =
      Click (x, y) dimensions
  in
    Signal.map2 createClick Touch.taps Window.dimensions
      |> Signal.sampleOn Touch.taps


arrows : Signal Action
arrows =
  let
    toAction arrow =
      if | arrow == { x = -1, y = 0 } -> ArrowLeft
         | arrow == { x = 1, y = 0 } -> ArrowRight
         | arrow == { x = 0, y = 1 } -> ArrowUp
         | arrow == { x = 0, y = -1 } -> ArrowDown
         | otherwise -> NoOp
  in
    Keyboard.arrows
      |> Signal.map toAction
      |> Signal.filter (\a -> a /= NoOp) NoOp


input : Signal Action
input =
  Signal.merge arrows clicks


model : Signal Model
model =
  Signal.foldp update initialModel input


-- MAIN

main : Signal Element
main =
  Signal.map2 view Window.dimensions model
