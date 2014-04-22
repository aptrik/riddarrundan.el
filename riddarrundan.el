;;; riddarrundan.el --- Minor mode for reporting Riddarrundan results.

;; Copyright (C) 2014 Patrik Berglund

;;; Code:

(require 'helm)
(require 'yaml-mode)
(require 'yasnippet)

;; TODO
;; - Make sure total and score match up. (http://flycheck.github.io/Usage.html)

(defvar riddarrundan-players-file "spelare.yml")

(define-minor-mode riddarrundan-mode
  "Minor mode to support when inputting round results."
  :lighter " rr"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-c N") 'riddarrundan-new-round)
            (define-key map (kbd "C-c n") 'riddarrundan-new-result)
            map)
  (make-variable-buffer-local
   (defvar riddarrundan--result-dir
     (ignore-errors
       (file-name-directory
        (file-truename (buffer-file-name)))))))

(defvar riddarrundan--registered-players nil)
(defun riddarrundan--registered-players ()
  (let ((players '()))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "^- spelare: *\\(.*\\) *$" nil t)
        (add-to-list 'players (match-string-no-properties 1) t)))
    (setq riddarrundan--registered-players (sort players 'string<))))

(defun riddarrundan--player-candidates ()
  (let ((players '()))
    (with-temp-buffer
      (insert-file-contents
       (concat riddarrundan--result-dir riddarrundan-players-file))
      (goto-char (point-min))
      (while (re-search-forward "^- \\(.*\\) *$" nil t)
        (add-to-list 'players (match-string-no-properties 1) t)))
    (dolist (p riddarrundan--registered-players)
      (setq players (delete p players)))
    (sort players 'string<)))

(defvar helm-source-riddarrundan-players
  '((name . "Riddarrundan players")
    (volatile)
    (candidates . riddarrundan--player-candidates)
    (action . (("Insert" . insert)))))
;; TODO Add action to create new player.

(defun riddarrundan--select-player ()
  (helm :sources '(helm-source-riddarrundan-players)
        :prompt "Select a player: "
        :helm-candidate-number-limit 200))

(defun riddarrundan-new-round (&optional ask)
  "Create a new result file."
  (interactive "P")
  (when riddarrundan--result-dir
    (let* ((today (format-time-string "%Y-%m-%d" (current-time)))
           (date (if ask (read-string "Which date? " today nil today) today))
           (fname (concat riddarrundan--result-dir date ".yml")))
      (switch-to-buffer fname)
      (set-visited-file-name fname)
      (yaml-mode)
      (riddarrundan-mode 1)
      (insert
       "# -*- coding: utf-8; mode: yaml; mode: riddarrundan; -*-\n"
       "---\n"
       "omgång: " date "\n"
       "\n"
       "resultat:\n"))))

(defun riddarrundan-new-result ()
  "Insert a result."
  (interactive)
  (riddarrundan--registered-players)
  (beginning-of-line)
  (open-line 1)
  (yas-expand-snippet
   (concat
    "- spelare: ${1:`(riddarrundan--select-player)`}\n"
    "  totalt: ${2:54}\n"
    "  resultat: $0\n"
    "  ctp: ")
   nil nil '((yas-indent-line 'no))))

(provide 'riddarrundan)

;;; riddarrundan.el ends here
