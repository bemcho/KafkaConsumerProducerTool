module Main where

import           Control.Monad
import           Graphics.UI.Gtk        hiding (Action, backspace)
import           UI.Producer

main :: IO ()
main = do
    void initGUI -- (1)
    windowProducer <- initProducer
    widgetShowAll windowProducer
    mainGUI
