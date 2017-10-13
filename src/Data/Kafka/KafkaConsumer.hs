{-# LANGUAGE ScopedTypeVariables #-}

module Data.Kafka.KafkaConsumer where

import qualified Data.ByteString            as BS
import           Control.Arrow  ((&&&))
import           Data.Monoid    ((<>))
import           Kafka.Consumer

-- Global consumer properties
consumerProps :: String -> String -> ConsumerProperties
consumerProps brokerAddress consumerGroupId =
    brokersList [BrokerAddress brokerAddress] <> groupId (ConsumerGroupId consumerGroupId) <> noAutoCommit <>
    setCallback (rebalanceCallback printingRebalanceCallback) <>
    setCallback (offsetCommitCallback printingOffsetCallback) <>
    logLevel KafkaLogInfo

-- Subscription to topics
consumerSub :: String -> Subscription
consumerSub topicName = topics [TopicName topicName] <> offsetReset Latest

-- Running an example
readFromTopic :: String -> String -> String -> IO (Either KafkaError (ConsumerRecord (Maybe BS.ByteString) (Maybe BS.ByteString)))
readFromTopic brokerAddress topicName consumerGroupId  = do
    let consumerProperties = (consumerProps brokerAddress consumerGroupId)
    let consumerTopic = consumerSub topicName
    print $ cpLogLevel consumerProperties
    runConsumer consumerProperties consumerTopic processMessages

-------------------------------------------------------------------
processMessages :: KafkaConsumer ->  IO (Either KafkaError (ConsumerRecord (Maybe BS.ByteString) (Maybe BS.ByteString)))
processMessages kafka  = do
    msg1 <- pollMessage kafka (Timeout 1000)
    putStrLn $ "Message: " ++ show msg1
    if check msg1
        then do
            return msg1
        else do
            err <- commitAllOffsets OffsetCommit kafka
            res <- f err
            return msg1
    where
    f :: Maybe KafkaError -> IO (Either KafkaError (ConsumerRecord (Maybe BS.ByteString) (Maybe BS.ByteString)))
    f er =
        case er of
            Just e  -> return $ Left e
            Nothing -> processMessages kafka
    check :: Either KafkaError (ConsumerRecord (Maybe BS.ByteString) (Maybe BS.ByteString)) -> Bool
    check msg =
        case msg of
            Left e -> True
            Right e -> False

printingRebalanceCallback :: KafkaConsumer -> KafkaError -> [TopicPartition] -> IO ()
printingRebalanceCallback k e ps =
    case e of
        KafkaResponseError RdKafkaRespErrAssignPartitions -> do
            putStr "[Rebalance] Assign partitions: "
            mapM_ (print . (tpTopicName &&& tpPartition &&& tpOffset)) ps
            assign k ps >>= print
        KafkaResponseError RdKafkaRespErrRevokePartitions -> do
            putStr "[Rebalance] Revoke partitions: "
            mapM_ (print . (tpTopicName &&& tpPartition &&& tpOffset)) ps
            assign k [] >>= print
        x -> print "Rebalance: UNKNOWN (and unlikely!)" >> print x

printingOffsetCallback :: KafkaConsumer -> KafkaError -> [TopicPartition] -> IO ()
printingOffsetCallback _ e ps = do
    print ("Offsets callback:" ++ show e)
    mapM_ (print . (tpTopicName &&& tpPartition &&& tpOffset)) ps
