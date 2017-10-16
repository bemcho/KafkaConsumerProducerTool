module UI.Producer
    ( initProducer
    ) where

import           Control.Concurrent
import           Control.Monad.IO.Class
import           Data.Kafka.KafkaProducer
import           Graphics.UI.Gtk          hiding (Action, backspace)
import           UI.Utils

sendToKafkaTopicFromUI ::
       IO String -> IO String -> IO String -> IO String -> Statusbar -> ContextId -> Button -> Spinner -> IO ()
sendToKafkaTopicFromUI kafkaUrlInputString kafkaTopicInputString kafkaMessageKeyInputString kafkaMessageInputString statusBar statusBarId button spinner = do
    (v1, err1, kUrl) <- process kafkaUrlInputString "- Kafka Url can not be empty!"
    (v2, err2, kTopic) <- process kafkaTopicInputString " - Kafka Topic can not be empty!"
    (v3, err3, kMessageKey) <- process kafkaMessageKeyInputString " - Kafka Message Key can not be empty!"
    (v4, err4, kMessage) <- process kafkaMessageInputString " - Kafka Message can not be empty!"
    if v1 && v2 && v3 && v4
        then do
            debugMessage $ " - Start sending - message ... \n" ++ kMessage
            err <- sendToKafkaTopic kUrl kTopic (stringToByteStr kMessageKey) $ stringToByteStr kMessage
            debugMessage " - End sending - message ... "
            postGUISync (updateStatusBar statusBar statusBarId $ " - " ++ renderProducerError err)
            postGUISync (widgetSetSensitive button True)
            postGUISync (spinnerStop spinner)
            return ()
        else do
            postGUISync (updateStatusBar statusBar statusBarId $ err1 ++ err2 ++ err3 ++ err4)
            postGUISync (widgetSetSensitive button True)
            postGUISync (spinnerStop spinner)
            return ()

initProducer :: IO Window
initProducer = do
    window <- windowNew -- (2)
    set
        window
        [ windowTitle := "Kafka Producer Tool"
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
    zonedTime <- timestamp
    kafkaMessageKeyFrame <- frameNew
    frameSetLabel kafkaMessageKeyFrame "Kafka Message Key:"
    kafkaMessageKey <- entryNew
    set
        kafkaMessageKey
        [ entryEditable := True
        , entryXalign := 0 -- makes contents right-aligned
        , entryText := zonedTime
        ]
    containerAdd kafkaMessageKeyFrame kafkaMessageKey
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
    uuid <- getUUIDAsString
    buffer <- textViewGetBuffer kafkaMessage
    set
        buffer
        [ textBufferText := "{\n\t\"id\" : \"" ++ uuid ++ "\",\n\t\"key\" : \"somekey\",\n\t\"time\" : \"" ++ zonedTime ++
          "\",\n\t\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\n\t\"payload\" : \n\t{\n\t\"tmessage\" : \"Helllooo kafkaaaa!Haskellll is awesome\"\n\t}\n}"
        ]

    scrwin <- scrolledWindowNew Nothing Nothing
    scrolledWindowAddWithViewport scrwin kafkaMessage
    containerAdd kafkaMessageFrame scrwin
    sendButton <- mkButton "Send"
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
    gridSetRowHomogeneous grid True -- (2)
    gridSetRowSpacing grid 5

    let attach x y w h item = gridAttach grid item x y w h -- (3)
    attach 0 1 7 1 kafkaBrokerUrlFrame
    attach 0 2 7 1 kafkaTopicFrame
    attach 0 3 7 1 kafkaMessageKeyFrame
    attach 0 4 7 1 spinner -- (4)
    attach 0 5 7 1 sendButton
    attach 0 6 7 1 actionStatusBarFrame
    attach 0 7 7 10 kafkaMessageFrame
    containerAdd window grid
    window `on` deleteEvent $ -- handler to run on window destruction
        liftIO mainQuit >>
        return False
    sendButton `on` buttonActivated $ do
        widgetSetSensitive sendButton False
        spinnerStart spinner
        forkIO
            (sendToKafkaTopicFromUI
                 (entryGetText kafkaBrokerUrl)
                 (entryGetText kafkaTopic)
                 (entryGetText kafkaMessageKey)
                 (getTextFromTextBuffer buffer)
                 actionStatusBar
                 actionStatusBarId
                 sendButton
                 spinner)
        return ()
    return window
