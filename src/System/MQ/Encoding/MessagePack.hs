{-# LANGUAGE ViewPatterns #-}

module System.MQ.Encoding.MessagePack
  (
    pack
  , unpack
  , unpackM
  ) where

import           Control.Monad.Except (throwError)
import qualified Data.ByteString      as BS (ByteString)
import qualified Data.ByteString.Lazy as BSL (fromStrict, toStrict)
import qualified Data.MessagePack     as MP (MessagePack (..), pack, unpack)
import           System.MQ.Error      (MQError (..), errorEncoding)
import           System.MQ.Monad      (MQMonadS)
import           Text.Printf          (printf)

-- | Packs something from 'MP.MessagePack' to 'BS.ByteString'.
--
pack :: MP.MessagePack a => a -> BS.ByteString
pack = BSL.toStrict . MP.pack

-- | Unpacks something from 'BS.ByteString' to 'MP.MessagePack'.
-- If 'unpack' failes then 'Nothing' will be returned.
--
unpack :: MP.MessagePack a => BS.ByteString -> Maybe a
unpack = MP.unpack . BSL.fromStrict

-- | Unpacks something from 'BS.ByteString' to 'MP.MessagePack' inside 'MQMonad'.
-- If 'unpackM' failes then 'MQError' will be thrown.
--
unpackM :: MP.MessagePack a => BS.ByteString -> MQMonadS s a
unpackM bs@(unpack -> m) = maybe (throwError err) pure m
  where
    err = MQError errorEncoding . printf "could not unpack MessagePack: %s" . show $ bs
