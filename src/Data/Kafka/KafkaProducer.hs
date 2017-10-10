{-# LANGUAGE OverloadedStrings #-}

module Data.Kafka.KafkaProducer
    ( sendToKafkaTopic
    , timestamp
    , formattedTimeStamp
    ) where

import           Control.Monad            (forM_)
import           Data.ByteString.Internal (ByteString)
import qualified Data.ByteString.UTF8     as BU
import qualified Data.Map                 as M
import           Data.Maybe
import           Data.Monoid
import           Data.Time
import           Kafka.Producer
import           Text.Read

-- time utils
timestamp :: IO (String)
timestamp = do
    zonedTime <- getZonedTime
    return $ formattedZonedTimeNow zonedTime
  where
    formattedZonedTimeNow :: ZonedTime -> String
    formattedZonedTimeNow zonedTime = (formatTime defaultTimeLocale "%FT%T%z" zonedTime)

formattedTimeStamp :: IO (String)
formattedTimeStamp = do
    timeNow <- timestamp
    return $ "[" ++ timeNow ++ "]"

-- Global producer properties
producerProps :: String -> ProducerProperties
producerProps brokerAddress =
    (extraProps $
     M.fromList
         [ ("client.id", "rdkafka-haskell-producer-tool")
         , ("request.required.acks","1")
         , ("socket.max.fails", "3")
         , ("message.timeout.ms", "0")
         , ("topic.metadata.refresh.interval.ms", "120000")
               -- retry failed sends as many times as possible
         , ("message.send.max.retries", "100000")
         , ("compression.codec","snappy")
         ]) <>
    brokersList [BrokerAddress brokerAddress] <>
    logLevel KafkaLogDebug

-- Topic to send messages to
targetTopic :: String -> TopicName
targetTopic topicName = TopicName topicName

mkMessage :: TopicName -> Maybe ByteString -> Maybe ByteString -> ProducerRecord
mkMessage topic k v = ProducerRecord {prTopic = topic, prPartition = UnassignedPartition, prKey = k, prValue = v}

-- Run an example
sendToKafkaTopic :: String -> String -> ByteString -> IO (Either KafkaError ())
sendToKafkaTopic brokerAddress kafkaTopic message = do
    beginTime <- formattedTimeStamp
    putStrLn $ beginTime  ++ " - Start sending - message ... \n" ++ BU.toString message
    res <- runProducer (producerProps brokerAddress) sendMsg
    endTime <- formattedTimeStamp
    putStrLn $ endTime  ++ " - End sending - message ... "
    return res
  where
    sendMsg prod = sendMessage prod (targetTopic kafkaTopic) message

sendMessage :: KafkaProducer -> TopicName -> ByteString -> IO (Either KafkaError ())
sendMessage prod topic message = do
    zonedTime <- timestamp
    err <- produceMessage prod (mkMessage topic (Just (BU.fromString zonedTime)) (Just message))
    f err
  where
    f :: (Maybe KafkaError) -> IO (Either KafkaError ())
    f er =
        case er of
            Just e  -> return $ Left e
            Nothing -> return $ Right ()
