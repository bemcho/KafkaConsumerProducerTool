module Main where

import Control.Monad
import Control.Monad.IO.Class
import Data.IORef
import Graphics.UI.Gtk hiding (Action, backspace)
import Graphics.UI.Gtk.Layout.Grid
import Graphics.UI.Gtk.Gdk.Display
import Graphics.UI.Gtk.Buttons.Button
import Graphics.UI.Gtk.Gdk.EventM
import Data.Kafka.KafkaProducer
import Kafka.Types
import qualified Data.ByteString.UTF8     as BU

-- | Create a button and attach handler to it that mutates calculator's
-- state with given function.
mkButton  ::
     String            -- ^ Button label
  -> IO Button         -- ^ Resulting button object
mkButton label  = do
  btn <- buttonNew
  set btn [ buttonLabel := label]
  return btn

-- | Emitted when the button has been activated (pressed and released).
-- buttonActivated :: ButtonClass self => Signal self (IO ())

-- | Exit the main event loop.
-- mainQuit :: IO ()

-- | Render given 'Value'.
renderValue :: (Either KafkaError ()) -> String
renderValue err = do
  case err of
    Left  val -> "Kafka Said" ++  (show err)
    Right val -> "Send to kafka Succeeded"

sendToKafkaTopicFromUI :: Entry -> Entry -> Entry -> Statusbar -> ContextId -> IO()
sendToKafkaTopicFromUI kafkaUrlEntry kafkaTopicEntry kafkaMessageEntry statusBar statusBarId = do
    statusbarPop statusBar statusBarId
    kUrl <- entryGetText kafkaUrlEntry
    kTopic <- entryGetText kafkaTopicEntry
    kMessage <- entryGetText kafkaMessageEntry
    err <- sendToKafkaTopic kUrl kTopic (BU.fromString kMessage)
    timeNow <- timestamp
    msgId <- statusbarPush statusBar statusBarId $ timeNow ++ " - " ++ (renderValue err)
    return ()

main :: IO ()
main = do
  void initGUI          -- (1)

  window <- windowNew   -- (2)
  set window [ windowTitle         := "Kafka Producer Consumer Tool"
               , windowResizable    := True
               , windowDefaultWidth  := 800
               , windowDefaultHeight := 800
               , containerBorderWidth := 10
               ]

  kafkaBrokerUrlFrame <- frameNew
  frameSetLabel kafkaBrokerUrlFrame "Kafka Broker URL:"
  kafkaBrokerUrl <- entryNew
  set kafkaBrokerUrl [ entryEditable := True
                  , entryXalign   := 0 -- makes contents right-aligned
                  , entryText     := "localhost:9092" ]
  containerAdd kafkaBrokerUrlFrame kafkaBrokerUrl

  kafkaTopicFrame <- frameNew
  frameSetLabel kafkaTopicFrame "Kafka Target Topic:"
  kafkaTopic <- entryNew
  set kafkaTopic [ entryEditable := True
                  , entryXalign   := 0 -- makes contents right-aligned
                  , entryText     := "test_kafka_topic" ]
  containerAdd kafkaTopicFrame kafkaTopic

  kafkaMessageFrame <- frameNew
  frameSetLabel kafkaMessageFrame "Kafka Message:"
  kafkaMessage <- entryNew
  set kafkaMessage [ entryEditable := True
                , entryXalign   := 0 -- makes contents right-aligned
                , entryText     := "{id : someId,key: somekey, payload : {message : \"Helllooo kafkaaaa!Haskellll is awesome\"}}" ]
  containerAdd kafkaMessageFrame kafkaMessage

  sendButton <- mkButton "Send"

  actionStatusBar <- statusbarNew
  actionStatusBarFrame <- frameNew
  frameSetLabel actionStatusBarFrame "Status:"
  actionStatusBarId <- statusbarGetContextId actionStatusBar "Kafka"
  timeNow <- timestamp
  statusbarPush actionStatusBar actionStatusBarId $ timeNow ++ " - " ++ "Just started ..."
  containerAdd actionStatusBarFrame actionStatusBar

  grid <- gridNew
  gridSetColumnHomogeneous grid True
  gridSetRowHomogeneous grid True  -- (2)
  gridSetRowSpacing grid 10

  let attach x y w h item = gridAttach grid item x y w h -- (3)
  attach 0 1 7 1 kafkaBrokerUrlFrame
  attach 0 2 7 1 kafkaTopicFrame
  attach 0 3 7 5 kafkaMessageFrame           -- (4)
  attach 0 15 7 1 sendButton
  attach 0 16 7 1 actionStatusBarFrame

  containerAdd window grid
  window `on` deleteEvent $ do -- handler to run on window destruction
      liftIO mainQuit
      return False
  sendButton `on` buttonPressEvent $ do
      liftIO (sendToKafkaTopicFromUI kafkaBrokerUrl kafkaTopic kafkaMessage actionStatusBar actionStatusBarId)
      return True
  widgetShowAll window
  mainGUI
