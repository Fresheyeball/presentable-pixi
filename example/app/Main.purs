module Main where

import Presentable.ViewParser
import Presentable.Router
import Pixi.Point
import Pixi.Detector
import Pixi.DisplayObject
import Pixi.DisplayObject.Container
import Pixi.DisplayObject.Container.Stage
import Pixi.DisplayObject.Container.Graphic
import qualified Pixi.DisplayObject.Container.Sprite.Text as T
import History
import Data.Either
import Data.Tuple
import Data.Maybe
import Debug.Trace
import Debug.Foreign
import Control.Monad.JQuery
import Control.Monad.Eff

sampleYaml = 
  "- header:\n\
  \    attributes:\n\
  \      title : 'Presentable'\n\
  \    children:\n\
  \      - logo\n\
  \- footer"

sampleYamlAbout = 
  "- header:\n\
  \    attributes:\n\
  \      title : 'Presentable / About'\n\
  \    children:\n\
  \      - logo\n\
  \- footer"

renderJ item = ready $ do i <- item
                          b <- body
                          append i b
clearFrame = body >>= clear

foreign import getWindowWidth
  "function getWindowWidth(){ return window.innerWidth; }" 
  :: forall e. Eff (dom :: DOM | e) Number 

foreign import getWindowHeight
  "function getWindowHeight(){ return window.innerHeight; }" 
  :: forall e. Eff (dom :: DOM | e) Number 

header (Just p@{ stage = s }) (Just { title = t }) = do
  width <- getWindowWidth
  text  <- getText
  draw width text
  return $ Just p{ src = "http://www.peoplepulse.com.au/heart-icon.png" }
  where
  getText = T.newText t T.textStyleDefault{ fill = "white" } 
          >>= setPosition {x : 40, y : 10}
  draw w t = newGraphic >>= beginFill 0x00 1
                        >>= drawRect {x : 0, y : 0, height : 45, width : w} 
                        >>= addChild (s :: Stage) 
                        >>= flip addChild t
  
logo (Just p) _ = do 
  renderJ $ create dom
    >>= css style >>= on "click" click
  return Nothing
  where
  dom   = "<img src='" ++ p.src ++ "' />"
  click _ _ = clearFrame >>= \_ -> pushState about
  about = { url : "/about", title : "about", "data" :{} }
  style = { top      : 6
          , left     : 8
          , zIndex   : 1
          , height   : 25
          , cursor   : "pointer"
          , position : "fixed"}  

footer _ _ = do
  trace "renderJ footer"
  return Nothing

main = ready $ do
  w        <- getWindowWidth
  stage    <- newStage 0xFFFFFF
  renderer <- autoDetectRenderer w 300
  appendToBody renderer.view

  let root = { renderer : renderer
             , stage    : stage
             , src      : ""}

  route rs $ renderYaml (Just root)
    $ register "footer" footer
    $ register "header" header
    $ register "logo"   logo
    $ emptyRegistery

  subscribeStateChange $ const $ render stage renderer
  
  initRoutes
  
  where rs = [ (Tuple {url : "/index", title : "home",  "data" :{}} sampleYaml)
             , (Tuple {url : "/about", title : "about", "data" :{}} sampleYamlAbout)]