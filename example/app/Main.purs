module Main where

import Presentable.ViewParser
import Data.Either
import Debug.Trace
import Debug.Foreign

sampleYaml = 
  "- header:\n\
  \    attributes:\n\
  \      foo : 'foo'\n\
  \    children:\n\
  \      - logo\n\
  \- footer"

header _ a = do
  trace "render header"
  fprint a
footer _ _ = fprint "render footer"
logo   _ _ = fprint "render logo"

main = parseAndRender sampleYaml
     $ register "footer" footer
     $ register "header" header
     $ register "logo" logo
     $ emptyRegistery