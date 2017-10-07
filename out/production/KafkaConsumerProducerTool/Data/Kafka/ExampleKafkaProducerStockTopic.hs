{-# LANGUAGE OverloadedStrings #-}
module Data.Kafka.ExampleKafkaProducerStockTopic where

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
targetTopic = TopicName "product_recall_stock"

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
            [ mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"f066eec5-1c0b-4097-bda5-0f7eec1a03a8\",\"key\":\"somekey19\",\"time\":\"2017-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{\"articleId\":\"a42c-4310-a4e3\",\"quantity\":\"123\",\"quantityUnit\":\"KGG\",\"batchNumber\":\"1234batchNumber\",\"nan\":\"not existing field\",\"storeId\":\"111111\"}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"886fc037-9974-4f46-a2e2-5cfd84a959a8\",\"key\":\"somekey18\",\"time\":\"2017-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{\"articleId\":\"22b958236c07\",\"quantity\":\"1253\",\"quantityUnit\":\"PC\",\"batchNumber\":\"1234234batchNumber\",\"nan\":\"not existing field\",\"storeId\":\"111111\",\"stockElements\": [    {      \"lastModified\": \"2017-02-10T20:00:00.231+01:00\",      \"quantity\": 23,      \"reasonCode\": \"string\",      \"state\": \"blocked\"    }  ]}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"a9bee46d-a42c-4310-a4e3-22b928236c07\",\"key\":\"somekey111\",\"time\":\"2017-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{ \"articleId\":\"a9b3e46d\",\"quantity\":\"53\",\"quantityUnit\":\"PC\",\"batchNumber\":\"124batchNumber\",\"nan\":\"not existing field\",\"storeId\":\"111111\"}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"a9bee46d-a42c-4310-a4e3-22b928236c07\",\"key\":\"somekey111\",\"time\":\"2017-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{ \"articleId\":\"a9b3e46d\",\"quantity\":\"530\",\"quantityUnit\":\"PC\",\"batchNumber\":\"124batchNumber\",\"nan\":\"not existing field\",\"storeId\":\"111111\",\"stockElements\": [    {      \"lastModified\": \"2017-02-10T20:00:00.231+01:00\",      \"quantity\": 50,      \"reasonCode\": \"string\",      \"state\": \"picked\"    }  ]}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"a9bee46d-a42c-4310-a4e3-22b928236c07\",\"key\":\"somekey111\",\"time\":\"2017-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{ \"articleId\":\"a9b3e46d\",\"quantity\":\"53\",\"quantityUnit\":\"PC\",\"batchNumber\":\"124samearticleidbatchNumber\",\"nan\":\"not existing field\",\"storeId\":\"111111\",\"stockElements\": [    {      \"lastModified\": \"2017-02-10T20:00:00.231+01:00\",      \"quantity\": 50,      \"reasonCode\": \"string\",      \"state\": \"picked\"    }  ]}}")
            ]

  forM_ errs (print . snd)
  return $ Right ()
