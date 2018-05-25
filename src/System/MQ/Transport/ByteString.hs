{-# LANGUAGE OverloadedStrings #-}

module System.MQ.Transport.ByteString
  (
    push
  , pull
  , pub
  , sub
  ) where

import           Control.Monad.Except
import qualified Data.ByteString                    as BS (ByteString, split)
import           Data.List.NonEmpty                 (NonEmpty (..))
import           Data.Maybe                         (fromJust, isJust)
import qualified System.MQ.Encoding.MessagePack     as MP (unpack)
import           System.MQ.Error                    (MQError (..), errorTag,
                                                     errorTransport)
import           System.MQ.Monad                    (MQMonadS)
import           System.MQ.Protocol                 (delimiter)
import           System.MQ.Transport.Internal.Types (PubChannel, PullChannel,
                                                     PushChannel, SubChannel)
import           System.ZMQ4                        (receiveMulti, sendMulti)
import           Text.Printf                        (printf)

-- | Pushes @(tag, content)@ to the 'PushChannel'.
--
push :: PushChannel -> (BS.ByteString, BS.ByteString) -> MQMonadS s ()
push channel (msgTag, msgContent) = liftIO . sendMulti channel $ msgTag :| [msgContent]

-- | Pulls @(tag, content)@ from the 'PullChannel'.
--
pull :: PullChannel -> MQMonadS s (BS.ByteString, BS.ByteString)
pull channel = do
    msg' <- liftIO . receiveMulti $ channel
    processMessage msg'

-- | Publishes @(tag, content)@ to the 'PubChannel'.
--
pub :: PubChannel -> (BS.ByteString, BS.ByteString) -> MQMonadS s ()
pub channel (msgTag, msgContent) = liftIO . sendMulti channel $ msgTag :| [msgContent]

-- | Subscribes and gets @(tag, content)@ from the 'SubChannel'.
--
sub :: SubChannel -> MQMonadS s (BS.ByteString, BS.ByteString)
sub channel = do
    msg' <- liftIO . receiveMulti $ channel
    processMessage msg'

processMessage :: [BS.ByteString] -> MQMonadS s (BS.ByteString, BS.ByteString)
processMessage [msgTag, msgContent] = if tagIsValid msgTag
                                      then pure (msgTag, msgContent)
                                      else throwError . MQError errorTag $ "tag is not valid."
processMessage list = throwError . MQError errorTransport . printf "expected message with [header, body]; received list with %d element(s)." $ length list

tagIsValid :: BS.ByteString -> Bool
tagIsValid bs = isMessagePack && length delimited == 5 && head delimited `elem` msgTypes
  where
    tagUnpackedM = MP.unpack bs
    isMessagePack = isJust tagUnpackedM

    delimited = BS.split delimiter $ fromJust tagUnpackedM

    msgTypes = ["config", "result", "data", "error"]
