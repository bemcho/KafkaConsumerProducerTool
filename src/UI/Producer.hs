module UI.Producer
    ( initProducer
    ) where

import           Control.Monad.IO.Class
import           Data.Kafka.KafkaProducer
import           Graphics.UI.Gtk             hiding (Action, backspace)
import           Graphics.UI.Gtk.Gdk.EventM
import           Graphics.UI.Gtk.Layout.Grid
import           UI.Utils

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
            err <- sendToKafkaTopic kUrl kTopic $ stringToByteStr kMessage
            timeNow <- formattedTimeStamp
            statusbarPop statusBar statusBarId
            msgId <- statusbarPush statusBar statusBarId $ timeNow ++ " - " ++ renderValue err
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
    report :: Bool -> String -> IO String
    report False msg = return msg
    report True msg  = return ""
    validate :: IO String -> IO Bool
    validate entry = do
        eText <- entry
        return $ not $ null eText

initProducer :: IO Window
initProducer = do
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
        [ textBufferText := "{\n\tid : " ++ uuid ++ ",\n\tkey : somekey,\n\ttime : " ++ zonedTime ++
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
    return window
