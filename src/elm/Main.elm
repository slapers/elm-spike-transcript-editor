module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Mouse exposing (Position)
import Dict exposing (Dict)
import String


-- MODEL


type alias InteractionId =
    String


type Interaction
    = MkMessage Message
    | MkQuestion Question


type alias Message =
    { id : InteractionId
    , msg : String
    , next : InteractionId
    , position : Position
    }


type alias Question =
    { id : InteractionId
    , msg : String
    , next : InteractionId
    , position : Position
    }


type alias Drag =
    { offset : Position
    , current : Position
    , ix : InteractionId
    }


type alias Pan =
    { offset : Position
    , current : Position
    }


type alias Model =
    { zoom : Float
    , offset : Position
    , ixs : Dict InteractionId Interaction
    , drag : Maybe Drag
    , pan : Maybe Pan
    }


interactions : List Interaction
interactions =
    [ Message "h1" "Hello, thanks for visiting our restroom. thanks for visiting our restroom." "END" { x = 100, y = 60 } |> MkMessage
    , Message "h2" "hello 2" "END" { x = 100, y = 180 } |> MkMessage
    , Message "h3" "hello 2" "END" { x = 100, y = 300 } |> MkMessage
    , Question "q4" "How was your visit ?" "END" { x = 100, y = 420 } |> MkQuestion
    ]


getInteraction : Model -> InteractionId -> Maybe Interaction
getInteraction model ixId =
    Dict.get ixId model.ixs


getInteractionId : Interaction -> InteractionId
getInteractionId ix =
    case ix of
        MkMessage { id } ->
            id

        MkQuestion { id } ->
            id


getInteractionPosition : Interaction -> Position
getInteractionPosition ix =
    case ix of
        MkMessage { position } ->
            position

        MkQuestion { position } ->
            position


setInteractionPosition : Position -> Interaction -> Interaction
setInteractionPosition newPos ix =
    case ix of
        MkMessage m ->
            MkMessage { m | position = newPos }

        MkQuestion q ->
            MkQuestion { q | position = newPos }


init : ( Model, Cmd Msg )
init =
    ( { zoom = 1
      , offset = { x = 0, y = 0 }
      , ixs = Dict.fromList <| List.map (\i -> ( getInteractionId i, i )) interactions
      , drag = Nothing
      , pan = Nothing
      }
    , Cmd.none
    )



-- MESSAGES


type Msg
    = NoOp
    | Zoom Int
    | PanStart Position
    | PanAt Position
    | PanEnd Position
    | DragStart InteractionId Position
    | DragAt Position
    | DragEnd Position



-- VIEW


view : Model -> Html Msg
view model =
    let
        scale =
            toString model.zoom

        matrix =
            String.join ","
                [ scale
                , "0"
                , "0"
                , scale
                , toString model.offset.x
                , toString model.offset.y
                ]

        editorStyle =
            style
                [ ( "transform", "matrix(" ++ matrix ++ ")" )
                , ( "transform-origin", "0px 0px 0px" )
                ]
    in
        div [ class "editor", editorStyle, onWheel Zoom, onMouseDown PanStart ]
            ([ div [ class "canvas-bg" ] []
             , div [ class "canvas black-70" ] <| List.map viewInteraction <| Dict.values model.ixs
             ]
            )


viewInteraction : Interaction -> Html Msg
viewInteraction ix =
    case ix of
        MkMessage msg ->
            viewMessage msg

        MkQuestion q ->
            viewQuestion q


viewMessage : Message -> Html Msg
viewMessage message =
    let
        msgStyle =
            style
                [ ( "top", toString message.position.y ++ "px" )
                , ( "left", toString message.position.x ++ "px" )
                ]
    in
        div
            [ class "message"
            , msgStyle
            , onMouseDown (DragStart message.id)
            ]
            [ div [ class "body" ]
                [ text message.msg ]
            , div [ class "next" ]
                [ span [] [ text "next" ] ]
            ]


viewQuestion : Question -> Html Msg
viewQuestion question =
    let
        qStyle =
            style
                [ ( "top", toString question.position.y ++ "px" )
                , ( "left", toString question.position.x ++ "px" )
                ]
    in
        div
            [ class "question"
            , qStyle
            , onMouseDown (DragStart question.id)
            ]
            [ div [ class "body" ]
                [ text question.msg
                ]
            ]


onWheel : (Int -> Msg) -> Attribute Msg
onWheel message =
    let
        options =
            { stopPropagation = True
            , preventDefault = True
            }
    in
        onWithOptions "wheel" options (Json.map message (Json.at [ "deltaY" ] Json.int))


onMouseDown : (Position -> Msg) -> Attribute Msg
onMouseDown tag =
    let
        options =
            { stopPropagation = True
            , preventDefault = True
            }
    in
        onWithOptions "mousedown" options (Json.map tag Mouse.position)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            1

        -- Debug.log "msg" ( msg, model )
    in
        case msg of
            NoOp ->
                ( model, Cmd.none )

            Zoom y ->
                let
                    newZoom =
                        if (model.zoom <= 0.3 && y > 0) then
                            model.zoom
                        else
                            model.zoom - toFloat y / 500.0
                in
                    ( { model | zoom = newZoom }, Cmd.none )

            PanStart mouse ->
                let
                    offset =
                        calcOffset 1 mouse model.offset
                in
                    ( { model | pan = Just <| Pan offset mouse }, Cmd.none )

            PanAt mouse ->
                let
                    newOffset =
                        model.pan
                            |> Maybe.map (\p -> { p | current = mouse })
                            |> Maybe.map (correctZoomAndOffset 1)
                            |> Maybe.withDefault model.offset
                in
                    ( { model | offset = newOffset }, Cmd.none )

            PanEnd mouse ->
                ( { model | pan = Nothing }, Cmd.none )

            DragStart ixId mouse ->
                let
                    newDrag =
                        ixId
                            |> getInteraction model
                            |> Maybe.map getInteractionPosition
                            |> Maybe.map (calcOffset model.zoom mouse)
                            |> Maybe.map (\offset -> Drag offset mouse ixId)
                in
                    ( { model | drag = newDrag }, Cmd.none )

            DragAt pos ->
                let
                    updatedDrag =
                        Maybe.map (\d -> { d | current = pos }) model.drag

                    updatedIxs =
                        updatedDrag
                            |> Maybe.andThen (getInteraction model << .ix)
                            |> Maybe.map2 (setInteractionPosition << correctZoomAndOffset model.zoom) updatedDrag
                            |> Maybe.map (\ix -> Dict.insert (getInteractionId ix) ix model.ixs)
                            |> Maybe.withDefault model.ixs
                in
                    ( { model | drag = updatedDrag, ixs = updatedIxs }, Cmd.none )

            DragEnd pos ->
                ( { model | drag = Nothing }, Cmd.none )


calcOffset : Float -> Position -> Position -> Position
calcOffset zoom relative origin =
    { x = round (toFloat relative.x / zoom - toFloat origin.x)
    , y = round (toFloat relative.y / zoom - toFloat origin.y)
    }


correctZoomAndOffset : Float -> { x | offset : Position, current : Position } -> Position
correctZoomAndOffset zoom { offset, current } =
    { x = round (toFloat current.x / zoom - toFloat offset.x)
    , y = round (toFloat current.y / zoom - toFloat offset.y)
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        drag =
            case model.drag of
                Nothing ->
                    []

                Just _ ->
                    [ Mouse.moves DragAt, Mouse.ups DragEnd ]

        pan =
            case model.pan of
                Nothing ->
                    []

                Just _ ->
                    [ Mouse.moves PanAt, Mouse.ups PanEnd ]
    in
        Sub.batch <| drag ++ pan



-- MAIN


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
