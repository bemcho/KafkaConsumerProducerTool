{-# LANGUAGE OverloadedStrings #-}
module Data.Kafka.ExampleKafkaProducerProductRecallTopic where

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
targetTopic = TopicName "product_recall"

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
            [ mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"f066eec5-1c0b-4097-bda5-0f7eec1a03a8\",\"key\":\"somekey19\",\"time\":\"2017-09-29T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{    \"banner\": {    \"displayFrom\": \"2017-01-07\",    \"displayTo\": \"2037-12-31\",    \"subjectBestBefore\": \"MHD 31.12.2037\",    \"subjectProduct\": \"Marmeladentraum Erdbeer\",    \"subjectReason\": \"Nicht ausgewiesene Allergene\",    \"visible\": true  },  \"content\": \"Im Sinne des vorbeugenden Verbraucherschutzes ruft die Firma Evil Corp das Produkt Marmeladentraum Erdbeer, 250g, EAN-Code: 123456789 zurück.\",  \"distributionChannels\": [    \"DELIVERY\",    \"MARKETPLACE\"  ],  \"fulfillmentId\": \"111111\",  \"id\": \"84a9a789-4218-44d2-a85d-bc65e9b5085a\",  \"issuedOn\": \"2018-09-26\",  \"mailSubject\": \"Marmeladentraum Erdbeer, Mindesthaltbarkeitsdatum 07.02.2017, nicht ausgewiesene Allergene\",  \"orderSelection\": {    \"placedFrom\": \"2018-02-07T12:34:56+01:00\",    \"placedTo\": \"2018-02-10T20:00:00+01:00\"  },  \"partner\": \"Marmeladenfreunde\",  \"pdfUrl\": \"https://rewe.akamai.com/recall-xx.pdf\",  \"products\": [    {      \"batches\": [        {          \"batchNumber\": \"123456\",          \"bestBefore\": \"2017-02-07\",          \"gtin\": \"123456\"        }      ],      \"name\": \"Marmeladentraum Erdbeer\",      \"nan\": \"1234567\"    },    {      \"batches\": [        {          \"batchNumber\": \"123466\",          \"bestBefore\": \"2017-02-12\",          \"gtin\": \"123458\"        }      ],      \"name\": \"Marmeladentraum Kirsche\",      \"nan\": \"1234568\"    }  ],  \"publicationType\": \"PUBLIC\",  \"supplierId\": \"s123456\",  \"url\": \"https://www.rewe-group.com/de/newsroom/pressemitteilungen/1425.html\",  \"version\": 16}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"886fc037-9974-4f46-a2e2-5cfd84a959a8\",\"key\":\"somekey18\",\"time\":\"2017-09-29T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{    \"banner\": {    \"displayFrom\": \"2017-01-07\",    \"displayTo\": \"2037-12-31\",    \"subjectBestBefore\": \"MHD 31.12.2037\",    \"subjectProduct\": \"Marmeladentraum Erdbeer\",    \"subjectReason\": \"Nicht ausgewiesene Allergene\",    \"visible\": true  },  \"content\": \"Im Sinne des vorbeugenden Verbraucherschutzes ruft die Firma Evil Corp das Produkt Marmeladentraum Erdbeer, 250g, EAN-Code: 123456789 zurück.\",  \"distributionChannels\": [    \"DELIVERY\",    \"MARKETPLACE\"  ],  \"fulfillmentId\": \"111111\",  \"id\": \"84a9a789-4218-ffd2-a85d-bc65e9b5085a\",  \"issuedOn\": \"2018-03-01\",  \"mailSubject\": \"Marmeladentraum Erdbeer, Mindesthaltbarkeitsdatum 07.02.2017, nicht ausgewiesene Allergene\",  \"orderSelection\": {    \"placedFrom\": \"2018-02-07T12:34:56+01:00\",    \"placedTo\": \"2018-02-10T20:00:00+01:00\"  },  \"partner\": \"Marmeladenfreunde\",  \"pdfUrl\": \"https://rewe.akamai.com/recall-xx.pdf\",  \"products\": [    {      \"batches\": [        {          \"batchNumber\": \"123456\",          \"bestBefore\": \"2017-02-07\",          \"gtin\": \"123456\"        }      ],      \"name\": \"Marmeladentraum Erdbeer\",      \"nan\": \"1234567\"    },    {      \"batches\": [        {          \"batchNumber\": \"123466\",          \"bestBefore\": \"2017-02-12\",          \"gtin\": \"123458\"        }      ],      \"name\": \"Marmeladentraum Kirsche\",      \"nan\": \"1234hehe568\"    }  ],  \"publicationType\": \"PUBLIC\",  \"supplierId\": \"s123456\",  \"url\": \"https://www.rewe-group.com/de/newsroom/pressemitteilungen/1425.html\",  \"version\": 16}}")
            , mkMessage (Just "\"StockServiceKey\"") (Just "{\"id\":\"a9bee46d-a42c-4310-a4e3-22b928236c07\",\"key\":\"somekey111\",\"time\":\"2017-09-29T20:00:00+01:00\",\"type\":\"typeValue\",\"channel\":\"channelValue\",\"storeId\":\"111111\",\"tenant\":\"REWE\",\"payloadId\":\"asnID\",\"payload\":{    \"banner\": {    \"displayFrom\": \"2017-01-07\",    \"displayTo\": \"2037-12-31\",    \"subjectBestBefore\": \"MHD 31.12.2037\",    \"subjectProduct\": \"Marmeladentraum Erdbeer\",    \"subjectReason\": \"Nicht ausgewiesene Allergene\",    \"visible\": true  },  \"content\": \"Im Sinne des vorbeugenden Verbraucherschutzes ruft die Firma Evil Corp das Produkt Marmeladentraum Erdbeer, 250g, EAN-Code: 123456789 zurück.\",  \"distributionChannels\": [    \"DELIVERY\",    \"MARKETPLACE\"  ],  \"fulfillmentId\": \"111111\",  \"id\": \"84a9a789-4218-ccd2-a85d-bc65e9b5085a\",  \"issuedOn\": \"2018-03-01\",  \"mailSubject\": \"Marmeladentraum Erdbeer, Mindesthaltbarkeitsdatum 07.02.2017, nicht ausgewiesene Allergene\",  \"orderSelection\": {    \"placedFrom\": \"2018-02-07T12:34:56+01:00\",    \"placedTo\": \"2018-02-10T20:00:00+01:00\"  },  \"partner\": \"Marmeladenfreunde\",  \"pdfUrl\": \"https://rewe.akamai.com/recall-xx.pdf\",  \"products\": [    {      \"batches\": [        {          \"batchNumber\": \"123456\",          \"bestBefore\": \"2017-02-07\",          \"gtin\": \"123456\"        }      ],      \"name\": \"Marmeladentraum Erdbeer\",      \"nan\": \"1234567\"    },    {      \"batches\": [        {          \"batchNumber\": \"123466\",          \"bestBefore\": \"2017-02-12\",          \"gtin\": \"123458\"        }      ],      \"name\": \"Marmeladentraum Kirsche\",      \"nan\": \"12345hoho68\"    }  ],  \"publicationType\": \"PUBLIC\",  \"supplierId\": \"s123456\",  \"url\": \"https://www.rewe-group.com/de/newsroom/pressemitteilungen/1425.html\",  \"version\": 16}}")
            ]

  forM_ errs (print . snd)
  return $ Right ()
