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
				

(require-package 'evil)
(evil-mode t)
(require-package 'evil-commentary)
(evil-commentary-mode t)
(require-package 'evil-surround)
(global-evil-surround-mode t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("aae95fc700f9f7ff70efbc294fc7367376aa9456356ae36ec234751040ed9168" default))))
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
 truncate-lines t)

(require-package 'distinguished-theme)

(load-theme 'distinguished t)
(global-linum-mode t)
(menu-bar-mode -1)
(tool-bar-mode -1)
