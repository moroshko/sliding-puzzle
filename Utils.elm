module Utils (unsafeExtract, randomListItem) where

import Random exposing (Seed)
import Debug


unsafeExtract : Maybe a -> a
unsafeExtract maybe =
  case maybe of
    Just a ->
      a
    _ ->
      Debug.crash "unsafeExtract failed"


randomListItem : Seed -> List a -> (a, Seed)
randomListItem seed list =
  let
    gen = Random.int 0 ((List.length list) - 1)
    (randomIndex, newSeed) = Random.generate gen seed
    randomItem = List.drop randomIndex list
      |> List.head
      |> unsafeExtract
  in
    (randomItem, newSeed)
