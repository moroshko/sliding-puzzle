import Graphics.Element exposing (Element)
import Graphics.Collage
import Window
import Keyboard
import Board


-- MODEL

type alias Model =
  Board.Model


initialModel : Model
initialModel =
  Board.init 4 3 100 1


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
      model |> Board.update Board.MoveLeft

    ArrowRight ->
      model |> Board.update Board.MoveRight

    ArrowUp ->
      model |> Board.update Board.MoveUp

    ArrowDown ->
      model |> Board.update Board.MoveDown
    
    _ ->
      model


-- VIEW

view : (Int, Int) -> Model -> Element
view (windowWidth, windowHeight) model =
  Graphics.Collage.collage windowWidth windowHeight (Board.view model)


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
