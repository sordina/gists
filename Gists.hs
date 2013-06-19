{-# LANGUAGE NoMonomorphismRestriction #-}

import Text.XML.HXT.Core
import Text.HandsomeSoup
import Network.HTTP.Conduit      (simpleHttp)
import Data.ByteString.Lazy.UTF8 (toString)
import System.Environment

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
  let
    text = toString bytes
    doc  = readString [withParseHTML yes, withWarnings no] text

  gists <- runX $ doc >>> getGists

  mapM_ (putStrLn . (base ++)) gists

  runX (doc >>> getNextPageLink) >>= mapM_ run . take 1

getNextPageLink = css ".pagination a"       >>> filterA (this //> hasText (elem "Older" . words)) ! "href"
getGists        = css ".gist-item"          >>> (link <+> description <+> snippet) >. unwords
link            = css ".creator a"          >>. drop 1 >>> (getAttrValue "href" <+> deep getText) >. unwords
snippet         = css ".line-data"          >>> deep getText >. strip
description     = css ".description"        >>> deep getText >. strip
strip           = unwords . words . unwords
