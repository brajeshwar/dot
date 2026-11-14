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

;; Theme: built-in only, no packages. Dark with a cool blue tint, the closest
;; native match to Nord. Try others live with M-x load-theme (modus-vivendi,
;; modus-operandi for light, misterioso, wombat, ...); to keep one, change the
;; name here.
(load-theme 'modus-vivendi-tinted t)

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

;;; Markdown

;; A writing mode modeled on the Sublime setup in ~/dev/sublime-user: same
;; font, a centered 80-character column, a ruler at 79, roomier lines, spell
;; check, and saving when Emacs loses focus.
(set-face-attribute 'default nil :family "JetBrains Mono" :height 170)

;; Centers the text in a fixed-width column, like Sublime's draw_centered.
(use-package olivetti
  :custom
  (olivetti-body-width 80))

(defun oinam/markdown-writing ()
  "Turn a Markdown buffer into a prose view."
  (visual-line-mode 1)
  (olivetti-mode 1)
  (setq-local fill-column 80
              tab-width 4
              line-spacing 0.25
              display-fill-column-indicator-column 79)
  (display-fill-column-indicator-mode 1)
  ;; Needs a spell checker on the machine: brew install aspell.
  (when (or (executable-find "aspell") (executable-find "hunspell"))
    (flyspell-mode 1)))

(use-package markdown-mode
  ;; Entries are pushed in turn, so the README rule must come last to win.
  :mode (("\\.\\(md\\|markdown\\)\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :hook ((markdown-mode . oinam/markdown-writing))
  :custom
  (markdown-fontify-code-blocks-natively t)
  (markdown-asymmetric-header t))

(defun oinam/save-markdown-on-blur ()
  "Save edited Markdown files when Emacs loses focus, like Sublime."
  (unless (frame-focus-state)
    (save-some-buffers t (lambda ()
                           (and buffer-file-name
                                (derived-mode-p 'markdown-mode))))))

(add-function :after after-focus-change-function #'oinam/save-markdown-on-blur)

;;; init.el ends here
