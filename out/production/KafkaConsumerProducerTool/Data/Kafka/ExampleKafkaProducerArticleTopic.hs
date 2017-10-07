{-# LANGUAGE OverloadedStrings #-}
module Data.Kafka.ExampleKafkaProducerArticleTopic where

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
targetTopic = TopicName "product_recall_article"

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
            [ mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"f066eec5-1c0b-4097-bda5-0f7eec1a03a8\",\"key\":\"somekey19\",\"time\":\"2017-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"storeIdValue\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{\"id\": \"33df090d-9741-46df-84b8-3e2b6a91555f\",\"title\": \"ja! Honey Wheats 750g\",\"status\":\"ACTIVE\",\"lastModified\":\"20170208082740\",\"created\":\"20170208082740\",\"tenantAttributes\":{\"gtin\" :\"39814\",\"nan\":\"23nana2323\"}}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"886fc037-9974-4f46-a2e2-5cfd84a959a8\",\"key\":\"somekey18\",\"time\":\"2017-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"storeIdValue\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{\"id\": \"33df090d-9741-46aa-84cd-3e2b6a91555f\",\"title\": \"ja! Apples\",\"status\":\"ACTIVE\",\"lastModified\":\"20170208082740\",\"created\":\"20170208082740\",\"tenantAttributes\":{\"gtin\" :\"9dfe814\",\"nan\":\"23nana123\",\"batchSize\":\"23\"}}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"a9bee46d-a42c-4310-a4e3-22b928236c07\",\"key\":\"somekey111\",\"time\":\"2017-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"storeIdValue\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{\"id\": \"33df090d-9741-46df-84b8-3e2b6a91555f\",\"title\": \"ja! Beer 750g\",\"status\":\"ACTIVE\",\"lastModified\":\"20170208082740\",\"created\":\"20170208082740\",\"tenantAttributes\":{\"gtin\" :\"123979814\",\"nan\":\"23nana234\"}}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"a9bee46d-a42c-4310-a4e3-22b928236c07\",\"key\":\"somekey111\",\"time\":\"2017-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"storeIdValue\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{\"id\": \"33df090d-9741-46df-84ff-3e2b6a91555f\",\"title\": \"ja! Broken article 750g\",\"status\":\"ACTIVE\",\"lastModified\":\"20170208082740\",\"created\":\"20170208082740\",\"tenantAttributes\":{\"gtin\" :\"123979814\",\"nan\":\"23nana234\"}}}")
            ]

  forM_ errs (print . snd)
  return $ Right ()
