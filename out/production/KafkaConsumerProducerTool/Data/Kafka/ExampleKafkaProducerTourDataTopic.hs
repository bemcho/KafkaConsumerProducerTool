{-# LANGUAGE OverloadedStrings #-}
module Data.Kafka.ExampleKafkaProducerTourDataTopic where

import Control.Monad   (forM_)
import Data.ByteString (ByteString)
import Data.Monoid
import Kafka.Producer

-- Global producer properties
producerProps :: ProducerProperties
producerProps = brokersList [BrokerAddress "localhost:9092"]
             <> logLevel KafkaLogDebug

-- Topic to send messages to
targetTopic :: TopicName
targetTopic = TopicName "product_recall_tour_data"

mkMessage :: Maybe ByteString -> Maybe ByteString -> ProducerRecord
mkMessage k v = ProducerRecord
                  { prTopic = targetTopic
                  , prPartition = UnassignedPartition
                  , prKey = k
                  , prValue = v
                  }

-- Run an example
runProducerExample :: IO ()
runProducerExample = do
    res <- runProducer producerProps sendMessages
    print res

sendMessages :: KafkaProducer -> IO (Either KafkaError ())
sendMessages prod = do

  errs <- produceMessageBatch prod
            [ mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"f066eec5-1c0b-4097-bda5-0f7eec1a03a8\",\"key\":\"somekey11\",\"time\":\"2018-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{  \"functionCode\": 5,  \"status\": 3,  \"eventTime\": 4506002631.518000000,  \"slotStartTime\": 4506002631.519000000,  \"slotEndTime\": 6506002631.519000000,  \"plannedArrivalTime\": 1506002631.519000000,  \"plannedVisitDuration\": 4,  \"actualVisitDuration\": 6,  \"distance\": 6,  \"drivingDuration\": 5,  \"sequence\": 2,  \"infoText\": \"Tour data info text.\",  \"vtId\": 1,  \"extId\": 4,  \"fmExtId\": \"9f5685d1-7825-42dc-b907-d634c81b70e2\"}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"886fc037-9974-4f46-a2e2-5cfd84a959a8\",\"key\":\"somekey22\",\"time\":\"2018-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{  \"functionCode\": 5,  \"status\": 3,  \"eventTime\": 4506002631.518000000,  \"slotStartTime\": 4506002631.519000000,  \"slotEndTime\": 6506002631.519000000,  \"plannedArrivalTime\": 1506002631.519000000,  \"plannedVisitDuration\": 4,  \"actualVisitDuration\": 6,  \"distance\": 6,  \"drivingDuration\": 5,  \"sequence\": 2,  \"infoText\": \"Tour data info text.\",  \"vtId\": 1,  \"extId\": 4,  \"fmExtId\": \"9f5685d1-7825-42dc-b907-d634c81b70e2\"}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"a9bee46d-a42c-4310-a4e3-22b928236c07\",\"key\":\"somekey33\",\"time\":\"2018-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{  \"functionCode\": 5,  \"status\": 3,  \"eventTime\": 4506002631.518000000,  \"slotStartTime\": 4506002631.519000000,  \"slotEndTime\": 6506002631.519000000,  \"plannedArrivalTime\": 1506002631.519000000,  \"plannedVisitDuration\": 4,  \"actualVisitDuration\": 6,  \"distance\": 6,  \"drivingDuration\": 5,  \"sequence\": 2,  \"infoText\": \"Tour data info text.\",  \"vtId\": 1,  \"extId\": 4,  \"fmExtId\": \"9f5685d1-7825-42dc-b907-d634c81b70e2\"}}")
            ]

  forM_ errs (print . snd)
  return $ Right ()
