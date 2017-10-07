{-# LANGUAGE OverloadedStrings #-}
module Data.Kafka.ExampleKafkaProducerAsnTopic where

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
targetTopic = TopicName "product_recall_asn"

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
            [ mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"f06344c5-1c0b-4097-bda5-0f7eec1a03a8\",\"key\":\"latestKey1\",\"time\":\"2018-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{ \"id\" : \"0bee2d52-e064-4231-8329-8a222763f759\", \"eta\" : \"2017-08-23T00:00:00.000Z\", \"status\" : \"OPEN\", \"asnNumber\" : \"d0afcaf1-1650-4ff2-969b-4959989b6a2e\", \"lineItems\" : [ { \"nan\" : \"166042\", \"quantity\" : { \"unit\" : \"PCS\", \"amount\" : 6 }, \"lineItemNumber\" : \"0\", \"incomingGoodsUnit\" : 1, \"outgoingGoodsUnit\" : 1, \"purchaseOrderNumber\" : 1708210003, \"purchaseOrderNumberSuffix\" : 0, \"serialShippingContainerCodes\" : [ \"1708210003_0\" ] } ], \"createDate\" : 1505984598645, \"deleteDate\" : null, \"modifiedDate\" : 1505985596305, \"supplierNumber\" : \"H2213\", \"deliveryNoteNumber\" : 0}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"f06344c5-1c0b-ff97-bda5-0f7eec1a03a8\",\"key\":\"latestKey11\",\"time\":\"2018-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{ \"id\" : \"0bee2d52-e064-4231-8329-8a222763f759\", \"eta\" : \"2017-08-23T00:00:00.000Z\", \"status\" : \"ARRIVED\", \"asnNumber\" : \"d0afcbf1-1650-4f52-969b-4959989b6a2e\", \"lineItems\" : [ { \"nan\" : \"166034\", \"quantity\" : { \"unit\" : \"PCS\", \"amount\" : 160 }, \"lineItemNumber\" : \"0\", \"incomingGoodsUnit\" : 1, \"outgoingGoodsUnit\" : 1, \"purchaseOrderNumber\" : 1708210003, \"purchaseOrderNumberSuffix\" : 0, \"serialShippingContainerCodes\" : [ \"1708210003_0\" ] } ], \"createDate\" : 1505984598645, \"deleteDate\" : null, \"modifiedDate\" : 1505985596305, \"supplierNumber\" : \"H2213\", \"deliveryNoteNumber\" : 0}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"f06344c5-1c0b-cc97-bda5-0f7eec1a03a8\",\"key\":\"latestKey4111\",\"time\":\"2018-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{ \"id\" : \"0bee2d52-e064-4231-8329-8a222763f759\", \"eta\" : \"2017-08-23T00:00:00.000Z\", \"status\" : \"OPEN\", \"asnNumber\" : \"d0afccf1-1650-4f52-969b-4959989b6a2e\", \"lineItems\" : [ { \"nan\" : \"1660345\", \"quantity\" : { \"unit\" : \"PCS\", \"amount\" : 60 }, \"lineItemNumber\" : \"0\", \"incomingGoodsUnit\" : 1, \"outgoingGoodsUnit\" : 1, \"purchaseOrderNumber\" : 1708210003, \"purchaseOrderNumberSuffix\" : 0, \"serialShippingContainerCodes\" : [ \"1708210003_0\" ] } ], \"createDate\" : 1505984598645, \"deleteDate\" : null, \"modifiedDate\" : 1505985596305, \"supplierNumber\" : \"H2213\", \"deliveryNoteNumber\" : 0}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"f06344c5-1c0b-4057-bda5-0f7eec1a03a8\",\"key\":\"latestKeynew4\",\"time\":\"2018-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{ \"id\" : \"0bee2d52-e064-4231-8329-8a222763f759\", \"eta\" : \"2017-08-23T00:00:00.000Z\", \"status\" : \"UNLOADED\", \"asnNumber\" : \"d0afcdf1-1650-4f52-969b-4959989b6a2e\", \"lineItems\" : [ { \"nan\" : \"1662342\", \"quantity\" : { \"unit\" : \"PCS\", \"amount\" : 600 }, \"lineItemNumber\" : \"0\", \"incomingGoodsUnit\" : 1, \"outgoingGoodsUnit\" : 1, \"purchaseOrderNumber\" : 1708210003, \"purchaseOrderNumberSuffix\" : 0, \"serialShippingContainerCodes\" : [ \"1708210003_0\" ] } ], \"createDate\" : 1505984598645, \"deleteDate\" : null, \"modifiedDate\" : 1505985596305, \"supplierNumber\" : \"H2213\", \"deliveryNoteNumber\" : 0}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"f06344c5-1c0b-fc97-bda5-0f7eec1a03a8\",\"key\":\"latestKeynew3\",\"time\":\"2018-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{ \"id\" : \"0bee2d52-e064-4231-8329-8a222763f759\", \"eta\" : \"2017-08-23T00:00:00.000Z\", \"status\" : \"DELETED\", \"asnNumber\" : \"d0afcaf1-1650-4ff2-969b-4959989b6a2e\", \"lineItems\" : [ { \"nan\" : \"16624334\", \"quantity\" : { \"unit\" : \"PCS\", \"amount\" : 23 }, \"lineItemNumber\" : \"0\", \"incomingGoodsUnit\" : 1, \"outgoingGoodsUnit\" : 1, \"purchaseOrderNumber\" : 1708210003, \"purchaseOrderNumberSuffix\" : 0, \"serialShippingContainerCodes\" : [ \"1708210003_0\" ] } ], \"createDate\" : 1505984598645, \"deleteDate\" : null, \"modifiedDate\" : 1505985596305, \"supplierNumber\" : \"H2213\", \"deliveryNoteNumber\" : 0}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"f06344c5-1c0b-ccb7-bda5-0f7eec1a03a8\",\"key\":\"latestKeynew2\",\"time\":\"2018-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{ \"id\" : \"0bee2d52-e064-4231-8329-8a222763f759\", \"eta\" : \"2017-08-23T00:00:00.000Z\", \"status\" : \"REJECTED\", \"asnNumber\" : \"d0afcff1-1650-4f52-969e-4959989b6a2e\", \"lineItems\" : [ { \"nan\" : \"1662453345\", \"quantity\" : { \"unit\" : \"PCS\", \"amount\" : 123 }, \"lineItemNumber\" : \"0\", \"incomingGoodsUnit\" : 1, \"outgoingGoodsUnit\" : 1, \"purchaseOrderNumber\" : 1708210003, \"purchaseOrderNumberSuffix\" : 0, \"serialShippingContainerCodes\" : [ \"1708210003_0\" ] } ], \"createDate\" : 1505984598645, \"deleteDate\" : null, \"modifiedDate\" : 1505985596305, \"supplierNumber\" : \"H2213\", \"deliveryNoteNumber\" : 0}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"f06344c5-1c0b-ccb7-bda5-0f7eec1a03a8\",\"key\":\"latestKeynew2\",\"time\":\"2018-02-10T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{ \"id\" : \"0bee2d52-e064-4231-8329-8a222763f759\", \"eta\" : \"2017-08-23T00:00:00.000Z\", \"status\" : \"COMPLETED\", \"asnNumber\" : \"d0afcff1-ff50-4f52-969e-4959989b6a2e\", \"lineItems\" : [ { \"nan\" : \"1662453345\", \"quantity\" : { \"unit\" : \"PCS\", \"amount\" : 123 }, \"lineItemNumber\" : \"0\", \"incomingGoodsUnit\" : 1, \"outgoingGoodsUnit\" : 1, \"purchaseOrderNumber\" : 1708210003, \"purchaseOrderNumberSuffix\" : 0, \"serialShippingContainerCodes\" : [ \"1708210003_0\" ] } ], \"createDate\" : 1505984598645, \"deleteDate\" : null, \"modifiedDate\" : 1505985596305, \"supplierNumber\" : \"H221w3\", \"deliveryNoteNumber\" : 0}}")
            ]

  forM_ errs (print . snd)
  return $ Right ()
