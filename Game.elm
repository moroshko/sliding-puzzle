import Graphics.Element exposing (Element)
import Graphics.Collage
import Window
import Keyboard
import Debug
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

{--
canMove : Model -> Action -> Bool
canMove model action =
  case action of
    ArrowLeft -> model.emptySquareColumn < model.gameWidth - 1
    ArrowRight -> model.emptySquareColumn > 0
    ArrowUp -> model.emptySquareRow < model.gameHeight - 1
    ArrowDown -> model.emptySquareRow > 0
    _ -> False

--}

update : Action -> Model -> Model
update action model =
  model

{--
  let
    _ = Debug.log "action" action
    _ = Debug.log "can move" (canMove model action)
  in
    model
--}


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
