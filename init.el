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

;(require-package 'color-theme-sanityinc-tomorrow)
;(load-theme 'sanityinc-tomorrow-night t)

;(require-package 'leuven-theme)
;(load-theme 'leuven t)

;(require-package 'cyberpunk-theme)
;(load-theme 'cyberpunk t)

;(require-package 'soothe-theme)

;(require-package 'zonokai-theme)
;(load-theme 'zonokai t)

(require-package 'monokai-theme)
(load-theme 'monokai t)


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

;(require-package 'flx-ido)
;(ido-mode 1)
;(ido-everywhere 1)
;(flx-ido-mode 1)
;(setq ido-use-faces nil)


;; --- ido-ubiquitos ----------------------------------------------------------

;(require-package 'ido-ubiquitous)
;(ido-ubiquitous-mode)


;; --- smex -------------------------------------------------------------------

;(require-package 'smex)
;(smex-initialize)


;; --- ag ---------------------------------------------------------------------

(require-package 'ag)
(add-to-list 'evil-motion-state-modes 'ag-mode)
(setq ag-highlight-search t)
(defun eshell/ag (&rest args)
  (compilation-start
   (mapconcat 'shell-quote-argument
              (append (list ag-executable
                            "--color" "--color-match" "30;43"
                            "--smart-case" "--nogroup" "--column" "--")
                      args) " ")
   'ag-mode))


;; --- projectile -------------------------------------------------------------

(require-package 'projectile)
(projectile-global-mode)
(setq projectile-enable-caching t)


;; --- helm -------------------------------------------------------------------

(require-package 'helm)
(setq helm-command-prefix-key "C-c h")

(require 'helm-config)
(require 'helm-eshell)
(require 'helm-files)
(require-package 'helm-projectile)

(setq
 helm-scroll-amount 4
 helm-quick-update t
 helm-ff-search-library-in-sexp t

 helm-split-window-default-side 'other
 helm-split-window-in-side-p t
 helm-candidate-number-limit 200
 helm-M-x-requires-pattern 0
 helm-ff-file-name-history-use-recentf t
 helm-move-to-line-cycle-in-source t

 ido-use-virtual-buffers t
 helm-buffers-fuzzy-matching t)

; keys to launch helm
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "C-x b") 'helm-mini)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(define-key evil-normal-state-map ",f" 'helm-projectile)
(define-key evil-normal-state-map " " 'helm-projectile)
(global-set-key (kbd "C-c h o") 'helm-occur)
(define-key evil-normal-state-map ",o" 'helm-occur)
(add-hook 'eshell-mode-hook
          #'(lambda ()
              (define-key eshell-mode-map
                [remap eshell-pcomplete]
                'helm-esh-pcomplete)))
(add-hook 'eshell-mode-hook
          #'(lambda () (define-key eshell-mode-map (kbd "M-l")  'helm-eshell-history)))

; keys in helm
(define-key helm-map (kbd "C-k") 'helm-previous-line)
(define-key helm-map (kbd "C-j") 'helm-next-line)
(define-key helm-map (kbd "C-h") 'helm-previous-source)
(define-key helm-map (kbd "C-l") 'helm-next-source)
(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
(define-key helm-find-files-map (kbd "C-h") 'helm-find-files-up-one-level)
(define-key helm-find-files-map (kbd "C-l") 'helm-execute-persistent-action)

; go!
(helm-mode 1)


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

;(require-package 'perspective)
;(add-hook 'after-init-hook #'(lambda () (persp-mode 1)))


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
(global-set-key (kbd "C-c 1") 'select-window-1)
(global-set-key (kbd "C-c 2") 'select-window-2)
(global-set-key (kbd "C-c 3") 'select-window-3)
(global-set-key (kbd "C-c 4") 'select-window-4)
(global-set-key (kbd "C-c 5") 'select-window-5)
(global-set-key (kbd "C-c 6") 'select-window-6)
(global-set-key (kbd "C-c 7") 'select-window-7)


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

(setq LaTeX-command-style '(("" "%(PDF)%(latex) -file-line-error %S%(PDFout)")))

(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

(add-hook 'LaTeX-mode-hook 'visual-line-mode)
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)

(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(setq reftex-plug-into-AUCTeX t)


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


;; --- ggtags -----------------------------------------------------------------

(require-package 'ggtags)

(add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
              (ggtags-mode 1))))
(define-key evil-normal-state-map (kbd "M-.") nil)
(define-key evil-normal-state-map (kbd "C-]") 'ggtags-find-tag-dwim)


;; --- company ----------------------------------------------------------------

(require-package 'company)
(add-to-list 'company-backends 'company-omnisharp)
(setq company-idle-delay 0.2)
(add-hook 'csharp-mode-hook 'company-mode)
(define-key company-active-map (kbd "\C-n") 'company-select-next)
(define-key company-active-map (kbd "\C-p") 'company-select-previous)
(define-key company-active-map (kbd "\C-d") 'company-show-doc-buffer)
(define-key company-active-map (kbd "<tab>") 'company-complete)


;; --- omnisharp --------------------------------------------------------------

(require-package 'omnisharp)
(add-hook 'csharp-mode-hook 'omnisharp-mode)
(add-hook 'csharp-mode-hook (lambda () (setq omnisharp--auto-complete-display-backend nil)))

(setq omnisharp-server-executable-path "/Users/nikki/Development/OmniSharpServer/OmniSharp/bin/Debug/OmniSharp.exe")

(evil-define-key 'insert omnisharp-mode-map (kbd "M-.") 'omnisharp-auto-complete)
(evil-define-key 'normal omnisharp-mode-map (kbd "<f12>") 'omnisharp-go-to-definition)
(evil-define-key 'normal omnisharp-mode-map (kbd "g u") 'omnisharp-find-usages)
(evil-define-key 'normal omnisharp-mode-map (kbd "g o") 'omnisharp-go-to-definition)
(evil-define-key 'normal omnisharp-mode-map (kbd "g r") 'omnisharp-run-code-action-refactoring)
(evil-define-key 'normal omnisharp-mode-map (kbd "g f") 'omnisharp-fix-code-issue-at-point)
(evil-define-key 'normal omnisharp-mode-map (kbd "g R") 'omnisharp-rename)
(evil-define-key 'normal omnisharp-mode-map (kbd ", i") 'omnisharp-current-type-information)
(evil-define-key 'insert omnisharp-mode-map (kbd ".") 'omnisharp-add-dot-and-auto-complete)
(evil-define-key 'normal omnisharp-mode-map (kbd ", n t") 'omnisharp-navigate-to-current-file-member)
(evil-define-key 'normal omnisharp-mode-map (kbd ", n s") 'omnisharp-navigate-to-solution-member)
(evil-define-key 'normal omnisharp-mode-map (kbd ", n f") 'omnisharp-navigate-to-solution-file-then-file-member)
(evil-define-key 'normal omnisharp-mode-map (kbd ", n F") 'omnisharp-navigate-to-solution-file)
(evil-define-key 'normal omnisharp-mode-map (kbd ", n r") 'omnisharp-navigate-to-region)
(evil-define-key 'normal omnisharp-mode-map (kbd "<f12>") 'omnisharp-show-last-auto-complete-result)
(evil-define-key 'insert omnisharp-mode-map (kbd "<f12>") 'omnisharp-show-last-auto-complete-result)
(evil-define-key 'normal omnisharp-mode-map (kbd ",.") 'omnisharp-show-overloads-at-point)
(evil-define-key 'normal omnisharp-mode-map (kbd ",rt") (lambda() (interactive) (omnisharp-unit-test "single")))
(evil-define-key 'normal omnisharp-mode-map (kbd ",rf") (lambda() (interactive) (omnisharp-unit-test "fixture")))
(evil-define-key 'normal omnisharp-mode-map (kbd ",ra") (lambda() (interactive) (omnisharp-unit-test "all")))
(evil-define-key 'normal omnisharp-mode-map (kbd ",rl") 'recompile)

(setq omnisharp-auto-complete-want-documentation nil)


;; --- slime ------------------------------------------------------------------

;; setup load-path and autoloads
(add-to-list 'load-path "~/quicklisp/dists/quicklisp/software/slime-2.10.1")
(require 'slime-autoloads)
(setq slime-contribs '(slime-fancy slime-company slime-highlight-edits))
(setq slime-repl-return-behaviour :send-only-if-after-complete)


;; --- cider ------------------------------------------------------------------

(require-package 'cider)

(setq cider-repl-use-clojure-font-lock t) ; syntax highlighting in REPL
(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode) ; argument hints
(add-hook 'cider-repl-mode-hook 'subword-mode) ; CamelCase word jumps

;; autocompletion
(add-hook 'cider-mode-hook 'company-mode)
(add-hook 'cider-repl-mode-hook 'company-mode)

;; don't show '^M's in repl
(defun remove-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))
(add-hook 'cider-repl-mode-hook 'remove-dos-eol)


;; --- smartparents -----------------------------------------------------------

;(require-package 'smartparens)
;(smartparens-global-mode t)
;(require 'smartparens-config)
;(sp-use-smartparens-bindings)
;(add-hook 'clojure-mode-hook 'smartparens-strict-mode)
;(add-hook 'cider-repl-mode-hook 'smartparens-strict-mode)


;; --- neotree ----------------------------------------------------------------

(require-package 'neotree)
(global-set-key [f8] 'neotree-toggle)
(add-hook 'neotree-mode-hook
          (lambda ()
            (define-key evil-normal-state-local-map (kbd "TAB") 'neotree-enter)
            (define-key evil-normal-state-local-map (kbd "SPC") 'neotree-enter)
            (define-key evil-normal-state-local-map (kbd "q") 'neotree-hide)
            (define-key evil-normal-state-local-map (kbd "RET") 'neotree-enter)))


;; --- paredit, paxedit -------------------------------------------------------

(require-package 'paxedit)
;; (require-package 'evil-paredit)
(add-hook 'lisp-mode-hook 'paredit-mode)
;; (add-hook 'lisp-mode-hook 'evil-paredit-mode)
(add-hook 'slime-repl-mode-hook 'enable-paredit-mode)
(defun override-slime-repl-bindings-with-paredit ()
   (define-key slime-repl-mode-map
        (read-kbd-macro paredit-backward-delete-key)
            nil))
    (add-hook 'slime-repl-mode-hook 'override-slime-repl-bindings-with-paredit)

(add-hook 'lisp-mode-hook 'paxedit-mode)
(eval-after-load "paxedit"
                 '(progn (define-key paxedit-mode-map (kbd "M-<right>") 'paxedit-transpose-forward)
                         (define-key paxedit-mode-map (kbd "M-<left>") 'paxedit-transpose-backward)
                         (define-key paxedit-mode-map (kbd "M-<up>") 'paxedit-backward-up)
                         (define-key paxedit-mode-map (kbd "M-<down>") 'paxedit-backward-end)
                         (define-key paxedit-mode-map (kbd "M-b") 'paxedit-previous-symbol)
                         (define-key paxedit-mode-map (kbd "M-f") 'paxedit-next-symbol)
                         (define-key paxedit-mode-map (kbd "C-%") 'paxedit-copy)
                         (define-key paxedit-mode-map (kbd "C-&") 'paxedit-kill)
                         (define-key paxedit-mode-map (kbd "C-*") 'paxedit-delete)
                         (define-key paxedit-mode-map (kbd "C-^") 'paxedit-sexp-raise)
                         (define-key paxedit-mode-map (kbd "M-u") 'paxedit-symbol-change-case)
                         (define-key paxedit-mode-map (kbd "C-@") 'paxedit-symbol-copy)
                         (define-key paxedit-mode-map (kbd "C-#") 'paxedit-symbol-kill)))


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

;; apps
(define-key evil-normal-state-map ",t" 'eshell)

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

;; cgame
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



;; find file at point goes to line number
(defvar ffap-file-at-point-line-number nil
  "Variable to hold line number from the last `ffap-file-at-point' call.")
(defadvice ffap-file-at-point (after ffap-store-line-number activate)
  "Search `ffap-string-at-point' for a line number pattern and
save it in `ffap-file-at-point-line-number' variable."
  (let* ((string (ffap-string-at-point)) ;; string/name definition copied from `ffap-string-at-point'
         (name
          (or (condition-case nil
                  (and (not (string-match "//" string)) ; foo.com://bar
                       (substitute-in-file-name string))
                (error nil))
              string))
         (line-number-string 
          (and (string-match ":[0-9]+" name)
               (substring name (1+ (match-beginning 0)) (match-end 0))))
         (line-number
          (and line-number-string
               (string-to-number line-number-string))))
    (if (and line-number (> line-number 0)) 
        (setq ffap-file-at-point-line-number line-number)
      (setq ffap-file-at-point-line-number nil))))
(defadvice find-file-at-point (after ffap-goto-line-number activate)
  "If `ffap-file-at-point-line-number' is non-nil goto this line."
  (when ffap-file-at-point-line-number
    (goto-line ffap-file-at-point-line-number)
    (setq ffap-file-at-point-line-number nil)))


;; ----------------------------------------------------------------------------
;; run local.el for computer-specific settings
;; ----------------------------------------------------------------------------

(when (file-exists-p "~/.emacs.d/local.el") (load-file "~/.emacs.d/local.el"))
