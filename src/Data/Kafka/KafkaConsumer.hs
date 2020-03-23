{-# LANGUAGE ScopedTypeVariables #-}

module Data.Kafka.KafkaConsumer where

import           Control.Arrow        ((&&&))
import qualified Data.ByteString      as BS
import qualified Data.ByteString.UTF8 as BS
import qualified Data.Map             as M
import           Data.Monoid          ((<>))
import qualified Data.Text            as T
import qualified Data.Text.IO         as T
import           Kafka.Consumer

-- Global consumer properties
consumerProps :: String -> String -> ConsumerProperties
consumerProps brokerAddress consumerGroupId =
    extraProps (M.fromList [(T.pack "client.id",T.pack "rdkafka-haskell-consumer-tool")]) <>
    brokersList [BrokerAddress (T.pack brokerAddress)] <>
    groupId (ConsumerGroupId (T.pack consumerGroupId)) <>
    noAutoCommit <>
    setCallback (offsetCommitCallback printingOffsetCallback) <>
    logLevel KafkaLogInfo

-- Subscription to topics
consumerSub :: String -> Subscription
consumerSub topicName = topics [TopicName (T.pack topicName)] <> offsetReset Earliest

-- Running an example
readFromTopic ::
       String -> String -> String -> IO (Either KafkaError (ConsumerRecord (Maybe BS.ByteString) (Maybe BS.ByteString)))
readFromTopic brokerAddress topicName consumerGroupId = do
    let consumerProperties = consumerProps brokerAddress consumerGroupId
    let consumerTopic = consumerSub topicName
    print $ cpLogLevel consumerProperties
    print $ cpProps consumerProperties
    runConsumer consumerProperties consumerTopic processMessages

-------------------------------------------------------------------
processMessages :: KafkaConsumer -> IO (Either KafkaError (ConsumerRecord (Maybe BS.ByteString) (Maybe BS.ByteString)))
processMessages kafka = do
    msg1 <- pollMessage kafka (Timeout 5000)
    printRecord msg1
    if checkError msg1
        then do
            return msg1
        else do
            err <- commitAllOffsets OffsetCommit kafka
            res <- recursiveProcessMessages err
            return msg1
  where
    recursiveProcessMessages er =
        case er of
            Just e  -> return $ Left e
            Nothing -> processMessages kafka
    checkError msg =
        case msg of
            Left e  -> True
            Right e -> False
    printRecord msg =
        case msg of
            Left e -> print e
            Right e -> do
                putStrLn
                    "\nMessage Begin: ---------------------------------------------------------------------------------------------------------------"
                print (crTopic e)
                print (crPartition e)
                print (crOffset e)
                print (crTimestamp e)
                putStr "Key: "
                T.putStrLn (maybeToText $ crKey e)
                putStrLn "Value: "
                T.putStrLn (maybeToText $ crValue e)
                putStrLn
                    "Message End: ---------------------------------------------------------------------------------------------------------------\n"
    maybeToString m =
        case m of
            Just m' -> BS.toString m'
            Nothing -> "Nothing"
    maybeToText m =
        case m of
            Just m' -> T.pack $ BS.toString m'
            Nothing -> T.pack $ "Nothing"

printingOffsetCallback :: KafkaConsumer -> KafkaError -> [TopicPartition] -> IO ()
printingOffsetCallback _ e ps = do
    print ("Offsets callback:" ++ show e)
    mapM_ (print . (tpTopicName &&& tpPartition &&& tpOffset)) ps
