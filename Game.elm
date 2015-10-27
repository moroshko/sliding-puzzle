import Html exposing (Html, div, button, text)
import Graphics.Element exposing (Element)
import Graphics.Collage
import Keyboard
import Random
import Window
import Board


-- MODEL

type alias Model =
  Board.Model


initialModel : Model
initialModel =
  Board.init 4 4 100 1
    |> Board.update (Board.Shuffle (Random.initialSeed 2) 10000)


-- UPDATE

type Action
  = NoOp
  | ArrowLeft
  | ArrowRight
  | ArrowUp
  | ArrowDown


update : Action -> Model -> Model
update action model =
  case action of
    ArrowLeft ->
      model |> Board.update (Board.Move Board.Left)

    ArrowRight ->
      model |> Board.update (Board.Move Board.Right)

    ArrowUp ->
      model |> Board.update (Board.Move Board.Up)

    ArrowDown ->
      model |> Board.update (Board.Move Board.Down)
    
    _ ->
      model


-- VIEW

view : (Int, Int) -> Model -> Html
view (windowWidth, windowHeight) model =
  div [ ]
    [ {--button [ ] [ text "Randomize" ]
    , --}Html.fromElement (Graphics.Collage.collage windowWidth windowHeight (Board.view model))
    ]


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

main : Signal Html
main =
  Signal.map2 view Window.dimensions model
