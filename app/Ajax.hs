{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
module Ajax (ajaxView) where

import JavaScript.Ajax
import React.Flux
import React.Flux.Lifecycle
import qualified Data.Text as T

ajaxView :: ReactView ()
ajaxView =
    defineLifecycleView "canvasView" Nothing $
    lifecycleConfig
    { lRender =
      \st _ -> span_ [] $
      case st of
        Nothing -> "Loading ..."
        Just t -> elemText $ T.unpack t
    , lComponentDidMount =
      Just $ \_ _ setSt ->
      sendRequest GET "ajax.txt" Nothing Nothing (\_ val -> setSt $ Just val)
    }
