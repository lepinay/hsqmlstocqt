{-# LANGUAGE DeriveDataTypeable, OverloadedStrings, TypeFamilies #-}
module GUI.StocQt where

import Control.Concurrent
import qualified Data.Text as T
import Data.Typeable
import Graphics.QML

-- | QML Context Object.
data StocQt = StocQt { stockModel     :: ObjRef StockModel
                     , stockListModel :: [ObjRef StockListItem]
                     , stockSettings  :: ObjRef StockSettings
                     } deriving Typeable

data StockModel = StockModel { stockId        :: MVar T.Text
                             , stockName      :: MVar T.Text
                             , stockDataCycle :: MVar T.Text
                             , ready          :: MVar Bool
                             } deriving Typeable

type ChartType = T.Text
data StockSettings = StockSettings { chartType :: MVar ChartType
                                   } deriving Typeable

data StockListItem = StockListItem { name        :: T.Text
                                   , stockItemId :: T.Text
                                   } deriving (Show, Typeable)

-- Signals
data StockIdChanged deriving Typeable
data StockNameChanged deriving Typeable
data StockDataCycleChanged deriving Typeable
data ReadyChanged deriving Typeable
data ChartTypeChanged deriving Typeable

instance DefaultClass StocQt where
    classMembers = [
              defPropertyRO "stockModel" $ return . stockModel . fromObjRef
            , defPropertyRO "stockListModel" $ return . stockListModel . fromObjRef
            , defPropertyRO "stockSettings" $ return . stockSettings . fromObjRef
            ]

instance DefaultClass StockModel where
    classMembers = [
              defPropertySigRW "stockId" (Proxy :: Proxy StockIdChanged) (getter stockId) setStockId
            , defPropertySigRW "stockName" (Proxy :: Proxy StockNameChanged) (getter stockName) setStockName
            , defPropertySigRW "stockDataCycle" (Proxy :: Proxy StockDataCycleChanged) (getter stockDataCycle) setStockDataCycle
            , defPropertySigRW "ready" (Proxy :: Proxy ReadyChanged) (getter ready) setReady
            ]

instance DefaultClass StockListItem where
    classMembers = [
              defPropertyRO "name" $ return . name . fromObjRef
            , defPropertyRO "stockId" $ return . stockItemId . fromObjRef
            ]

instance DefaultClass StockSettings where
    classMembers = [
              defPropertySigRW "chartType" (Proxy :: Proxy ChartTypeChanged) (getter chartType) setChartType
            ]

instance SignalKeyClass StockIdChanged where
    type SignalParams StockIdChanged = IO ()

instance SignalKeyClass StockNameChanged where
    type SignalParams StockNameChanged = IO ()

instance SignalKeyClass StockDataCycleChanged where
    type SignalParams StockDataCycleChanged = IO ()

instance SignalKeyClass ReadyChanged where
    type SignalParams ReadyChanged = IO ()

instance SignalKeyClass ChartTypeChanged where
    type SignalParams ChartTypeChanged = IO ()

getter :: (tt -> MVar a) -> ObjRef tt -> IO a
getter gtr = readMVar . gtr . fromObjRef

setStockId :: ObjRef StockModel -> T.Text -> IO ()
setStockId sm sid = modifyMVar_ (stockId $ fromObjRef sm) $ \_ ->
        fireSignal (Proxy :: Proxy StockIdChanged) sm >> return sid

setStockName :: ObjRef StockModel -> T.Text -> IO ()
setStockName sm sn = modifyMVar_ (stockName $ fromObjRef sm) $ \_ ->
        fireSignal (Proxy :: Proxy StockNameChanged) sm >> return sn

setStockDataCycle :: ObjRef StockModel -> T.Text -> IO ()
setStockDataCycle sm sdc = modifyMVar_ (stockDataCycle $ fromObjRef sm) $ \_ ->
        fireSignal (Proxy :: Proxy StockDataCycleChanged) sm >> return sdc

setReady :: ObjRef StockModel -> Bool -> IO ()
setReady sm r = modifyMVar_ (ready $ fromObjRef sm) $ \_ ->
        fireSignal (Proxy :: Proxy StockDataCycleChanged) sm >> return r

setChartType :: ObjRef StockSettings -> ChartType -> IO ()
setChartType ss ct = modifyMVar_ (chartType $ fromObjRef ss) $ \_ ->
        fireSignal (Proxy :: Proxy ChartTypeChanged) ss >> return ct

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
