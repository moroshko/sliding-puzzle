import Graphics.Element exposing (..)
import Graphics.Collage exposing (..)
import Text exposing (..)
import Array
import Color
import Window
import Keyboard
import Debug


-- MODEL

type alias Row = Array.Array String

type alias Board = Array.Array Row

type alias Model =
  { gameWidth : Int,
    gameHeight : Int,
    boardSquareSize : Int,
    boardSquareSpacing : Int,
    board : Board,
    emptySquareRow : Int,
    emptySquareColumn : Int
  }


createSquare : Int -> Int -> Int -> String
createSquare gameWidth row column =
  gameWidth * row + column + 1
    |> toString


createRow : Int -> Int -> Int -> Row
createRow gameWidth gameHeight row =
  Array.initialize gameWidth (createSquare gameWidth row)


createModel : Int -> Int -> Int -> Int -> Model
createModel gameWidth gameHeight boardSquareSize boardSquareSpacing =
  { gameWidth = gameWidth,
    gameHeight = gameHeight,
    boardSquareSize = boardSquareSize,
    boardSquareSpacing = boardSquareSpacing,
    board =
      Array.initialize gameHeight identity
        |> Array.map (createRow gameWidth gameHeight),
    emptySquareRow = gameHeight - 1,
    emptySquareColumn = gameWidth - 1
  }


initialModel : Model
initialModel = createModel 4 3 100 1


-- UPDATE

update : { x : Int, y : Int } -> Model -> Model
update arrow model =
  model


-- VIEW

boardTextSize : Int -> Int -> Int
boardTextSize boardSquareSize boardSquareSpacing =
  (boardSquareSize - 2 * boardSquareSpacing) // 2


boardTextOffset : Int -> Int -> Int
boardTextOffset boardSquareSize boardSquareSpacing =
  (boardTextSize boardSquareSize boardSquareSpacing) // 5


boardWidth : Int -> Int -> Int
boardWidth gameWidth boardSquareSize =
  gameWidth * boardSquareSize


boardHeight : Int -> Int -> Int
boardHeight gameHeight boardSquareSize =
  gameHeight * boardSquareSize


drawBoard : Int -> Int -> Form
drawBoard width height =
  rect (toFloat width) (toFloat height)
    |> filled Color.lightGrey


drawSquare : Int -> Int -> Int -> Int -> Int -> Int -> String -> List Form
drawSquare gameWidth gameHeight boardSquareSize boardSquareSpacing row column name =
  let
    actualSquareSize = boardSquareSize - 2 * boardSquareSpacing
    boardWidth' = boardWidth gameWidth boardSquareSize
    boardHeight' = boardHeight gameHeight boardSquareSize

    dx = (actualSquareSize - boardWidth') // 2 + (column * boardSquareSize) + boardSquareSpacing
    dy = (boardHeight' - actualSquareSize) // 2 - (row * boardSquareSize) - boardSquareSpacing
  in
    [ square (toFloat actualSquareSize)
        |> filled Color.grey
        |> move (toFloat dx, toFloat dy),
      fromString name
        |> monospace
        |> Text.height (toFloat (boardTextSize boardSquareSize boardSquareSpacing))
        |> text
        |> move (toFloat dx, toFloat (dy + (boardTextOffset boardSquareSize boardSquareSpacing)))
    ]


drawRow : Int -> Int -> Int -> Int -> Int -> Int -> Int -> Row -> List Form
drawRow gameWidth gameHeight boardSquareSize boardSquareSpacing emptySquareRow emptySquareColumn row squareNames =
  let
    nonEmptySquareNames =
      if row == emptySquareRow
        then Array.append
          (Array.slice 0 emptySquareColumn squareNames)
          (Array.slice (emptySquareColumn + 1) (Array.length squareNames) squareNames)
        else squareNames
  in
    nonEmptySquareNames
      |> Array.toList
      |> List.indexedMap (drawSquare gameWidth gameHeight boardSquareSize boardSquareSpacing row)
      |> List.concat


view : (Int, Int) -> Model -> Element
view (windowWidth, windowHeight) model =
  let
    boardWidth' = boardWidth model.gameWidth model.boardSquareSize
    boardHeight' = boardHeight model.gameHeight model.boardSquareSize

    board = drawBoard boardWidth' boardHeight'
    
    squares =
      model.board
        |> Array.toList
        |> List.indexedMap (drawRow model.gameWidth model.gameHeight model.boardSquareSize model.boardSquareSpacing model.emptySquareRow model.emptySquareColumn)
        |> List.concat
  in
    collage windowWidth windowHeight (board :: squares)


-- SIGNALS

model : Signal Model
model =
  Signal.foldp update initialModel Keyboard.arrows


-- MAIN

main : Signal Element
main =
  Signal.map2 view Window.dimensions model
