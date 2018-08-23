module Main exposing (..)

import Html exposing (..)
import String
import Svg as S
import Svg.Attributes as SA
import Debug


type alias Model =
    Int


type alias Message =
    { id : String
    , msg : String
    , next : String
    }


type Msg
    = NoOp


init : ( Model, Cmd Msg )
init =
    ( 1, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    S.svg
        [ SA.width "600", SA.height "600", SA.viewBox "0 0 600 600" ]
        [ viewMessage { id = "1", msg = "Hi {{ firstname }}, thanks for using one of our washrooms.", next = "2" }
        ]


viewMessage : Message -> S.Svg Msg
viewMessage message =
    let
        messageLines =
            splitLines 40 message.msg

        width =
            400

        height =
            55 + 21 * List.length messageLines
    in
        S.g
            []
            [ viewInteractionOutPort height "next"
            , viewInteractionBackground width height
            , viewInteractionInPort chatIcon
            , viewInteractionTitle "Message"
            , viewMessageLines 21 messageLines
            ]


viewInteractionBackground : Int -> Int -> S.Svg Msg
viewInteractionBackground width height =
    S.rect
        [ SA.width <| toString width
        , SA.height <| toString height
        , SA.stroke "#D8D8D8"
        , SA.fill "#FFFFFF"
        , SA.strokeWidth "2"
        , SA.x "1"
        , SA.y "0"
        , SA.rx "4"
        ]
        []


viewInteractionInPort : S.Svg Msg -> S.Svg Msg
viewInteractionInPort icon =
    S.g []
        [ S.path
            [ SA.fill "#D8D8D8"
            , SA.d "M0,3.99847066 C0,1.79017629 1.7837733,0 3.99789262,0 L35,0 L35,23.0015293 C35,25.2098237 33.2162267,27 31.0021074,27 L0,27 L0,3.99847066 Z"
            ]
            []
        , S.g [ SA.transform "translate(6, 5)" ] [ icon ]
        ]


viewInteractionOutPort : Int -> String -> S.Svg Msg
viewInteractionOutPort interactionHeight label =
    let
        top =
            toString <| interactionHeight - 2

        position =
            String.join "" [ "translate(20,", top, ")" ]
    in
        S.g [ SA.transform position ]
            [ S.rect [ SA.fill "#D8D8D8", SA.width "43", SA.height "20", SA.rx "4" ] []
            , S.text_
                [ SA.fontSize "13"
                , SA.fontWeight "400"
                , SA.fill "#727272"
                , SA.fontFamily "Lucida Console, Monaco, monospace"
                , SA.x "6"
                , SA.y "15"
                ]
                [ S.text label ]
            ]


chatIcon : S.Svg Msg
chatIcon =
    S.path
        [ SA.fill "#707070", SA.fillRule "nonzero", SA.d "M19.6842105,16.4705882 L15.8249474,16.4705882 L15.8249474,19.6078431 C15.8249474,19.7662745 15.7307719,19.9094118 15.5864211,19.9701961 C15.5385614,19.9901961 15.488386,20 15.4385965,20 C15.3382456,20 15.2398246,19.96 15.1657193,19.885098 L11.8051228,16.4705882 L1.92982456,16.4705882 C0.865719298,16.4705882 0,15.5909804 0,14.5098039 L0,1.96078431 C0,0.879607843 0.865719298,0 1.92982456,0 L19.6842105,0 C20.7483158,0 21.6144211,0.879607843 21.6144211,1.96078431 L21.6144211,14.5098039 C21.6144211,15.5909804 20.7483158,16.4705882 19.6842105,16.4705882 Z M20.8421053,1.96078431 C20.8421053,1.31215686 20.3229825,0.784313725 19.6842105,0.784313725 L1.92982456,0.784313725 C1.2914386,0.784313725 0.771929825,1.31215686 0.771929825,1.96078431 L0.771929825,14.5098039 C0.771929825,15.1584314 1.2914386,15.6862745 1.92982456,15.6862745 L11.9649123,15.6862745 C12.0675789,15.6862745 12.165614,15.727451 12.2377895,15.8011765 L15.0526316,18.6611765 L15.0526316,16.0784314 C15.0526316,15.8619608 15.2255439,15.6862745 15.4385965,15.6862745 L19.6842105,15.6862745 C20.3229825,15.6862745 20.8421053,15.1584314 20.8421053,14.5098039 L20.8421053,1.96078431 Z M15.4385965,9.41176471 C14.5875439,9.41176471 13.8947368,8.70823529 13.8947368,7.84313725 C13.8947368,6.97803922 14.5875439,6.2745098 15.4385965,6.2745098 C16.2900351,6.2745098 16.9824561,6.97803922 16.9824561,7.84313725 C16.9824561,8.70823529 16.2900351,9.41176471 15.4385965,9.41176471 Z M15.4385965,7.05882353 C15.0128772,7.05882353 14.6666667,7.41058824 14.6666667,7.84313725 C14.6666667,8.27568627 15.0128772,8.62745098 15.4385965,8.62745098 C15.8643158,8.62745098 16.2105263,8.27568627 16.2105263,7.84313725 C16.2105263,7.41058824 15.8643158,7.05882353 15.4385965,7.05882353 Z M10.8070175,9.41176471 C9.95596491,9.41176471 9.26315789,8.70823529 9.26315789,7.84313725 C9.26315789,6.97803922 9.95596491,6.2745098 10.8070175,6.2745098 C11.6584561,6.2745098 12.3508772,6.97803922 12.3508772,7.84313725 C12.3508772,8.70823529 11.6584561,9.41176471 10.8070175,9.41176471 Z M10.8070175,7.05882353 C10.3816842,7.05882353 10.0350877,7.41058824 10.0350877,7.84313725 C10.0350877,8.27568627 10.3816842,8.62745098 10.8070175,8.62745098 C11.2327368,8.62745098 11.5793333,8.27568627 11.5793333,7.84313725 C11.5793333,7.41058824 11.2327368,7.05882353 10.8070175,7.05882353 Z M6.1754386,9.41176471 C5.32438596,9.41176471 4.63157895,8.70823529 4.63157895,7.84313725 C4.63157895,6.97803922 5.32438596,6.2745098 6.1754386,6.2745098 C7.02687719,6.2745098 7.71929825,6.97803922 7.71929825,7.84313725 C7.71929825,8.70823529 7.02687719,9.41176471 6.1754386,9.41176471 Z M6.1754386,7.05882353 C5.7497193,7.05882353 5.40350877,7.41058824 5.40350877,7.84313725 C5.40350877,8.27568627 5.7497193,8.62745098 6.1754386,8.62745098 C6.60115789,8.62745098 6.94775439,8.27568627 6.94775439,7.84313725 C6.94775439,7.41058824 6.60115789,7.05882353 6.1754386,7.05882353 Z" ]
        []


viewInteractionTitle : String -> S.Svg Msg
viewInteractionTitle title =
    S.g
        [ SA.transform "translate(52.000000, 21.000000)"
        , SA.fill "#B5B5B5"
        , SA.fontSize "15"
        , SA.fontWeight "400"
        , SA.fontFamily "Lucida Console, Monaco, monospace"
        ]
        [ S.text_ [] [ S.text title ]
        ]


viewMessageLines : Int -> List String -> S.Svg Msg
viewMessageLines lineHeight lines =
    let
        messageLine idx line =
            let
                y =
                    toString <| 55 + (idx * lineHeight)
            in
                S.tspan [ SA.x "15", SA.y y ] [ S.text line ]
    in
        S.text_
            [ SA.fontSize "14"
            , SA.fontWeight "normal"
            , SA.fontFamily "Lucida Console, Monaco, monospace"
            , SA.fill "#707070"
            ]
            (List.indexedMap messageLine lines)


splitLines : Int -> String -> List String
splitLines maxLineLenght inputText =
    let
        words =
            String.split " " inputText

        initial =
            { currLine = ""
            , lines = []
            }

        addToCurrentLine word acc =
            { acc | currLine = String.concat [ acc.currLine, " ", word ] }

        addNewLine word acc =
            { acc | currLine = word, lines = acc.currLine :: acc.lines }

        wouldSurpassLineLength word acc =
            String.length word > maxLineLenght - String.length acc.currLine

        lineBuilder word acc =
            if (wouldSurpassLineLength word acc) then
                addNewLine word acc
            else
                addToCurrentLine word acc

        result =
            List.foldl lineBuilder initial words
    in
        List.reverse <| result.currLine :: result.lines


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
