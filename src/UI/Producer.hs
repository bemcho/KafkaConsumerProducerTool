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
sendToKafkaTopicFromUI kafkaUrlInputString kafkaTopicInputString kafkaMessageInputString statusBar statusBarId = do
    (v1, err1, kUrl) <- process kafkaUrlInputString "- Kafka Url can not be empty!"
    (v2, err2, kTopic) <- process kafkaTopicInputString " - Kafka Topic can not be empty!"
    (v3, err3, kMessage) <- process kafkaMessageInputString " - Kafka Message can not be empty!"
    if v1 && v2 && v3
        then do
            kTopicKey <- timestamp
            debugMessage $ " - Start sending - message ... \n" ++  kMessage
            err <- sendToKafkaTopic kUrl kTopic (stringToByteStr kTopicKey) $ stringToByteStr kMessage
            debugMessage " - End sending - message ... "
            msgId <- updateStatusBar statusBar statusBarId $ " - " ++ renderValue err
            return ()
        else do
            msgId <- updateStatusBar statusBar statusBarId $ err1 ++ err2 ++ err3
            return ()

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
