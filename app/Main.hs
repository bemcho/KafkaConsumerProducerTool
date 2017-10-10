module Main where

import           Control.Monad
import           Control.Monad.IO.Class
import qualified Data.ByteString.UTF8           as BU
import           Data.IORef
import           Data.Kafka.KafkaProducer
import           Data.Strings
import           Graphics.UI.Gtk                hiding (Action, backspace)
import           Graphics.UI.Gtk.Buttons.Button
import           Graphics.UI.Gtk.Gdk.Display
import           Graphics.UI.Gtk.Gdk.EventM
import           Graphics.UI.Gtk.Layout.Grid
import           Kafka.Types
import qualified Data.UUID                   as UUID
import qualified Data.UUID.V1                as UUID.V1

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
renderValue :: Either KafkaError () -> String
renderValue err = do
    case err of
        Left val  -> "Kafka Said - " ++ (show err)
        Right val -> "Send to kafka Succeeded"

sendToKafkaTopicFromUI :: IO String -> IO String -> IO String -> Statusbar -> ContextId -> IO ()
sendToKafkaTopicFromUI kafkaUrlEntry kafkaTopicEntry kafkaMessageEntry statusBar statusBarId = do
    v1 <- process kafkaUrlEntry "- Kafka Url can not be empty!"
    v2 <- process kafkaTopicEntry " - Kafka Topic can not be empty!"
    v3 <- process kafkaMessageEntry " - Kafka Message can not be empty!"
    if fst v1 && fst v2 && fst v3
        then do
            kUrl <- kafkaUrlEntry
            kTopic <- kafkaTopicEntry
            kMessage <- kafkaMessageEntry
            err <- sendToKafkaTopic kUrl kTopic $ BU.fromString kMessage
            timeNow <- formattedTimeStamp
            statusbarPop statusBar statusBarId
            msgId <- statusbarPush statusBar statusBarId $ timeNow ++ " - " ++ (renderValue err)
            return ()
        else do
            timeNow <- formattedTimeStamp
            statusbarPop statusBar statusBarId
            msgId <- statusbarPush statusBar statusBarId $ timeNow ++ snd v1 ++ snd v2 ++ snd v3
            return ()
  where
    process :: IO String -> String -> IO (Bool, String)
    process ent msg = do
        v1 <- validate ent
        res <- report v1 msg
        return (v1, res)
    report :: Bool -> String -> IO (String)
    report False msg = return msg
    report True msg  = return ""
    validate :: IO String -> IO (Bool)
    validate entry = do
        eText <- entry
        return $ not $ strNull eText

main :: IO ()
main = do
    void initGUI -- (1)
    window <- windowNew -- (2)
    set
        window
        [ windowTitle := "Kafka Producer Consumer Tool"
        , windowResizable := True
        , windowDefaultWidth := 800
        , windowDefaultHeight := 800
        , containerBorderWidth := 10
        ]
    kafkaBrokerUrlFrame <- frameNew
    frameSetLabel kafkaBrokerUrlFrame "Kafka Broker URL:"
    kafkaBrokerUrl <- entryNew
    set
        kafkaBrokerUrl
        [ entryEditable := True
        , entryXalign := 0 -- makes contents right-aligned
        , entryText := "localhost:9092"
        ]
    containerAdd kafkaBrokerUrlFrame kafkaBrokerUrl
    kafkaTopicFrame <- frameNew
    frameSetLabel kafkaTopicFrame "Kafka Target Topic:"
    kafkaTopic <- entryNew
    set
        kafkaTopic
        [ entryEditable := True
        , entryXalign := 0 -- makes contents right-aligned
        , entryText := "test_kafka_topic"
        ]
    containerAdd kafkaTopicFrame kafkaTopic
    kafkaMessageFrame <- frameNew
    frameSetLabel kafkaMessageFrame "Kafka Message:"
    kafkaMessage <- textViewNew
    set
        kafkaMessage
        [ textViewCursorVisible := True
        , textViewEditable := True -- makes contents right-aligned
        , textViewOverwrite := True
        , textViewAcceptsTab := True
        , textViewIndent := 4
        ]
    zonedTime <- timestamp
    uuid <- getUUIDAsString
    buffer <- textViewGetBuffer kafkaMessage
    set
        buffer
        [ textBufferText := "{\n\tid : "++  uuid ++",\n\tkey : somekey,\n\ttime : " ++ zonedTime ++
          ",\n\tpayload : \n\t{\n\t\tmessage : \"Helllooo kafkaaaa!Haskellll is awesome\"\n\t}\n}"
        ]
    containerAdd kafkaMessageFrame kafkaMessage
    sendButton <- mkButton "Send"
    actionStatusBar <- statusbarNew
    actionStatusBarFrame <- frameNew
    frameSetLabel actionStatusBarFrame "Status:"
    actionStatusBarId <- statusbarGetContextId actionStatusBar "Kafka"
    timeNow <- formattedTimeStamp
    statusbarPush actionStatusBar actionStatusBarId $ timeNow ++ " - Just started ..."
    containerAdd actionStatusBarFrame actionStatusBar
    grid <- gridNew
    gridSetColumnHomogeneous grid True
    gridSetRowHomogeneous grid True -- (2)
    gridSetRowSpacing grid 10
    let attach x y w h item = gridAttach grid item x y w h -- (3)
    attach 0 1 7 1 kafkaBrokerUrlFrame
    attach 0 2 7 1 kafkaTopicFrame
    attach 0 3 7 10 kafkaMessageFrame -- (4)
    attach 0 15 7 1 sendButton
    attach 0 16 7 1 actionStatusBarFrame
    containerAdd window grid
    window `on` deleteEvent $ -- handler to run on window destruction
     do
        liftIO mainQuit
        return False
    sendButton `on` buttonPressEvent $ do
        liftIO
            (sendToKafkaTopicFromUI
                 (entryGetText kafkaBrokerUrl)
                 (entryGetText kafkaTopic)
                 (getText buffer)
                 actionStatusBar
                 actionStatusBarId)
        return False
    widgetShowAll window
    mainGUI

getText :: TextBuffer -> IO String
getText b = do
    lcnt <- textBufferGetLineCount b
    bBeginIt <- textBufferGetIterAtLine b 0
    bEndIt <- textBufferGetIterAtLine b lcnt
    result <- textBufferGetText b bBeginIt bEndIt True
    return $ result

getUUIDAsString :: IO String
getUUIDAsString =do
    uuid <- UUID.V1.nextUUID
    return $ f uuid
    where
        f::Maybe UUID.UUID -> String
        f u =
            case u of
              Just u' -> UUID.toString $  u'
              Nothing  ->  "meh-meh-beh"