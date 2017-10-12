module Main where

import           Control.Monad
import           Control.Monad.IO.Class
import qualified Data.ByteString.UTF8   as BU
import           Graphics.UI.Gtk        hiding (Action, backspace)
import           UI.Producer

main :: IO ()
main = do
    void initGUI -- (1)
    windowProducer <- initProducer
    widgetShowAll windowProducer
    mainGUI
