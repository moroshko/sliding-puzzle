module Utils (unsafeExtract) where

import Debug


unsafeExtract : Maybe a -> a
unsafeExtract maybe =
  case maybe of
    Just a ->
      a
    _ ->
      Debug.crash "unsafeExtract failed"
