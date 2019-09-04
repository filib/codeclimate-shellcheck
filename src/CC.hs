{-# LANGUAGE OverloadedStrings #-}

module CC (
  -- * Handle engine configuration
    loadConfig
  -- * Handle engine results
  , printIssue
  -- * Re-export common types
  , module CC.Types
) where

import           CC.Types
import           Data.Aeson
import qualified Data.ByteString.Lazy as BSL
import           Data.Maybe
import           System.Directory

--------------------------------------------------------------------------------

-- | Load config from CodeClimate engine path or use a default.
loadConfig :: FilePath -> IO Config
loadConfig path = do
  fileExists <- doesFileExist path
  config <- if fileExists
              then decode <$> BSL.readFile path
              else return Nothing
  return $! fromMaybe (Config []) config

--------------------------------------------------------------------------------

-- | Print an issue to the console as per CodeClimate spec.
printIssue :: Issue -> IO ()
printIssue = BSL.putStr . (<> "\0") . encode
