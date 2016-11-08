module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, class)
import Time exposing (Time)
import Html.App as App
import Http exposing (Error(..))
import Debug exposing (log)
import Task
import CoffeeAPI exposing (Coffee, fetchCoffee, Brew)
import Date exposing (..)


(.) : (a -> b) -> (c -> a) -> (c -> b)
(.) f g x =
    f (g x)


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    Maybe Coffee


init : ( Model, Cmd Msg )
init =
    Nothing ! [ getCoffee ]


getCoffee : Cmd Msg
getCoffee =
    Task.perform CoffeeFailure CoffeeSuccess fetchCoffee



--------------
--  UPDATE  --
--------------


type Msg
    = Update
    | CoffeeSuccess Coffee
    | CoffeeFailure Http.Error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Update ->
            model ! [ getCoffee ]

        CoffeeSuccess coffee ->
            Just coffee ! []

        CoffeeFailure error ->
            Nothing ! []



---------------------
--  SUBSCRIPTIONS  --
---------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        id x y =
            x
    in
        Time.every (10 * Time.second) (id Update)



------------
--  VIEW  --
------------


coffeeView : Coffee -> List (Html Msg)
coffeeView { cups, timestamp, brew } =
    let
        cupsstring =
            toString cups

        datestring =
            toString timestamp

        inner =
            [ span [ id "cups" ] [ text <| toString cups ]
            , text " koppar kaffe kvar"
            ]
                ++ brewView brew
    in
        inner


dateDiff : Date -> Date -> Date
dateDiff d1 d2 =
    let
        diff =
            toTime d2 - toTime d1
    in
        fromTime diff


formatDate : Date -> String
formatDate d =
    let
        min =
            toString <| minute d

        sec =
            toString <| second d
    in
        if min /= "0" then
            min ++ " minuter och " ++ sec ++ " sekunder"
        else
            sec ++ " sekunder"


brewView : Maybe Brew -> List (Html Msg)
brewView b =
    case b of
        Nothing ->
            []

        Just { cups, start, end } ->
            let
                diff =
                    dateDiff start end

                timeago =
                    formatDate diff
            in
                [ text (" (+" ++ (toString cups) ++ " om " ++ timeago ++ ")") ]


frame : List (Html Msg) -> Html Msg
frame xs =
    div [ class "center" ]
        [ header [ id "cups-text", class "cups-high" ]
            [ h1 [] xs ]
        ]


view : Model -> Html Msg
view model =
    case model of
        Nothing ->
            frame [ text "Laddar kaffe..." ]

        Just coffee ->
            frame <| coffeeView coffee
