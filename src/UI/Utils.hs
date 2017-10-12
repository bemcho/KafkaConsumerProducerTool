module UI.Utils
    ( mkButton
    , renderValue
    , getText
    , getUUIDAsString
    , KafkaError
    , stringToByteStr
    , byteStringToString
    ) where

import qualified Data.ByteString.UTF8           as BU
import qualified Data.UUID                      as UUID
import qualified Data.UUID.V1                   as UUID.V1
import           Graphics.UI.Gtk                (AttrOp ((:=)), TextBuffer, set,
                                                 textBufferGetIterAtLine,
                                                 textBufferGetLineCount,
                                                 textBufferGetText)
import           Graphics.UI.Gtk.Buttons.Button
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
renderValue :: Either KafkaError () -> String
renderValue err =
    case err of
        Left val  -> "Kafka Said - " ++ show err
        Right val -> "Send to kafka Succeeded"

getText :: TextBuffer -> IO String
getText b = do
    lcnt <- textBufferGetLineCount b
    bBeginIt <- textBufferGetIterAtLine b 0
    bEndIt <- textBufferGetIterAtLine b lcnt
    result <- textBufferGetText b bBeginIt bEndIt True
    return result

getUUIDAsString :: IO String
getUUIDAsString = do
    uuid <- UUID.V1.nextUUID
    return $ f uuid
  where
    f :: Maybe UUID.UUID -> String
    f u =
        case u of
            Just u' -> UUID.toString $ u'
            Nothing -> "meh-meh-beh"

stringToByteStr = BU.fromString

byteStringToString = BU.toString
