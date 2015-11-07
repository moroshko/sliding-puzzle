module App where

import Html exposing (Html, div, button, text)
import Graphics.Element exposing (Element)
import Dict exposing (Dict)
import Graphics.Collage
import Keyboard
import Random
import Window
import Touch
import Board
import Utils
import Debug


-- MODEL

type alias Model =
  Board.Model


initialModel : Model
initialModel =
  let
    defaultBoardWidth = 3
    minBoardWidth = 2
    maxBoardWidth = 10
    width = Utils.dictGetInt "width" defaultBoardWidth minBoardWidth maxBoardWidth queryParams

    defaultBoardHeight = 3
    minBoardHeight = 2
    maxBoardHeight = 10
    height = Utils.dictGetInt "height" defaultBoardHeight minBoardHeight maxBoardHeight queryParams
    
    tileSize = getTileSize (width, height) windowSize
    
    tileSpacing = 1
  in
    Board.init initialSeed width height tileSize tileSpacing
      |> Board.update (Board.Shuffle 100)


queryParams : Dict String String
queryParams =
  Utils.queryParams locationSearch


getTileSize : (Int, Int) -> (Int, Int) -> Int
getTileSize (boardWidth, boardHeight) (windowWidth, windowHeight) =
  let
    padding = 40
    tileWidth = (windowWidth - padding) // boardWidth
    tileHeight = (windowHeight - padding) // boardHeight
    
    defaultTileSize = min tileWidth tileHeight |> min maxTileSize
    minTileSize = 5
    maxTileSize = 200
  in
    Utils.dictGetInt "tileSize" defaultTileSize minTileSize maxTileSize queryParams


-- UPDATE

type Action
  = NoOp
  | ArrowLeft
  | ArrowRight
  | ArrowUp
  | ArrowDown
  | Click (Int, Int) (Int, Int)
  | WindowResize (Int, Int)


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
    
    WindowResize dimensions ->
      { model | tileSize <- getTileSize (boardWidth, boardHeight) dimensions }

    _ ->
      model


-- VIEW

view : (Int, Int) -> Model -> Element
view (windowWidth, windowHeight) model =
  Board.view model
    |> Graphics.Collage.collage windowWidth windowHeight


-- PORTS

port initialSeed : Int
port locationSearch : String
port windowSize : (Int, Int)


-- SIGNALS

windowDimensions : Signal (Int, Int)
windowDimensions =
  Window.dimensions


windowResize : Signal Action
windowResize =
  Signal.map WindowResize windowDimensions


clicks : Signal Action
clicks =
  let
    createClick { x, y } dimensions =
      Click (x, y) dimensions
  in
    Signal.map2 createClick Touch.taps windowDimensions
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
  Signal.mergeMany
    [ windowResize
    , arrows
    , clicks
    ]


model : Signal Model
model =
  Signal.foldp update initialModel input


-- MAIN

main : Signal Element
main =
  Signal.map2 view windowDimensions model
