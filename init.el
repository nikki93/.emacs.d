;; set exec-path from $PATH
(defun set-exec-path-from-shell-PATH ()
  "Sets the exec-path to the same value used by the user shell"
  (let ((path-from-shell
	 (replace-regexp-in-string
	  "[[:space:]\n]*$" ""
	  (shell-command-to-string "$SHELL -l -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))
(set-exec-path-from-shell-PATH)

;; ----------------------------------------------------------------------------
;; .clang_complete reading
;; ----------------------------------------------------------------------------

(defun read-c-flags ()
  "list of flags from upward-found .clang_complete file, nil if not found"

  (defun upward-find-file (filename &optional startdir)
    (let ((dirname (expand-file-name (if startdir startdir ".")))
          (found nil)
          (top nil))
      (while (not (or found top))
             (if (string= (expand-file-name dirname) "/") (setq top t))
             (if (file-exists-p (expand-file-name filename dirname))
               (setq found t)
               (setq dirname (expand-file-name ".." dirname))))
      (if found (concat dirname "/") nil)))

  (defun read-lines (path)
    (with-temp-buffer
      (insert-file-contents path)
      (split-string (buffer-string) "\n" t)))

  (let ((path (upward-find-file ".clang_complete")))
    (if path (read-lines (concat path ".clang_complete")) nil)))


;; ----------------------------------------------------------------------------
;; packages
;; ----------------------------------------------------------------------------

(require 'package)
(setq package-archives '(("melpa" . "http://melpa.milkbox.net/packages/")
                         ("org" . "http://orgmode.org/elpa/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)

(defun require-package (package)
  "same as require, but installs package if needed"
  (progn
    (unless (package-installed-p package)
      (unless (assoc package package-archive-contents)
        (package-refresh-contents))
      (package-install package))
    (require package)))


;; --- theme ------------------------------------------------------------------

(require-package 'color-theme-sanityinc-tomorrow)
(load-theme 'sanityinc-tomorrow-night t)

;(require-package 'leuven-theme)
;(load-theme 'leuven t)

;(require-package 'soothe-theme)

;(require-package 'hemisu-theme)
;(load-theme 'hemisu-dark t)


;; --- evil -------------------------------------------------------------------

(setq evil-want-C-u-scroll t)

(require-package 'evil)
(evil-mode 1)

(define-key evil-normal-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
(define-key evil-motion-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
(define-key evil-motion-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)

(setq-default evil-cross-lines t)


;; --- powerline --------------------------------------------------------------

(require-package 'powerline)
(powerline-default-theme)


;; --- diminish ---------------------------------------------------------------

(require-package 'diminish)
(when (display-graphic-p)
  (eval-after-load "magit"
                   '(diminish 'magit-auto-revert-mode))
  (eval-after-load "git-gutter"
                   '(diminish 'git-gutter-mode))
  (eval-after-load "undo-tree"
                   '(diminish 'undo-tree-mode))
  (eval-after-load "abbrev"
                   '(diminish 'abbrev-mode))
  (eval-after-load "auto-complete"
                   '(diminish 'auto-complete-mode " ac"))
  (eval-after-load "flycheck"
                   '(diminish 'flycheck-mode " fly"))
  (eval-after-load "projectile"
                   '(diminish 'projectile-mode " pr"))
  (eval-after-load "flyspell"
                   '(diminish 'flyspell-mode " flysp"))
  (eval-after-load "yasnippet"
                   '(diminish 'yas-minor-mode " yas")))


;; --- evil-nerd-commenter ----------------------------------------------------

(require-package 'evil-nerd-commenter)
(define-key evil-normal-state-map ",ci" 'evilnc-comment-or-uncomment-lines)
(define-key evil-normal-state-map ",cl" 'evilnc-comment-or-uncomment-to-the-line)
(define-key evil-normal-state-map ",cc" 'evilnc-comment-or-uncomment-lines)
(define-key evil-normal-state-map ",cp" 'evilnc-comment-or-uncomment-paragraphs)
(define-key evil-normal-state-map ",cr" 'comment-or-uncomment-region)


;; --- flx-ido ----------------------------------------------------------------

(require-package 'flx-ido)
(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)
(setq ido-use-faces nil)


;; --- ido-ubiquitos ----------------------------------------------------------

(require-package 'ido-ubiquitous)
(ido-ubiquitous-mode)


;; --- smex -------------------------------------------------------------------

(require-package 'smex)
(smex-initialize)


;; --- projectile -------------------------------------------------------------

(require-package 'projectile)
(projectile-global-mode)
(setq projectile-enable-caching t)


;; --- project-explorer -------------------------------------------------------

(require-package 'project-explorer)
(add-to-list 'evil-emacs-state-modes 'project-explorer-mode)
(setq pe/width 23)


;; --- yasnippet --------------------------------------------------------------

(require-package 'yasnippet)
(yas-global-mode 1)

(setq yas-keymap (let ((map (make-sparse-keymap)))
                   (define-key map (kbd "C-o") 'yas-next-field-or-maybe-expand)
                   (define-key map (kbd "C-i") 'yas-prev-field)
                   (define-key map (kbd "C-g") 'yas-abort-snippet)
                   (define-key map (kbd "C-d") 'yas-skip-and-clear-or-delete-char)
                   map))


;; --- auto-complete ----------------------------------------------------------

(require-package 'auto-complete)

(define-key ac-complete-mode-map "\C-n" 'ac-next)
(define-key ac-complete-mode-map "\C-p" 'ac-previous)
(setq ac-auto-start nil)
(ac-set-trigger-key "C-f")

;; c
(require-package 'auto-complete-clang)
(defun ac-cc-mode-setup ()
  (setq ac-clang-flags (append (read-c-flags)
                               '("-code-completion-macros" "-code-completion-patterns"
                                 "-I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../lib/c++/v1"
                                 "-I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../lib/clang/5.1/include"
                                 "-I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include"
                                 "-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/usr/include")))
  (setq ac-sources '(ac-source-clang)))

;; common
(defun my-ac-config ()
  (add-hook 'c-mode-common-hook 'ac-cc-mode-setup)
  (global-auto-complete-mode t))
(my-ac-config)


;; --- flycheck ---------------------------------------------------------------

(require-package 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)

;; c
(defun my-flycheck-c-config ()
  (defun read-c-includes ()
    (defun include-path-flag-p (s)
      (cond ((>= (length s) (length "-I"))
             (string-equal (substring s 0 (length "-I")) "-I"))
            (t nil)))
    (mapcar #'(lambda (s) (substring s 2))
            (remove-if-not 'include-path-flag-p (read-c-flags))))
  (setq flycheck-clang-include-path (read-c-includes)))
(add-hook 'c-mode-common-hook 'my-flycheck-c-config)

(add-hook 'c++-mode-hook (lambda ()
                           (setq flycheck-clang-language-standard "c++11")))


;; --- perspective ------------------------------------------------------------

(require-package 'perspective)
(add-hook 'after-init-hook #'(lambda () (persp-mode 1)))


;; --- magit ------------------------------------------------------------------

(require-package 'magit)
(define-key evil-normal-state-map ",gs" 'magit-status)
(define-key evil-normal-state-map ",gl" 'magit-log)


;; --- diff-hl ----------------------------------------------------------------

(require-package 'diff-hl)
(global-diff-hl-mode)


;; --- pcmpl-git --------------------------------------------------------------

(require-package 'pcmpl-git)


;; --- haskell-mode -----------------------------------------------------------

(require-package 'haskell-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(eval-after-load "haskell-mode"
  '(progn
    (define-key haskell-mode-map (kbd "C-x C-d") nil)
    (define-key haskell-mode-map (kbd "C-c C-z") 'haskell-interactive-switch)
    (define-key haskell-mode-map (kbd "C-c C-l") 'haskell-process-load-file)
    (define-key haskell-mode-map (kbd "C-c C-b") 'haskell-interactive-switch)
    (define-key haskell-mode-map (kbd "C-c C-t") 'haskell-process-do-type)
    (define-key haskell-mode-map (kbd "C-c C-i") 'haskell-process-do-info)
    (define-key haskell-mode-map (kbd "C-c M-.") nil)
    (define-key haskell-mode-map (kbd "C-c C-d") nil)))


;; --- window-numbering -------------------------------------------------------

(require-package 'window-numbering)
(window-numbering-mode)


;; --- buffer-move ------------------------------------------------------------

(require-package 'buffer-move)
(global-set-key (kbd "M-h") 'buf-move-left)
(global-set-key (kbd "M-l") 'buf-move-right)
(global-set-key (kbd "M-k") 'buf-move-up)
(global-set-key (kbd "M-j") 'buf-move-down)


;; --- dired-details+ ---------------------------------------------------------

(require-package 'dired-details+)


;; --- dired-subtree ----------------------------------------------------------

(require-package 'dired-subtree)


;; --- auctex -----------------------------------------------------------------

(require 'tex)
(require 'preview)
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq TeX-PDF-mode t)
(TeX-global-PDF-mode t)
(setq-default TeX-master nil)

(require 'tex-site)
(add-hook 'TeX-mode-hook
          (lambda ()
            (add-to-list 'TeX-output-view-style
                         '("^pdf$" "."
                           "/Applications/Skim.app/Contents/SharedSupport/displayline %n %o %b"))))


;; --- maxframe ---------------------------------------------------------------

(require-package 'maxframe)
(add-hook 'window-setup-hook 'maximize-frame t)


;; --- web-mode ---------------------------------------------------------------

(require-package 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(setq web-mode-engines-alist '(("django" . "\\.html\\'")))


;; --- zencoding --------------------------------------------------------------

(require-package 'zencoding-mode)
(add-hook 'web-mode-hook 'zencoding-mode)


;; --- glsl-mode --------------------------------------------------------------

(require-package 'glsl-mode)


;; --- ein --------------------------------------------------------------------

(require-package 'ein)
(setq ein:use-auto-complete t)


;; --- rust-mode --------------------------------------------------------------

(require-package 'rust-mode)


;; --- js2-mode ---------------------------------------------------------------

(require-package 'js2-mode)


;; ----------------------------------------------------------------------------
;; languages
;; ----------------------------------------------------------------------------

(setq lua-indent-level 4)
(require-package 'lua-mode)

(require-package 'cmake-mode)


;; ----------------------------------------------------------------------------
;; manual
;; ----------------------------------------------------------------------------

(add-to-list 'load-path "~/.emacs.d/lisp/")

;; --- gud (with lldb) --------------------------------------------------------
(require 'gud)

;; --- magit config -----------------------------------------------------------
(require 'my-magit)


;; ----------------------------------------------------------------------------
;; interface
;; ----------------------------------------------------------------------------

;; reduce startup flicker?
(setq redisplay-dont-pause t)

;; don't save backup files
(setq make-backup-files nil)
(setq auto-save-default nil)

;; don't use mac fullscreen
(setq ns-use-native-fullscreen nil)

;; cleanup
(menu-bar-mode 0)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(set-default 'truncate-lines t)
(setq initial-scratch-message "")
(setq inhibit-startup-message t)
(defalias 'yes-or-no-p 'y-or-n-p)

;; transparency
(set-frame-parameter (selected-frame) 'alpha '(98 98))
(add-to-list 'default-frame-alist '(alpha 98 98))

;; scrolling
(setq scroll-margin 7
      scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position 1
      mouse-wheel-scroll-amount '(0.01))
(defun disable-scroll-margin ()
  (set (make-local-variable 'scroll-margin) 0))
(add-hook 'shell-mode-hook 'disable-scroll-margin)
(add-hook 'eshell-mode-hook 'disable-scroll-margin)
(add-hook 'gud-mode-hook 'disable-scroll-margin)
(add-hook 'magit-mode-hook 'disable-scroll-margin)

;; font
(defvar *default-font*
  "-apple-Menlo-medium-normal-normal-*-11-*-*-*-m-0-iso10646-1")
(when window-system (set-face-font 'default *default-font*))

;; gdb
(setq gdb-many-windows t)

;; dired
(setq-default dired-listing-switches "-alhv")

;; uniquify
(require 'uniquify)

;; continuous scroll for doc-view
(setq doc-view-continuous t)

;; allow undo of window config
(winner-mode 1)

;; disable popup dialogs
(defadvice yes-or-no-p (around prevent-dialog activate)
  "Prevent yes-or-no-p from activating a dialog"
  (let ((use-dialog-box nil))
    ad-do-it))
(defadvice y-or-n-p (around prevent-dialog-yorn activate)
  "Prevent y-or-n-p from activating a dialog"
  (let ((use-dialog-box nil))
    ad-do-it))

;; reload changed files
(global-auto-revert-mode 1)


;; ----------------------------------------------------------------------------
;; keys
;; ----------------------------------------------------------------------------

;; find
(define-key evil-normal-state-map ",f" 'projectile-find-file)
(define-key evil-normal-state-map " " 'projectile-find-file)

;; apps
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
(define-key evil-normal-state-map ",t" 'eshell)
(define-key evil-normal-state-map ",p" 'project-explorer-open)

;; persp
(define-key evil-normal-state-map ";w" 'persp-switch)
(define-key evil-normal-state-map ";r" 'persp-rename)
(define-key evil-normal-state-map ";k" 'persp-kill)
(define-key evil-normal-state-map ",a" 'persp-add-buffer)
(define-key evil-normal-state-map ",i" 'persp-import)
(define-key evil-normal-state-map ",k" 'persp-remove-buffer)

;; splits
(define-key evil-normal-state-map ",s" 'split-window-below)
(define-key evil-normal-state-map ",v" 'split-window-right)
(when (fboundp 'windmove-default-keybindings) (windmove-default-keybindings))
(global-set-key (kbd "C-h")  'windmove-left)
(global-set-key (kbd "C-l") 'windmove-right)
(global-set-key (kbd "C-k")    'windmove-up)
(global-set-key (kbd "C-j")  'windmove-down)
(define-key evil-normal-state-map ",q" 'delete-window)

;; buffers
(define-key evil-normal-state-map "\C-p" nil)
(global-set-key (kbd "C-p") 'previous-buffer)
(define-key evil-normal-state-map "\C-n" nil)
(global-set-key (kbd "C-n") 'next-buffer)

(setq cgame-path "/Users/nikki/Development/cgame/")
(setq cgame-scratch-path (concat cgame-path "/usr/scratch.lua"))
(defun cgame-scratch (&optional start end)
  (interactive (if (use-region-p)
                   (list (region-beginning) (region-end))
                 (list nil nil)))
  (if (and start end)
      (let ((buf (current-buffer))
            (n (count-lines 1 start)))
        (with-temp-buffer
          (while (> n 0) (insert "\n") (setq n (- n 1)))
          (insert-buffer-substring buf start end)
          (write-file cgame-scratch-path)))
    (let ((buf (current-buffer)))
      (with-temp-buffer
        (insert-buffer-substring buf)
        (write-file cgame-scratch-path)))))
(define-key evil-normal-state-map ",r" 'cgame-scratch)
(define-key evil-visual-state-map ",r" 'cgame-scratch)


;; ----------------------------------------------------------------------------
;; formatting
;; ----------------------------------------------------------------------------

(setq-default indent-tabs-mode nil)

;; c
(require 'cc-mode)
(setq c-default-style "bsd" c-basic-offset 4)
(c-set-offset 'case-label '+)
(define-key c-mode-base-map (kbd "RET") 'c-indent-new-comment-line)


;; ----------------------------------------------------------------------------
;; eshell
;; ----------------------------------------------------------------------------

(defun eshell/clear ()
  (interactive)
  (let ((inhibit-read-only t))
    (erase-buffer)))

(add-hook 'eshell-mode-hook
          '(lambda () (setenv "TERM" "eterm-color")))
(add-hook 'eshell-preoutput-filter-functions 'ansi-color-apply)


