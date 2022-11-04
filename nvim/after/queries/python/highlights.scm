; extends

; module docstring
(module . (expression_statement . ((string) @comment.doc)))

; class docstring
(class_definition
  body: (block . (expression_statement . ((string) @comment.doc))))

; function/method docstring
(function_definition
  body: (block . (expression_statement . ((string) @comment.doc))))

; attribute docstring
((expression_statement (assignment)) .
  (expression_statement . ((string) @comment.doc)))
