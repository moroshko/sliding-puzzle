import Graphics.Element exposing (..)
import Graphics.Collage exposing (..)
import Text exposing (..)
import Array
import Color
import Window
import Keyboard
import Debug


-- MODEL

type alias Square = { name : String }

type alias Row = Array.Array Square

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


createSquare : Int -> Int -> Int -> Square
createSquare gameWidth row column =
  { name = gameWidth * row + column + 1 |> toString }


createRow : Int -> Int -> Int -> Row
createRow gameWidth gameHeight row =
  Array.initialize gameWidth (createSquare gameWidth row)


createModel : Int -> Int -> Int -> Int -> Model
createModel gameWidth gameHeight boardSquareSize boardSquareSpacing =
  { gameWidth = gameWidth
  , gameHeight = gameHeight
  , boardSquareSize = boardSquareSize
  , boardSquareSpacing = boardSquareSpacing
  , board =
      Array.initialize gameHeight identity
        |> Array.map (createRow gameWidth gameHeight)
  , emptySquareRow = gameHeight - 1
  , emptySquareColumn = gameWidth - 1
  }


initialModel : Model
initialModel = createModel 4 3 100 1


-- UPDATE

type Action = NoOp | ArrowLeft | ArrowRight | ArrowUp | ArrowDown


canMove : Model -> Action -> Bool
canMove model action =
  case action of
    ArrowLeft -> model.emptySquareColumn < model.gameWidth - 1
    ArrowRight -> model.emptySquareColumn > 0
    ArrowUp -> model.emptySquareRow < model.gameHeight - 1
    ArrowDown -> model.emptySquareRow > 0
    _ -> False


update : Action -> Model -> Model
update action model =
  let
    _ = Debug.log "action" action
    _ = Debug.log "can move" (canMove model action)
  in
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


drawSquare : Model -> Int -> Int -> Square -> List Form
drawSquare model row column square =
  let
    squareSize = model.boardSquareSize - 2 * model.boardSquareSpacing
    boardWidth' = boardWidth model.gameWidth model.boardSquareSize
    boardHeight' = boardHeight model.gameHeight model.boardSquareSize

    dx = (squareSize - boardWidth') // 2 + (column * model.boardSquareSize) + model.boardSquareSpacing
    dy = (boardHeight' - squareSize) // 2 - (row * model.boardSquareSize) - model.boardSquareSpacing
  in
    [ Graphics.Collage.square (toFloat squareSize)
        |> filled Color.grey
        |> move (toFloat dx, toFloat dy),
      fromString square.name
        |> monospace
        |> Text.height (toFloat (boardTextSize model.boardSquareSize model.boardSquareSpacing))
        |> text
        |> move (toFloat dx, toFloat (dy + (boardTextOffset model.boardSquareSize model.boardSquareSpacing)))
    ]


drawRow : Model -> Int -> Row -> List Form
drawRow model row squares =
  let
    nonEmptySquares =
      if row == model.emptySquareRow
        then Array.append
          (Array.slice 0 model.emptySquareColumn squares)
          (Array.slice (model.emptySquareColumn + 1) (Array.length squares) squares)
        else squares
  in
    nonEmptySquares
      |> Array.toList
      |> List.indexedMap (drawSquare model row)
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
        |> List.indexedMap (drawRow model)
        |> List.concat
  in
    collage windowWidth windowHeight (board :: squares)


-- SIGNALS

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
  arrows -- Will add mouse clicks later


model : Signal Model
model =
  Signal.foldp update initialModel input


-- MAIN

main : Signal Element
main =
  Signal.map2 view Window.dimensions model
