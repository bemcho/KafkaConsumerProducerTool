module UI.Utils
  ( mkButton
  , renderProducerError
  , renderConsumerError
  , getTextFromTextBuffer
  , getUUIDAsString
  , KafkaError
  , stringToByteStr
  , byteStringToString
  , validate
  , report
  , process
  , updateStatusBar
  , timestamp
  , formattedTimeStamp
  , debugMessage
  , getSpinButtonValue
  ) where

import qualified Data.ByteString.UTF8             as BU
import           Data.Time
import qualified Data.UUID                        as UUID
import qualified Data.UUID.V1                     as UUID.V1
import           Graphics.UI.Gtk                  (AttrOp ((:=)), ContextId,
                                                   MessageId, Statusbar,
                                                   TextBuffer, set,
                                                   statusbarPop, statusbarPush,
                                                   textBufferGetIterAtLine,
                                                   textBufferGetLineCount,
                                                   textBufferGetSlice,
                                                   textBufferGetBounds)
import           Graphics.UI.Gtk.Buttons.Button
import           Graphics.UI.Gtk.Entry.SpinButton
import           Kafka.Consumer.Types
import           Kafka.Types

-- | Create a button and attach handler to it that mutates calculator's
-- state with given function.
mkButton ::
     String -- ^ Button label
  -> IO Button -- ^ Resulting button object
mkButton label = do
  btn <- buttonNew
  set btn [buttonLabel := label]
  return btn

-- | Render given 'Value'.
renderProducerError :: Either KafkaError () -> String
renderProducerError err =
  case err of
    Left val  -> "Kafka Said - " ++ show err
    Right val -> "Send Succeeded"

renderConsumerError :: Either KafkaError (ConsumerRecord (Maybe BU.ByteString) (Maybe BU.ByteString)) -> String
renderConsumerError err =
  case err of
    Left val  -> "Kafka Said - " ++ show err
    Right val -> "Read Succeeded"

getTextFromTextBuffer :: TextBuffer -> IO String
getTextFromTextBuffer b = do
  (bBeginIt,bEndIt) <- textBufferGetBounds b
  textBufferGetSlice b bBeginIt bEndIt True

getUUIDAsString :: IO String
getUUIDAsString = do
  uuid <- UUID.V1.nextUUID
  return $ f uuid
  where
    f :: Maybe UUID.UUID -> String
    f u =
      case u of
        Just u' -> UUID.toString u'
        Nothing -> "meh-meh-beh"

stringToByteStr :: String -> BU.ByteString
stringToByteStr = BU.fromString

byteStringToString :: BU.ByteString -> String
byteStringToString = BU.toString

process :: IO String -> String -> IO (Bool, String, String)
process inputValue errMsg = do
  value <- inputValue
  v1 <- validate inputValue
  errorMsg <- report v1 errMsg
  return (v1, errorMsg, value)

report :: Bool -> String -> IO String
report False msg = return msg
report True msg  = return ""

validate :: IO String -> IO Bool
validate inputValue = do
  eText <- inputValue
  return (not $ null eText)

updateStatusBar :: Statusbar -> ContextId -> String -> IO MessageId
updateStatusBar statusBar statusBarId msg = do
  timeNow <- formattedTimeStamp
  statusbarPop statusBar statusBarId
  statusbarPush statusBar statusBarId $ timeNow ++ msg

-- time utils
timestamp :: IO String
timestamp = do
  zonedTime <- getZonedTime
  return $ insertColon $ formattedZonedTimeNow zonedTime
  where
    formattedZonedTimeNow :: ZonedTime -> String
    formattedZonedTimeNow = formatTime defaultTimeLocale $ iso8601DateFormat (Just "%T%z")
    insertColon str = take ((-) (length str) 2) str ++ (colonOrEmptyStr $ getCharAt str 3) ++ drop ((-) (length str) 2) str
    getCharAt tt n = (tt !! ((-) (length tt) n))
    colonOrEmptyStr ':' = ""
    colonOrEmptyStr _   = ":"

formattedTimeStamp :: IO String
formattedTimeStamp = do
  timeNow <- timestamp
  return $ "[" ++ timeNow ++ "]"

debugMessage :: String -> IO ()
debugMessage message = do
  beginTime <- formattedTimeStamp
  putStrLn $ beginTime ++ message
  return ()

getSpinButtonValue :: SpinButton -> IO Double
getSpinButtonValue btn = do
  spinButtonUpdate btn
  spinButtonGetValue btn
