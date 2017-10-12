{-# LANGUAGE ScopedTypeVariables #-}

module Data.Kafka.KafkaConsumer where

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
consumerSub topicName = topics [TopicName topicName] <> offsetReset Earliest

-- Running an example
readFromTopic :: String -> String -> String -> Integer -> Integer -> IO ()
readFromTopic brokerAddress topicName consumerGroupId offsetStart offsetEnd = do
    let consumerProperties = (consumerProps brokerAddress consumerGroupId)
    let consumerTopic = consumerSub topicName
    print $ cpLogLevel consumerProperties
    res <- runConsumer consumerProperties consumerTopic processMessagesWithinOffset
    print res
  where
    processMessagesWithinOffset consumer = processMessages consumer offsetStart offsetEnd

-------------------------------------------------------------------
processMessages :: KafkaConsumer -> Integer -> Integer -> IO (Either KafkaError ())
processMessages kafka offsetStart offsetEnd = do
    mapM_
        (\_ -> do
             msg1 <- pollMessage kafka (Timeout 5000)
             putStrLn $ "Message: " <> show msg1
             --err <- commitAllOffsets OffsetCommit kafka
             --putStrLn $ "Offsets: " <> maybe "Committed." show err)
        )[offsetStart .. offsetEnd]
    return $ Right ()

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
