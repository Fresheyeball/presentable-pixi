module Pixi.Detector where

import Pixi.Internal
import Control.Monad.Eff
import Data.Function

type Renderer = { view :: DOM }

foreign import autoDetectRendererImpl
  "function autoDetectRendererImpl(x, y){\
  \  return function(){\
  \    return PIXI.autoDetectRenderer(x, y);\
  \  };\
  \}" :: forall e. Fn2 Number Number (Eff e Renderer)
autoDetectRenderer = runFn2 autoDetectRendererImpl

foreign import appendToBody 
  "function appendToBody(x){\
  \  return function(){\
  \    document.body.appendChild(x);\
  \  };\
  \}" :: forall e. DOM -> Eff (domMutation :: DOMMutation | e) Unit
