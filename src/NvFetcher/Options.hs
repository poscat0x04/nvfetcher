{-# LANGUAGE TemplateHaskell #-}

-- | Copyright: (c) 2021 berberman
-- SPDX-License-Identifier: MIT
-- Maintainer: berberman <berberman@yandex.com>
-- Stability: experimental
-- Portability: portable
--
-- CLI interface of nvfetcher
module NvFetcher.Options
  ( CLIOptions (..),
    cliOptionsParser,
    getCLIOptions,
  )
where

import Options.Applicative.Simple
import qualified Paths_nvfetcher as Paths

-- | Options for nvfetcher CLI
data CLIOptions = CLIOptions
  { buildDir :: FilePath,
    commit :: Bool,
    logPath :: Maybe FilePath,
    threads :: Int,
    retries :: Int,
    timing :: Bool,
    verbose :: Bool,
    target :: String
  }
  deriving (Show)

cliOptionsParser :: Parser CLIOptions
cliOptionsParser =
  CLIOptions
    <$> strOption
      ( long "build-dir"
          <> short 'o'
          <> metavar "DIR"
          <> help "Directory that nvfetcher puts artifacts to"
          <> showDefault
          <> value "_sources"
          <> completer (bashCompleter "directory")
      )
    <*> switch
      ( long "commit-changes"
          <> help "`git commit` changes in this run (with shake db)"
      )
    <*> optional
      ( strOption
          ( long "changelog"
              <> short 'l'
              <> metavar "FILE"
              <> help "Dump version changes to a file"
              <> completer (bashCompleter "file")
          )
      )
    <*> option
      auto
      ( short 'j'
          <> metavar "NUM"
          <> help "Number of threads (0: detected number of processors)"
          <> value 0
          <> showDefault
      )
    <*> option
      auto
      ( short 'r'
          <> long "retry"
          <> metavar "NUM"
          <> help "Times to retry of some rules (nvchecker, prefetch, nix-instantiate, etc.)"
          <> value 3
          <> showDefault
      )
    <*> switch (long "timing" <> short 't' <> help "Show build time")
    <*> switch (long "verbose" <> short 'v' <> help "Verbose mode")
    <*> strArgument
      ( metavar "TARGET"
          <> help "Two targets are available: 1.build  2.clean"
          <> value "build"
          <> completer (listCompleter ["build", "clean"])
          <> showDefault
      )

version :: String
version = $(simpleVersion Paths.version)

-- | Parse nvfetcher CLI options
getCLIOptions :: Parser a -> IO a
getCLIOptions parser = do
  (opts, ()) <-
    simpleOptions
      version
      "nvfetcher"
      "generate nix sources expr for the latest version of packages"
      parser
      empty
  pure opts
