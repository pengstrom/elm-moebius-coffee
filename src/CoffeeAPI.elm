module CoffeeAPI exposing (fetchCoffee, Coffee, Brew)

import Task exposing (Task)
import Json.Decode exposing (string, at, Decoder, object4, object3, (:=), int, bool, customDecoder)
import Http exposing (get, Error(..))
import Date exposing (Date, fromString)


fetchCoffee : Task Error Coffee
fetchCoffee =
    get responseDecoder apiUrl


type alias Brew =
    { cups : Int
    , start : Date
    , end : Date
    }


type alias Coffee =
    { cups : Int
    , timestamp : Date
    , brew : Maybe Brew
    }


apiUrl : String
apiUrl =
    "https://www.moebius.nu/coffee/cups.json"


date : Decoder Date
date =
    customDecoder string fromString


responseDecoder : Decoder Coffee
responseDecoder =
    object3 toCoffee
        ("cups" := int)
        ("timestamp" := date)
        ("brewing" := brewDecoder)


brewDecoder : Decoder (Maybe Brew)
brewDecoder =
    object4 toBrew
        ("cups" := int)
        ("start" := date)
        ("end" := date)
        ("is_brewing" := bool)


toBrew : Int -> Date -> Date -> Bool -> Maybe Brew
toBrew cups start end isbrewing =
    if (xor isbrewing (cups /= 0)) then
        Just <| Brew cups start end
    else
        Nothing


toCoffee : Int -> Date -> Maybe Brew -> Coffee
toCoffee cups timestamp brew =
    { cups = cups
    , timestamp = timestamp
    , brew = brew
    }
