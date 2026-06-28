import XMonad
import XMonad.Util.EZConfig
import XMonad.Hooks.ManageHelpers
import System.Exit
import qualified XMonad.StackSet as W

myFloatingRect :: W.RationalRect
myFloatingRect =
    W.RationalRect 0.08 0.08 0.84 0.84
    -- x y width height
    -- 8% from left, 8% from top, 84% width, 84% height

myManageHook :: ManageHook
myManageHook =
  composeAll
    [ isDialog --> doFloat
    , className =? "float-kitty" --> doRectFloat myFloatingRect
    , className =? "float-nvim" --> doRectFloat myFloatingRect
    ]

main :: IO ()
main =
  xmonad $
    def
      { modMask = mod4Mask
      , terminal = "kitty"
      , borderWidth = 2
      , manageHook = myManageHook <+> manageHook def
      }
      `additionalKeysP`
      [ ("M-<Return>", spawn "kitty")
      , ("M-S-<Return>", spawn "kitty --class float-kitty")
      , ("M-n", spawn "kitty --class float-nvim -e nvim")

      , ("M-p", spawn "dmenu_run")
      , ("M-S-r", spawn "xmonad --recompile; xmonad --restart")
      , ("M-S-q", io exitSuccess)

      -- Manually float focused window.
      , ("M-f", withFocused $ \w -> windows $ W.float w (W.RationalRect 0.2 0.2 0.6 0.6))
      -- Return focused window to tiling
      , ("M-t", withFocused $ \w -> windows $ W.sink w)
      ]
