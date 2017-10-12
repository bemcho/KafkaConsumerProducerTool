module UI.Consumer
    ( initConsumer
    ) where

import           Control.Monad.IO.Class
import           Data.Kafka.KafkaConsumer
import           Graphics.UI.Gtk             hiding (Action, backspace)
import           Graphics.UI.Gtk.Layout.Grid
import           UI.Utils

startReadingFromKafkaTopicFromUI ::
       IO String -> IO String -> IO String -> IO String -> IO String -> Statusbar -> ContextId -> IO ()
startReadingFromKafkaTopicFromUI kafkaUrlInputString kafkaTopicInputString kafkaConsumerGroupIdInputString kafkaOffsetStartInputString kafkaOffsetEndInputString statusBar statusBarId = do
    (v1, err1, kUrl) <- process kafkaUrlInputString "- Kafka Url can not be empty!"
    (v2, err2, kTopic) <- process kafkaTopicInputString " - Kafka Topic can not be empty!"
    (v3, err3, kConsumerGroupId) <- process kafkaConsumerGroupIdInputString " - Kafka Consumer Group Id can not be empty!"
    (v4, err4, kOffsetStart) <- process kafkaOffsetStartInputString " - Kafka Offset Start can not be empty!"
    (v5, err5, kOffsetEnd) <- process kafkaOffsetEndInputString " - Kafka Offset End can not be empty!"
    if v1 && v2 && v3 && v4 && v5
        then do
            debugMessage $ " - Start reading - message from \n" ++ kTopic
            err <-
                readFromTopic kUrl kTopic kConsumerGroupId (read kOffsetStart :: Integer) (read kOffsetEnd :: Integer)
            --msgId <- updateStatusBar statusBar statusBarId $ " - " ++ renderValue err
            return ()
        else do
            msgId <- updateStatusBar statusBar statusBarId $ err1 ++ err2 ++ err3 ++ err4 ++ err5
            return ()

initConsumer :: IO Window
initConsumer = do
    window <- windowNew -- (2)
    set
        window
        [ windowTitle := "Kafka Consumer Tool"
        , windowResizable := True
        , windowDefaultWidth := 400
        , windowDefaultHeight := 400
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
    kafkaConsumerGroupIdFrame <- frameNew
    frameSetLabel kafkaConsumerGroupIdFrame "Consumer Group Id:"
    kafkaConsumerGroupId <- entryNew
    set
        kafkaConsumerGroupId
        [ entryEditable := True
        , entryXalign := 0 -- makes contents right-aligned
        , entryText := "rdkafka_consumer_group"
        ]
    containerAdd kafkaConsumerGroupIdFrame kafkaConsumerGroupId
    kafkaOffsetStartFrame <- frameNew
    frameSetLabel kafkaOffsetStartFrame "Kafka Topic Offset Start:"
    kafkaOffsetStart <- entryNew
    set
        kafkaOffsetStart
        [ entryEditable := True
        , entryXalign := 0 -- makes contents right-aligned
        , entryText := "0"
        ]
    containerAdd kafkaOffsetStartFrame kafkaOffsetStart
    kafkaOffsetEndFrame <- frameNew
    frameSetLabel kafkaOffsetEndFrame "Kafka Topic Offset End:"
    kafkaOffsetEnd <- entryNew
    set
        kafkaOffsetEnd
        [ entryEditable := True
        , entryXalign := 0 -- makes contents right-aligned
        , entryText := "100"
        ]
    containerAdd kafkaOffsetEndFrame kafkaOffsetEnd
    startButton <- mkButton "Start"
    actionStatusBar <- statusbarNew
    actionStatusBarFrame <- frameNew
    frameSetLabel actionStatusBarFrame "Status:"
    actionStatusBarId <- statusbarGetContextId actionStatusBar "Kafka"
    timeNow <- formattedTimeStamp
    statusbarPush actionStatusBar actionStatusBarId $ timeNow ++ " - Just started ..."
    containerAdd actionStatusBarFrame actionStatusBar
    grid <- gridNew
    gridSetColumnHomogeneous grid False
    gridSetRowHomogeneous grid True -- (2)
    gridSetRowSpacing grid 10
    let attach x y w h item = gridAttach grid item x y w h -- (3)
    attach 0 1 7 1 kafkaBrokerUrlFrame
    attach 0 2 7 1 kafkaTopicFrame
    attach 0 3 7 1 kafkaConsumerGroupIdFrame
    attach 0 4 1 1 kafkaOffsetStartFrame
    attach 2 4 1 1 kafkaOffsetEndFrame
    attach 0 14 7 1 startButton
    attach 0 15 7 1 actionStatusBarFrame
    containerAdd window grid
    window `on` deleteEvent $ -- handler to run on window destruction
     do
        liftIO mainQuit
        return False
    startButton `on` buttonPressEvent $ do
        liftIO
            (startReadingFromKafkaTopicFromUI
                 (entryGetText kafkaBrokerUrl)
                 (entryGetText kafkaTopic)
                 (entryGetText kafkaConsumerGroupId)
                 (entryGetText kafkaOffsetStart)
                 (entryGetText kafkaOffsetEnd)
                 actionStatusBar
                 actionStatusBarId)
        return False
    return window
