{-# LANGUAGE RecordWildCards #-}
module Pure.Loader where

import Pure hiding (key)

import Control.Monad
import Data.Typeable

data Loader key view response = Loader
  { initial :: view
  , loading :: view
  , reload  :: Bool
  , accept  :: response -> view
  , render  :: view -> View
  , key     :: key
  , loader  :: key -> (response -> IO ()) -> IO ()
  }

instance (Eq key, Typeable key, Typeable view, Typeable response) => Pure (Loader key view response) where
    view =
        ComponentIO $ \self ->
            let
                upd = modify_ self . const

                load setLoading = do
                    Loader {..} <- ask self
                    when setLoading (upd $ \_ -> (True,loading))
                    loader key $ \rsp -> upd $ \_ -> (True,accept rsp)

            in
                def
                    { construct = do
                        Loader {..} <- ask self
                        return (False,initial)
                    , mounted = do
                        l <- ask self
                        load True
                    , receive = \newprops oldstate -> do 
                        oldprops <- ask self
                        when (reload newprops && not (reload oldprops) || key newprops /= key oldprops) (load False)
                        return (True,loading newprops) 
                    , Pure.render = \l (loaded,s) -> if loaded then Pure.Loader.render l s else Null
                    }