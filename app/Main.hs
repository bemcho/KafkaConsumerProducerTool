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
import qualified Data.ByteString.UTF8     as BU

-- | Change second argument inside of 'Action'.
mapAction :: (String -> String) -> Action -> Action
mapAction f (Send           x) = Send       (f x)

-- | Get second argument from 'Action'.
getSndArg :: Action -> String
getSndArg (Send           x) = x
-- | 'Value' holds textual representation of first argument reversed and
-- 'Action' to apply to it, which see.
data Value = Value String (Maybe Action)

-- | Action to apply to first argument and textual representation of second
-- argument reversed (if relevant).
data Action
  = Send       String

-- | The deleteEvent signal is emitted if a user requests that a toplevel
-- window is closed. The default handler for this signal destroys the window.
-- Calling 'widgetHide' and returning 'True' on reception of this signal will
-- cause the window to be hidden instead, so that it can later be shown again
-- without reconstructing it.
-- deleteEvent :: WidgetClass self => Signal self (EventM EAny Bool)

-- | Render given 'Value'.
--renderValue :: Value -> String
--renderValue (Value x action) =
--  g x ++ f a ++ (if null y then "" else g y)
--  where
--    (a, y) =
--      case action of
--        Nothing                   -> ("", "")
--        Just (Addition       arg) -> ("+", arg)
--        Just (Subtraction    arg) -> ("–", arg)
--        Just (Multiplication arg) -> ("*", arg)
--        Just (Division       arg) -> ("÷", arg)
--    f "" = ""
--    f l  = " " ++ l ++ " "
--    g "" = "0"
--    g xs = reverse xs

-- | Make calculator's display show given 'Value'.
updateDisplay :: Entry -> Value -> IO ()
updateDisplay display value =
  set display [ entryText := "Sent" ]

-- | Create a button and attach handler to it that mutates calculator's
-- state with given function.
mkButton  ::
     String            -- ^ Button label
  -> IO Button         -- ^ Resulting button object
mkButton label  = do
  btn <- buttonNew
  set btn [ buttonLabel := label ]
  return btn

-- | Emitted when the button has been activated (pressed and released).
-- buttonActivated :: ButtonClass self => Signal self (IO ())

-- | Exit the main event loop.
-- mainQuit :: IO ()

-- | Render given 'Value'.
renderValue :: Value -> String
renderValue (Value x action) =
  f a
  where
    (a, y) =
      case action of
        Nothing         -> ("", "")
        Just (Send arg) -> ("Sent", arg)
    f l  = " " ++ l ++ " "

sendToKafkaTopicFromUI :: Entry -> Entry -> Entry -> IO(Either KafkaError ())
sendToKafkaTopicFromUI kafkaUrlEntry kafkaTopicEntry kafkaMessageEntry = do
    kUrl <- entryGetText kafkaUrlEntry
    kTopic <- entryGetText kafkaTopicEntry
    kMessage <- entryGetText kafkaMessageEntry
    err <- sendToKafkaTopic kUrl kTopic (BU.fromString kMessage)
    forM_ err print
    return $ Right ()

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

  grid <- gridNew
  gridSetColumnHomogeneous grid True
  gridSetRowHomogeneous grid True  -- (2)
  gridSetRowSpacing grid 10

  let attach x y w h item = gridAttach grid item x y w h -- (3)
  attach 0 1 7 1 kafkaBrokerUrlFrame
  attach 0 2 7 1 kafkaTopicFrame
  attach 0 3 7 5 kafkaMessageFrame           -- (4)
  attach 0 15 7 1 sendButton

  containerAdd window grid
  window `on` deleteEvent $ do -- handler to run on window destruction
      liftIO mainQuit
      return False
  sendButton `on` buttonPressEvent $ do
      liftIO (sendToKafkaTopicFromUI kafkaBrokerUrl kafkaTopic kafkaMessage)
      return True
  widgetShowAll window
  mainGUI
