;;; quantified.el - functions for working with quantifiedawesome.com

(require 'json)

(defcustom quantified-url "https://quantifiedawesome.com" "URL for Quantified Awesome instance")
(defcustom quantified-username nil "Username for Quantified Awesome")
(defcustom quantified-password nil "Password for Quantified Awesome")
(defvar quantified-token nil "Authentication token")

(defun quantified-path (&optional path)
  "Return the URL to Quantified Awesome"
  (concat quantified-url "/" path))
  
;; inspired by https://github.com/hober/37emacs/blob/master/backpack.el
(defun quantified-request (path &optional payload method)
  "Perform an API request to PATH.
PAYLOAD may contain extra arguments to certain API calls."
  (when (and payload (not (stringp payload)))
    (setq payload (encode-coding-string (json-encode payload) 'utf-8)))
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
    (let ((json-object-type 'alist)
					(json-array-type 'list))
      (json-read))))

(defun quantified-login ()
  "Log on to Quantified Awesome."
  (interactive)
  (let ((url-request-method "GET")
        url-request-data
        url-request-extra-headers)
    (setq quantified-token (alist-get
									'token
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
            nil "GET")))
          (categories (alist-get 'categories entries))
          my-list)
    (mapcar
     (lambda (row)
       (setq my-list (cons (cons (alist-get 'full_name (alist-get (car row) categories))
                                 (alist-get 'total (cddr row)))
													 my-list)))
     (alist-get 'rows (alist-get 'summary entries)))
    my-list))

(defun quantified-records (start &optional end options)
	"Return records between START and END."
	(quantified-parse-json
   (quantified-request
    (concat "records.json?start=" (or start "") "&end=" (or end "")
						(or options "&order=newest&display_type=time&split=keep"))
    (list (cons 'auth_token (quantified-token))) "GET")))

;;; SVG

(defun quantified-svg-to-text (svg)
	(with-temp-buffer
		(svg-print svg)
		(buffer-string)))

(defun quantified-svg-days (day num-days &optional direction g modify-func records)
	(let* ((start (quantified-midnight day))
				 (next-day (quantified-next-midnight day))
				 (end (quantified-next-midnight day nil num-days))
				 (direction (or direction 'horizontal))
				 (time-factor (/ 100.0 (- (time-to-seconds end) (time-to-seconds next-day))))
				 (day-size 20)
				 (main-size 1000)
				 (i 0))
		(unless records
			(setq records (quantified-records (format-time-string "%Y-%m-%d" start)
															(format-time-string "%Y-%m-%d" end))))
		(unless g
			(setq g
						(cond
						 ((eq direction 'horizontal)
							(svg-create main-size (* day-size num-days)))
						 (t
							(svg-create (* day-size num-days) main-size))))
			(dom-set-attribute g 'viewBox
												 (format "0 0 %s %s" (dom-attr g 'width)
																 (dom-attr g 'height)))
			(dom-set-attribute g 'preserveAspectRatio "none"))
		(dotimes (i num-days)
			(let ((group (dom-node 'g
															(if (eq direction 'horizontal)
																	`((width . ,main-size)
																		(height . ,day-size)
																		(transform . ,(format "translate(0 %d)" (* i day-size))))
																`((width . ,day-size)
																	(height . ,main-size)
																	(transform . ,(format "translate(%d 0)" (* i day-size)))))))
						(day-records (seq-filter
									 (lambda (o)
										 (let-alist o
											 (let* ((record-start (date-to-time .timestamp))
															(record-end (date-to-time .end_timestamp)))
												 (or (and (time-less-p record-end next-day)
																	(time-less-p start record-end))
														 (and (time-less-p record-start next-day)
																	(time-less-p start record-end))))))
									 records)))
				(dom-append-child g group)
				(quantified-svg-day start direction group nil
									day-records))
			(setq start next-day
						next-day (quantified-next-midnight start)))
		g))

(defun quantified-svg-day (day direction &optional g modify-func records)
	"Add segments for RECORDS for DAY for G.
DIRECTION should be 'horizontal or 'vertical."
	(let* ((start (quantified-midnight day))
				 (end (quantified-next-midnight day))
				 (time-factor (/ 100.0 (- (time-to-seconds end) (time-to-seconds start)))))
		(unless records
			(setq records (quantified-records (format-time-string "%Y-%m-%d" start)
															(format-time-string "%Y-%m-%d" end))))
		(unless g
			(cond
			 ((eq direction 'horizontal)
				(setq g (svg-create 500 20))
				(dom-set-attribute g 'viewBox "0 0 500 20"))
			 (t
				(setq g (svg-create 20 500))
				(dom-set-attribute g 'viewBox "0 0 20 500")))
			(dom-set-attribute g 'preserveAspectRatio "none"))
		(dolist (o records)
			(let-alist o
				(when (and .timestamp .end_timestamp)
					;; calculate time offset from start
					(let* ((record-start (date-to-time .timestamp))
								 (record-end (date-to-time .end_timestamp))
								 (clamped-start (if (time-less-p record-start start) start record-start))
								 (clamped-end (if (time-less-p end record-end) end record-end))
								 (start-pos-n (* time-factor (- (time-to-seconds clamped-start) (time-to-seconds start))))
								 (dim-n (* time-factor (- (time-to-seconds clamped-end) (time-to-seconds clamped-start))))
								 (attrs `((fill . ,.color) (stroke . ,.color) (stroke-opacity . 0.3)))
								 (rect
									(if (eq direction 'horizontal)
											(dom-node 'rect
																 `((width . ,(format "%.3f%%" dim-n))
																	 (height . "100%")
																	 (x . ,(format "%.3f%%" start-pos-n))
																	 (y . 0)
																	 ,@attrs))
										(dom-node 'rect
															 `((height . ,(format "%.3f%%" dim-n))
																 (width . "100%")
																 (y . ,(format "%.3f%%" start-pos-n))
																 (x . 0)
																 ,@attrs)))))
						(when (and (>= start-pos-n 0) (> dim-n 0))
							(dom-append-child
							 rect
							 (dom-node 'title nil
													(format "%s - %s: %s"
																	(format-time-string
																	 "%Y-%m-%d %H:%M"
																	 (date-to-time (alist-get 'timestamp o)))
																	(format-time-string
																	 "%H:%M"
																	 (date-to-time (alist-get 'end_timestamp o)))
																	(alist-get 'full_name o))))
							(when modify-func
								(setq rect (funcall modify-func g rect o)))
							(when rect
								(dom-append-child g rect)))))))
		g))

(defun quantified-midnight (day &optional zone)
	"Return Emacs time value for DAY at midnight in local time or ZONE if specified."
	(let ((day (decode-time (if (stringp day) (date-to-time day) day))))
		(encode-time
		 (list
			0 0 0
			(elt day 3)
			(elt day 4)
			(elt day 5)
			nil -1 zone))))

(defun quantified-next-midnight (day &optional zone num-days)
	"Return Emacs time value for the day after DAY at midnight in local time or ZONE if specified.
If NUM-DAYS is specified, add that many days."
	(let ((day (decode-time (if (stringp day) (date-to-time day) day))))
		(encode-time
		 (list
			0 0 0
			(+ (elt day 3) (or num-days 1))
			(elt day 4)
			(elt day 5)
			nil -1 zone))))

(provide 'quantified)

