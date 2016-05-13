module Main exposing (..)

import Html
import Html.App as Html
import Json.Decode as Json
import Mouse exposing (Position)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Task
import VirtualDom
import Window


type alias Model =
    { size : Window.Size
    , pos : Position
    }


type Msg
    = Error
    | WindowSize Window.Size
    | MouseMove Position


main : Program Never
main =
    Html.program { init = init, update = update, view = view, subscriptions = subscriptions }


init : ( Model, Cmd Msg )
init =
    ( { size = Window.Size 600 600
      , pos = Position 0 0
      }
    , Task.perform (\_ -> Debug.crash "task") WindowSize Window.size
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        WindowSize { width, height } ->
            ( { model | size = Window.Size (width - 20) (height - 100) }, Cmd.none )

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
        , style "margin-left: 10px"
        ]
        [ background model
        , tracker model
        ]


background : Model -> Svg.Svg Msg
background model =
    Svg.rect
        [ width <| toString model.size.width
        , height <| toString model.size.height
        , fill "gray"
        , VirtualDom.on "mousemove" (Json.map MouseMove Mouse.position)
        ]
        []


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
