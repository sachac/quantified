;;; quantified.el - functions for working with quantifiedawesome.com

(require 'json)

(defcustom quantified-host "quantifiedawesome.com" "URL for Quantified Awesome instance")
(defcustom quantified-username nil "Username for Quantified Awesome")
(defcustom quantified-password nil "Password for Quantified Awesome")
(defvar quantified-token nil "Authentication token")

(defun quantified-path (&optional path)
  "Return the URL to Quantified Awesome"
  (concat "http://" quantified-host "/" path))
  
;; inspired by https://github.com/hober/37emacs/blob/master/backpack.el
(defun quantified-request (path &optional payload method)
  "Perform an API request to PATH.
PAYLOAD may contain extra arguments to certain API calls."
  (when (and payload (not (stringp payload)))
    (setq payload (json-encode payload)))
  (let ((url-package-name "quantified.el")
	(url-mime-encoding-string "identity")
	(url-request-method (or method "POST"))
        (url-request-extra-headers '(("Content-Type" . "application/json")))
	(url-http-attempt-keepalives nil)
        (url-request-data payload))
    (condition-case nil
	(url-retrieve-synchronously
	 (quantified-path path)))))
 
;; http://code.google.com/p/openhandle/wiki/OpenHandleCodeLisp
(defun quantified-parse-json (buffer)
  "Parse the json string in BUFFER."
  (save-excursion
    (set-buffer buffer)
    (goto-char (point-min))
    (delete-region (point-min) (search-forward "\n\n"))
    (let ((json-object-type 'hash-table))
      (json-read))))

(defun quantified-login ()
  "Log on to Quantified Awesome."
  (interactive)
  (let ((url-request-method "GET")
        url-request-data
        url-request-extra-headers)
    (setq quantified-token (gethash
                            "token"
                            (quantified-parse-json
                             (quantified-request
                              "api/v1/tokens.json"
                              (list (cons "login" quantified-username)
                                    (cons "password" quantified-password))))))))

(defun quantified-token ()
  "Return the token or log in if necessary."
  (or quantified-token (quantified-login)))
   
(defun quantified-record-create (entry)
  "Create a record."
  (quantified-parse-json
   (quantified-request
    "api/v1/records.json"
    (cons (cons 'auth_token (quantified-token))
          entry))))

(defun quantified-text (text)
  "Save a quick snippet of text."
  (interactive "MText: ")
  (quantified-record-create
   (list
    (cons 'source "Emacs")
    (cons 'category "Text")
    (cons 'data (list (cons 'note text))))))

(defun quantified-track (category)
  "Track something quickly."
  (interactive "MCategory: ")
  (let ((response (quantified-record-create
                   (list
                    (cons 'source "Emacs")
                    (cons 'category category)))))))

(defun quantified-share-org-subtree ()
  "Push the current Org subtree to Quantified Awesome as a record."
  (interactive)
  ;; Get the current Org subtree
  (quantified-record-create
   (list
    (cons 'record "Text")
    (cons 'data
          (cons 'note
                (save-excursion
                  (buffer-substring-no-properties
                   (1+ (and (org-back-to-heading) (line-end-position)))
                   (org-end-of-subtree))))))))

(defun quantified-summarize-time (start end)
  "Return an alist of (category-name . total time) for all entries between START and END."
  (let* ((entries
          (quantified-parse-json
           (quantified-request
            (concat "time/review.json?start=" start "&end=" end "&category_tree=full&display_type=time&commit=Filter")
            (list (cons 'auth_token (quantified-token))) "GET")))
          (categories (gethash "categories" entries))
          my-list)
    (maphash
     (lambda (key value)
       (setq my-list (cons (cons (gethash "full_name" (gethash key categories))
                                 (gethash "total" value)) my-list)))
     (gethash "rows" (gethash "summary" entries)))
    my-list))


;; Create the request

(provide 'quantified)

