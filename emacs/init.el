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
(defvar oinam/packages '(markdown-mode olivetti)
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
;; A thin bar cursor, like Sublime's caret.
(setq-default cursor-type '(bar . 2))
(setq ring-bell-function #'ignore)
(pixel-scroll-precision-mode 1)
(column-number-mode 1)

;; Theme: built-in only, no packages. Dark with a cool blue tint, the closest
;; native match to Nord. Try others live with M-x load-theme (modus-vivendi,
;; modus-operandi for light, misterioso, wombat, ...); to keep one, change the
;; name here.
(load-theme 'modus-vivendi-tinted t)

;;; Sidebar

;; Built in, no packages: a dired folder list of ~/dev pinned on the left.
;; Toggle it with ⌘K ⌘B, as in Sublime; that takes ⌘K away from its default
;; (close buffer), which C-x k still does. In the list, RET or a click opens a
;; folder in place and a file in the editor; ^ goes up a folder.
(defvar-keymap oinam/sidebar-mode-map
  "RET" #'oinam/sidebar-open
  "<mouse-2>" #'oinam/sidebar-click
  "^" #'oinam/sidebar-up)

(define-minor-mode oinam/sidebar-mode
  "Keys for the sidebar's dired buffers."
  :keymap oinam/sidebar-mode-map)

;; Folders first, using Emacs's own directory listing rather than macOS ls.
(setq ls-lisp-use-insert-directory-program nil
      ls-lisp-dirs-first t
      dired-omit-files "\\`[.]\\'\\|\\`[.]\\(git\\|DS_Store\\)\\'")

(defun oinam/sidebar-show (dir)
  "Show DIR in the sidebar window, replacing what was there."
  (let ((old (current-buffer))
        (buf (dired-noselect dir)))
    (with-current-buffer buf
      (dired-hide-details-mode 1)
      (dired-omit-mode 1)
      (oinam/sidebar-mode 1))
    (set-window-buffer nil buf)
    (unless (or (eq old buf) (get-buffer-window old t))
      (kill-buffer old))))

(defun oinam/sidebar-open ()
  "Open the folder at point in the sidebar, or the file in the editor."
  (interactive)
  (let ((file (dired-get-file-for-visit)))
    (if (file-directory-p file)
        (oinam/sidebar-show file)
      (select-window (get-mru-window nil nil t))
      (find-file file))))

(defun oinam/sidebar-click (event)
  "Open what was clicked, as RET does."
  (interactive "e")
  (mouse-set-point event)
  (oinam/sidebar-open))

(defun oinam/sidebar-up ()
  "Show the parent folder in the sidebar."
  (interactive)
  (oinam/sidebar-show (file-name-directory (directory-file-name default-directory))))

(defun oinam/sidebar ()
  "Toggle the ~/dev folder list on the left."
  (interactive)
  (if-let* ((win (window-with-parameter 'window-side 'left)))
      (delete-window win)
    (require 'ls-lisp)
    (require 'dired-x)
    (let ((buf (dired-noselect "~/dev/")))
      (select-window
       (display-buffer-in-side-window
        buf '((side . left) (window-width . 32)
              (window-parameters . ((no-delete-other-windows . t))))))
      (oinam/sidebar-show "~/dev/"))))

(keymap-global-unset "s-k")
(keymap-global-set "s-k s-b" #'oinam/sidebar)

;;; Finding files

;; ⌘P finds a file in the current project by typing part of its name, like
;; Sublime's Goto Anything; C-x p p switches project. Both are built in, and a
;; project is any folder under git. The vertical list narrows as you type.
(fido-vertical-mode 1)
(keymap-global-set "s-p" #'project-find-file)

;; Make every project in ~/dev known the first time a project command runs.
(with-eval-after-load 'project
  (project-remember-projects-under "~/dev"))

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

;;; Light pages

;; Markdown and .txt files read on a light page, like iA Writer and the Sublime
;; setup, while code stays dark. Themes are frame-wide, so this repaints only
;; those buffers' faces. Colors match MarkdownEditor.sublime-color-scheme in
;; ~/dev/sublime-user.
(defvar oinam/page-faces
  `((default :foreground "#1E1E1E" :background "#F6F6F6")
    (fringe :background "#F6F6F6")
    (region :background "#D6EAF8")
    (fill-column-indicator :foreground "#E0E0E0" :background "#F6F6F6")
    ;; Markdown syntax fades to grey; words stay dark.
    (markdown-markup-face :foreground "#B4B4B4")
    (markdown-header-delimiter-face :foreground "#B4B4B4")
    (markdown-list-face :foreground "#B4B4B4")
    (markdown-language-keyword-face :foreground "#B4B4B4")
    (markdown-reference-face :foreground "#B4B4B4")
    ;; Headings stay text-colored and only get bold.
    ,@(mapcar (lambda (n)
                `(,(intern (format "markdown-header-face-%d" n))
                  :foreground "#1E1E1E" :weight bold))
              (number-sequence 1 6))
    (markdown-bold-face :foreground "#1E1E1E" :weight bold)
    (markdown-italic-face :foreground "#1E1E1E" :slant italic)
    (markdown-blockquote-face :foreground "#5A5A5A")
    (markdown-link-face :foreground "#5B9BD5")
    (markdown-url-face :foreground "#5B9BD5")
    (markdown-plain-url-face :foreground "#5B9BD5")
    (markdown-inline-code-face :foreground "#1E1E1E" :background "#EBEBEB")
    (markdown-code-face :background "#EBEBEB")
    (markdown-pre-face :foreground "#1E1E1E"))
  "Faces repainted on a light page.")

(defun oinam/light-page ()
  "Repaint this buffer as a light page."
  (dolist (face oinam/page-faces)
    (face-remap-add-relative (car face) (cdr face))))

(add-hook 'markdown-mode-hook #'oinam/light-page)
(add-hook 'text-mode-hook
          (lambda ()
            (when (and (eq major-mode 'text-mode) buffer-file-name
                       (string-suffix-p ".txt" buffer-file-name t))
              (oinam/light-page))))

;;; init.el ends here
