module UI.Consumer
    ( initConsumer
    ) where

import           Control.Concurrent
import           Control.Monad.IO.Class
import           Data.Kafka.KafkaConsumer
import           Graphics.UI.Gtk          hiding (Action, backspace)
import           UI.Utils

startReadingFromKafkaTopicFromUI :: IO String -> IO String -> IO String -> Statusbar -> ContextId -> Button -> Spinner -> IO ()
startReadingFromKafkaTopicFromUI kafkaUrlInputString kafkaTopicInputString kafkaConsumerGroupIdInputString statusBar statusBarId button spinner = do
    (v1, err1, kUrl) <- process kafkaUrlInputString "- Kafka Url can not be empty!"
    (v2, err2, kTopic) <- process kafkaTopicInputString " - Kafka Topic can not be empty!"
    (v3, err3, kConsumerGroupId) <-
        process kafkaConsumerGroupIdInputString " - Kafka Consumer Group Id can not be empty!"
    if v1 && v2 && v3
        then do
            debugMessage $ " - Start reading - message from: " ++ kTopic
            err <- readFromTopic kUrl kTopic kConsumerGroupId
            postGUISync (updateStatusBar statusBar statusBarId $ " - " ++ renderConsumerError err)
            postGUISync (widgetSetSensitive button True)
            postGUISync (spinnerStop spinner)
            return ()
        else do
            postGUISync (updateStatusBar statusBar statusBarId $ err1 ++ err2 ++ err3)
            postGUISync (widgetSetSensitive button True)
            postGUISync (spinnerStop spinner)
            return ()

initConsumer :: IO Window
initConsumer = do
    window <- windowNew -- (2)
    set
        window
        [ windowTitle := "Kafka Consumer Tool"
        , windowResizable := False
        , windowDefaultWidth := 800
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
    startButton <- mkButton "Consume Messages"
    actionStatusBar <- statusbarNew
    actionStatusBarFrame <- frameNew
    frameSetLabel actionStatusBarFrame "Status:"
    actionStatusBarId <- statusbarGetContextId actionStatusBar "Kafka"
    timeNow <- formattedTimeStamp
    statusbarPush actionStatusBar actionStatusBarId $ timeNow ++ " - Just started ..."
    containerAdd actionStatusBarFrame actionStatusBar
    spinner <- spinnerNew
    grid <- gridNew
    gridSetColumnHomogeneous grid True
    gridSetRowHomogeneous grid False -- (2)
    gridSetRowSpacing grid 10
    let attach x y w h item = gridAttach grid item x y w h -- (3)
    attach 0 1 7 1 kafkaBrokerUrlFrame
    attach 0 2 7 1 kafkaTopicFrame
    attach 0 3 7 1 kafkaConsumerGroupIdFrame
    attach 0 4 7 1 startButton
    attach 0 5 7 1 actionStatusBarFrame
    attach 0 6 7 1 spinner
    containerAdd window grid
    window `on` deleteEvent $ -- handler to run on window destruction
        liftIO mainQuit >>
        return False
    startButton `on` buttonActivated $ do
        widgetSetSensitive startButton False
        spinnerStart spinner
        forkIO
            (startReadingFromKafkaTopicFromUI
                 (entryGetText kafkaBrokerUrl)
                 (entryGetText kafkaTopic)
                 (entryGetText kafkaConsumerGroupId)
                 actionStatusBar
                 actionStatusBarId
                 startButton
                 spinner)
        return ()
    return window
