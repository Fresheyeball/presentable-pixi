module History where

import Debug.Foreign
import Data.Foreign.EasyFFI
import Control.Monad.Eff

-- This is the record both sent and returned by History.js
type State d        = {title :: Title, url :: Url, "data" :: { | d }}
type Title          = String
type Url            = String

foreign import data History :: !

type StateUpdater d = forall eff. { | d } -> Title -> Url -> Eff (history :: History | eff) {}

------

pushState' :: forall d. StateUpdater d
pushState' = unsafeForeignProcedure ["d","title","url", ""] "window.history.pushState(d,title,url)"

pushState :: forall eff d. State d -> Eff (history :: History | eff) {}
pushState s = pushState' s."data" s.title s.url

------

replaceState' :: forall d. StateUpdater d
replaceState' = unsafeForeignProcedure ["d","title","url", ""] "window.history.replaceState(d,title,url)"

replaceState :: forall eff d. State d -> Eff (history :: History | eff) {}
replaceState s = replaceState' s."data" s.title s.url

------

getData :: forall d m. (Monad m) => m { | d }
getData = unsafeForeignFunction [""] "window.history.state"

getTitle :: forall m. (Monad m) => m String
getTitle = unsafeForeignFunction [""] "document.title"

getUrl :: forall m. (Monad m) => m String
getUrl = unsafeForeignFunction [""] "location.pathname"

getState :: forall m d. (Monad m) => m (State d)
getState = do t <- getTitle
              u <- getUrl
              d <- getData
              return { title : t, url : u, "data" : d }

stateChange :: forall a e. Eff e a -> Eff (history :: History | e) {}
stateChange = unsafeForeignFunction ["fn",""] "window.addEventListener('click', fn)"

goBack :: forall eff. Eff (history :: History | eff) {}
goBack = unsafeForeignFunction [""] "window.history.back()"

goForward :: forall eff. Eff (history :: History | eff) {}
goForward = unsafeForeignFunction [""] "window.history.forward()"

go :: forall eff. Number -> Eff (history :: History | eff) {}
go = unsafeForeignProcedure ["dest",""] "window.history.go(dest)"