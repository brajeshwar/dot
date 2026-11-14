;;; init.el --- Main Emacs config -*- lexical-binding: t; -*-

;; Lives in ~/dot/emacs/ and is symlinked into ~/.config/emacs/ by bootstrap.sh.
;; Everything Emacs generates (packages, history, autosaves) stays in
;; ~/.config/emacs/ and out of the dotfiles repo.

;;; Generated settings

;; The Customize UI writes here instead of into this file. Not symlinked, so
;; it stays per-machine.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror 'nomessage)

;;; Packages

;; Declare every package with `use-package'; each machine installs its own
;; copy on first launch.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(require 'use-package)
(setq use-package-always-ensure t)

;;; Files

;; Agents edit files behind Emacs's back. Reload buffers when the file on
;; disk changes, including directory listings.
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

;; Keep backups and autosaves in the config directory, not next to the files.
(let ((backups (expand-file-name "backups/" user-emacs-directory))
      (autosaves (expand-file-name "autosaves/" user-emacs-directory)))
  (make-directory backups t)
  (make-directory autosaves t)
  (setq backup-directory-alist `(("." . ,backups))
        auto-save-file-name-transforms `((".*" ,autosaves t))))
(setq create-lockfiles nil)

;; Remember recent files, minibuffer history, and the cursor position per file.
(recentf-mode 1)
(savehist-mode 1)
(save-place-mode 1)

;;; Editing

(delete-selection-mode 1)
(setq-default indent-tabs-mode nil)
(setq use-short-answers t)

;;; Display

(setq inhibit-startup-screen t)
(setq ring-bell-function #'ignore)
(pixel-scroll-precision-mode 1)
(column-number-mode 1)

;;; Sidebar

;; A Sublime-style folder tree on the left, opened on ~/dev at startup so every
;; project is one click away. Toggle it with ⌘K ⌘B, as in Sublime; that takes
;; ⌘K away from its default (close buffer), which C-x k still does.
(keymap-global-unset "s-k")

(use-package treemacs
  :bind ("s-k s-b" . treemacs)
  :custom
  (treemacs-width 32)
  ;; Plain text markers instead of picture icons.
  (treemacs-no-png-images t)
  :config
  (treemacs-follow-mode 1)
  (treemacs-filewatch-mode 1))

(defun oinam/sidebar-on-dev ()
  "Show the sidebar with ~/dev in it, leaving the cursor in the editor."
  (require 'treemacs)
  (treemacs-do-add-project-to-workspace (expand-file-name "~/dev") "dev")
  (save-selected-window (treemacs-select-window)))

(add-hook 'emacs-startup-hook #'oinam/sidebar-on-dev)

;;; init.el ends here
