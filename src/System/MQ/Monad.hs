{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE RankNTypes                 #-}

module System.MQ.Monad
  (
    MQMonad
  , MQMonadS
  , runMQMonad
  , runMQMonadS
  , errorHandler
  -- , errorHandlerS
  , foreverSafe
  -- , foreverSafeS
  ) where

import           Control.Exception              (throw)
import           Control.Monad.Except           (ExceptT, MonadError, MonadIO,
                                                 catchError, forever, liftIO,
                                                 runExceptT)
import           Control.Monad.State.Strict     (MonadState, StateT, runStateT)
import           System.Log.Logger              (errorM)
import           System.MQ.Error.Internal.Types (MQError (..))
import           Text.Printf                    (printf)

-- | 'MQMonadS' is the base monad for the Monique System with state.
--
newtype MQMonadS s a = MQMonadS {unMQMonadS :: StateT s (ExceptT MQError IO) a }
  deriving ( Monad
           , Functor
           , Applicative
           , MonadIO
           , MonadError MQError
           , MonadState s)



-- | 'MQMonad' is the base monad for the Monique System.
--
type MQMonad a = MQMonadS () a

-- | Turns 'MQMonadS s a' into 'IO' monad.
-- If exception happens error will be thrown.
--
runMQMonadS :: MQMonadS s a -> s -> IO (a, s)
runMQMonadS m state = either throw pure =<< runExceptT (runStateT (unMQMonadS m) state)

-- | Turns 'MQMonad' into 'IO' monad.
-- If exception happens error will be thrown.
--
runMQMonad :: MQMonad a -> IO a
runMQMonad m = fst <$> runMQMonadS m ()

-- | 'errorHandler' logs message with error @err@ for the component with name @name@
--
errorHandler :: forall s. String -> MQError -> MQMonadS s ()
errorHandler name (MQError c m) = do
  liftIO . errorM name $! printf "MQError (code %d): %s" c m
  pure ()


-- | 'foreverSafe' runs given @MQMonadS s ()@ forever.
-- If exception happens it prints log and runs further.
--
foreverSafe :: forall s. String -> MQMonadS s () -> MQMonadS s ()
foreverSafe name = forever . (`catchError` errorHandler name)

