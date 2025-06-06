;;--------------------------------------------------------------------
;; lispy
;;--------------------------------------------------------------------

(with-eval-after-load 'lispyville
  (lispyville-set-key-theme '(operators c-w (escape insert) mark-toggle))
  (lispyville--define-key '(motion normal visual)
    (kbd "M-h") #'lispyville-previous-opening
    (kbd "M-l") #'lispyville-next-opening
    (kbd "M-H") #'lispy-up-slurp
    (kbd "M-J") #'lispyville-drag-forward
    (kbd "M-K") #'lispyville-drag-backward
    (kbd "M-L") #'lispy-move-right
    (kbd "C-x C-e") #'lispy-eval
    (kbd "C-<return>") #'lispy-join
    (kbd "M-<backspace>") 'lispyville-delete-backward-word
    ")" #'lispy-right)
  (lispyville--define-key 'insert
    (kbd "<backspace>") 'lispy-delete-backward
    (kbd "M-<backspace>") 'lispyville-delete-backward-word
    ";" 'lispy-comment
    "'" 'lispy-tick
    "`" 'lispy-backtick
    "\"" 'lispy-quotes
    "(" 'lispy-parens
    ")" 'lispy-right-nostring))

(defun boogs/init-lispy ()
  (when (require 'lispy nil t)
    (if (require 'sly nil 'noerror)
        (setq lispy-use-sly t)
        ;;(progn
          ;;(add-to-list 'lispy-goto-symbol-alist
            ;;           '(sly-mrepl-mode lispy-goto-symbol-lisp le-lisp))
          ;;(setq lispy-use-sly t)))
      )
    (set-face-foreground 'lispy-face-hint "#FF00FF")
    (when (require 'lispyville nil t)
      (add-hook 'lispy-mode-hook 'lispyville-mode))
    (lispyville-mode)))

(with-eval-after-load 'lispy
  (require 'patch-lispy nil :noerror))

(provide 'init-lispy)
