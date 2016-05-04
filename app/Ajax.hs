{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
module Ajax (ajaxView) where

import Control.Concurrent.Async
import Control.Monad
import Data.Maybe
import JavaScript.Web.XMLHttpRequest
import React.Flux hiding (reqMethod, reqURI, reqHeaders)
import React.Flux.Lifecycle
import qualified Data.JSString as S
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
      void $ async $
      do setSt (Just "Please wait")
         vals <-
             flip mapConcurrently [1, 2, 1, 2] $ \idx ->
             do let req =
                        Request
                        { reqMethod = GET
                        , reqURI = S.pack $ "ajax" ++ show idx ++ ".txt"
                        , reqLogin = Nothing
                        , reqHeaders = [("Content-Type", "text/plain")]
                        , reqWithCredentials = False
                        , reqData = NoData
                        }
                xhrText req
         setSt (Just $ T.intercalate "\n" $ mapMaybe contents vals)
    }
