;;; early-init.el --- Runs before the first frame is drawn -*- lexical-binding: t; -*-

;; Anything that shapes the window itself goes here, so the frame opens in its
;; final form instead of flickering through the defaults.

;; The compiler bundled with Emacs.app misreads the macOS version on macOS 26
;; and later, and every background native compile fails with a warning. Naming
;; a deployment target it understands fixes that. Must be set before the first
;; compile starts, hence here.
(when (eq system-type 'darwin)
  (setenv "MACOSX_DEPLOYMENT_TARGET" "11.0"))

(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(width . 120) default-frame-alist)
(push '(height . 48) default-frame-alist)

;; Resize by pixel, not by character cell, so the frame fills tiled layouts.
(setq frame-resize-pixelwise t)

;;; early-init.el ends here
