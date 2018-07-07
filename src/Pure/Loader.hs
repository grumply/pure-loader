{-# LANGUAGE RecordWildCards #-}
module Pure.Loader where

import Pure

import qualified Pure.Visibility as V

import Control.Monad
import Data.Typeable

data Loader key view response = Loader
  { initial :: view
  , loading :: view
  , reload  :: Bool
  , lazy    :: Bool
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
                        unless (Pure.Loader.lazy l) (load True)
                    , receive = \newprops oldstate -> do 
                        oldprops <- ask self
                        when (reload newprops && not (reload oldprops) || key newprops /= key oldprops) (load False)
                        return (True,loading newprops) 
                    , Pure.render = \l (loaded,s) -> 
                        if not loaded && Pure.Loader.lazy l
                            then V.Visibility def <| V.OnOnScreen (Just (\_ -> load True)) . V.FireOnMount True |> [ Span ]
                            else Pure.Loader.render l s 
                    }