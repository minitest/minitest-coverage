(defface mtc-uncovered
  '((t :background "#ffdddd"))
  "Face for uncovered lines of code"
  :group 'mtc)

(defface mtc-covered
  '((t :background "#ddffdd" :inherit region))
  "Face for covered lines of code"
  :group 'mtc)

(defun mtc-overlay (coverage-path)
  (let ((coverage (assoc (intern (buffer-file-name))
                         (json-read-file coverage-path))))
    (when coverage
      (let ((coverage (cdr coverage))
            (line-pos
             (save-excursion
               (goto-char (point-min))
               (mapcar (lambda (n) (cons (line-beginning-position n)
                                         (line-end-position n)))
                       (number-sequence 1 (line-number-at-pos (point-max)))))))
        (remove-overlays)
        (mapcar* (lambda (cov range)
                   (when cov
                     (let ((start (car range))
                           (stop  (cdr range))
                           (color (if (zerop cov) 'mtc-uncovered 'mtc-covered)))
                       (if nil
                           ;; bad w/ font-lock
                           (with-silent-modifications
                             (put-text-property start stop 'font-lock-face color))
                         ;; bad with highlighted region
                         (overlay-put (make-overlay start stop)
                                      'face
                                      ;; (cons 'background-color color)
                                      (list color)))
                       )))
                 coverage line-pos)))))

(defun mtc-find-project-file (file &optional dir)
  (or dir (setq dir default-directory))
  (let ((file-path (concat (file-name-as-directory dir) file)))
   (if (file-exists-p file-path)
       file-path
     (if (equal dir "/")
         nil
       (mtc-find-project-file file
                              (directory-file-name (file-name-directory dir)))))))

(defun mtc-update ()
  (interactive)
  (let ((coverage-path (mtc-find-project-file "coverage.json")))
    (when coverage-path
      (mtc-clear)
      (mtc-overlay coverage-path)
      nil)))

(defun mtc-clear ()
  (interactive)
  (remove-overlays))

;; (with-current-buffer (window-buffer (next-window)) (mtc-update))
;; (with-current-buffer (window-buffer (next-window)) (mtc-clear))
