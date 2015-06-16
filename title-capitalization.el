;;; title-capitalization.el --- Proper English title capitalization of a marked region
;; Copyright (C) 2015 and later by Karl Voit

;; Author: Karl Voit <tools@Karl-Voit.at>
;; Maintainer: Karl Voit <tools@Karl-Voit.at>
;; URL: http://github.com/nicferrier/example
;; Created: 2015-06-16
;; Version: 0.1
;; Keywords: lisp, tools
;; Package-Requires: 

;;; Code:


;; TEMPLATE:
;; ;; additionally to the list defined in title-capitalization:
;; (defvar my-do-not-capitalize-words '("lazyblorg" "mutt")
;;   "My personal list of words that doesn't get capitalized in titles.")


(defun title-capitalization (beg end)
  "Proper English title capitalization of a marked region"
  ;; - before: the presentation of this heading of my own from my keyboard and yet
  ;; - after:  The Presentation of This Heading of My Own from My Keyboard and Yet
  ;; - before: a a a a a a a a
  ;; - after:  A a a a a a a A
  (interactive "r")
  (save-excursion
    (let* (
	   ;; basic list of words which don't get capitalized according to simplified rules:
	   ;; http://karl-voit.at/2015/05/25/elisp-title-capitalization/
           (do-not-capitalize-basic-words '("a" "ago" "an" "and" "as" "at" "but" "by" "for"
                                            "from" "in" "into" "it" "next" "nor" "of" "off"
                                            "on" "onto" "or" "over" "past" "so" "the" "till"
                                            "to" "up" "yet"
                                            "n" "t" "es" "s"))
	   ;; if user has defined 'my-do-not-capitalize-words, append to basic list:
           (do-not-capitalize-words (if (boundp 'my-do-not-capitalize-words)
                                        (append do-not-capitalize-basic-words my-do-not-capitalize-words )
                                      do-not-capitalize-basic-words
                                      )
                                    )
           )
      ;; go to begin of first word:
      (goto-char beg)
      (capitalize-word 1)
      ;; go through the region, word by word:
      (while (< (point) end)
        (skip-syntax-forward "^w" end)
        (let ((word (thing-at-point 'word t)))
          (if (stringp word)
              ;; capitalize current word except it is list member:
              (if (member (downcase word) do-not-capitalize-words)
                  (downcase-word 1)
                (capitalize-word 1)))))
      ;; capitalize last word in any case:
      (backward-word 1)
      (if (and (>= (point) beg)
               (not (member (or (thing-at-point 'word t) "s")
                            '("n" "t" "es" "s"))))
          (capitalize-word 1)))))


(ert-deftest my-title-capitalization ()
  "Tests proper English title capitalization"
  (should (string= (with-temp-buffer
		     (insert "the presentation of this heading of my own from my keyboard and yet\n")
		     (goto-char (point-min))
		     (set-mark-command nil)
		     (goto-char (point-max))
		     ;(transient-mark-mode 1)
		     (title-capitalization)
		     (buffer-string))
		   "The Presentation of This Heading of My Own from My Keyboard and Yet\n"
		   )))


;; Teststrings:
;; this is a test and as at but mutt textsecure lazyblorg foobar
;; this is a test and as at but mutt textsecure lazyblorg foobar
;; This Is a Test and as at but mutt Textsecure lazyblorg Foobar

;;; title-capitalization.el ends here
