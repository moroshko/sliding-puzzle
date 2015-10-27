module Board (Model, init, Direction(..), Action(..), update, view) where

import Graphics.Collage exposing (Form)
import Array exposing (Array)
import Color exposing (Color)
import Random exposing (Seed)
import Dict exposing (Dict)
import Text
import Utils


-- MODEL

type alias Tile =
  { text : String
  , color : Color
  }

type alias Model =
  { seed : Seed
  , boardWidth : Int
  , boardHeight : Int
  , tileSize : Int
  , tileSpacing : Int
  , tiles : Dict (Int, Int) Tile
  , empty : (Int, Int)
  }


init : Int -> Int -> Int -> Int -> Int -> Model
init seed boardWidth boardHeight tileSize tileSpacing =
  let
    initialSeed = Random.initialSeed seed
    lastRowIndex = boardHeight - 1
    lastColumnIndex = boardWidth - 1
    empty = (lastRowIndex, lastColumnIndex)
    
    createTile row column =
      let
        text = boardWidth * row + column + 1 |> toString
        color = Color.grey
      in
        Tile text color

    addTile row column =
      Dict.insert (row, column) (createTile row column)

    addRow row dict =
      List.foldl (addTile row) dict [0..lastColumnIndex] 
    
    tiles = List.foldl addRow Dict.empty [0..lastRowIndex]
  in
    Model initialSeed boardWidth boardHeight tileSize tileSpacing tiles empty


-- UPDATE

type Direction = Left | Right | Up | Down

type Action
  = Move Direction
  | Shuffle Int


directions : List Direction
directions = [ Left, Right, Up, Down ]


emptyAfterMove : Direction -> Model -> (Int, Int)
emptyAfterMove direction model =
  let
    (row, column) = model.empty
  in
    case direction of
      Left ->
        (row, column + 1 |> min (model.boardWidth - 1))

      Right ->
        (row, column - 1 |> max 0)

      Up ->
        (row + 1 |> min (model.boardHeight - 1), column)

      Down ->
        (row - 1 |> max 0, column)

      _ ->
        (row, column)


canMove : Model -> Direction -> Bool
canMove model direction =
  let
    (row, column) = model.empty
  in
    case direction of
      Left ->
        column < model.boardWidth - 1

      Right ->
        column > 0

      Up ->
        row < model.boardHeight - 1

      Down ->
        row > 0

      _ ->
        False


makeRandomMove : Model -> Model
makeRandomMove model =
  let
    (randomDirection, newSeed) = directions
      |> List.filter (canMove model)
      |> Utils.randomListItem model.seed
    modelAfterMove = update (Move randomDirection) model
  in
    { modelAfterMove | seed <- newSeed }


update : Action -> Model -> Model
update action model =
  case action of
    Move direction ->
      let
        newEmpty = emptyAfterMove direction model
        tileToMove = Dict.get newEmpty model.tiles |> Utils.unsafeExtract
        newTiles = Dict.insert model.empty tileToMove model.tiles
      in
        { model |
            tiles <- newTiles
          , empty <- newEmpty
        }

    Shuffle times ->
      List.foldl (\_ model -> makeRandomMove model) model [1..times]

    _ ->
      model


-- VIEW

renderBoard : Model -> Form
renderBoard model =
  let
    boardWidth = model.boardWidth * model.tileSize
    boardHeight = model.boardHeight * model.tileSize
    boardColor = Color.lightGrey
  in
    Graphics.Collage.rect (toFloat boardWidth) (toFloat boardHeight)
      |> Graphics.Collage.filled boardColor


renderTile : Model -> Int -> Int -> List Form
renderTile model row column =
  if (row, column) == model.empty
    then []
    else
      let
        size = model.tileSize - 2 * model.tileSpacing
        boardWidth = model.boardWidth * model.tileSize
        boardHeight = model.boardHeight * model.tileSize
        textSize = (model.tileSize - 2 * model.tileSpacing) // 2
        textOffset = textSize // 5

        dx = (size - boardWidth) // 2 + (column * model.tileSize) + model.tileSpacing
        dy = (boardHeight - size) // 2 - (row * model.tileSize) - model.tileSpacing

        tile = Dict.get (row, column) model.tiles |> Utils.unsafeExtract
      in
        [ Graphics.Collage.square (toFloat size)
            |> Graphics.Collage.filled tile.color
            |> Graphics.Collage.move (toFloat dx, toFloat dy),
          Text.fromString tile.text
            |> Text.monospace
            |> Text.height (toFloat textSize)
            |> Graphics.Collage.text
            |> Graphics.Collage.move (toFloat dx, toFloat (dy + textOffset))
        ]


renderRow : Model -> Int -> List Form
renderRow model row =
  let
    lastColumnIndex = model.boardWidth - 1
  in
    List.map (renderTile model row) [0..lastColumnIndex]
      |> List.concat


view : Model -> List Form
view model =
  let
    board = renderBoard model
    lastRowIndex = model.boardHeight - 1
    tiles = List.map (renderRow model) [0..lastRowIndex]
      |> List.concat
  in
    board :: tiles
