(require 'package)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))
(setq package-enable-at-startup nil)
(package-initialize)

(defun require-package (package)
  "Ensures that PACKAGE is installed. Stolen from Bailey Ling."
  (unless (or (package-installed-p package)
			  (require package nil 'noerror))
	(unless (assoc package package-archive-contents)
	  (package-refresh-contents))
	(package-install package)))

(require-package 'ujelly-theme)
(load-theme 'ujelly t)
(require-package 'evil)
(evil-mode t)
(require-package 'evil-commentary)
(evil-commentary-mode t)
(require-package 'evil-surround)
(global-evil-surround-mode t)
(require-package 'git-gutter)
(git-gutter-mode t)
(require-package 'whitespace)
(global-whitespace-mode t)
(require-package 'helm)
(helm-mode t)
(global-hl-line-mode t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
	("3f78849e36a0a457ad71c1bda01001e3e197fe1837cb6eaa829eb37f0a4bdad5" "aae95fc700f9f7ff70efbc294fc7367376aa9456356ae36ec234751040ed9168" default)))
 '(global-whitespace-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(setq-default
 inhibit-splash-screen t
 inhibit-startup-message t
 initial-scratch-message nil
 tab-width 4
 fill-column 120
 truncate-lines t
 whitespace-style (quote (face newline tab-mark newline-mark))
 whitespace-display-mappings '((tab-mark ?\t [?¦ ?\t] [?\\ ?\t])))


;; (require-package 'distinguished-theme)
;; (load-theme 'distinguished t)
(global-linum-mode t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
