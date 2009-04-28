;;; shindent.el --- indentation support for shell-script modes for some shells

;;; Commentary:
;;
;; This is an "add-on" for sh-script.el to implementation indentation
;; for some shells.   csh derivatives are not supported,  but sh
;; rc derived shells are.
;;
;; Eventually I'd like to see this merged into sh-script.el,  but for
;; now it must be loaded separately,  after which it is invoked
;; automatically from sh-script mode's hook.
;;
;;
;; Suggested Setup
;;
;; One way would simply be to load shindent.el,  by (assuming it is in
;; your load-path):
;;      (require 'shindent)
;;
;; Alternatively,  you can arrange for shindent to be loaded whenever
;; sh-script.el is loaded, like this:
;;      (eval-after-load "sh-script"
;;        '(require 'shindent))
;;
;; Customization:
;;
;; Indentation for rc and es modes is very limited, but for Bourne shells
;; and its derivatives it is quite customizable.
;;
;; The following description applies to sh and derived shells (bash,
;; zsh, ...).
;;
;; There are various customization variables which allow tailoring to
;; a wide variety of styles.  Most of these variables are named
;; shi-indent-for-XXX and shi-indent-after-XXX.  For example.
;; shi-indent-after-if controls the indenting of a line following
;; and if statement,  and shi-indent-for-fi controls the indentation
;; of the line containing the fi.
;;
;; You can set each to a numeric value, but it is often more convenient
;; to use the symbol '+ or '- which used the "default" value (or its
;; negative) which is the value in variable  `shi-basic-offset'.
;; By changing this one variable you can increase or decrease how much
;; indentation there is.
;;
;;
;; Examples are sometimes handy;   some possibilities for indenting
;; an sh if statement are:
;;
;; if [ aaa ] ; then
;;     bbb
;; else
;;     ccc
;; fi
;; ddd
;;
;; if [ aaa ] ; then
;;         bbb
;;     else
;;         ccc
;;     fi
;; ddd
;;
;;
;; If you like `then' on a line by itself,  you could have (shown side by
;; side for brevity):
;;
;; if [ aaa ]        if [ aaa ]        if [ aaa ]       if [ aaa ]
;; then                    then          then             then
;;       bbb               bbb               bbb              bbb
;; else              else              else               else
;;       ccc               ccc               ccc              ccc
;; fi                fi                fi                 fi
;; ddd               ddd               ddd              ddd
;;
;;
;; There are 4 commands to help set these variables:
;;
;; shi-show-indent
;;    This shows what variable controls the indentation of the current
;;    line and its value.
;;
;; shi-set-indent
;;    This allows you to set the value of the variable controlling the
;;    current line's indentation.  You can enter a number, or one of a
;;    number of special symbols to denote the value of shi-basic-offset,
;;    or its negative, or half it, or twice it, or..  If you've used
;;    cc-mode this should be familiar.
;;
;; shi-learn-line-indent
;;    Simply make the line look the way you want it, then invoke this
;;    function.  It will set the value of the variable to the value
;;    that makes the line indent like that.  If the value is that of
;;    shi-basic-offset it will set it to the symbol `+' and so on.
;;    
;; shi-learn-buffer-indent
;;    This is the deluxe function!  It "learns" the whole buffer (use
;;    narrowing if you want it to process only part).  It outputs to a
;;    buffer *indent* any conflicts it finds, and then outputs to it all
;;    the variables it has learned.  This buffer is a sort of Occur mode
;;    buffer, allowing you to easily find where something was set.  It is
;;    popped to automatically if there are any conflicts found or if
;;    `shi-popup-occur-buffer' is non-nil.  It will attempt to learn
;;    `shi-indent-comment' if all comments follow the same pattern; if
;;    they don't it sets it to nil.  It can be made to set
;;    `shi-basic-offset' depending on how variable
;;    `shi-learn-basic-offset' is set.  If it does not set it, it will
;;    write into the *indent* buffer its guess or guesses if it finds
;;    some.
;;    Unfortunately, this command can take a long time to run
;;    (e.g. if there are large case statements).  Perhaps it does not
;;    make sense to run it on large buffers:  if lots of lines have
;;    different indentation styles it will produce a lot of
;;    diagnostics in the *indent* buffer;  if there is a consistent
;;    style then running `shi-learn-buffer-indent' on a small region
;;    of the buffer should suffice.   Maybe.
;;
;; These commands are not bound by default, but can easily be done
;; so using a hook.
;;
;;    Hooks
;;
;; When hook `shi-set-shell-hook' is called the shell type is known.
;; Example use:
;; (defun my-shi-set-shell-hook ()
;;   (message (format "shell type: %s  shi-basic-offset it %s"
;;                 sh-shell shi-basic-offset))
;;   (local-set-key '[f9] 'shi-show-indent)
;;   (local-set-key '[f10] 'shi-set-indent)
;;   (local-set-key '[f11] 'shi-learn-line-indent)
;;   (local-set-key '[f12] 'shi-learn-buffer-indent)
;;   )
;; (add-hook 'shi-set-shell-hook 'my-shi-set-shell-hook)
;;
;; `shi-hook' is, I think, obsolete now and may be removed.
;;
;;
;;  
;; Saving indentation values...
;;
;; After you've learned the values in a buffer, how to you remember
;; them?   Originally I had hoped that `shi-learn-buffer-indent'
;; would make this unnecessary;  simply learn the values when you visit
;; the buffer.
;; You can do this automatically like this:
;;   (add-hook 'shi-set-shell-hook 'shi-learn-buffer-indent)
;;
;; However...
;;
;; For one thing,  `shi-learn-buffer-indent' is extremely slow,
;; especially on large-ish buffer.  Also,  if there are conflicts the
;; "last one wins" which may not produce the desired setting.
;;
;; So...
;;  
;; There is a minimal way of being able to save indentation values and
;; to reload them in another buffer or at another point in time.
;;
;; Note: This should be considered tentative at best...
;; It is a bit like cc-mode's styles,  but the user interface is
;; different and the internal format is different.  I am assuming that
;; while one may deal with only a few different styles of C,  one may
;; be faced with a bigger variety of shell script settings.  Perhaps
;; this is not true.  Anyway,  this is how to use it.
;;
;; Use `shi-name-style' to give a name to the indentation settings of
;;      the current buffer.
;; Use `shi-load-style' to load indentation settings for the current
;;      buffer from a specific style.
;; Use `shi-save-styles-to-buffer' to write all the styles to a buffer
;;      in lisp code.  You can then store it in a file and later use
;;      `load-file' to load it.
;;
;;
;; Indentation variables - buffer local or global?
;;
;; I think that often having them buffer-local makes sense,
;; especially if one is using `shi-learn-buffer-indent'.  However, if
;; a user sets values using customization,  these changes won't appear
;; to work if the variables are already local!
;;
;; To get round this,  there is a variable `shi-make-vars-local' and 2
;; functions: `shi-make-vars-local' and
;; `shi-reset-indent-vars-to-global-values' .
;;
;; If `shi-make-vars-local' is non-nil,  then these variables become
;; buffer local when the mode is established.
;; If this is nil,  then the variables are global.  At any time you
;; can make them local with the command `shi-make-vars-local'.
;; Conversely,  to update with the global values you can use the
;; command `shi-reset-indent-vars-to-global-values'.
;;
;; This may be awkward,  but the intent is to cover all cases.
;;
;;
;;
;; Awkward things, pitfalls, ...
;;
;; Indentation for a sh script is complicated for a number of reasons:
;;
;; 1. You can't format by simply looking at symbols,  you need to look
;;    at keywords.  [This is not the case for rc and es shells.]
;; 2. The character ")" is used both as a matched pair "(" ... ")" and
;;    as a stand-alone symbol (in a case alternative).  This makes
;;    things quite tricky!
;; 3. Here-documents in a script should be treated "as is",  and when
;;    they terminate we want to revert to the indentation of the line
;;    containing the "<<" symbol.
;; 4. A line may be continued using the "\".
;; 5. The character "#" (outside a string) normally starts a comment,
;;    but it doesn't in the sequence "$#"!
;;
;; To try and address points 2 3 and 5 I used a feature that cperl mode
;; uses,  that of a text's syntax property.  This, however, has 2
;; disadvantages:
;; 1. We need to scan the buffer to find which ")" symbols belong to a
;;    case alternative, to find any here documents, and handle "$#".
;; 2. Setting the text property makes the buffer modified,  and cannot
;;    be done in a read-only buffer.  Since you may start visiting a
;;    read-only buffer and then want to change something,  we rescan
;;    the buffer when going from read-only to non read-only.  Since I
;;    couldn't find a suitable hook,  I constructed one (for
;;    toggle-read-only) using `advice'.
;;
;;
;;
;; BUGS:
;;
;; - Here-documents are marked with text properties face and syntax
;;   table.  This serves 2 purposes: stopping indentation while inside
;;   them, and moving over them when finding the previous line to
;;   indent to.  However, if font-lock mode is active when there is
;;   any change inside the here-document font-lock clears that
;;   property.  This causes several problems: lines after the here-doc
;;   will not be re-indentation properly,  words in the here-doc region
;;   may be fontified,  and indentation may occur within the
;;   here-document.
;;   I'm not sure how to fix this, perhaps using the point-entered
;;   property.  Anyway, if you use font lock and change a
;;   here-document,  I recommend using M-x shi-rescan-buffer after the
;;   changes are made.  Similarly, when using higlight-changes-mode,
;;   changes inside a here-document may confuse shindent,  but again
;;   using `shi-rescan-buffer' should fix them.
;;
;; - Indenting many lines is slow.  It currently does each line
;;   independantly, rather than saving state information.
;;
;; - `shi-learn-buffer-indent' is extremely slow.
;;
;;
;; Possible Future Plans:
;;
;; - integrate with sh-script.el.
;; - have shi-get-indent-info optionally use and return state info to
;;   make indent-region less slow.
;;
;; Richard Sharman <rsharman@pobox.com>  June 1999.
;; Newer versions may be availabale in
;; http://pobox.com/~rsharman/emacs/

;;; History:
;;

;;; Code:

(require 'sh-script)

(defgroup shindent nil
  "Indentation for Shell script mode"
  :group 'sh
  )

(defgroup shindent-vars nil
  "Indentation variables for shindent."
  :group 'shindent)

(defcustom shi-learn-basic-offset nil
  "*When `shi-guess-basic-offset' should learn `shi-basic-offset'.

nil mean:              never.
t means:               if we are \"reasonably sure\" about the value.
Anything else means:   if we have a \"good guess\" as to the value."

  :type '(choice
          (const :tag "Never" nil)
          (const :tag "Only if sure"  t)
          (const :tag "If have a good guess" usually)
          )
  :group 'shindent
  )

(defcustom shi-set-shell-hook nil
  "*Hook run by `shi-shell-setup'."
   :type 'hook
   :group 'shindent)

(defcustom shi-hook nil
  "*Hook run by `shi-setup'."
   :type 'hook
  :group 'shindent)

(defcustom shi-learn-basic-offset nil
  "*When `shi-guess-basic-offset' should learn `shi-basic-offset'.

nil mean:              never.
t means:               only if there seems to be an obvious value.
Anything else means:   whenever we have a \"good guess\" as to the value."
:group 'shindent)

(defcustom shi-popup-occur-buffer nil
  "*Controls when  `shi-learn-buffer-indent' poos the *indent* buffer.
If t it is always shown.  If nil,  it is shown only when there
are conflicts."
  :type '(choice
          (const :tag "Only when there are conflicts." nil)
          (const :tag "Always"  t)
          )
  :group 'shindent)

(defcustom shi-blink t
  "*If non-nil,  `shi-show-indent' shows the line indentation is relative to.
The position on the line is not necessarily meaningful.
In some cases the line will be the matching keyword, but this is not
always the case."
  :type 'boolean
  :group 'shindent)

(defcustom shi-first-lines-indent 0
  "*The indentation of the first non-blank non-comment line.
Usually 0 meaning first column.
Can be set to a number,  or to nil which means leave it as is."
  :type '(choice
          (const :tag "Leave as is"   nil)
          (integer :tag "Column number"
                   :menu-tag "Indent to this col (0 means first col)" )
          )
  :group 'shindent-vars)

(defcustom shi-basic-offset 4
  "*The default indentation incrementation.
This value is used for the + and - symbols in an indentation variable."
  :type 'integer
  :group 'shindent-vars)

(defcustom shi-indent-comment nil
  "*How a comment line is to be indented.
nil means leave as is,
t  means indent as a normal line,  align to previous non-blank
   non-comment line
a number means align to that column,  e.g. 0 means fist column."
  :type '(choice
          (const :tag "Leave as is." nil)
          (const :tag "Indent as a normal line."  t)
          (integer :menu-tag "Indent to this col (0 means first col)."
           :tag "Indent to column number.") )
  :group 'shindent-vars)

;; ========================================================================

(defvar shi-debug nil "*Enable lots of debug messages.")
(defun shi-debug (&rest args)
  "For debugging:  display message ARGS if variable SHI-DEBUG is non-nil."
  (if shi-debug
      (apply 'message args)))

(setq shi-symbol-list
 '(
   (const :tag "+ "  :value +
          :menu-tag "+   Indent right by shi-basic-offset")
   (const :tag "- "  :value -
          :menu-tag "-   Indent left  by shi-basic-offset")
   (const :tag "++"  :value  ++
          :menu-tag "++  Indent right twice shi-basic-offset")
   (const :tag "--"  :value --
          :menu-tag "--  Indent left  twice shi-basic-offset")
   (const :tag "* " :value *
          :menu-tag "*   Indent right half shi-basic-offset")
   (const :tag "/ " :value /
          :menu-tag "/   Indent left  half shi-basic-offset")
   ))

(setq shi-number-or-symbol-list
      (append (list '(
                      integer :menu-tag "A number (positive=>indent right)"
                              :tag "A number")
                    '(const :tag "--") ;; separator
                    )
              shi-symbol-list)
      )

(defcustom shi-indent-for-else 0
  "*How much to indent an else relative to an if.  Usually 0."
  :type `(choice
          (integer :menu-tag "A number (positive=>indent right)"
                   :tag "A number")
          (const :tag "--") ;; separator!
          ,@ shi-symbol-list
          )
  :group 'shindent-vars)

(defcustom shi-indent-for-fi 0
  "*How much to indent a fi relative to an if.   Usually 0."
  :type `(choice ,@ shi-number-or-symbol-list )
  :group 'shindent-vars)

(defcustom shi-indent-for-done '0
  "*How much to indent a done relative to its matching stmt.   Usually 0."
  :type `(choice ,@ shi-number-or-symbol-list )
  :group 'shindent-vars)

(defcustom shi-indent-after-else '+
  "*How much to indent a statement after an else statement."
  :type `(choice ,@ shi-number-or-symbol-list )
  :group 'shindent-vars)

(defcustom shi-indent-after-if '+
  "*How much to indent a statement after an if statement.
This includes lines after else and elif statements, too, but
does not affect then else elif or fi statements themselves."
  :type `(choice ,@ shi-number-or-symbol-list )
:group 'shindent-vars)

(defcustom shi-indent-for-then '+
  "*How much to indent an then relative to an if."
  :type `(choice ,@ shi-number-or-symbol-list )
:group 'shindent-vars)

(defcustom shi-indent-for-do '*
  "*How much to indent a do statement.
This is relative to the statement before the do,  i.e. the
while until or for statement."
  :type `(choice ,@ shi-number-or-symbol-list)
  :group 'shindent-vars)

(defcustom shi-indent-after-do '*
"*How much to indent a line after a do statement.
This is used when the do is the first word of the line.
This is relative to the statement before the do,  e.g. a
while for repeat or select statement."
  :type `(choice ,@ shi-number-or-symbol-list)
  :group 'shindent-vars)

(defcustom shi-indent-after-loop-construct '+
  "*How much to indent a statement after a loop construct.

This variable is used when the keyword \"do\" is on the same line as the
loop statement (e.g.  \"until\", \"while\" or \"for\").
If the do is on a line by itself, then `shi-indent-after-do' is used instead."
  :type `(choice ,@ shi-number-or-symbol-list)
  :group 'shindent-vars)

(defcustom shi-indent-after-done 0
  "*How much to indent a statement after a \"done\" keyword.
Normally this is 0, which aligns the \"done\" to the matching
looping construct line.
Setting it non-zero allows you to have the \"do\" statement on a line
by itself and align the done under to do."
  :type `(choice ,@ shi-number-or-symbol-list)
  :group 'shindent-vars)

(defcustom shi-indent-for-case-label '+
  "*How much to indent a case label statement.
This is relative to the line containing the case statement."
  :type `(choice ,@ shi-number-or-symbol-list)
  :group 'shindent-vars)

(defcustom shi-indent-for-case-alt '++
  "*How much to indent statements after the case label.
This is relative to the line containing the case statement."
  :type `(choice ,@ shi-number-or-symbol-list)
  :group 'shindent-vars)

(defcustom shi-indent-for-continuation '+
  "*How much to indent for a continuation statement."
  :type `(choice ,@ shi-number-or-symbol-list)
  :group 'shindent-vars)

(defcustom shi-indent-after-open '+
  "*How much to indent after a line with an opening parenthesis or brace."
  :type `(choice ,@ shi-number-or-symbol-list)
  :group 'shindent-vars)

(defcustom shi-indent-after-function '+
  "*How much to indent after a function line."
  :type `(choice ,@ shi-number-or-symbol-list)
  :group 'shindent-vars)

;; These 2 are for the rc shell.

(defcustom shi-indent-after-switch '+
  "*How much to indent a case statement relative to the switch statement.
This is for the rc shell."
  :type `(choice ,@ shi-number-or-symbol-list)
  :group 'shindent-vars)

(defcustom shi-indent-after-case '+
  "*How much to indent a statement relative to the case statement.
This is for the rc shell."
  :type `(choice ,@ shi-number-or-symbol-list)
  :group 'shindent-vars)

(defface shi-heredoc-face
  '((((class color)
      (background dark))
     (:foreground "yellow" :bold t))
    (((class color)
      (background light))
     (:foreground "tan" ))
    (t
     (:bold t)))
  "Face to show a here-document"
  :group 'shindent)

(defface shi-st-face
  '((((class color)
      (background dark))
     (:foreground "yellow" :bold t))
    (((class color)
      (background light))
     (:foreground "tan" ))
    (t
     (:bold t)))
  "Face to show characters with special syntax properties."
  :group 'shindent)

;; ------------------------------------------------------------------------

(defconst shi-here-doc-syntax '(15))    ;; generic string
;; (defconst shi-st-word '(2))
(defconst shi-st-punc '(1))
(defconst shi-special-syntax shi-st-punc)

(defun shi-mkword-regexpr (word)
  (concat word "\\([^-a-z0-9_]\\|$\\)"))

(defun shi-mkword-regexp (word)
  (concat "\\(^\\|[^-a-z0-9_]\\)" word "\\([^-a-z0-9_]\\|$\\)"))

(setq shi-re-done (shi-mkword-regexpr "done"))

(defconst shi-kws-for-done
  '(
    (sh .  ( "while" "until" "for" ) )
    (bash . ( "while" "until" "for" "select"  ) )
    (ksh88 . ( "while" "until" "for" "select"  ) )
    (zsh .  ( "while" "until" "for" "repeat" "select" ) )
    )
  )

(defconst shi-indent-supported
  '(
    (sh . t)
    (csh . nil)
    (rc . t)                            ;; arguable...
    )
  "Shell types that shindent can do something with."
  )

(defconst shi-electric-rparen-needed
  '(
    (sh . t))
  "Non-nil if the shell type needs an electric handling of case alternatives."
  )

(defconst shi-var-list
  '(
    shi-basic-offset shi-first-lines-indent shi-indent-after-case
    shi-indent-after-do shi-indent-after-done
    shi-indent-after-else
    shi-indent-after-if
    shi-indent-after-loop-construct
    shi-indent-after-open

    shi-indent-comment
    shi-indent-for-case-alt
    shi-indent-for-case-label
    shi-indent-for-continuation

    shi-indent-for-do
    shi-indent-for-done
    shi-indent-for-else
    shi-indent-for-fi
    shi-indent-for-then
    )
  "A list of style of buffer specific variables used by script mode."
  )

(defvar shi-make-vars-local t
  "*Controls whether indentation variables are local to the buffer.
If non-nil,  indentation variables are made local initially.
If nil,  you can later make the variables local by invoking
command `shi-make-vars-local'.
The default is t because I assume that in one Emacs session one is
frequently editing existing scripts with different styles.")

(defun shi-must-be-shell-mode ()
  "Signal an error if not in shell script mode."
  (unless (eq major-mode 'sh-mode)
    (error "This buffer is not in Shell-script mode")))

(defun shi-make-vars-local ()
  "Make the indentation variables local to this buffer.
Normally they already are local.  This command is provided in case
variable `shi-make-vars-local' has been set to nil.

To revert all these variables to the global values,  use
command `shi-reset-indent-vars-to-global-values'."
  (interactive)
  (shi-must-be-shell-mode)
  (mapcar 'make-local-variable shi-var-list)
  (message "Indentation variable are now local."))

(defun shi-reset-indent-vars-to-global-values ()
  "Reset local indenatation variables to the global values.
Then, if variable `shi-make-vars-local' is non-nil,  make them local."
  (interactive)
  (shi-must-be-shell-mode)
  (mapcar 'kill-local-variable shi-var-list)
  (if shi-make-vars-local
      (mapcar 'make-local-variable shi-var-list)))

(defvar shi-kw-alist nil
  "A buffer-local, since it is shell-type dependent, list of keywords.")

(defvar shi-regexp-for-done nil
  "A buffer-local regexp to match opening keyword for done.")

;; Theoretically these are only needed in shell and derived modes.
;; However, the routines which use them are only called in those modes.
(defconst shi-special-keywords "then\\|do")

;; ( key-word  first-on-this  on-prev-line )
;; This is used to set `shi-kw-alist' which is a list of sublists each
;; having 3 elements:
;;   a keyword
;;   a rule to check when the keyword apepars on "this" line
;;   a rule to check when the keyword apepars on "the previous" line
;; The keyword is usually a string and is the first word on a line.
;; If this keyword appears on the line whose indenation is to be
;; calculated,  the rule in element 2 is called.  If this returns
;; non-zero,  the resulting point (which may be changed by the rule)
;; is used as the default indentation.
;; If it returned false or the keyword was not found in the table,
;; then the keyword from the previous line is looked up and the rule
;; in element 3 is called.  In this case, however,
;; `shi-get-indent-info' does not stop but may keepp going and test
;; other keywords against rules in element 3.  This is because the
;; precending line could have, for example, an opening "if" and an
;; opening "while" keyword and we need to add the indentation offsets
;; for both.
;;
(defconst shi-kw
  '(
    (sh
        ( "if"
          nil
          shi-handle-prev-if   )

        ( "elif"
          shi-handle-this-else
          shi-handle-prev-else )

        ( "else"
          shi-handle-this-else
          shi-handle-prev-else )

        ( "fi"
          shi-handle-this-fi
          shi-handle-prev-fi )

        ( "then"
          shi-handle-this-then
          shi-handle-prev-then
          )

        ( "("
          nil
          shi-handle-prev-open  )
        ( "{"
          nil
          shi-handle-prev-open  )
        ( "["
          nil
          shi-handle-prev-open  )

        ( "}"
          shi-handle-this-close
          nil  )
        ( ")"
          shi-handle-this-close
          nil  )
        ( "]"
          shi-handle-this-close
          nil  )

        ( "case"
          nil
          shi-handle-prev-case   )
        ( "esac"
          shi-handle-this-esac
          shi-handle-prev-esac )
        ( case-label
          nil   ;; ???
          shi-handle-after-case-label )
        ( ";;"
          nil   ;; ???
          shi-handle-prev-case-alt-end  ;; ??
          )
        ( "done"
          shi-handle-this-done
          shi-handle-prev-done )
        ( "do"
          shi-handle-this-do
          shi-handle-prev-do )

        ) ;; end of sh

    ;; Note: we don't need specific stuff for bash and zsh shells;
    ;; the regexp `shi-regexp-for-done' handles the extra keywords
    ;; these shells use.

    (rc

     ( "{"
          nil
          shi-handle-prev-open  )

     ( "}"
          shi-handle-this-close
          nil  )

     ( "case"
       shi-handle-this-rc-case
       shi-handle-prev-rc-case   )

     ) ;; end of rc

    ))

(defun shi-help-string-for-variable (var)
  "Construct a string for `shi-read-variable' when changing variable VAR ."
  (let ((msg (documentation-property var 'variable-documentation))
        (msg2 ""))
    (unless (or
             (eq var 'shi-first-lines-indent)
             (eq var 'shi-indent-comment))
      (setq msg2
            (format "\n
You can enter a number (positive to increase indentenation,
negative to decrease indentation,  zero for no change to  indentnation).

Or,  you can enter one of the following symbols which are relative to
the value of variable `shi-basic-offset'
which in this buffer is currently %s.

\t%s."
                    shi-basic-offset
                    (mapconcat  '(lambda (x)
                                   (nth (1- (length x))  x) )
                                shi-symbol-list  "\n\t")
                    )))

    (concat
     ;; The following shows the global not the local value!
     ;; (format "Current value of %s is %s\n\n" var (symbol-value var))
     msg msg2)))

(defun shi-read-variable (var)
  "Read a new value for indentation variable VAR."
  (interactive "*variable? ") ;; to test
  (let ((minibuffer-help-form `(shi-help-string-for-variable
                                (quote ,var)))
        val)
    (setq val (read-from-minibuffer
                 (format "New value for %s (press %s for help): "
                         var  (single-key-description help-char))
                 (format "%s" (symbol-value var))
                 nil t))
    val))

(defun shi-in-comment-or-string (start)
  "Return non-nil if START is in a comment or string."
  (save-excursion
    (let (state)
      (beginning-of-line)
      (setq state (parse-partial-sexp (point) start nil nil nil t))
      (or (nth 3 state)(nth 4 state)))))

(defun shi-goto-matching-if ()
  (let ((found (shi-find-prev-matching "\\bif\\b" "\\bfi\\b" 1)))
    (if found
        (goto-char found))))

(defun shi-handle-prev-if ()
  (list '(+ shi-indent-after-if))
  )

(defun shi-handle-this-else ()
  (if (shi-goto-matching-if)
      ;; (list "aligned to if")
      (list "aligned to if" '(+ shi-indent-for-else))
    nil
    ))

(defun shi-handle-prev-else ()
  (if (shi-goto-matching-if)
      (list  '(+ shi-indent-after-if))
    ))

(defun shi-handle-this-fi ()
  (if (shi-goto-matching-if)
      (list "aligned to if" '(+ shi-indent-for-fi))
    nil
    ))

(defun shi-handle-prev-fi ()
  ;; ? Why do we have this rule?
  ;; Because we must go back to the if to get its indent.  We may continue
  ;; back from there.
  ;; We return nil because we don't have anything to add to result,  
  ;; the side affect of setting align-point is all that matters.
  ;; we could return a comment (a string) but I can't think of a good one...
  (shi-goto-matching-if)
  nil)

(defun shi-handle-this-then ()
  (let ((p (shi-goto-matching-if)))
    (if p
        (list '(+ shi-indent-for-then))
      ))
  )

(defun shi-handle-prev-then ()
  (let ((p (shi-goto-matching-if)))
    (if p
        (list '(+ shi-indent-after-if))
      )
  ))

(defun shi-handle-prev-open ()
  (save-excursion
    (let ((x (shi-prev-stmt)))
      (if (and x
               (progn
                 (goto-char x)
                 (or
                  (looking-at "function\\b")
                  (looking-at "\\s-*\\S-+\\s-*()")
                  )))
          (list '(+ shi-indent-after-function))
        (list '(+ shi-indent-after-open)))
      )))

(defun shi-handle-this-close ()
  (forward-char 1) ;; move over ")"
  (let ((p (shi-safe-backward-sexp)))
    (if p
        (list "aligned to opening paren")
      nil
  )))

(defun shi-goto-matching-case ()
  (let ((found (shi-find-prev-matching "\\bcase\\b" "\\besac\\b" 1)))
    (if found
        (goto-char found))))

(defun shi-handle-prev-case ()
  ;; This is typically called when point is on same line as a case
  ;; we shouldn't -- and can't find prev-case
  (if (looking-at ".*\\bcase\\b")
      (list '(+ shi-indent-for-case-label))
    (error "We don't see to be on a line with a case") ;; debug
    ))

(defun shi-handle-this-esac ()
  (let ((p (shi-goto-matching-case)))
    (if p
        (list "aligned to matching case")
      nil
      )))

(defun shi-handle-prev-esac ()
  (let ((p (shi-goto-matching-case)))
    (if p
        (list "matching case")
      nil
    )))

(defun shi-handle-after-case-label ()
  (let ((p (shi-goto-matching-case)))
    (if p
        (list '( + shi-indent-for-case-alt ))
      nil
    )))

(defun shi-handle-prev-case-alt-end ()
  (let ((p (shi-goto-matching-case)))
    (if p
        (list '( + shi-indent-for-case-label ))
      nil
      )))

(defun shi-safe-backward-sexp ()
  "Try and do a `backward-sexp', but do not error.
Return new point if successful,  nil if an error occurred."
  (condition-case nil
      (progn
        (backward-sexp 1)
        (point) ;; return point if successful
        )
    (error
     (shi-debug "oops!(0) %d" (point))
     nil ;; return nil if fail
     )))

(defun shi-safe-forward-sexp ()
  "Try and do a `forward-sexp', but do not error.
Return new point if successful,  nil if an error occurred."
  (condition-case nil
      (progn
        (forward-sexp 1)
        (point) ;; return point if successful
        )
    (error
     (shi-debug "oops!(1) %d" (point))
     nil ;; return nil if fail
     )))

(defun shi-goto-match-for-done ()
  (let ((found (shi-find-prev-matching shi-regexp-for-done shi-re-done 1)))
    (if found
        (goto-char found))))

(defun shi-handle-this-done ()
  (if (shi-goto-match-for-done)
      (list  "aligned to do stmt"  '(+ shi-indent-for-done))
    nil
    ))

(defun shi-handle-prev-done ()
  (if (shi-goto-match-for-done)
      (list "previous done")
    nil
    ))

(defun shi-handle-this-do ()
  (let ( (p (shi-goto-match-for-done))  )
    (if p
        (list  '(+ shi-indent-for-do))
      nil
      ))
  )

(defun shi-handle-prev-do ()
  (let ( (p) )
    (cond
     ((save-restriction
        (narrow-to-region
         (point)
         (save-excursion
           (beginning-of-line)
           (point)))
        (shi-goto-match-for-done))
      (shi-debug "match for done found on THIS line")
      (list '(+ shi-indent-after-loop-construct)))
     ((shi-goto-match-for-done)
      (shi-debug "match for done found on PREV line")
      (list '(+ shi-indent-after-do)))
     (t
      (message "match for done NOT found")
      nil))))

;; for rc:
(defun shi-find-prev-switch ()
  "Find the line for the switch keyword matching this line's case keyword."
  (re-search-backward "\\bswitch\\b" nil t))

(defun shi-handle-this-rc-case ()
  (if (shi-find-prev-switch)
      (list  '(+ shi-indent-after-switch))
      ;; (list  '(+ shi-indent-for-case-label))
    nil))

(defun shi-handle-prev-rc-case ()
  (list '(+ shi-indent-after-case))
  )

(defun shi-check-rule (n thing)
  (let ((rule (nth n (assoc thing shi-kw-alist)))
        (val nil))
    (if rule
        (progn
          (setq val (funcall rule))
          (if shi-debug
              (message "rule (%d) for %s at %d is %s\n-> returned %s"
                       n thing (point) rule val))
          ))
    val))

(defun shi-get-indent-info ()
  "Return indent-info for this line.
This is a list.  nil means the line is to be left as is.
Otherwise it contains one or more of the following sublists:
(t NUMBER)   NUMBER is the base location in the buffer that indendation is
             relative to.  If present, this is always the first of the
             sublists.  The indentation of the line in question is
             derived from the indentation of this point,  possibly
             modified by subsequent sublists.
(+ VAR)
(- VAR)      Get the value of variable VAR and add to or subtract from
             the indentation calculated so far.
(= VAR)      Get the value of variable VAR and *replace* the
             indentation with itss value.  This only occurs for
             special variables such as `shi-indent-comment'.
STRING       This is ignored for the purposes of calculating
             indentation,  it is printed in certain cases to help show
             what the indentation is based on."
  ;; See comments before `shi-kw'.
  (save-excursion
    (let (
          (prev-kw nil)
          (prev-stmt nil)
          (have-result nil)
          depth-bol depth-eol
          this-kw
          (state nil)
          state-bol
          (depth-prev-bol nil)
          start
          func val
          (result nil)
          prev-lines-indent
          (prev-list nil)
          (this-list nil)
          (align-point nil)
          ;; noticed by the byte compiler:
          prev-line-end x
          )
      (beginning-of-line)
      ;; Note: setting result to t means we are done and will return nil.
      ;;( This function never returns just t.)
      (cond
       ((equal (get-text-property (point) 'syntax-table) shi-here-doc-syntax)
        (setq result t)
        (setq have-result t)
        )
       ((looking-at "\\s-*#") ; was (equal this-kw "#")
        (if (bobp)
            (setq result t) ;; return nil if 1st line!
          (setq result (list '(= shi-indent-comment)))
          ;; we still need to get previous line in case
          ;; shi-indent-comnent is t (indent as normal)
          ;; (setq align-point (point))
          (setq align-point (shi-prev-line-beg))
          ;; No, do not set have-result because we may need to still
          ;; try and find the previous line.
          ;; (setq have-result t)
          ;; ? Why?  Why do we need to find the previous line?
          ;; This causes problems,  since we can have info with
          ;; multiple things such as
          ;; ((t 232) (= shi-indent-comment) (+ shi-indent-after-do))
          ;; So I'm putting this back in:
          (setq have-result t)
          ;; Thu Apr 22 22:52:35 1999
          (setq have-result nil)
          ))
       ) ;; cond

      (unless have-result

        ;; continuation lines are handled specially
        (if (shi-this-is-a-continuation)
            (progn
              ;; We assume the line being continued is already
              ;; properly indented...
              ;; (setq prev-line-end (shi-prev-line))
              (setq align-point (shi-prev-line-beg))
              (setq result (list '(+ shi-indent-for-continuation)))
              (setq have-result t))
          (beginning-of-line)
          (skip-chars-forward " \t")
          (setq this-kw (shi-get-kw)))

        ;; Handle "this" keyword:  first word on the line we're
        ;; calculating indentation info for.
        (if this-kw
            (if (setq val (shi-check-rule 1 this-kw))
                (progn
                  (setq align-point (point))
                  (shi-debug
                   "this - setting align-point to %d" align-point)
                  (setq result (append result val))
                  (setq have-result t)
                  ;; set prev-line to continue processing remainder
                  ;; of this line as a previous l ine
                  (setq prev-line-end (point))
                  )))
        )

      (unless have-result
        (setq prev-line-end (shi-prev-line 'end)))

      ;; if prev-line-end  ;; (and prev-line-end (null result))
      ;; if (and (not have-result) prev-line-end)
      (if prev-line-end
           (save-excursion
             ;; We start off at beginning of this line.
             ;; Scan previous statements while this is <=
             ;; start of previous line.
             (setq start (point));; for debug only
             (goto-char prev-line-end)
             (setq x t)
             (while (and x (setq x  (shi-prev-thing)))
               (shi-debug "at %d x is: %s  result is: %s" (point) x result)
               (cond
                ((and (equal x ")")
                      (equal (get-text-property (1- (point)) 'syntax-table)
                          shi-special-syntax))
                 (shi-debug "Case label) here")
                 (setq x 'case-label)
                 (if (setq val (shi-check-rule 2 x))
                     (progn
                       (setq result (append result val))
                       (setq align-point (point))))
                 (forward-char -1)
                 (skip-chars-forward "[a-z0-9]*?")
                 )
                ((string-match "[])}]" x)
                 (setq x (shi-safe-backward-sexp))
                 (if x
                     (progn
                       (setq align-point (point))
                       (setq result (append result
                                            (list "aligned to opening paren")))
                       ))
                 )
                ((string-match "[[({]" x)
                 (shi-debug "Checking special thing: %s" x)
                 (if (setq val (shi-check-rule 2 x))
                     ;; this check removed:
                     ;; (or (eq t (car val))
                     ;; (eq t (car (car val))))
                     (setq result (append result val)))
                 (forward-char -1)
                 (setq align-point (point)) ; ??
                 )
                ((string-match "[\"'`]" x)
                 (shi-debug "Skipping back for %s" x)
                 ;; this was oops-2
                 (setq x (shi-safe-backward-sexp))
                 )
                ((stringp x)
                 (shi-debug "Checking string %s at %s" x (point))
                 (if (setq val (shi-check-rule 2 x))
                     ;; (or (eq t (car val))
                     ;; (eq t (car (car val))))
                     (setq result (append result val)))
                 ;; not sure about this test Wed Jan 27 23:48:35 1999
                 (setq align-point (point))
                 (unless (bolp)
                   (forward-char -1));; ? originally, not done
                 )
                (t
                 (error "Don't konw what to do with %s" x))
                )
               );; while
             (shi-debug "result is %s" result)
             )
         (shi-debug "No prev line!")
         (shi-debug "result: %s  align-point: %s" result align-point)
         )

      (if align-point
          ;; was: (setq result (append result (list (list t align-point))))
          (setq result (append  (list (list t align-point)) result))
        )
      (shi-debug "result is now: %s" result)

      (or result
           (if prev-line-end
               (setq result (list (list t prev-line-end)))
             (setq result (list (list '= 'shi-first-lines-indent)))
             ))

      (if (eq result t)
          (setq result nil))
      (shi-debug  "result is: %s" result)
      result
      );; let
    );; save-excursion
  )

(defun shi-get-indent-var-for-line (&optional info)
  "Return the variable controlling indentation for this line.
If there is not [just] one such variable, return a string
indicating the problem.
If INFO is supplied it is used, else it is calculated."
  (let (
        (var nil)
        (result nil)
        (reason nil)
        sym elt)
    (or info
        (setq info (shi-get-indent-info)))
    (if (null info)
        (setq result "this line to be left as is")
      (while (and info (null result))
        (setq elt (car info))
        (cond
         ((stringp elt)
          (setq reason elt)
          )
         ((not (listp elt))
          (error "shi-get-indent-var-for-line invalid elt: %s" elt))
         ;; so it is a list
         ((eq t (car elt))
          ) ;; nothing
         ((symbolp  (setq sym (nth 1 elt)))
          ;; A bit of a kludge - when we see the shi-indent-comment
          ;; ignore other variables.  Otherwise it is tricky to
          ;; "learn" the comment indentation.
          (if (eq var 'shi-indent-comment)
              (setq result var)
            (if var
                (setq result
                      "this line is controlled by more than 1 variable.")
              (setq var sym))))
         (t
          (error "shi-get-indent-var-for-line invalid list elt: %s" elt)))
        (setq info (cdr info))
        ))
    (or result
        (setq result var))
    (or result
        (setq result reason))
    (if (null result)
        ;; e.g. just had (t POS)
        (setq result "line has default indentation"))
    result))

;; Finding the previous line isn't trivial.
;; We must *always* go back one more and see if that is a continuation
;; line -- it is the PREVIOUS line which is continued,  not the one
;; we are going to!
;; Also, we want to treat a whole "here document" as one big line,
;; because we may want to a align to the beginning of it.
;;
;; What we do:
;; - go back a line,  if empty repeat
;; - (we are now at a previous non empty line)
;; - save this
;; - if this is in a here-document,  go to the beginning of it
;;   and save that
;; - go back one more physcial line and see if it is a continuation line
;; - if yes,  save it and repeat
;; - if no,  go back to where we last saved.
(defun shi-prev-line (&optional end)
  "Back to end of previous non-comment non-empty line.
Go to beginning of logical line unless END is non-nil,  in which case
we go to the end of the previous line and do not check for continuations."
  (shi-must-be-shell-mode)
  (let ((going t)
          (last-contin-line nil)
          (result nil)
          bol eol state)
    (save-excursion
      (beginning-of-line)
      (while (and going
                  (not (bobp))
                  (>= 0  (forward-line -1))
                  )
        (setq bol (point))
        (end-of-line)
        (setq eol (point))
        (save-restriction
          (setq state (parse-partial-sexp bol eol nil nil nil t))
          (if (nth 4 state)
              (setq eol (nth 8 state)))
          (narrow-to-region bol eol)
          (goto-char bol)
          (cond
           ((looking-at "\\s-*$"))
           (t
            (if end
                (setq result eol)
              (setq result bol))
            (setq going nil))
           ))
        )
      (if (and result
               (equal (get-text-property (1- result) 'syntax-table)
                   shi-here-doc-syntax))
          (let ((p1 (previous-single-property-change
                     (1- result) 'syntax-table)))
            (if p1
                (progn
                  (goto-char p1)
                  (forward-line -1)
                  (if end
                      (end-of-line))
                  (setq result (point)))
              )))

      (unless end
        ;; we must check previous lines to see if they are continuation lines
        ;; if so, we must return position of first of them
        (while (and (shi-this-is-a-continuation)
                    (>= 0  (forward-line -1)))
          (setq result (point)))
        (if result
            (progn
              (goto-char result)
              (beginning-of-line)
              (skip-chars-forward " \t")
              (setq result (point))
              )))
        )  ;; save-excursion
    result
    ) ;; let
  )

(defun shi-prev-line-beg ()
  (shi-prev-line nil))
(defun shi-prev-line-end ()
  (shi-prev-line 'end))

;; Moved the test of not moving to AFTER the skip forward
;; Also made it test >= not just = .
;; This is used when we are trying to find a matching keyword.
;; Searching backward for the keyword would certainly be quicker,  but
;; it is hard to remove "false matches" -- such as if the keyword
;; appears in a string or quote.  This way is slower, but (I think) safer.
(defun shi-prev-stmt ()
  "Return the address of the previous stmt or nil."
  (interactive)
  (save-excursion
    (let ((going t)
          (start (point))
          (found nil)
          (prev nil)
          )
      (skip-chars-backward " \t;|&({[")
      (while (and (not found)
                  (not (bobp))
                  going
                  )
        ;; do a backward-sexp if possible,  else backup
        ;; bit by bit...
        (if (shi-safe-backward-sexp)
            (progn
              (if (looking-at shi-special-keywords)
                  (progn
                    (setq found prev))
                (setq prev (point))
                )
              )
            ;; backward-sexp failed
          (if (zerop (skip-chars-backward " \t()[\]{};`'"))
              (forward-char -1))
          (if (bolp)
              (let ((back (shi-prev-line-beg)))
                (if back
                    (goto-char back)
                  (setq going nil)))
            ))
        (unless found
          (skip-chars-backward " \t")
          (if (or (and (bolp) (not (shi-this-is-a-continuation)))
                  (eq (char-before) ?\;)
                  (looking-at "\\s-*[|&]"))
              (setq found (point))
            )
          )
        ) ;; while
      (if found
          (goto-char found))
      (if found
          (progn
            (skip-chars-forward " \t|&({[")
            (setq found (point)))
        )
      (if (>= (point) start)
          (progn
            (debug "We didn't move!")
            (setq found nil))
        (or found
            (shi-debug "Did not find prev stmt."))
        )
      found
      )))

(defun shi-get-word ()
  "Get a shell word skipping whitespace from point."
  (interactive)
  (skip-chars-forward "\t ")
  (let ((start (point)))
    (while
        (if (looking-at "[\"'`]")
            (shi-safe-forward-sexp)
          ;; (> (skip-chars-forward "^ \t\n\"'`") 0)
          (> (skip-chars-forward "-_a-zA-Z\$0-9") 0)
          )
      )
    (buffer-substring start (point))
    ))

(defun shi-prev-thing ()
  "Return the previous thing this logical line."
  ;; Added a kludge for ";;"
  ;; Possible return values:
  ;;  nil  -  nothing
  ;; a string - possibly a keyword
  ;;
  (if (bolp)
      nil
    (let ((going t)
          c n
          min-point
          (start (point))
          (found nil))
      (save-restriction
        (narrow-to-region
         (if (shi-this-is-a-continuation)
             (progn
               (setq min-point (shi-prev-line-beg))
               )
           (save-excursion
             (beginning-of-line)
             (setq min-point (point))))
         (point))
        (skip-chars-backward " \t;")
        (unless (looking-at "\\s-*;;")
          (skip-chars-backward "^)}];\"'`({[")
          (setq c (char-before)))
        )
      (shi-debug "stopping at %d c is %s  start=%d min-point=%d"
                 (point) c start min-point)
      (if (< (point) min-point)
          (error "point %d < min-point %d" (point) min-point))
      (cond
       ((looking-at "\\s-*;;")
        ;; (message "Found ;; !")
        ";;")
       ((or (eq c ?\n)
            (eq c nil)
            (eq c ?\;))
        (save-excursion
          ;; skip forward over white space newline and \ at eol
          (skip-chars-forward " \t\n\\\\")
          (shi-debug "Now at %d   start=%d" (point) start)
          (if (>= (point) start)
              (progn
                (shi-debug "point: %d >= start: %d" (point) start)
                nil)
            (shi-get-word))
          ))
       (t
        ;; c    -- return a string
        (char-to-string c)
        ))
      )))

(defun shi-this-is-a-continuation ()
  "Return non-nil if current line is a continuation of previous line."
  (let ((result nil)
        bol eol state)
    (save-excursion
      (if (and (zerop (forward-line -1))
               (looking-at ".*\\\\$"))
          (progn
            (setq bol (point))
            (end-of-line)
            (setq eol (point))
            (setq state (parse-partial-sexp bol eol nil nil nil t))
            (unless (nth 4 state)
              (setq result t))
            )))))

(defun shi-get-kw (&optional where and-move)
  "Return first word of line from WHERE.
If AND-MOVE is non-nil then move to end of word."
  (let ((start (point)))
    (if where
        (goto-char where))
    (prog1
        (buffer-substring (point)
        (progn (skip-chars-forward "^ \t\n")(point)))
      (unless and-move
        (goto-char start)))
    ))

(defun shi-find-prev-matching (open close &optional depth)
  "Find a matching token for a set of opening and closing keywords.
This takes into account that there may be nested open..close pairings.
OPEN and CLOSE are regexps denoting the tokens to be matched.
Optional parameter DEPTH (usually 1) says how many to look for."
  (let ((parse-sexp-ignore-comments t)
        prev)
    (setq depth (or depth 1))
    (save-excursion
      (condition-case nil
          (while (and
                  (/= 0  depth)
                  (not (bobp))
                  (setq prev (shi-prev-stmt)))
            (goto-char prev)
            (save-excursion
              (if (looking-at "\\\\\n")
                  (progn
                    (forward-char 2)
                    (skip-chars-forward " \t")))
              (cond
               ((looking-at open)
                (setq depth (1- depth))
                (shi-debug "found open at %d - depth = %d" (point) depth))
               ((looking-at close)
                (setq depth (1+ depth))
                (shi-debug "found close - depth = %d" depth))
               (t
                ))))
                (error nil))
      (if (eq depth 0)
          prev ;; (point)
        nil)
      )))

(defun shi-var-value (var &optional ignore-error)
  "Return the value of variable VAR, interpreting symbols.
It can also return t or nil.
If an illegal value is found,  throw an error unless Optional argument
IGNORE-ERROR is non-nil."
;; As well as the `+' `-' etc symbols,  t means the previous line.
;; NO - the t has been disabled.
;;Optional argument IGNORE-ERROR means continue on bad values of the variable."
  (let ((val (symbol-value var)))
    (cond
     ((numberp val)
      val)
     ((eq val t)
      val)
     ((null val)
      val)
     ((eq val '+)
      shi-basic-offset)
     ((eq val '-)
      (- shi-basic-offset))
     ((eq val '++)
      (* 2 shi-basic-offset))
     ((eq val '--)
      (* 2 (- shi-basic-offset)))
     ((eq val '*)
      (/ shi-basic-offset 2))
     ((eq val '/)
      (/ (- shi-basic-offset) 2))
     (t
      (if ignore-error
          (progn
            (message "Don't konw how to handle %s's value of %s" var val)
            0)
        (error "Don't konw how to handle %s's value of %s" var val))
      ))))

(defun shi-set-var-value (var value &optional no-symbol)
  "Set variable VAR to VALUE.
Unless optional argument NO-SYMBOL is non-nil,  then if VALUE is
can be represented by a symbol then do so."
  (cond
   (no-symbol
    (set var value))
   ((= value shi-basic-offset)
    (set var '+))
   ((= value (- shi-basic-offset))
    (set var '-))
   ((eq value (* 2 shi-basic-offset))
    (set var  '++))
   ((eq value (* 2 (- shi-basic-offset)))
    (set var  '--))
   ((eq value (/ shi-basic-offset 2))
    (set var  '*))
   ((eq value (/ (- shi-basic-offset) 2))
    (set var  '/))
   (t
    (set var value)))
  )

(defun shi-calculate-indent (&optional info)
  "Return the indentation for the current line.
If INFO is supplied it is used, else it is calculated from current line."
  (let (
        (ofs 0)
        (base-value 0)
        elt a b var val)
    (or info
        (setq info (shi-get-indent-info)))
    (if (null info)
        nil
      (while info
        (shi-debug "info: %s  ofs=%s" info ofs)
        (setq elt (car info))

        (cond
         ((stringp elt)
          ;; do nothing?
          )
         ((listp elt)
          (setq a (car (car info)))
          (setq b (nth 1 (car info)))
          (cond
           ((eq a t)
            (save-excursion
              (goto-char b)
              (setq val (current-indentation)))
            (setq base-value val))
           ((symbolp b)
            (setq val (shi-var-value b))
            (cond
             ((eq a '=)
              (cond
               ((null val)
                ;; no indentation
                ;; set info to nil so  we stop immediately
                (setq base-value nil  ofs nil  info nil))
               ((eq val t)
                ;; indent as normal line
                (setq ofs 0))
               (t
                ;; The following assume the (t POS) come first!
                (setq ofs val  base-value 0)
                (setq info nil) ;; ? stop now
                ))
              )
             ((eq a '+)
              (setq ofs (+ ofs val)))
             ((eq a '-)
              (setq ofs (- ofs val)))
             (t
              (error "shi-calculate-indent invalid a a=%s b=%s" a b))))
           (t
            (error "shi-calculate-indent invalid elt: a=%s b=%s" a b)))
          )
         (t
          (error "shi-calculate-indent invalid elt %s" elt))
         )
         (shi-debug "a=%s b=%s val=%s base-value=%s ofs=%s"
                    a b val base-value ofs)
         (setq info (cdr info))
         )
      ;; return value:
      (shi-debug "at end:  base-value: %s    ofs: %s" base-value ofs)

      (cond
       ((or (null base-value)(null ofs))
        nil)
       ((and (numberp base-value)(numberp ofs))
        (shi-debug "base (%d) + ofs (%d) = %d"
                   base-value ofs (+ base-value ofs))
        (+ base-value ofs)) ;; return value
       (t
        (error "shi-calculate-indent:  Help.  base-value=%s ofs=%s"
               base-value ofs)
        nil))
      )))

;; If and when we merge with sh-script.el,  this should get
;; merged into sh-indent-line.
(defun shi-indent-line ()
  "Indent the current line."
  (interactive)
  (shi-must-be-shell-mode)
  (let ((indent (shi-calculate-indent)) shift-amt beg end
        (pos (- (point-max) (point))))
    (if indent
      (progn
        (beginning-of-line)
        (setq beg (point))
        (skip-chars-forward " \t")
        (setq shift-amt (- indent (current-column)))
        (if (zerop shift-amt)
            nil
          (delete-region beg (point))
          (indent-to indent))
        ;; If initial point was within line's indentation,
        ;; position after the indentation.  Else stay at same point in text.
        (if (> (- (point-max) pos) (point))
          (goto-char (- (point-max) pos)))
        ))))

(defun shi-blink (blinkpos &optional msg)
  "Move cursor momentarily to BLINKPOS and display MSG."
  ;; We can get here without it being a number on first line
  (if (numberp blinkpos)
      (save-excursion
        (goto-char blinkpos)
        (message msg)
        (sit-for blink-matching-delay))
    (message msg)
    ))

(defun shi-show-indent (arg)
  "Show the how the currently line would be indented.
This tells you which variable, if any, controls the indentation of
this line.
If optional arg ARG is non-null (called interactively with a prefix),
a pop up window describes this variable.
If variable `shi-blink' is non-nil then momentarily go to the line
we are indenting relative to, if applicable."

  (interactive "P")
  (let* ((info (shi-get-indent-info))
         (var (shi-get-indent-var-for-line info))
        val msg
        (curr-indent (current-indentation))
        )
    (if (stringp var)
        (message (setq msg var))
      (setq val (shi-calculate-indent info))

      (if (eq curr-indent val)
          (setq msg (format "%s is %s" var (symbol-value var)))
        (setq msg
              (if val
                  (format "%s (%s) would change indent from %d to: %d"
                          var (symbol-value var) curr-indent val)
                (format "%s (%s) would leave line as is"
                        var (symbol-value var)))
              ))
      (if (and arg var)
          (describe-variable var)))
    (if shi-blink
        (let ((info (shi-get-indent-info)))
          (if (and info (listp (car info))
                   (eq (car (car info)) t))
              (shi-blink (nth 1 (car info))  msg)
            (message msg)))
      (message msg))
    ))

(defun shi-set-indent ()
  "Set the indentation for the current line.
If the current line is controlled by an indentation variable, prompt
for a new value for it."
  (interactive)
  (shi-must-be-shell-mode)
  (let* ((info (shi-get-indent-info))
         (var (shi-get-indent-var-for-line info))
         val val0 new-val old-val indent-val)
    (if (stringp var)
        (message (format "Cannot set indent - %s" var))
      (setq val (shi-calculate-indent info))
      (setq old-val (symbol-value var))
;;;   (setq val (read-from-minibuffer
;;;      (format "New value for %s: " var)
;;;              (format "%s" (symbol-value var))
;;;              nil t))
      (setq val (shi-read-variable var))
      (condition-case nil
          (progn
            (set var val)
            (setq indent-val (shi-calculate-indent info))
            (if indent-val
                (message "Variable: %s  Value: %s  would indent to: %d"
                         var (symbol-value var) indent-val)
              (message "Variable: %s  Value: %s  would leave line as is."
                       var (symbol-value var)))
            ;; I'm not sure about this,  indenting it now?
            ;; No.  Because it would give the impression that an undo would
            ;; restore thing,  but the value has been altered.
            ;; (shi-indent-line)
            )
        (error
         (set var old-val)
         (message "Bad value for %s,  restoring to previous value %s"
                  var old-val)
         (sit-for 1)
         nil))
      )
    ))

(defun shi-learn-line-indent (arg)
  "Learn how to indent a line as it currently is indented.

If there is an indentation variable which controls this line's indentation,
then set it to a value which would indent the line the way it
presently is.

If the value can be represented by one of the symbols then do so
unless optional argument ARG (the prefix when interactive) is non-nil."
  (interactive "*P")
  ;; I'm not sure if we show allow learning on an empty line.
  ;; Though it might occasionally be useful I think it usually
  ;; would just be confusing.
  (if (save-excursion
        (beginning-of-line)
        (looking-at "\\s-*$"))
      (message "shi-learn-line-indent ignores empty lines.")
    (let* ((info (shi-get-indent-info))
           (var (shi-get-indent-var-for-line info))
           ival sval diff new-val
           (no-symbol arg)
           (curr-indent (current-indentation)))
    (cond
     ((stringp var)
      (message (format "Cannot learn line - %s" var)))
     ((eq var 'shi-indent-comment)
      ;; This is arbitrary...
      ;; - if curr-indent is 0,  set to curr-indent
      ;; - else if it has the indentation of a "normal" line,
      ;;   then set to t
      ;; - else set to curr-indent.
      (setq shi-indent-comment
            (if (= curr-indent 0)
                0
              (let* ((shi-indent-comment t)
                     (val2 (shi-calculate-indent info)))
                (if (= val2 curr-indent)
                    t
                  curr-indent))))
      (message "%s set to %s" var (symbol-value var))
      )
     ((numberp (setq sval (shi-var-value var)))
      (setq ival (shi-calculate-indent info))
      (setq diff (- curr-indent ival))

      (shi-debug "curr-indent: %d   ival: %d  diff: %d  var:%s  sval %s"
               curr-indent ival diff  var sval)
      (setq new-val (+ sval diff))
;;;       I commented out this because someone might want to replace
;;;       a value of `+' with the current value of shi-basic-offset
;;;       or vice-versa.
;;;       (if (= 0 diff)
;;;           (message "No change needed!")
      (shi-set-var-value var new-val no-symbol)
      (message "%s set to %s" var (symbol-value var))
      )
     (t
      (debug)
      (message "Cannot change %s" var))
     ))))

(defun shi-mark-init (buffer)
  "Initialize a BUFFER to be used by `shi-mark-line'."
  (let ((main-buffer (current-buffer)))
    (save-excursion
      (set-buffer (get-buffer-create buffer))
      (erase-buffer)
      (occur-mode)
      (setq occur-buffer main-buffer)
      )))

(defun shi-mark-line (message point buffer &optional add-linenum occur-point)
  "Insert MESSAGE referring to location POINT in current buffer into BUFFER.
Buffer BUFFER is in `occur-mode'.
If ADD-LINENUM is non-nil the message is preceded by the line number.
If OCCUR-POINT is non-nil then the line is marked as a new occurence
so that `occur-next' and `occur-prev' will work."
  (let ((m1 (make-marker))
        (main-buffer (current-buffer))
        start
        (line "") )
    (if point
        (progn
          (set-marker m1 point (current-buffer))
          (if add-linenum
              (setq line (format "%d: " (1+ (count-lines 1 point)))))))
    (save-excursion
      (if (get-buffer buffer)
          (set-buffer (get-buffer buffer))
        (set-buffer (get-buffer-create buffer))
        (occur-mode)
        (setq occur-buffer main-buffer)
        )
      (goto-char (point-max))
      (setq start (point))
      (insert line)
      (if occur-point
          (setq occur-point (point)))
      (insert message)
      (if point
          (put-text-property start (point) 'mouse-face 'highlight))
      (insert "\n")
      (if point
          (progn
            (put-text-property start (point) 'occur m1)
            (if occur-point
                (put-text-property occur-point (1+ occur-point)
                                   'occur-point t))
            ))
      )))

(defvar shi-learned-buffer-hook nil
  "*An abnormal hook,  called with an alist of leared variables.")
;;; Example of how to use shi-learned-buffer-hook
;;
;; (defun what-i-learned (list)
;;   (let ((p list))
;;     (save-excursion
;;       (set-buffer "*scratch*")
;;       (goto-char (point-max))
;;       (insert "(setq\n")
;;       (while p
;;      (insert (format "  %s %s \n"
;;                      (nth 0 (car p)) (nth 1 (car p))))
;;      (setq p (cdr p)))
;;       (insert ")\n")
;;       )))
;;
;; (add-hook 'shi-learned-buffer-hook 'what-i-learned)

;; Originally this was shi-learn-region-indent (beg end)
;; However, in practise this was awkward so I changed it to
;; use the whole buffer.  Use narrowing if needbe.
(defun shi-learn-buffer-indent (&optional arg)
  "Learn how to indent the buffer the way it currently is.

Output in buffer \"*indent*\" shows any lines which have conflicting
values of a variable, and the final value of all variables learnt.
This buffer is popped to automatically if there are any discrepencies.

If no prefix ARG is given,  then variables are set to numbers.
If a prefix arg is given,  then variables are set to symbols when
applicable -- e.g. to symbol `+' if the value is that of the
basic indent.
If a positive numerical prefix is given, then  `shi-basic-offset'
is set to the prefix's numerical value.
Otherwise,  shi-basic-offset may or may not be changed,  according
to the value of variable `shi-learn-basic-offset'.

Abnormal hook `shi-learned-buffer-hook' if non-nil is called when the
function completes.  The function is abnormal because it is called
with an alist of variables learnt.  This feature may be changed or
removed in the future.

This command can often take a long time to run."
  (interactive "P")
  (shi-must-be-shell-mode)
  (save-excursion
    (goto-char (point-min))
    (let ((learned-var-list nil)
          (out-buffer "*indent*")
          (num-diffs 0)
          last-pos
          previous-set-info
          (max 17)
          vec
          msg
          (comment-col nil) ;; number if all same,  t if seen diff values
          (comments-always-default t) ;; nil if we see one not default
          initial-msg
          (specified-basic-offset (and arg (numberp arg)
                                       (> arg 0)))
          (linenum 0)
          suggested)
      (setq vec (make-vector max 0))
      (shi-mark-init out-buffer)

      (if specified-basic-offset
          (progn
            (setq shi-basic-offset arg)
            (setq initial-msg
                  (format "Using specified shi-basic-offset of %d"
                          shi-basic-offset)))
        (setq initial-msg
              (format "Initial value of shi-basic-offset: %s"
                      shi-basic-offset)))

      (while (< (point) (point-max))
        (setq linenum (1+ linenum))
;;      (if (zerop (% linenum 10))
            (message "line %d" linenum)
;;        )
        (unless (looking-at "\\s-*$") ;; ignore empty lines!
          (let* ((shi-indent-comment t) ;; info must return default indent
                 (info (shi-get-indent-info))
                 (var (shi-get-indent-var-for-line info))
                 sval ival diff new-val
                 (curr-indent (current-indentation)))
            (cond
             ((null var)
              nil)
             ((stringp var)
              nil)
             ((numberp (setq sval (shi-var-value var 'no-error)))
              ;; the numberp excludes comments since sval will be t.
              (setq ival (shi-calculate-indent))
              (setq diff (- curr-indent ival))
              (setq new-val (+ sval diff))
              (shi-set-var-value var new-val 'no-symbol)
              (unless (looking-at "\\s-*#");; don't learn from comments
                (if (setq previous-set-info (assoc var learned-var-list))
                    (progn
                      ;; it was already there,  is it same value ?
                      (unless (eq (symbol-value var)
                                  (nth 1 previous-set-info))
                        (shi-mark-line
                         (format "Variable %s was set to %s"
                                 var (symbol-value var))
                         (point) out-buffer t t)
                        (shi-mark-line
                         (format "  but was previously set to %s"
                                 (nth 1 previous-set-info))
                         (nth 2 previous-set-info) out-buffer t)
                        (setq num-diffs (1+ num-diffs))
                        ;; (delete previous-set-info  learned-var-list)
                        (setcdr previous-set-info
                                (list (symbol-value var) (point)))
                        )
                      )
                  (setq learned-var-list
                        (append (list (list var (symbol-value var)
                                            (point)))
                                learned-var-list)))
                (if (numberp new-val)
                    (progn
                      (shi-debug
                       "This line's indent value: %d"  new-val)
                      (if (< new-val 0)
                          (setq new-val (- new-val)))
                      (if (< new-val max)
                          (aset vec new-val (1+ (aref vec new-val))))))
                ))
             ((eq var 'shi-indent-comment)
              (unless (= curr-indent (shi-calculate-indent info))
                ;; this is not the default indentation
                (setq comments-always-default nil)
                (if comment-col;; then we have see one before
                    (or (eq comment-col curr-indent)
                        (setq comment-col t));; seen a different one
                  (setq comment-col curr-indent))
                    ))
              (t
              (shi-debug "Cannot learn this line!!!")
              ))
            (shi-debug
                "at %s learned-var-list is %s" (point) learned-var-list)
            ))
        (forward-line 1)
        ) ;; while
      (if shi-debug
          (progn
            (setq msg (format
                       "comment-col = %s  comments-always-default = %s"
                       comment-col comments-always-default))
            ;; (message msg)
            (shi-mark-line  msg nil out-buffer)))
      (cond
       ((eq comment-col 0)
        (setq msg  "\nComments are all in 1st column.\n"))
       (comments-always-default
        (setq msg  "\nComments follow default indentation.\n")
        (setq comment-col t))
       ((numberp comment-col)
        (setq msg  (format "\nComments are in col %d." comment-col)))
       (t
        (setq msg  "\nComments seem to be mixed,  leaving them as is.\n")
        (setq comment-col nil)
        ))
      (shi-debug msg)
      (shi-mark-line  msg nil out-buffer)

      (shi-mark-line initial-msg nil out-buffer t t)

      (setq suggested (shi-guess-basic-offset vec))

      (if (and suggested (not specified-basic-offset))
          (let ((new-value
                 (cond
                  ;; t => set it if we have a single value as a number
                  ((and (eq shi-learn-basic-offset t) (numberp suggested))
                   suggested)
                  ;; other non-nil => set it if only one value was found
                  (shi-learn-basic-offset
                   (if (numberp suggested)
                       suggested
                     (if (= (length suggested) 1)
                         (car suggested))))
                  (t
                   nil))))
            (if new-value
                (progn
                  (setq learned-var-list
                        (append (list (list 'shi-basic-offset
                                            (setq shi-basic-offset new-value)
                                            (point-max)))
                                learned-var-list))
                  ;; Not sure if we need to put this line in, since
                  ;; it will appear in the "Learned variable settings".
                  (shi-mark-line
                   (format "Changed shi-basic-offset to: %d" shi-basic-offset)
                   nil out-buffer))
              (shi-mark-line
               (if (listp suggested)
                   (format "Possible value(s) for shi-basic-offset:  %s"
                           (mapconcat 'int-to-string suggested " "))
                 (format "Suggested shi-basic-offset:  %d" suggested))
               nil out-buffer))))

      (setq learned-var-list
            (append (list (list 'shi-indent-comment comment-col (point-max)))
                                learned-var-list))
      (setq shi-indent-comment comment-col)

      (let ((name (buffer-name))
                (lines (if (and (eq (point-min) 1)
                                (eq (point-max) (1+ (buffer-size))))
                           ""
                         (format "lines %d to %d of "
                                 (1+ (count-lines 1 (point-min)))
                                 (1+ (count-lines 1 (point-max))))))
                )
        (shi-mark-line  "\nLearned variable settings:" nil out-buffer)

        (if arg
            ;; Set learned variables to symbolic rather than numeric
            ;; values where possible.
            (progn

              (let ((p (reverse learned-var-list))
                    var val)
                (while p
                  (setq var (car (car p)))
                  (setq val (nth 1 (car p)))
                  (cond
                   ((eq var 'shi-basic-offset)
                    )

                  ((numberp val)
                   (shi-set-var-value var val))
                  (t
                   ))

                  (setq p (cdr p))
                  ))

        ))

        (let ((p (reverse learned-var-list))
              var)
          (while p
            (setq var (car (car p)))
            (shi-mark-line (format "  %s %s" var (symbol-value var))
                           (nth 2 (car p)) out-buffer)
            (setq p (cdr p))
            ))

        (save-excursion
              (set-buffer out-buffer)
              (goto-char (point-min))
              (insert
               (format "Indentation values for buffer %s.\n" name)
               (format "%d indentation variable%s different values%s\n\n"
                       num-diffs
                       (if (= num-diffs 1)
                           " has"   "s have")
                       (if (zerop num-diffs)
                           "." ":"))
              )))
      ;; Are abnormal hooks considered bad form?
      (run-hook-with-args 'shi-learned-buffer-hook learned-var-list)
      (if (or shi-popup-occur-buffer (> num-diffs 0))
          (pop-to-buffer out-buffer))
      )))

(defun shi-guess-basic-offset (vec)
  "See if we can determine a reasonbable value for `shi-basic-offset'.
This is experimental, heuristic and arbitrary!
Argument VEC is a vector of information collected by
`shi-learn-buffer-indent'.
Return values:
  number          - there appears to be a good single value
  list of numbers - no obvious one,  here is a list of one or more
                    reasonable choices
  nil             - we couldn't find a reasonable one."
  (let* ((max (1- (length vec)))
        (i 1)
        (totals (make-vector max 0))
        (return nil)
        j)
    (while (< i max)
      (aset totals i (+ (aref totals i) (* 4 (aref vec i))))
      (setq j (/ i 2))
      (if (zerop (% i 2))
          (aset totals i (+ (aref totals i) (aref vec (/ i 2)))))
      (if (< (* i 2) max)
          (aset totals i (+ (aref totals i) (aref vec (* i 2)))))
      (setq i (1+ i))
      )
    (let ((x nil)
          (result nil)
          tot sum p
          )
      (setq i 1)
      (while (< i max)
        (if (/= (aref totals i) 0)
            (setq x (append x (list (cons i (aref totals i))))))
        (setq i (1+ i)))

      (setq x (sort x '(lambda (a b)
                         (> (cdr a)(cdr b)))))
      (setq tot (apply '+ (append totals nil)))

      (shi-debug (format "vec: %s\ntotals: %s\ntot: %d"
                         vec totals tot))

      (cond
       ((zerop (length x))
        (message "no values!"))       ;; we return nil
       ((= (length x) 1)
        (message "only value is %d" (car (car x)))
        (setq result (car (car x))))    ;; return single value
       ((> (cdr (car x)) (/ tot 2))
        ;; 1st is > 50%
        (message "basic-offset is probably %d" (car (car x)))
        (setq result (car (car x)))) ;;   again, return a single value
       ((>=  (cdr (car x)) (* 2 (cdr (car (cdr x)))))
        ;; 1st is >= 2 * 2nd
        (message "basic-offset could be %d" (car (car x)))
        (setq result (car (car x))))
       ((>= (+ (cdr (car x))(cdr (car (cdr x)))) (/ tot 2))
        ;; 1st & 2nd together >= 50%  - return a list
        (setq p x  sum 0 result nil)
        (while  (and p
                     (<= (setq sum (+ sum (cdr (car p)))) (/ tot 2)))
          (setq result (append result (list (car (car p)))))
          (setq p (cdr p)))
        (message "Possible choices for shi-basic-offset: %s"
                 (mapconcat 'int-to-string result " ")))
       (t
        (message "No obvious value for shi-basic-offset.  Perhaps %d"
                 (car (car x)))
        ;; result is nil here
        ))
      result
      )
    ))

;; ========================================================================

;; This syntax table stuff was derived from cperl-mode.el.
;; It needs
;;   (setq parse-sexp-lookup-properties t)
;; to work!

(defun shi-do-nothing (a b c)
  ;; checkdoc-params: (a b c)
  "A dummy function to prevent font-lock from re-fontifying a change.
Otherwise,  we fontify something and font-lock overwrites it."
  )

(defun shi-set-char-syntax (where new-prop)
  "Set the character's syntax table property at WHERE to be NEW-PROP."
  (or where
      (setq where (point)))
  (let ((font-lock-fontify-region-function 'shi-do-nothing))
    (put-text-property where (1+ where) 'syntax-table new-prop)
    (add-text-properties where (1+ where)
                         '(face shi-st-face rear-nonsticky t))
    ))

(defun shi-check-paren-in-case ()
  "Make syntax class of case label's right parenthesis not close parenthesis.
If this parenthesis is a case alternative,  set its syntax class to a word."
  (let ((start (point))
        state prev-line)
    ;; First test if this is a possible candidate,  the first "(" or ")"
    ;; on the line;  then, if go, check prev line is ;; or case.
    (save-excursion
      (beginning-of-line)
      ;; stop at comment or when depth becomes -1
      (setq state (parse-partial-sexp (point) start -1 nil nil t))
      (if (and
           (= (car state) -1)
           (= (point) start)
           (setq prev-line (shi-prev-line-beg)))
          (progn
            (goto-char prev-line)
            (beginning-of-line)
            ;; (setq case-stmt-start (point))
            ;; (if (looking-at "\\(^\\s-*case[^-a-z0-9_]\\|[^#]*;;\\s-*$\\)")
            (if (shi-search-word "\\(case\\|;;\\)" start)
                (shi-set-char-syntax (1- start) shi-special-syntax)
              ))))))

(defun shi-electric-rparen ()
  "Insert a right parethese,  and check if it is a case alternative.
If so, its syntax class is set to word.
Its text proerty has face `shi-st-face'."
  (interactive)
  (insert ")")
  (shi-check-paren-in-case))

(defun shi-electric-hash ()
  "Insert a hash, but check it is preceded by \"$\".
If so, it is given a syntax type of comment.
Its text proerty has face `shi-st-face'."
  (interactive)
  (let ((pos (point)))
    (insert "#")
    (if (eq (char-before pos) ?$)
      (shi-set-char-syntax pos shi-st-punc))))

(defun shi-electric-less (arg)
  "Insert a \"<\" and see if this is the start of a here-document.
If so, the syntax class is set so that it will not be automatically
reindented.
Argument ARG if non-nil disables this test."
  (interactive "*P")
  (let ((p1 (point)) p2 p3)
    (sh-maybe-here-document arg) ;; call the original fn in sh-script.el.
    (setq p2 (point))
    (if (/= (+ p1 (prefix-numeric-value arg)) p2)
        (save-excursion
          (forward-line 1)
          (end-of-line)
          (setq p3 (point))
          (shi-set-here-doc-region p2 p3))
      )))

(defun shi-set-here-doc-region (start end)
  "Mark a here-document from START to END so that it will not be reindented."
  (interactive "r")
  ;; Make the whole thing have syntax type word...
  ;; That way sexp movement doens't worry about any parentheses.
  ;; A disadvantage of this is we can't use forward-word within a
  ;; here-doc, which is annoying.
  (let ((font-lock-fontify-region-function 'shi-do-nothing))
    (put-text-property start end 'syntax-table shi-here-doc-syntax)
    (put-text-property start end 'face 'shi-heredoc-face)
    (put-text-property (1- end) end  'rear-nonsticky t)
    (put-text-property start (1+ start)  'front-sticky t)
    ))

(defun shi-remove-our-text-properties ()
  "Remove text properties relating to right parentheses and here documents."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (not (eobp))
      (let ((plist (text-properties-at (point)))
            (next-change
             (or (next-single-property-change (point) 'syntax-table
                                              (current-buffer) )
                 (point-max))))
        ;; Process text from point to NEXT-CHANGE...
        (if (get-text-property (point) 'syntax-table)
            (progn
              (shi-debug "-- removing props from %d to %d --"
                         (point) next-change)
              (remove-text-properties (point) next-change
                                      '(syntax-table nil))
              (remove-text-properties (point) next-change '(face nil))
              ))
        (goto-char next-change)))
    ))

(defun shi-search-word (word &optional limit)
  "Search forward for regexp WORD occuring as a word not in string nor comment.
If found, returns non nil with the match available in  \(match-string 2\).
Yes 2, not 1, since we build a regexp to guard against false matches
such as matching \"a-case\" when we are searching for \"case\".
If not found, it returns nil.
The search maybe limited by optional argument LIMIT."
  (interactive "sSearch for: ")
  (let ((found nil)
        ;; Cannot use \\b here since it matches "-" and "_"
        ;; (regexp (concat "\\(^\\|\\s-\\)" word "\\($\\|\\s-\\)"))
        ;; (regexp (concat "\\(^\\|\\Sw\\)" word "\\($\\|\\Sw\\)"))
        (regexp (shi-mkword-regexp word))
        start state where)
    (setq start (point))
    (while (and (setq start (point))
                (not found)
                (re-search-forward regexp limit t))
      ;; Found str;  check it is not in a comment or string.
      (setq state
            ;; Stop on comment:
            (parse-partial-sexp start (point) nil nil nil 'syntax_table))
      (if (setq where (nth 8 state))
          (if (= where -1)
              (setq found (point))
            (if (eq (char-after where) ?#)
                (end-of-line)
              (goto-char where)
              (unless (shi-safe-forward-sexp)
                ;; If the above fails we must either give up or
                ;; move forward and try again.
                (forward-line 1))
              ))
        (message "? where is nil ? at %d" (point))
        )
      )
    found
    ))

(defun shi-scan-case ()
  "Scan a case statement for right parens belonging to case alternatives.
Mark each as having syntax `shi-special-syntax'.
Called from scan-buff.  If ok, return non-nil."
  (let (end
        state
        (depth 1) ;; we are called at a "case"
        (start (point))
        (return t))

    ;; We enter here at a case statement
    ;; First, find limits of the case.
    (while (and (> depth 0)
                (shi-search-word "\\(case\\|esac\\)"))
      (if (equal (match-string 2) "case")
          (setq depth (1+ depth))
        (setq depth (1- depth)))
      )
    ;; (message "end of search for esac  at %d depth=%d" (point) depth)
    (setq end (point))
    (goto-char start)

    ;; if we found the esac,  then fix all appropriate ')'s in the region
    (if (zerop depth)
        (progn
          ;;
          (while (< (point) end)
          ;; search for targetdepth of -1 meaning extra right paren
            (setq state (parse-partial-sexp (point) end -1 nil nil nil))
            (if (and (= (car state) -1)
                     (= (char-before) ?\)))
                (progn
                  ;; (message "At %d  state is %s" (point) state)
                  ;; (message "Fixing %d" (point))
                  (shi-set-char-syntax (1- (point)) shi-special-syntax)
                  ;; we could advance to the next ";;" perhaps
                  )
              ;; (message "? Not found at %d" (point)) ; ok, could be "]"
              )
            )
          (goto-char end)
          )
      (message "No matching esac for case at %d" start)
      ;; (sit-for 1)
      (setq return nil)
      )
    return
    ))

(defun shi-scan-buffer ()
  "Scan a sh buffer for case statements and here-documents.

For each case alternative found, mark its \")\" with a text property
so that its syntax class is no longer a close parenthesis character.

Each here-document is also marked so that it is effectively immune
from indenation changes."
;; Do not call this interactively, call `shi-rescan-buffer' instead.
  (shi-must-be-shell-mode)
  (let ((n 0)
        (initial-buffer-modified-p (buffer-modified-p))
        start end where label ws)
    (if buffer-read-only
        (message "Cannot scan buffer - it is read-only")
      (save-excursion
        (goto-char (point-min))
        ;; 1. Scan for ")" in case statements.
        (while (and ;; (re-search-forward "^[^#]*\\bcase\\b" nil t)
                (shi-search-word "\\(case\\|esac\\)")
                ;; (progn (message "Found a case at %d" (point)) t)
                (shi-scan-case))
          )
        ;; 2. Scan for here docs
        (goto-char (point-min))
        ;;  while (re-search-forward "<<\\(-?\\)\\(\\s-*\\)\\(.*\\)$" nil t)
        (while (re-search-forward "<<\\(-?\\)" nil t)
          (unless (shi-in-comment-or-string (match-beginning 0))
            ;; (setq label (match-string 3))
            (setq label (shi-get-word))
            (if (string= (match-string 1) "-")
                ;; if <<- then we allow whitespace
                (setq ws "\\s-*")
              ;; otherwise we don't
              (setq ws ""))
            (while (string-match "['\"\\]" label)
              (setq label (replace-match "" nil nil label)))
            (if (setq n (string-match "\\s-+$" label))
                (setq label (substring label 0 n)))
            (forward-line 1)
            ;; the line containing the << could be continued...
            (while (shi-this-is-a-continuation)
              (forward-line 1))
            (setq start (point))
            (if (re-search-forward (concat "^" ws (regexp-quote label) "\\b")
                                   nil t)
                (shi-set-here-doc-region start (point))
              (debug "missing here-doc delimiter `%s'" label))))
        ;; 3. Scan for $# -- make the "#" a punctuation not a comment
        (goto-char (point-min))
        (let (state)
          (while (and (not (eobp))
                      (setq state (parse-partial-sexp
                                   (1+ (point))(point-max) nil nil nil t))
                      (nth 4 state))
            (goto-char (nth 8 state))
            (shi-debug "At %d  %s" (point) (eq (char-before) ?$))
            (if (eq (char-before) ?$)
                (shi-set-char-syntax (point) shi-st-punc) ;; not a comment!
              (end-of-line) ;; if this *was* a comment, ignore rest of line!
              )))
        ;; 4. Hide these changes from making a previously unmodified
        ;; buffer into a modified buffer.
        (if shi-debug
            (if initial-buffer-modified-p
                (message "buffer was initially modified")
              (message
               "buffer not initially modified - so clearing modified flag")))
        (set-buffer-modified-p initial-buffer-modified-p)
        ))
    ))

(defun shi-rescan-buffer ()
  "Rescan the buffer for case alternative parentheses and here documents.
This is called when a buffer goes from read-only to non-read-only state."
  (interactive)
  (if (eq major-mode 'sh-mode)
      (unless buffer-read-only
        (shi-remove-our-text-properties)
        (message "Re-scanning buffer...")
        (shi-scan-buffer)
        (message "Re-scanning buffer...done")
        )))

;; ========================================================================

;; styles -- a quick and dirty way of saving the indenation settings.
;; May be changed...

(defvar shi-styles-alist nil
  "A list of all known shell indentation styles.")

(defun shi-name-style (name &optional confirm-overwrite)
  "Name the current indentation settings as a style called NAME.
If this name exists,  the command will prompt whether it should be
overwritten if
- it was called interactively with a prefix argument,  or
- called non-interactively with optional CONFIRM-OVERWRITE non-nil."
  ;; (interactive "sName for this style: ")
  (interactive
   (list
    (read-from-minibuffer "Name for this style? " )
    (not current-prefix-arg)))
  (let ((slist (list name))
        (p shi-var-list)
        var style)
    (while p
      (setq var (car p))
        (setq slist (append slist (list (cons var (symbol-value var)))))
        (setq p (cdr p)))
    (if (setq style (assoc name shi-styles-alist))
        (if (or (not confirm-overwrite)
                (y-or-n-p "This style exists.  Overwrite it? "))
            (progn
              (message "Updating style %s" name)
              (setcdr style (cdr slist)))
          (message "Not changing style %s" name))
      (message "Creating new style %s" name)
      (setq shi-styles-alist (append shi-styles-alist
                                 (list   slist)))
      )))

(defun shi-load-style (name)
  "Set shell indentation values for this buffer from those in style NAME."
  (interactive (list (completing-read
                      "Which style to use for this buffer? "
                      shi-styles-alist nil t)))
  (let ((sl (assoc name  shi-styles-alist)))
    (if (null sl)
        (error "shi-load-style - style %s not known" name)
      (setq sl (cdr sl))
      (while sl
        (set (car (car sl)) (cdr (car sl)))
        (setq sl (cdr sl))
        ))
    ))

(defun shi-save-styles-to-buffer (buff)
  "Save all current styles in elisp to buffer BUFF.
This is always added to the end of the buffer."
  (interactive (list
    (read-from-minibuffer "Buffer to save styles in? " "*scratch*")))
  ;; This is an attempt to sort of pretty print it...
  (save-excursion
    (set-buffer (get-buffer-create buff))
    (goto-char (point-max))
    (insert "\n")
    (let ((p shi-styles-alist) q)
      (insert "(setq shi-styles-alist '(\n")
      (while p
        (setq q (car p))
        (insert "  ( " (prin1-to-string (car q)) "\n")
        (setq q (cdr q))
        (while q
          (insert "    "(prin1-to-string (car q)) "\n")
          (setq q (cdr q)))
        (insert "    )\n")
        (setq p (cdr p))
        )
      (insert "))\n")
      )))

;; ========================================================================

(defun shi-setup ()
  "This is called from `sh-mode'."
  ;; Normally sh-mode calls sh-set-shell which will call our
  ;; shi-shell-setup hook.  Howeover,  if M-x sh-mode is done on a
  ;; buffer and it does not know what the intenrpreter is then
  ;; sh-set-shell is not called hence shi-shell-setup isn't either,
  ;; so we won't setup our indentation.
  ;; So,  catch this case by testing interpreter not being bound
  ;; (See function `sh-mode') and warn the user.
  (unless (boundp 'interpreter)
    (message (substitute-command-keys
              "Please use \\[sh-set-shell] to set the shell type"))
    (sit-for 1)
    ;; Actually sh-sell has been setup to a default, sh, so we
    ;; could call shi-shell-setup now...
    (shi-shell-setup)
    )
  ;; I don't see any point in having a hook here...
  (if (sh-feature shi-indent-supported)
      (run-hooks 'shi-hook)
    (message "no indentation for this shell type"))
  )

(defun shi-shell-setup ()
  "This is called from `sh-set-shell'."
  (interactive)
  (if (sh-feature shi-indent-supported)
      (progn
        (message "Setting up indent for shell type %s" sh-shell)
        (make-local-variable 'shi-kw-alist)
        (make-local-variable 'shi-regexp-for-done)
        (make-local-variable 'parse-sexp-lookup-properties)
        ;; FIXME
        ;; This doesn't do what is needed.  The local map is common to
        ;; both sh-type and other-type modes.
        (if (sh-feature shi-electric-rparen-needed)
            (local-set-key ")" (quote shi-electric-rparen)))
        (local-set-key "<" (quote  shi-electric-less))
        (local-set-key "#" (quote  shi-electric-hash))
        (setq parse-sexp-lookup-properties t)
        (shi-scan-buffer)
        (setq shi-kw-alist (sh-feature shi-kw))
        (let ((regexp (sh-feature shi-kws-for-done)))
          (if regexp
              (setq shi-regexp-for-done
                    (shi-mkword-regexpr (regexp-opt regexp t)))))
        (message "setting up indent stuff")
        ;; sh-mode has already made indent-line-function local
        ;; but do it in case this is called before that
        (make-local-variable 'indent-line-function)
        (setq indent-line-function 'shi-indent-line)
        ;; why didn't the following work???
        ;; override use of sh-indent-line for now:
        (local-unset-key '[tab])
        (local-set-key  '[tab] 'indent-for-tab-command)
        ;; It is very inefficient,  but this at least makes
        ;; indent-region work:
        (make-local-variable 'indent-region-function)
        (setq indent-region-function nil)
        (add-hook 'toggle-read-only-hook 'shi-rescan-buffer)
        (if shi-make-vars-local
            (shi-make-vars-local))
        (message "Indentation setup for shell type %s" sh-shell)
        (run-hooks 'shi-set-shell-hook)
        )
    (message "No indentation for this shell type.")
    ))

;; ========================================================================

;; These values have been changed from those in sh-script.el
;; so that the template works with indent.
;; Since indenation isn't supported for csh and tcsh shells,
;; those templates are unchanged.
;;
;; Typical changes:
;; - replaced many "<" with a ">" sometimes after the closing keyword
;; - added ">" at the beginning to set initial indent
;; - for case, replaced ")" by  shi-electric-paren

(define-skeleton sh-case
  "Insert a case/switch statement.  See `sh-feature'."
  (csh "expression: "
       "switch( " str " )" \n
       > "case " (read-string "pattern: ") ?: \n
       > _ \n
       "breaksw" \n
       ( "other pattern, %s: "
         < "case " str ?: \n
         > _ \n
         "breaksw" \n)
       < "default:" \n
       > _ \n
       resume:
       < < "endsw")
  (es)
  (rc "expression: "
      > "switch( " str " ) {" \n
      > "case " (read-string "pattern: ") \n
      > _ \n
      ( "other pattern, %s: "
        "case " str > \n
        > _ \n)
      "case *" > \n
      > _ \n
      resume:
       ?} > )
  (sh "expression: "
      > "case " str " in" \n
      > (read-string "pattern: ")
      '(shi-electric-rparen)
      \n
      > _ \n
      ";;" \n
      ( "other pattern, %s: "
        > str  '(shi-electric-rparen) \n
        > _ \n
        ";;" \n)
      > "*"  '(shi-electric-rparen) \n
      > _ \n
      resume:
      "esac" > ))

(define-skeleton sh-for
  "Insert a for loop.  See `sh-feature'."
  (csh eval sh-modify sh
       1 ""
       2 "foreach "
       4 " ( "
       6 " )"
       15 '<
       16 "end"
       )
  (es eval sh-modify rc
      4 " = ")
  (rc eval sh-modify sh
      2 "for( "
      6 " ) {"
      15 ?} )
  (sh "Index variable: "
      > "for " str " in " _ "; do" \n
      > _ | ?$ & (sh-remember-variable str) \n
      "done" > ))

(define-skeleton sh-indexed-loop
  "Insert an indexed loop from 1 to n.  See `sh-feature'."
  (bash eval identity posix)
  (csh "Index variable: "
       "@ " str " = 1" \n
       "while( $" str " <= " (read-string "upper limit: ") " )" \n
       > _ ?$ str \n
       "@ " str "++" \n
       < "end")
  (es eval sh-modify rc
      4 " =")
  (ksh88 "Index variable: "
         > "integer " str "=0" \n
         > "while (( ( " str " += 1 ) <= "
         (read-string "upper limit: ")
         " )); do" \n
         > _ ?$ (sh-remember-variable str) > \n
         "done" > )
  (posix "Index variable: "
         > str "=1" \n
         "while [ $" str " -le "
         (read-string "upper limit: ")
         " ]; do" \n
         > _ ?$ str \n
         str ?= (sh-add (sh-remember-variable str) 1) \n
         "done" > )
  (rc "Index variable: "
      > "for( " str " in" " `{awk 'BEGIN { for( i=1; i<="
      (read-string "upper limit: ")
      "; i++ ) print i }'`}) {" \n
      > _ ?$ (sh-remember-variable str) \n
       ?} >)
  (sh "Index variable: "
      > "for " str " in `awk 'BEGIN { for( i=1; i<="
      (read-string "upper limit: ")
      "; i++ ) print i }'`; do" \n
      > _ ?$ (sh-remember-variable str) \n
      "done" > ))

(define-skeleton sh-if
  "Insert an if statement.  See `sh-feature'."
  (csh "condition: "
       "if( " str " ) then" \n
       > _ \n
       ( "other condition, %s: "
         < "else if( " str " ) then" \n
         > _ \n)
       < "else" \n
       > _ \n
       resume:
       < "endif")
  (es "condition: "
       > "if { " str " } {" \n
       > _ \n
       ( "other condition, %s: "
         "} { " str " } {" > \n
         > _ \n)
       "} {" > \n
       > _ \n
       resume:
       ?} > )
  (rc "condition: "
       > "if( " str " ) {" \n
       > _ \n
       ( "other condition, %s: "
           "} else if( " str " ) {"  > \n
           > _ \n)
       "} else {" > \n
       > _ \n
       resume:
        ?} >
       )
  (sh "condition: "
      '(setq input (sh-feature sh-test))
      > "if " str "; then" \n
      > _ \n
      ( "other condition, %s: "
      >  "elif " str "; then" > \n
      > \n)
       "else" > \n
      > \n
      resume:
      "fi" > ))

(define-skeleton sh-repeat
  "Insert a repeat loop definition.  See `sh-feature'."
  (es nil
      > "forever {" \n
      > _ \n
       ?} > )
  (zsh "factor: "
       > "repeat " str "; do" > \n
      >  \n
       "done" > ))

(define-skeleton sh-select
  "Insert a select statement.  See `sh-feature'."
  (ksh88 "Index variable: "
         > "select " str " in " _ "; do" \n
         > ?$ str \n
         "done" > )
  (bash eval sh-append ksh88)
  )

(define-skeleton sh-until
  "Insert an until loop.  See `sh-feature'."
  (sh "condition: "
      '(setq input (sh-feature sh-test))
      > "until " str "; do" \n
      > _ \n
       "done" > ))

(define-skeleton sh-while
  "Insert a while loop.  See `sh-feature'."
  (csh eval sh-modify sh
       2 ""
       3 "while( "
       5 " )"
       10 '<
       11 "end" )
  (es eval sh-modify sh
      3 "while { "
      5 " } {"
      10 ?} )
  (rc eval sh-modify sh
      3 "while( "
      5 " ) {"
      10 ?} )
  (sh "condition: "
      '(setq input (sh-feature sh-test))
      > "while " str "; do" \n
      > _ \n
      "done" > ))

(define-skeleton sh-while-getopts
  "Insert a while getopts loop.  See `sh-feature'.
Prompts for an options string which consists of letters for each recognized
option followed by a colon `:' if the option accepts an argument."
  (bash eval sh-modify sh
        18 "${0##*/}")
  (csh nil
       "while( 1 )" \n
       > "switch( \"$1\" )" \n
       '(setq input '("- x" . 2))
       > >
       ( "option, %s: "
         < "case " '(eval str)
         '(if (string-match " +" str)
              (setq v1 (substring str (match-end 0))
                    str (substring str 0 (match-beginning 0)))
            (setq v1 nil))
         str ?: \n
         > "set " v1 & " = $2" | -4 & _ \n
         (if v1 "shift") & \n
         "breaksw" \n)
       < "case --:" \n
       > "shift" \n
       < "default:" \n
       > "break" \n
       resume:
       < < "endsw" \n
       "shift" \n
       < "end")
  (ksh88 eval sh-modify sh
         16 "print"
         18 "${0##*/}"
         36 "OPTIND-1")
  (posix eval sh-modify sh
         18 "$(basename $0)")
  (sh "optstring: "
      > "while getopts :" str " OPT; do" \n
      > "case $OPT in" \n
      '(setq v1 (append (vconcat str) nil))
      ( (prog1 (if v1 (char-to-string (car v1)))
          (if (eq (nth 1 v1) ?:)
              (setq v1 (nthcdr 2 v1)
                    v2 "\"$OPTARG\"")
            (setq v1 (cdr v1)
                  v2 nil)))
        > str "|+" str '(shi-electric-rparen) \n
        > _ v2 \n
        > ";;" \n)
      > "*"  '(shi-electric-rparen) \n
      > "echo" " \"usage: " "`basename $0`"
      " [+-" '(setq v1 (point)) str
      '(save-excursion
         (while (search-backward ":" v1 t)
           (replace-match " ARG] [+-" t t)))
      (if (eq (preceding-char) ?-) -5)
      "] [--] ARGS...\"" \n
      "exit 2"  > \n
        "esac" >
         \n "done"
         > \n
      "shift " (sh-add "OPTIND" -1)))

(define-skeleton sh-tmp-file
  "Insert code to setup temporary file handling.  See `sh-feature'."
  (bash eval identity ksh88)
  (csh (file-name-nondirectory (buffer-file-name))
       "set tmp = /tmp/" str ".$$" \n
       "onintr exit" \n _
       (and (goto-char (point-max))
            (not (bolp))
            ?\n)
       "exit:\n"
       "rm $tmp* >&/dev/null" >)
  (es (file-name-nondirectory (buffer-file-name))
      > "local( signals = $signals sighup sigint; tmp = /tmp/" str
      ".$pid ) {" \n
      > "catch @ e {" \n
      > "rm $tmp^* >[2]/dev/null" \n
      "throw $e" \n
      "} {" > \n
       _ \n
      ?} > \n
      ?} > )
  (ksh88 eval sh-modify sh
         7 "EXIT")
  (rc (file-name-nondirectory (buffer-file-name))
      > "tmp = /tmp/" str ".$pid" \n
       "fn sigexit { rm $tmp^* >[2]/dev/null }")
  (sh (file-name-nondirectory (buffer-file-name))
      > "TMP=/tmp/" str ".$$" \n
      "trap \"rm $TMP* 2>/dev/null\" " ?0))

;; ========================================================================
;; Do this when we're loaded:

(add-hook 'sh-mode-hook 'shi-setup)
(add-hook 'sh-set-shell-hook 'shi-shell-setup)

(defvar toggle-read-only-hook nil
  "Hook run by `run-hooks' after `toggle-read-only' is executed.")
(eval-when-compile (require 'advice))
(defadvice toggle-read-only (after shindent activate)
  "Add a hook for `toggle-read-only'."
  (run-hooks 'toggle-read-only-hook))

;; ========================================================================
;; Debug:
(defvar shi-debug-show-indent-info-shows-indent-value nil)
(defun shi-debug-show-indent-info ()
  (interactive)
  (let ( (info (shi-get-indent-info))
         n (str "") )
    (if shi-debug-show-indent-info-shows-indent-value
        (setq n (shi-calculate-indent info)))
    (pop-to-buffer "*temp*")
    (insert (format "%s\n" info))
    (if shi-debug-show-indent-info-shows-indent-value
        (insert (format "Indentation: %s\n" n)))
    )
  (other-window 1))

(defun shi-goto-prev-stmt ()
  "Back to end of previous non-comment non-empty stmt."
  (interactive)
  (let ((result (shi-prev-stmt)))
    (if result
        (goto-char result)
      (message "no previous stmt"))))

(defun shi-goto-prev-line (arg)
  "Back to end of previous non-comment non-empty line.
If ARG is supplied go to the end of the line, otherwise go to the
beginning."
  (interactive "P")
  (let ((result (shi-prev-line arg)))
    (if result
        (goto-char result)
      (message "no previous line"))))

(defun shi-show-prev-thing ()
  (interactive)
  (let ((start (point))
        thing)
    (setq thing (shi-prev-thing))
    (message "from %d now at %d thing is %s" start (point)
             (if (numberp thing)
                 (format "character `%s'" (char-to-string thing))
               (format "`%s'" thing)))))
;; ========================================================================

(provide 'shindent)
;;; shindent.el ends here
