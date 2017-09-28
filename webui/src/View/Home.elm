module View.Home exposing (view)

import Authentication
import Gravatar
import View.Centroid as Centroid
import Date
import List exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onWithOptions, on)
import Json.Decode as Json
import Keycloak
import View.LineChart as LineChart
import Route exposing (Location(..), locFor)
import String exposing (toLower)
import Types exposing (Model, Msg)
import WebComponents.App exposing (appDrawer, appDrawerLayout, appToolbar, appHeader, appHeaderLayout, ironSelector)
import WebComponents.Paper as Paper


header : Model -> Html Msg
header model =
  div [ class "mdc-toolbar mdc-toolbar--fixed header" ]
    [ div [ class "mdc-toolbar__row" ]
       [ section [ class "mdc-toolbar__section mdc-toolbar__section--align-start" ]
         [ button [ id "MenuButton"
                  , class "menu material-icons mdc-toolbar__icon--menu"
                  ]
           [ text "menu" ]
         , h1 [ class "mdc-toolbar__title" ]
           [ text "Haven GRC" ]
         ]
       ]
    ]

getGravatar : String -> String
getGravatar email =
    let
        options =
            Gravatar.defaultOptions
                |> Gravatar.withDefault Gravatar.Identicon

        url =
            Gravatar.url options email
    in
        "https:" ++ url


view : Model -> Keycloak.UserProfile -> Html Msg
view model user =
  div [ class "container" ]
    [ div [ id "MenuDrawer"
          , class "mdc-persistent-drawer mdc-typography sm-screen-drawer lg-screen-drawer"
          ]
        [ nav [ class "mdc-persistent-drawer__drawer sidebar" ]
            [ div [ class "nav-flex" ]
                [ div [ class "mdc-persistent-drawer__toolbar-spacer" ]
                    []
                , div [ class "user-container" ]
                    [ img [ attribute "sizing" "contain"
                          , attribute "src" (getGravatar user.username)
                          , class "user-avatar"
                          ]
                        []
                    , span [ class "user-name" ]
                        [ text user.firstName ]
                    , div [ class "mdc-menu-anchor" ]
                        [ button [ id "UserDropdownButton"
                            , class "user-menu-btn"
                            ]
                            [ i [ class "material-icons" ]
                                [ text "arrow_drop_down"]
                            ]
                        , div [ id "UserDropdownMenu"
                              , class "mdc-simple-menu"
                              , attribute "tabindex" "-1"
                              ]
                            [ ul [ class "mdc-simple-menu__items mdc-list" ]
                                [ a [ class "mdc-list-item"
                                    , href "/auth/realms/havendev/account/"
                                    , attribute "tabindex" "0"
                                    ]
                                    [ text "Edit Account" ]
                                , li [ class "mdc-list-item"
                                     , onClick (Types.AuthenticationMsg Authentication.LogOut)
                                     , attribute "tabindex" "0"
                                     ]
                                    [ text "Log Out" ]
                                ]
                            ]
                        ]
                    ]
                , nav [ class "mdc-persistent-drawer__content mdc-list" ]
                      (List.map (\item -> drawerMenuItem model item) menuItems)
                ]
            , div [ class "drawer-logo" ]
                [ img [ attribute "src" "%PUBLIC_URL%/img/logo@2x.png" ]
                    []
                ]
            ]
        ]
        , div [ class "mdc-toolbar-fixed-adjust" ]
            [ header model
            , body model
            ]
    ]

selectedItem : Model -> String
selectedItem model =
    let
        item =
            List.head (List.filter (\m -> m.route == model.route) menuItems)
    in
        case item of
            Nothing ->
                "dashboard"

            Just item ->
                String.toLower item.text


body : Model -> Html Msg
body model =
    div [ id "content" ]
        [ case model.route of
            Nothing ->
                dashboardBody model

            Just Home ->
                dashboardBody model

            Just Reports ->
                reportsBody model

            Just Regulations ->
                regulationsBody model

            Just Activity ->
                activityBody model

            Just _ ->
                notFoundBody model
        ]


dashboardBody : Model -> Html Msg
dashboardBody model =
    let
        data =
            [ 1, 1, 2, 3, 5, 8, 13 ]
    in
        div
            []
            [ Centroid.view data ]


reportsBody : Model -> Html Msg
reportsBody model =
    div [] [ text "This is the reports view" ]


regulationsBody : Model -> Html Msg
regulationsBody model =
    div []
        [ text "This is the regulations view"
        , ul []
            (List.map (\l -> li [] [ text l.description ]) model.regulations)
        , regulationsForm model
        ]


onValueChanged : (String -> msg) -> Html.Attribute msg
onValueChanged tagger =
    on "value-changed" (Json.map tagger Html.Events.targetValue)


regulationsForm : Model -> Html Msg
regulationsForm model =
    div
        []
        -- TODO wire up a handler to save the data from these inputs into
        -- our model when they change
        [ Paper.input
            [ attribute "label" "URI"
            , onValueChanged Types.SetRegulationURIInput
            , value model.newRegulation.uri
            ]
            []
        , Paper.input
            [ attribute "label" "identifier"
            , onValueChanged Types.SetRegulationIDInput
            , value model.newRegulation.identifier
            ]
            []
        , Paper.textarea
            [ attribute "label" "description"
            , onValueChanged Types.SetRegulationDescriptionInput
            , value model.newRegulation.description
            ]
            []
        , Paper.button
            [ attribute "raised" ""
            , onClick (Types.GetRegulations model)
            ]
            [ text "Add" ]
        , div [ class "debug" ] [ text ("DEBUG: " ++ toString model.newRegulation) ]
        ]


activityBody : Model -> Html Msg
activityBody model =
    let
        data =
            [ ( Date.fromTime 1448928000000, 2 )
            , ( Date.fromTime 1451606400000, 2 )
            , ( Date.fromTime 1454284800000, 1 )
            , ( Date.fromTime 1456790400000, 1 )
            ]
    in
        LineChart.view data


notFoundBody : Model -> Html Msg
notFoundBody model =
    div [] [ text "This is the notFound view" ]


type alias MenuItem =
    { text : String
    , iconName : String
    , route : Maybe Route.Location
    }


menuItems : List MenuItem
menuItems =
    [ { text = "Dashboard", iconName = "dashboard", route = Just Home }
    , { text = "Activity", iconName = "history", route = Just Activity }
    , { text = "Reports", iconName = "library_books", route = Just Reports }
    , { text = "Regulations", iconName = "gavel", route = Just Regulations }
    ]


drawerMenuItem : Model -> MenuItem -> Html Msg
drawerMenuItem model menuItem =
    a
      [ attribute "name" (toLower menuItem.text)
      , onClick <| Types.NavigateTo <| menuItem.route
      , classList [ ("mdc-list-item", True)
                  , ("mdc-persistent-drawer--selected", (toLower menuItem.text) == (selectedItem model) )
                  ]
      ]
      [ i [ class "material-icons mdc-list-item__start-detail" ] [ text menuItem.iconName ]
      , text menuItem.text
      ]
