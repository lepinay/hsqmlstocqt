{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE OverloadedStrings  #-}
{-# LANGUAGE TypeFamilies       #-}
module GUI.StocQt where

import           Control.Applicative ((<$>), (<*>))
import           Control.Concurrent
import           Control.Monad
import           Data.Proxy
import qualified Data.Text           as T
import           Data.Typeable
import           Graphics.QML

type ChartType = T.Text
type Color = T.Text -- RGB in Hex.
type Date = T.Text

-- | QML Context Object.
data StocQt = StocQt { stockModel     :: ObjRef StockModel
                     , stockListModel :: [ObjRef StockListItem]
                     , stockSettings  :: ObjRef StockSettings
                     } deriving Typeable

data StockModel = StockModel { stockId         :: MVar T.Text
                             , stockName       :: MVar T.Text
                             , stockDataCycle  :: MVar T.Text
                             , ready           :: MVar Bool
                             , stockPrice      :: MVar Double
                             , stockPriceDelta :: MVar Double
                             , highestPrice    :: MVar Double
                             , highestVolume   :: MVar Double
                             , startDate       :: MVar Date
                             , endDate         :: MVar Date
                             , stock           :: MVar [ObjRef StockItem]
                             } deriving Typeable

data StockSettings = StockSettings { chartType      :: MVar ChartType
                                   , drawHighPrice  :: MVar Bool
                                   , drawLowPrice   :: MVar Bool
                                   , drawOpenPrice  :: MVar Bool
                                   , drawClosePrice :: MVar Bool
                                   , drawVolume     :: MVar Bool
                                   , drawKLine      :: MVar Bool
                                   , closeColor     :: MVar Color
                                   , highColor      :: MVar Color
                                   , lowColor       :: MVar Color
                                   , openColor      :: MVar Color
                                   , volumeColor    :: MVar Color
                                   } deriving Typeable

data StockListItem = StockListItem { name        :: T.Text
                                   , stockItemId :: T.Text
                                   } deriving (Show, Typeable)

data StockItem = StockItem { date     :: Date
                           , open     :: Double
                           , high     :: Double
                           , low      :: Double
                           , close    :: Double
                           , volume   :: Int
                           , adjusted :: Double
                           } deriving Typeable

-- StockModel Signals
data StockIdChanged deriving Typeable
data StockNameChanged deriving Typeable
data StockDataCycleChanged deriving Typeable
data ReadyChanged deriving Typeable
data StockPriceChanged deriving Typeable
data StockPriceDeltaChanged deriving Typeable
data HighestPriceChanged deriving Typeable
data HighestVolumeChanged deriving Typeable
data StartDateChanged deriving Typeable
data EndDateChanged deriving Typeable
data StockReady deriving Typeable

-- StockSettings Signals
data ChartTypeChanged deriving Typeable
data DrawHighPriceChanged deriving Typeable
data DrawLowPriceChanged deriving Typeable
data DrawOpenPriceChanged deriving Typeable
data DrawClosePriceChanged deriving Typeable
data DrawVolumeChanged deriving Typeable
data DrawKLineChanged deriving Typeable

instance DefaultClass StocQt where
    classMembers = [
              defPropertyRO "stockModel" $ return . stockModel . fromObjRef
            , defPropertyRO "stockListModel" $ return . stockListModel . fromObjRef
            , defPropertyRO "stockSettings" $ return . stockSettings . fromObjRef
            ]

instance DefaultClass StockModel where
    classMembers = [
              defPropertySigRW "stockId" stockIdChanged
                        (getProperty stockId) $ setProperty stockId stockIdChanged
            , defPropertySigRW "stockName" stockNameChanged
                        (getProperty stockName) $ setProperty stockName stockNameChanged
            , defPropertySigRW "stockDataCycle" stockDataCycleChanged
                        (getProperty stockDataCycle) $ setProperty stockDataCycle stockDataCycleChanged
            , defPropertySigRW "ready" readyChanged (getProperty ready) $ setProperty ready readyChanged
            , defPropertySigRW "stockPrice" stockPriceChanged
                        (getProperty stockPrice) $ setProperty stockPrice stockPriceChanged
            , defPropertySigRW "stockPriceDelta" stockPriceDeltaChanged
                        (getProperty stockPriceDelta) $ setProperty stockPriceDelta stockPriceDeltaChanged
            , defPropertySigRW "highestPrice" highestPriceChanged
                        (getProperty highestPrice) $ setProperty highestPrice highestPriceChanged
            , defPropertySigRW "highestVolume" highestVolumeChanged
                        (getProperty highestVolume) $ setProperty highestVolume highestVolumeChanged
            , defPropertySigRW "startDate" startDateChanged
                        (getProperty startDate) $ setProperty startDate startDateChanged
            , defPropertySigRW "endDate" endDateChanged
                        (getProperty endDate) $ setProperty endDate endDateChanged
            , defPropertySigRW "stock" stockReady
                        (getProperty stock) $ setProperty stock stockReady

            -- Methods. Some of these redefine ListModel.
            , defMethod "append" appendStock
            , defMethod "count" countStock
            , defMethod "get" getStock
            , defMethod "clear" clearStock
            , defMethod "createStockPrice" createStockPrice
            , defMethod "stockPriceDeltaPercentage" stockPriceDeltaPercentage
            ]
      where stockIdChanged = Proxy :: Proxy StockIdChanged
            stockNameChanged = Proxy :: Proxy StockNameChanged
            stockDataCycleChanged = Proxy :: Proxy StockDataCycleChanged
            readyChanged = Proxy :: Proxy ReadyChanged
            stockPriceChanged = Proxy :: Proxy StockPriceChanged
            stockPriceDeltaChanged = Proxy :: Proxy StockPriceDeltaChanged
            highestPriceChanged = Proxy :: Proxy HighestPriceChanged
            highestVolumeChanged = Proxy :: Proxy HighestVolumeChanged
            startDateChanged = Proxy :: Proxy StartDateChanged
            endDateChanged = Proxy :: Proxy EndDateChanged
            stockReady = Proxy :: Proxy StockReady

instance DefaultClass StockListItem where
    classMembers = [
              defPropertyRO "name" $ return . name . fromObjRef
            , defPropertyRO "stockId" $ return . stockItemId . fromObjRef
            ]

instance DefaultClass StockSettings where
    classMembers = [
              defPropertySigRW "chartType" chartTypeChanged
                        (getProperty chartType) $ setProperty chartType chartTypeChanged
            , defPropertySigRW "drawHighPrice" drawHighPriceChanged
                        (getProperty drawHighPrice) $ setProperty drawHighPrice drawHighPriceChanged
            , defPropertySigRW "drawLowPrice" drawLowPriceChanged
                        (getProperty drawLowPrice) $ setProperty drawLowPrice drawLowPriceChanged
            , defPropertySigRW "drawOpenPrice" drawOpenPriceChanged
                        (getProperty drawOpenPrice) $ setProperty drawOpenPrice drawOpenPriceChanged
            , defPropertySigRW "drawClosePrice" drawClosePriceChanged
                        (getProperty drawClosePrice) $ setProperty drawClosePrice drawClosePriceChanged
            , defPropertySigRW "drawVolume" drawVolumeChanged
                        (getProperty drawVolume) $ setProperty drawVolume drawVolumeChanged
            , defPropertySigRW "drawKLine" drawKLineChanged
                        (getProperty drawKLine) $ setProperty drawKLine drawKLineChanged
            , defPropertyRO "closeColor" $ getProperty closeColor
            , defPropertyRO "highColor" $ getProperty highColor
            , defPropertyRO "lowColor" $ getProperty lowColor
            , defPropertyRO "openColor" $ getProperty openColor
            , defPropertyRO "volumeColor" $ getProperty volumeColor
            ]
      where chartTypeChanged = Proxy :: Proxy ChartTypeChanged
            drawHighPriceChanged = Proxy :: Proxy DrawHighPriceChanged
            drawLowPriceChanged = Proxy :: Proxy DrawLowPriceChanged
            drawOpenPriceChanged = Proxy :: Proxy DrawOpenPriceChanged
            drawClosePriceChanged = Proxy :: Proxy DrawClosePriceChanged
            drawVolumeChanged = Proxy :: Proxy DrawVolumeChanged
            drawKLineChanged = Proxy :: Proxy DrawKLineChanged

instance DefaultClass StockItem where
    classMembers = [
              defPropertyRO "date" $ return . date . fromObjRef
            , defPropertyRO "open" $ return . open . fromObjRef
            , defPropertyRO "high" $ return . high . fromObjRef
            , defPropertyRO "low" $ return . low . fromObjRef
            , defPropertyRO "close" $ return . close . fromObjRef
            , defPropertyRO "volume" $ return . volume . fromObjRef
            , defPropertyRO "adjusted" $ return . adjusted. fromObjRef
            ]

instance SignalKeyClass StockIdChanged where
    type SignalParams StockIdChanged = IO ()

instance SignalKeyClass StockNameChanged where
    type SignalParams StockNameChanged = IO ()

instance SignalKeyClass StockDataCycleChanged where
    type SignalParams StockDataCycleChanged = IO ()

instance SignalKeyClass StockPriceChanged where
    type SignalParams StockPriceChanged = IO ()

instance SignalKeyClass StockPriceDeltaChanged where
    type SignalParams StockPriceDeltaChanged = IO ()

instance SignalKeyClass HighestPriceChanged where
    type SignalParams HighestPriceChanged = IO ()

instance SignalKeyClass HighestVolumeChanged where
    type SignalParams HighestVolumeChanged = IO ()

instance SignalKeyClass ReadyChanged where
    type SignalParams ReadyChanged = IO ()

instance SignalKeyClass StartDateChanged where
    type SignalParams StartDateChanged = IO ()

instance SignalKeyClass EndDateChanged where
    type SignalParams EndDateChanged = IO ()

instance SignalKeyClass StockReady where
    type SignalParams StockReady = IO ()

instance SignalKeyClass ChartTypeChanged where
    type SignalParams ChartTypeChanged = IO ()

instance SignalKeyClass DrawHighPriceChanged where
    type SignalParams DrawHighPriceChanged = IO ()

instance SignalKeyClass DrawLowPriceChanged where
    type SignalParams DrawLowPriceChanged = IO ()

instance SignalKeyClass DrawOpenPriceChanged where
    type SignalParams DrawOpenPriceChanged = IO ()

instance SignalKeyClass DrawClosePriceChanged where
    type SignalParams DrawClosePriceChanged = IO ()

instance SignalKeyClass DrawVolumeChanged where
    type SignalParams DrawVolumeChanged = IO ()

instance SignalKeyClass DrawKLineChanged where
    type SignalParams DrawKLineChanged = IO ()


defaultStockModel :: IO StockModel
defaultStockModel =
  StockModel
    <$> newMVar "" -- stockId
    <*> newMVar "" -- stockName
    <*> newMVar "d" -- stockDataCycle
    <*> newMVar False -- ready
    <*> newMVar 0.0 -- stockPrice
    <*> newMVar 0.0 -- stockPriceModified
    <*> newMVar 0.0 -- highestPrice
    <*> newMVar 0.0 -- highestVolume
    <*> newMVar "1995-03-25" -- startDate 25, April 1995
    <*> newMVar "2014-05-31" -- Today...
    <*> newMVar [] -- stock


defaultStockSettings :: IO StockSettings
defaultStockSettings = do
  StockSettings
    <$> newMVar "year" -- chartType
    <*> newMVar False -- drawHighPrice
    <*> newMVar False -- drawLowPrice
    <*> newMVar False -- drawOpenPrice
    <*> newMVar True -- drawClosePrice
    <*> newMVar True -- drawVolume
    <*> newMVar False -- drawKLine
    <*> newMVar "#ecc088" -- closeColor
    <*> newMVar "#ff0000" -- highColor
    <*> newMVar "#00ff00" -- lowColor
    <*> newMVar "#0000ff" -- openColor
    <*> newMVar "#0000ff" -- volumeColor


defaultStockListModel :: [StockListItem]
defaultStockListModel = genStockList stocks


getProperty :: (tt -> MVar a) -> ObjRef tt -> IO a
getProperty gtr = readMVar . gtr . fromObjRef


-- | Set property on a DefaultClass and fire NOTIFY signal.
-- setProperty :: (tt -> MVar a) -> sig -> ObjRef tt -> a -> IO ()
setProperty setr sig obj v = modifyMVar_ (setr $ fromObjRef obj) $ \_ ->
        fireSignal sig obj >> return v


createStockPrice :: ObjRef StockModel ->
                    Date -> -- * date
                    Double -> -- * open
                    Double -> -- * high
                    Double -> -- * low
                    Double -> -- * close
                    Double -> -- * volume
                    Double -> -- * adjusted
                    IO (ObjRef StockItem)
createStockPrice sm d o h l c v a = do
            let sm' = fromObjRef sm

            h' <- readMVar $ highestPrice sm'
            when (h' < h) $ setProperty highestPrice (Proxy :: Proxy HighestPriceChanged) sm h

            v' <- readMVar $ highestVolume sm'
            when (v' < v) $ setProperty highestVolume (Proxy :: Proxy HighestVolumeChanged) sm v

            newObjectDC $ StockItem d o h l c (truncate v) a


appendStock :: ObjRef StockModel -> ObjRef StockItem -> IO ()
appendStock sm si = modifyMVar_ (stock $ fromObjRef sm) (\xs -> return $ xs ++ [si]) >>
                    fireSignal (Proxy :: Proxy StockReady) sm


getStock :: ObjRef StockModel -> Int -> IO (ObjRef StockItem)
getStock sm i = do
        st <- readMVar $ stock $ fromObjRef sm
        return $ st !! i


clearStock :: ObjRef StockModel -> IO ()
clearStock sm = modifyMVar_ (stock $ fromObjRef sm) (\_ -> return []) >>
                fireSignal (Proxy :: Proxy StockReady) sm


countStock :: ObjRef StockModel -> IO Int
countStock sm = do
    ls <- readMVar $ stock $ fromObjRef sm
    return $ length ls


stockPriceDeltaPercentage :: ObjRef StockModel -> IO Double
stockPriceDeltaPercentage sm = do
        spd <- readMVar $ stockPriceDelta $ fromObjRef sm
        sp  <- readMVar $ stockPrice $ fromObjRef sm
        return $ abs $ spd / (sp - spd) * 100.0


genStockList :: [(T.Text, T.Text)] -> [StockListItem]
genStockList [] = []
genStockList ((n,i):sts) = StockListItem n i : genStockList sts


stocks :: [(T.Text, T.Text)]
stocks = [
      ("Activision Blizzard",  "ATVI")
    , ("Adobe Systems Incorporated",  "ADBE")
    , ("Akamai Technologies, Inc",  "AKAM")
    , ("Alexion Pharmaceuticals",  "ALXN")
    , ("Altera Corporation",  "ALTR")
    , ("Amazon.com, Inc.",  "AMZN")
    , ("Amgen Inc.",  "AMGN")
    , ("Apollo Group, Inc.",  "APOL")
    , ("Apple Inc.",  "AAPL")
    , ("Applied Materials, Inc.",  "AMAT")
    , ("Autodesk, Inc.",  "ADSK")
    , ("Automatic Data Processing, Inc.",  "ADP")
    , ("Baidu.com, Inc.",  "BIDU")
    , ("Bed Bath & Beyond Inc.",  "BBBY")
    , ("Biogen Idec, Inc",  "BIIB")
    , ("BMC Software, Inc.",  "BMC")
    , ("Broadcom Corporation",  "BRCM")
    , ("C. H. Robinson Worldwide, Inc.",  "CHRW")
    , ("CA, Inc.",  "CA")
    , ("Celgene Corporation",  "CELG")
    , ("Cephalon, Inc.",  "CEPH")
    , ("Cerner Corporation",  "CERN")
    , ("Check Point Software Technologies Ltd.",  "CHKP")
    , ("Cisco Systems, Inc.",  "CSCO")
    , ("Citrix Systems, Inc.",  "CTXS")
    , ("Cognizant Technology Solutions Corporation",  "CTSH")
    , ("Comcast Corporation",  "CMCSA")
    , ("Costco Wholesale Corporation",  "COST")
    , ("Ctrip.com International, Ltd.",  "CTRP")
    , ("Dell Inc.",  "DELL")
    , ("DENTSPLY International Inc.",  "XRAY")
    , ("DirecTV",  "DTV")
    , ("Dollar Tree, Inc.",  "DLTR")
    , ("eBay Inc.",  "EBAY")
    , ("Electronic Arts Inc.",  "ERTS")
    , ("Expedia, Inc.",  "EXPE")
    , ("Expeditors International of Washington, Inc.",  "EXPD")
    , ("Express Scripts, Inc.",  "ESRX")
    , ("F5 Networks, Inc.",  "FFIV")
    , ("Fastenal Company",  "FAST")
    , ("First Solar, Inc.",  "FSLR")
    , ("Fiserv, Inc.",  "FISV")
    , ("Flextronics International Ltd.",  "FLEX")
    , ("FLIR Systems, Inc.",  "FLIR")
    , ("Garmin Ltd.",  "GRMN")
    , ("Gilead Sciences, Inc.",  "GILD")
    , ("Google Inc.",  "GOOG")
    , ("Green Mountain Coffee Roasters, Inc.",  "GMCR")
    , ("Henry Schein, Inc.",  "HSIC")
    , ("Illumina, Inc.",  "ILMN")
    , ("Infosys Technologies",  "INFY")
    , ("Intel Corporation",  "INTC")
    , ("Intuit, Inc.",  "INTU")
    , ("Intuitive Surgical Inc.",  "ISRG")
    , ("Joy Global Inc.",  "JOYG")
    , ("KLA Tencor Corporation",  "KLAC")
    , ("Lam Research Corporation",  "LRCX")
    , ("Liberty Media Corporation, Interactive Series A",  "LINTA")
    , ("Life Technologies Corporation",  "LIFE")
    , ("Linear Technology Corporation",  "LLTC")
    , ("Marvell Technology Group, Ltd.",  "MRVL")
    , ("Mattel, Inc.",  "MAT")
    , ("Maxim Integrated Products",  "MXIM")
    , ("Microchip Technology Incorporated",  "MCHP")
    , ("Micron Technology, Inc.",  "MU")
    , ("Microsoft Corporation",  "MSFT")
    , ("Mylan, Inc.",  "MYL")
    , ("NetApp, Inc.",  "NTAP")
    , ("Netflix, Inc.",  "NFLX")
    , ("News Corporation, Ltd.",  "NWSA")
    , ("NII Holdings, Inc.",  "NIHD")
    , ("NVIDIA Corporation",  "NVDA")
    , ("O'Reilly Automotive, Inc.",  "ORLY")
    , ("Oracle Corporation",  "ORCL")
    , ("PACCAR Inc.",  "PCAR")
    , ("Paychex, Inc.",  "PAYX")
    , ("Priceline.com, Incorporated",  "PCLN")
    , ("Qiagen N.V.",  "QGEN")
    , ("QUALCOMM Incorporated",  "QCOM")
    , ("Research in Motion Limited",  "RIMM")
    , ("Ross Stores Inc.",  "ROST")
    , ("SanDisk Corporation",  "SNDK")
    , ("Seagate Technology Holdings",  "STX")
    , ("Sears Holdings Corporation",  "SHLD")
    , ("Sigma-Aldrich Corporation",  "SIAL")
    , ("Staples Inc.",  "SPLS")
    , ("Starbucks Corporation",  "SBUX")
    , ("Stericycle, Inc",  "SRCL")
    , ("Symantec Corporation",  "SYMC")
    , ("Teva Pharmaceutical Industries Ltd.",  "TEVA")
    , ("Urban Outfitters, Inc.",  "URBN")
    , ("VeriSign, Inc.",  "VRSN")
    , ("Vertex Pharmaceuticals",  "VRTX")
    , ("Virgin Media, Inc.",  "VMED")
    , ("Vodafone Group, plc.",  "VOD")
    , ("Warner Chilcott, Ltd.",  "WCRX")
    , ("Whole Foods Market, Inc.",  "WFM")
    , ("Wynn Resorts Ltd.",  "WYNN")
    , ("Xilinx, Inc.",  "XLNX")
    , ("Yahoo! Inc.",  "YHOO")
    ]
