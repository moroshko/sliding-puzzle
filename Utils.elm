module Utils (getArrayItem) where

import Array exposing (Array)
import Debug

getArrayItem : Int -> Array a -> a
getArrayItem index array =
  case Array.get index array of
    Just item ->
      item

    _ ->
      Debug.crash ((toString array) ++ " doesn't have item at index " ++ (toString index))
