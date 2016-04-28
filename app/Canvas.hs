{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
module Canvas (canvasView) where

import JavaScript.Web.Canvas
import React.Flux
import React.Flux.Lifecycle

import Unsafe.Coerce

renderToCanvas :: Double -> Context ->IO ()
renderToCanvas rotation ctx =
    do save ctx
       fillStyle 255 255 255 1 ctx
       fillRect 0 0 200 200 ctx
       restore ctx
       save ctx
       translate 100 100 ctx
       rotate rotation ctx
       strokeRect (-50) (-50) 100 100 ctx
       restore ctx

canvasView :: ReactView Double
canvasView =
    defineLifecycleView "canvasView" () $
    lifecycleConfig
    { lRender =
      \_ _ -> canvas_ [ "ref" @= "canvas", "width" @= 200, "height" @= 200 ] mempty
    , lComponentDidMount = Just $ \propsAndSt ldom _ -> rerender propsAndSt ldom
    , lComponentDidUpdate = Just $ \propsAndSt ldom _ _ _ -> rerender propsAndSt ldom
    }

rerender :: LPropsAndState Double st -> LDOM -> IO ()
rerender propsAndSt ldom =
    do angle <- lGetProps propsAndSt
       canvas <-  lRef ldom "canvas"
       ctx <- getContext $ unsafeCoerce canvas
       renderToCanvas angle ctx
