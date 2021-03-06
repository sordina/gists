{-# LANGUAGE NoMonomorphismRestriction #-}

import Text.XML.HXT.Core
import Text.HandsomeSoup
import Network.HTTP.Conduit      (simpleHttp)
import Data.ByteString.Lazy.UTF8 (toString)
import System.Environment
import Data.Tree.NTree.TypeDefs

base :: String
base = "https://gist.github.com"

main :: IO ()
main = getArgs >>= options

options :: [String] -> IO ()
options ["-h"    ] = help
options ["--help"] = help
options [user    ] = run $ "/" ++ user
options _          = help

help :: IO ()
help = putStrLn "Usage: gists <username>"

run :: String -> IO ()
run path = do
  bytes <- simpleHttp $ base ++ path

  let text = toString bytes
      doc  = readString [withParseHTML yes, withWarnings no] text

  gists <- runX $ doc >>> getGists
  mapM_ (putStrLn . (base ++)) gists
  runX (doc >>> getNextPageLink) >>= mapM_ run . take 1

getNextPageLink, getGists, link, snippet, description :: ArrowXml cat => cat (NTree XNode) String

getNextPageLink = css ".pagination a" >>> filterA (this //> hasText (elem "Older" . words)) ! "href"
getGists        = css ".gist-item"    >>> (link <+> description <+> snippet) >. strip
link            = css ".creator a"    >>. drop 1 >>> (getAttrValue "href" <+> deep getText) >. strip
snippet         = css ".line-data"    >>> deep getText >. strip
description     = css ".description"  >>> deep getText >. strip

strip :: [String] -> String
strip = unwords . words . unwords
