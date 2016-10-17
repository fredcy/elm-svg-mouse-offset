module Main exposing (..)

import Html
import Json.Decode as Json
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Task
import VirtualDom
import Window


type alias Position =
    { x : Int, y : Int }


type alias Model =
    { size : Window.Size
    , pos : Position
    }


type Msg
    = Error
    | WindowSize Window.Size
    | MouseMove Position


marginScene =
    20


main : Program Never Model Msg
main =
    Html.program { init = init, update = update, view = view, subscriptions = subscriptions }


init : ( Model, Cmd Msg )
init =
    ( { size = Window.Size 600 600
      , pos = Position 0 0
      }
    , Task.perform WindowSize Window.size
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        WindowSize { width, height } ->
            ( { model | size = Window.Size (width - 2 * marginScene) (height - 100 - 2 * marginScene) }, Cmd.none )

        MouseMove pos ->
            ( { model | pos = pos }, Cmd.none )

        _ ->
            Debug.crash "update"


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.div [] [ Html.text (toString model) ]
        , scene model
        ]


scene : Model -> Html.Html Msg
scene model =
    Svg.svg
        [ width <| toString model.size.width
        , height <| toString model.size.height
        , style ("margin-left:" ++ px marginScene)
        ]
        [ background model
        , tracker model
        ]


px : a -> String
px n =
    toString n ++ "px"


background : Model -> Svg.Svg Msg
background model =
    Svg.rect
        [ width <| toString <| model.size.width - 20
        , height <| toString <| model.size.height - 20
        , fill "gray"
        , VirtualDom.onWithOptions "mousemove" options (Json.map MouseMove offsetPosition)
        ]
        []


{-| These options are an attempt to prevent double- and triple-clicking from
propagating and selecting text outside the SVG scene. Doesn't work.
-}
options =
    { preventDefault = True, stopPropagation = True }


offsetPosition : Json.Decoder Position
offsetPosition =
    Json.map2 Position (Json.field "offsetX" Json.int) (Json.field "offsetY" Json.int)


tracker : Model -> Svg Msg
tracker model =
    Svg.line
        [ x1 "0"
        , y1 "0"
        , x2 (toString model.pos.x)
        , y2 (toString model.pos.y)
        , style "stroke:rgb(255,0,0);stroke-width:2"
        ]
        []


subscriptions model =
    Window.resizes WindowSize
