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

;; Speed budget: every external package is listed here, loads lazily (on a
;; key, a mode, or a file type), and never at startup. Plain Emacs Lisp, no
;; `use-package': it and package.el cost ~160ms at startup on their own.
(defvar oinam/packages '(treemacs markdown-mode olivetti)
  "External packages. Each machine installs missing ones on first launch.")

;; package.el only loads when something on the list is missing.
(let ((missing (seq-remove (lambda (p) (locate-library (symbol-name p)))
                           oinam/packages)))
  (when missing
    (require 'package)
    (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
    (package-refresh-contents)
    (mapc #'package-install missing)))

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
(setq recentf-auto-cleanup 'never)
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

;; A Sublime-style folder tree on the left with ~/dev in it, so every project
;; is one click away. Toggle it with ⌘K ⌘B, as in Sublime; that takes ⌘K away
;; from its default (close buffer), which C-x k still does.
;;
;; Treemacs brings 10 dependencies and ~200ms, so it loads on the first ⌘K ⌘B,
;; not at startup.
(setq treemacs-width 32
      ;; Plain text markers instead of picture icons.
      treemacs-no-png-images t)

(with-eval-after-load 'treemacs
  (treemacs-follow-mode 1)
  (treemacs-filewatch-mode 1))

(defun oinam/sidebar ()
  "Toggle the sidebar, adding ~/dev to it the first time."
  (interactive)
  (require 'treemacs)
  (treemacs-do-add-project-to-workspace (expand-file-name "~/dev") "dev")
  (treemacs))

(keymap-global-unset "s-k")
(keymap-global-set "s-k s-b" #'oinam/sidebar)

;;; Markdown

;; A writing mode modeled on the Sublime setup in ~/dev/sublime-user: same
;; font, a centered 80-character column, a ruler at 79, roomier lines, spell
;; check, and saving when Emacs loses focus.
(set-face-attribute 'default nil :family "JetBrains Mono" :height 170)

;; olivetti centers the text in a fixed-width column, like Sublime's
;; draw_centered.
(setq olivetti-body-width 80)

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

;; markdown-mode's autoloads claim .md and .markdown; READMEs get GitHub's
;; dialect.
(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))
(add-hook 'markdown-mode-hook #'oinam/markdown-writing)
(setq markdown-fontify-code-blocks-natively t
      markdown-asymmetric-header t)

(defun oinam/save-markdown-on-blur ()
  "Save edited Markdown files when Emacs loses focus, like Sublime."
  (unless (frame-focus-state)
    (save-some-buffers t (lambda ()
                           (and buffer-file-name
                                (derived-mode-p 'markdown-mode))))))

(add-function :after after-focus-change-function #'oinam/save-markdown-on-blur)

;;; init.el ends here
