{-# LANGUAGE OverloadedStrings #-}

module Data.Kafka.KafkaProducer
 (sendToKafkaTopic,timestamp)
where

import           Control.Monad            (forM_)
import           Data.ByteString.Internal (ByteString)
import qualified Data.ByteString.UTF8     as BU
import           Data.Monoid
import           Data.Maybe
import           Data.Time
import           Kafka.Producer
import           Text.Read

-- time utils


timestamp:: IO(String)
timestamp = do
    zonedTime <- getZonedTime
    return $ formattedZonedTimeNow zonedTime
    where
        formattedZonedTimeNow :: ZonedTime -> String
        formattedZonedTimeNow zonedTime = (formatTime defaultTimeLocale "%FT%T%z" zonedTime)

-- Global producer properties
producerProps :: String -> ProducerProperties
producerProps brokerAddress = brokersList [BrokerAddress brokerAddress] <> logLevel KafkaLogDebug

-- Topic to send messages to
targetTopic :: String -> TopicName
targetTopic topicName = TopicName topicName

mkMessage :: TopicName -> Maybe ByteString -> Maybe ByteString -> ProducerRecord
mkMessage topic k v = ProducerRecord {prTopic = topic, prPartition = UnassignedPartition, prKey = k, prValue = v}

-- Run an example
sendToKafkaTopic :: String -> String -> ByteString -> IO (Either KafkaError ())
sendToKafkaTopic brokerAddress kafkaTopic message = do
    res <- runProducer  (producerProps brokerAddress) sendMsg
    return res
    where
      sendMsg prod = sendMessage  prod (targetTopic kafkaTopic) message


sendMessage :: KafkaProducer -> TopicName ->  ByteString -> IO (Either KafkaError ())
sendMessage prod topic message = do
    zonedTime <- timestamp
    err <- produceMessage prod (mkMessage topic (Just (BU.fromString zonedTime)) (Just message))
    f err
    where
        f :: (Maybe KafkaError) -> IO (Either KafkaError ())
        f er =case er of
            (Just e) -> return $ Left e
            Nothing -> return $ Right ()
