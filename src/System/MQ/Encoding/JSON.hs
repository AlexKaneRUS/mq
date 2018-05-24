{-# LANGUAGE ViewPatterns #-}

module System.MQ.Encoding.JSON
  (
    pack
  , unpack
  , unpackM
  ) where

import           Control.Monad.Except           (throwError)
import           Data.Aeson                     (FromJSON, ToJSON, decode,
                                                 encode)
import qualified Data.ByteString                as BS (ByteString)
import qualified Data.ByteString.Lazy           as BSL (fromStrict, toStrict)
import           System.MQ.Error.Internal.Types (MQError (..), errorEncoding)
import           System.MQ.Monad                (MQMonadS)
import           Text.Printf                    (printf)

-- | Packs something from JSON to 'BS.ByteString'.
--
pack :: ToJSON a => a -> BS.ByteString
pack = BSL.toStrict . encode

-- | Unpacks something from 'BS.ByteString' to JSON.
-- If 'unpack' failes then 'Nothing' will be returned.
--
unpack :: FromJSON a => BS.ByteString -> Maybe a
unpack = decode . BSL.fromStrict

-- | Unpacks something from 'BS.ByteString' to JSON inside 'MQMonad'.
-- If 'unpackM' failes then 'MQError' will be thrown.
--
unpackM :: FromJSON a => BS.ByteString -> MQMonadS s a
unpackM bs@(unpack -> m) = maybe (throwError err) pure m
  where
    err = MQError errorEncoding . printf "could not unpack JSON: %s" . show $ bs
