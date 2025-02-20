(in-package #:perplexity)

;; define the environment variable "OPENAI_KEY" with the value of your OpenAI API key

(defvar *model-host* "https://api.perplexity.ai/chat/completions")
;; use gpt-4o for very good results, or gpt-4o-mini to save abt 20x on costs, with similar results:
(defvar *model* "sonar-pro")

(defun openai-helper (curl-command)
  (princ curl-command)
  (let ((response
          (uiop:run-program
           curl-command
           :output :string)))
    (pprint response)
    (with-input-from-string
        (s response)
      (let* ((json-as-list (json:decode-json s)))
        ;; extract text (this might change if OpenAI changes JSON return format):
        (cdr (assoc :content (cdr (assoc :message (cadr (assoc :choices json-as-list))))))))))


(defun research (starter-text)
  "Send a search and LLM request"
  (let* ((input-text (write-to-string starter-text))
         (request-body
          (cl-json:encode-json-to-string
           `((:messages . (((:role . "user") (:content . ,input-text))))
             (:model . ,*model*))))
         (curl-command
           (format nil 
                  "curl ~A ~
                   -H \"Content-Type: application/json\" ~
                   -H \"Authorization: Bearer ~A\" ~
                   -d '~A'"
                   *model-host*
                   (uiop:getenv "PERPLEXITY_API_KEY")
                   request-body)))
    (openai-helper curl-command)))

#|

(print (perplexity:research "consultant Mark Watson has written AI and Lisp books. What musical instruments does he play?"))

|#
