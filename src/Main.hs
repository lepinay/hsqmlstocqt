{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Concurrent
import Graphics.QML

import GUI.StocQt

main :: IO ()
main = do

    y   <- newMVar "year" -- year
    sid <- newMVar "" -- stockId
    sn  <- newMVar "" -- stockName
    sdc <- newMVar "d" -- stockDataCycle

    sis <- mapM newObjectDC $ genStockList stocks

    sm  <- newObjectDC $ StockModel sid sn sdc
    ss  <- newObjectDC $ StockSettings y
    sc  <- newObjectDC $ StocQt sm sis ss

    runEngineLoop defaultEngineConfig {
      initialDocument = fileDocument "qml/stocqt.qml"
    , contextObject   = Just $ anyObjRef sc
    }
