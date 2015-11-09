module Utils (unsafeExtract, randomListItem, queryParams, dictGetInt) where

import UrlParameterParser exposing (ParseResult(..), parseSearchString)
import Random exposing (Seed)
import Dict exposing (Dict)
import String
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


queryParams : String -> Dict String String
queryParams locationSearch =
  case (parseSearchString locationSearch) of
    Error _ ->
      Dict.empty
    
    UrlParams dict ->
      dict

dictGetInt : String -> Int -> Int -> Int -> Dict String String -> Int
dictGetInt key default min max dict =
  case Dict.get key dict of
    Nothing ->
      default

    Just value ->
      case String.toInt value of
        Err _ ->
          default

        Ok intValue ->
          clamp min max intValue
