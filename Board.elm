module Board (Model, init, Action(..), update, view) where

import Graphics.Collage exposing (Form)
import Array exposing (Array)
import Color exposing (Color)
import Dict exposing (Dict)
import Text
import Utils


-- MODEL

type alias Tile =
  { name : String
  , color : Color
  }

type alias Model =
  { boardWidth : Int
  , boardHeight : Int
  , tileSize : Int
  , tileSpacing : Int
  , tiles : Dict (Int, Int) Tile
  , empty : (Int, Int)
  }


init : Int -> Int -> Int -> Int -> Model
init boardWidth boardHeight tileSize tileSpacing =
  let
    lastRowIndex = boardHeight - 1
    lastColumnIndex = boardWidth - 1
    empty = (lastRowIndex, lastColumnIndex)
    
    createTile row column =
      let
        name = boardWidth * row + column + 1 |> toString
        color = Color.grey
      in
        Tile name color

    addTile row column =
      Dict.insert (row, column) (createTile row column)

    addRow row dict =
      List.foldl (addTile row) dict [0..lastColumnIndex] 
    
    tiles = List.foldl addRow Dict.empty [0..lastRowIndex]
  in
    Model boardWidth boardHeight tileSize tileSpacing tiles empty


-- UPDATE

type Action
  = MoveLeft
  | MoveRight
  | MoveUp
  | MoveDown


emptyAfter : Action -> Model -> (Int, Int)
emptyAfter action model =
  let
    row = fst model.empty
    column = snd model.empty
  in
    case action of
      MoveLeft ->
        (row, column + 1 |> min (model.boardWidth - 1))

      MoveRight ->
        (row, column - 1 |> max 0)

      MoveUp ->
        (row + 1 |> min (model.boardHeight - 1), column)

      MoveDown ->
        (row - 1 |> max 0, column)

      _ ->
        (row, column)


update : Action -> Model -> Model
update action model =
  let
    newEmpty = emptyAfter action model
    tileToMove = Dict.get newEmpty model.tiles |> Utils.unsafeExtract
    newTiles = Dict.insert model.empty tileToMove model.tiles
  in
    { model |
        tiles <- newTiles
      , empty <- newEmpty
    }


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
          Text.fromString tile.name
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
