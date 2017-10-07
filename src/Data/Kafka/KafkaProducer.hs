{-# LANGUAGE OverloadedStrings #-}

module Data.Kafka.KafkaProducer
 (sendToKafkaTopic, KafkaError)
where

import           Control.Monad            (forM_)
import           Data.ByteString.Internal (ByteString)
import qualified Data.ByteString.UTF8     as BU
import           Data.Monoid
import           Data.Time
import           Kafka.Producer
import           Text.Read

-- time utils
formattedZonedTimeNow :: ZonedTime -> ByteString
formattedZonedTimeNow zonedTime = (BU.fromString $ (formatTime defaultTimeLocale "%FT%T%z" zonedTime))

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
    zonedTime <- getZonedTime
    err <- produceMessage prod (mkMessage topic (Just (formattedZonedTimeNow zonedTime)) (Just message))
    forM_ err print
    return $ Right ()
