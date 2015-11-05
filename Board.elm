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
  { id : Int
  , text : String
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
  , isSolved : Bool
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
        id = boardWidth * row + column
        text = id + 1 |> toString
        color = Color.grey
      in
        Tile id text color

    addTile row column =
      Dict.insert (row, column) (createTile row column)

    addRow row dict =
      List.foldl (addTile row) dict [0..lastColumnIndex] 
    
    tiles = List.foldl addRow Dict.empty [0..lastRowIndex]
    model = Model initialSeed boardWidth boardHeight tileSize tileSpacing tiles empty False
  in
    { model | isSolved <- allTilesInPlace model }


-- UPDATE

type Direction = Left | Right | Up | Down

type Action
  = Move Direction
  | MoveTile (Int, Int)
  | Shuffle Int


allTilesInPlace : Model -> Bool
allTilesInPlace { boardWidth, tiles, empty } =
  let
    tileInPlace (row, column) tile =
      if (row, column) == empty
        then True
        else boardWidth * row + column == tile.id
  in
    Dict.foldr (\coords tile result -> result && tileInPlace coords tile) True tiles


emptyAfterMove : Direction -> Model -> (Int, Int)
emptyAfterMove direction { boardWidth, boardHeight, empty } =
  let
    (row, column) = empty
  in
    case direction of
      Left ->
        (row, column + 1 |> min (boardWidth - 1))

      Right ->
        (row, column - 1 |> max 0)

      Up ->
        (row + 1 |> min (boardHeight - 1), column)

      Down ->
        (row - 1 |> max 0, column)

      _ ->
        (row, column)


canMove : Model -> Direction -> Bool
canMove { boardWidth, boardHeight, empty } direction =
  let
    (row, column) = empty
  in
    case direction of
      Left ->
        column < boardWidth - 1

      Right ->
        column > 0

      Up ->
        row < boardHeight - 1

      Down ->
        row > 0

      _ ->
        False


directions : List Direction
directions = [ Left, Right, Up, Down ]


makeRandomMove : Model -> Model
makeRandomMove ({ seed } as model) =
  let
    (randomDirection, seed') = directions
      |> List.filter (canMove model)
      |> Utils.randomListItem seed
    modelAfterMove = update (Move randomDirection) model
  in
    { modelAfterMove | seed <- seed' }


update : Action -> Model -> Model
update action ({ tiles, empty } as model) =
  case action of
    Move direction ->
      let
        empty' = emptyAfterMove direction model
        tileToMove = Dict.get empty' tiles |> Utils.unsafeExtract
        tiles' = Dict.insert empty tileToMove tiles
        model' =
          { model |
              tiles <- tiles'
            , empty <- empty'
          }
      in
        { model' | isSolved <- allTilesInPlace model' }

    MoveTile (row, column) ->
      if | (row, column - 1) == empty -> update (Move Left) model
         | (row, column + 1) == empty -> update (Move Right) model
         | (row - 1, column) == empty -> update (Move Up) model
         | (row + 1, column) == empty -> update (Move Down) model
         | otherwise -> model

    Shuffle times ->
      List.foldl (\_ model -> makeRandomMove model) model [1..times]

    _ ->
      model


-- VIEW

renderBoard : Model -> Form
renderBoard { boardWidth, boardHeight, tileSize, isSolved } =
  let
    boardWidth' = boardWidth * tileSize
    boardHeight' = boardHeight * tileSize
    boardColor =
      if isSolved
        then Color.rgb 90 160 90
        else Color.lightGrey
  in
    Graphics.Collage.rect (toFloat boardWidth') (toFloat boardHeight')
      |> Graphics.Collage.filled boardColor


renderTile : Model -> Int -> Int -> List Form
renderTile { boardWidth, boardHeight, tileSize, tileSpacing, tiles, empty } row column =
  if (row, column) == empty
    then []
    else
      let
        size = tileSize - 2 * tileSpacing
        boardWidth' = boardWidth * tileSize
        boardHeight' = boardHeight * tileSize
        textSize = (tileSize - 2 * tileSpacing) // 2
        textOffset = textSize // 5

        dx = (size - boardWidth') // 2 + (column * tileSize) + tileSpacing
        dy = (boardHeight' - size) // 2 - (row * tileSize) - tileSpacing

        tile = Dict.get (row, column) tiles |> Utils.unsafeExtract
      in
        [ Graphics.Collage.square (toFloat size)
            |> Graphics.Collage.filled tile.color
            |> Graphics.Collage.move (toFloat dx, toFloat dy)
        , Text.fromString tile.text
            |> Text.monospace
            |> Text.height (toFloat textSize)
            |> Graphics.Collage.text
            |> Graphics.Collage.move (toFloat dx, toFloat (dy + textOffset))
        ]


renderRow : Model -> Int -> List Form
renderRow ({ boardWidth } as model) row =
  let
    lastColumnIndex = boardWidth - 1
  in
    List.map (renderTile model row) [0..lastColumnIndex]
      |> List.concat


view : Model -> List Form
view ({ boardHeight } as model) =
  let
    board = renderBoard model
    lastRowIndex = boardHeight - 1
    tiles = List.map (renderRow model) [0..lastRowIndex]
      |> List.concat
  in
    board :: tiles
