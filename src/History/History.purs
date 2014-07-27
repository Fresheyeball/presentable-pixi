module History
  ( getState
  , pushState
  , replaceState    
  , goBack
  , goForward
  , goState
  , subscribeStateChange
  , History(..)
  , State(..)
  ) where

import Debug.Foreign
import Data.Foreign.EasyFFI
import Control.Monad.Eff
import Control.Reactive
import Control.Reactive.EventEmitter

type Title                  = String
type Url                    = String

--- Record representing browser state 
--- Passed to and returned by history
type State d                = {
    "data" :: { | d },
    title  :: Title, 
    url    :: Url    
  }

foreign import data History :: !

statechange = "statechange"

getData                     = unsafeForeignFunction [""] "window.history.state"
getTitle                    = unsafeForeignFunction [""] "document.title"
getUrl                      = unsafeForeignFunction [""] "location.pathname"

getState                    :: forall m d. (Monad m) => m (State d)
getState                    = do d <- getData
                                 t <- getTitle
                                 u <- getUrl
                                 return { title : t, url : u, "data" : d }


stateUpdaterNative          :: forall d eff. String ->
                             { | d } -> -- State.data
                             Title   -> -- State.title 
                             Url     -> -- State.url
                             Eff (history :: History | eff) Unit
stateUpdaterNative        x = unsafeForeignProcedure ["d","title","url", ""] $ x ++ "(d,title,url)"

pushState'                  = stateUpdaterNative "window.history.pushState"
pushState s                 = do
  pushState'    s."data" s.title s.url
  emit $ newEvent statechange { state : s }

replaceState'               = stateUpdaterNative "window.history.replaceState"
replaceState s              = do
  replaceState' s."data" s.title s.url
  emit $ newEvent statechange { state : s }



subscribeStateChange      f = subscribeEvented statechange f 



goBack                      = unsafeForeignFunction  [""]        "window.history.back()"
goForward                   = unsafeForeignFunction  [""]        "window.history.forward()"

goState                     :: forall eff. Number -> Eff (history :: History | eff) Unit
goState                     = unsafeForeignProcedure ["dest",""] "window.history.go(dest)"