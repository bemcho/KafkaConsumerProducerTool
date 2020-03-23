{-# LANGUAGE OverloadedStrings #-}

module Data.Kafka.KafkaProducer
    ( sendToKafkaTopic
    ) where

import           Data.ByteString.Internal (ByteString)
import qualified Data.Map             as M
import qualified Data.Text            as T
import           Data.Monoid
import           Kafka.Producer

-- Global producer properties
producerProps :: String -> ProducerProperties
producerProps brokerAddress =
    extraProps
        (M.fromList
             [ ("client.id", "rdkafka-haskell-producer-tool")
             , ("request.required.acks", "1")
             , ("socket.max.fails", "3")
             , ("message.timeout.ms", "0")
             , ("topic.metadata.refresh.interval.ms", "120000")
             , ("log.connection.close", "False")
             , ("message.send.max.retries", "100000")
             ]) <>
    brokersList [BrokerAddress (T.pack brokerAddress)] <>
    logLevel KafkaLogInfo

-- Topic to send messages to
targetTopic :: T.Text -> TopicName
targetTopic =  TopicName

mkMessage :: TopicName -> Maybe ByteString -> Maybe ByteString -> ProducerRecord
mkMessage topic k v = ProducerRecord {prTopic = topic, prPartition = UnassignedPartition, prKey = k, prValue = v}

-- Run an example
sendToKafkaTopic :: String -> String -> ByteString -> ByteString -> IO (Either KafkaError ())
sendToKafkaTopic brokerAddress kafkaTopic key message = runProducer (producerProps brokerAddress) sendMsg
  where
    sendMsg prod = sendMessage prod (targetTopic (T.pack kafkaTopic)) key message

sendMessage :: KafkaProducer -> TopicName -> ByteString -> ByteString -> IO (Either KafkaError ())
sendMessage prod topic key message = do
    err <- produceMessage prod (mkMessage topic (Just key) (Just message))
    handleResult err
  where
    handleResult er =
        case er of
            Just e  -> return $ Left e
            Nothing -> return $ Right ()
