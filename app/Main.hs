{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
module Main where

import Canvas

import Control.DeepSeq
import Data.Aeson (object, (.=))
import Data.Typeable
import GHC.Generics
import GHCJS.Types
import React.Flux
import React.Flux.Combinators
import React.Flux.Addons.Intl
import qualified Data.JSString as JSString

newtype Counter
    = Counter { unCounter :: Int }
    deriving (Show, Typeable)

data CounterAction
   = CounterIncrement
   | CounterDecrement
   deriving (Show, Typeable, Generic, NFData)

instance StoreData Counter where
    type StoreAction Counter = CounterAction
    transform action (Counter idx) =
        pure $ Counter $
        case action of
          CounterIncrement -> idx + 1
          CounterDecrement -> idx - 1

counterStore :: ReactStore Counter
counterStore = mkStore (Counter 1000)

dispatchCounter :: CounterAction -> [SomeStoreAction]
dispatchCounter a = [SomeStoreAction counterStore a]

counterApp :: ReactView ()
counterApp =
    defineControllerView "Counter APP" counterStore $ \counterState () ->
    div_ $
    do span_ [] $ int_ $ unCounter counterState
       button_ [ onClick $ \_ _ -> dispatchCounter CounterIncrement ] $ $(message "up-button" "Up") []
       button_ [ onClick $ \_ _ -> dispatchCounter CounterDecrement ] $ $(message "down-button" "Down") []
       br_ mempty
       view canvasView (2*pi * (fromIntegral (unCounter counterState) / 100)) mempty

lineChart :: [PropertyOrHandler eh] -> ReactElementM eh ()
lineChart props = foreign_ "ReactChartLine" props mempty

lcExample =
    lineChart
    [ "data" @=
        object
        [ "labels" .= ([ "Red", "Blue", "Yellow", "Green", "Purple", "Orange" ] :: [String])
        , "datasets" .=
            object
            [ "label" .= ("Votes" :: String)
            , "data" .= ([12, 19, 3, 5, 2, 3] :: [Int])
            ]
        ]
    , "options" @=
        object
        []
    , "width" @= ("600" :: String)
    , "height" @= ("250" :: String)
    ]

leafletMap :: [PropertyOrHandler eh] -> ReactElementM eh () -> ReactElementM eh ()
leafletMap = foreign_ "Leaflet.Map"

leafletTileLayer :: [PropertyOrHandler eh] -> ReactElementM eh ()
leafletTileLayer props = foreign_ "Leaflet.TileLayer" props mempty

leafletMarker :: [PropertyOrHandler eh] -> ReactElementM eh () -> ReactElementM eh ()
leafletMarker = foreign_ "Leaflet.Marker"

leafletPopup :: [PropertyOrHandler eh] -> ReactElementM eh () -> ReactElementM eh ()
leafletPopup = foreign_ "Leaflet.Popup"

mapExample =
    leafletMap [ "center" @= pos, "zoom" @= zoom,  "style" @= object [ "height" .= (600 :: Int) ] ] $
    do leafletTileLayer
           [ "url" @= ("http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png" :: String)
           , "attribution" @= ("&copy; <a href='http://osm.org/copyright'>OpenStreetMap</a> contributors" :: String)
           ]
       leafletMarker [ "position" @= pos ] $
           leafletPopup [] $ "Hi there!"
    where
        pos :: [Double]
        pos = [51.505, -0.09]

        zoom :: Int
        zoom = 13

realApp =
    div_ $
    do view counterApp () mempty
       lcExample
       mapExample

app :: ReactView ()
app =
    defineView "core app" $ \() ->
    intlProvider_ (JSString.unpack js_initialLocale) (Just $ js_myMessages js_initialLocale) Nothing $
    realApp
main :: IO ()
main =
    reactRender "app" app ()

foreign import javascript unsafe
    "$r = window['config']['locale']"
    js_initialLocale :: JSString

foreign import javascript unsafe
    "window['i18n'] ? window['i18n'][$1] : null"
    js_myMessages :: JSString -> JSVal


$(writeIntlMessages (intlFormatJson $ "i18n/core.json"))
