;;; bazel-mode.el --- A major mode for editing Bazel files

;; Version: 1.1.0
;; Author: Neri Marschik
;; Url: https://github.com/codesuki/bazel-mode
;; Keywords: languages, bazel
;; Package-Requires: ((emacs "26"))

;;; Commentary:
;;
;; Basic Bazel support for Emacs
;;
;; For now this mode gives you python syntax highlighting for `WORKSPACE`, `BUILD.bazel` and `.bzl` files.
;; Formatting is supported by running `buildifier`.
;;
;; ## Installing buildifier
;; Buildifier needs Go to compile and install. Follow the directions in [1] or install by running the following command.
;;
;; ```
;; go get -u github.com/bazelbuild/buildtools/buildifier
;; ```
;;
;; [1] https://github.com/bazelbuild/buildtools/blob/master/buildifier/README.md
;;
;; ## Formatting Bazel files manually
;; `C-c C-f` runs `bazel-format` on the current buffer.
;;
;; ## Formatting Bazel files automatically before saving
;; Add the following to your Emacs config.
;; ```
;; (add-hook 'bazel-mode-hook (lambda () (add-hook 'before-save-hook #'bazel-format nil t)))
;; ```

;;; Code:
(defgroup bazel nil
  "Major mode for editing Bazel files."
  :prefix "bazel-"
  :group 'languages)

(defcustom bazel-format-command "buildifier"
  "The command to run to format gn files in place."
  :group 'bazel
  :type 'string)

(defun bazel-format ()
  "Run 'buildifier' on the buffer."
  (interactive)
  (let ((current-buffer (current-buffer))
        (oldpoint (point))
        (result-buffer (get-buffer-create "*bazel-format*")))
    (with-current-buffer result-buffer (erase-buffer))
    (if (zerop (call-process-region (point-min) (point-max) bazel-format-command nil result-buffer nil))
        (progn
          (with-current-buffer current-buffer (replace-buffer-contents result-buffer))
          (goto-char oldpoint))
      (message "bazel-format failed"))
    (kill-buffer result-buffer)))

(defvar bazel-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-f" 'bazel-format)
    map))

(defconst bazel-mode--font-lock-keywords
  `(
       ;; attr
    (,(regexp-opt '("attr.bool" "attr.int" "attr.int_list" "attr.label" "attr.label_keyed_string_dict"
                    "attr.label_list" "attr.license" "attr.output" "attr.output_list" "attr.string"
                    "attr.string_dict" "attr.string_list" "attr.string_list_dict")
                  'symbols)
     . 'font-lock-builtin-face)

    ;; See https://github.com/bazelbuild/starlark/blob/master/spec.md.
    (,(regexp-opt '("and" "else" "load" "break" "for" "not" "continue" "if" "or" "def" "in" "pass" "elif" "return")
                  'symbols)
     . 'font-lock-keyword-face)

    (,(regexp-opt '("True" "False" "None")
                  'symbols)
     . 'font-lock-constant-face)

    (,(regexp-opt '("any" "all" "bool" "dict" "dir" "enumerate"
                    "getattr" "hasattr" "hash" "int" "len" "list"
                    "max" "min" "print" "range" "repr" "reversed"
                    "sorted" "str" "tuple" "type" "zip")
                  'symbols)
     . 'font-lock-builtin-face)

    ;; string
    (,(regexp-opt '("capitalize" "count" "elems" "endswith" "find" "format" "index"
                    "isalnum" "isalpha" "isdigit" "islower" "isspace" "istitle" "isupper"
                    "join" "lower" "lstrip" "partition" "replace"
                    "rfind" "rindex" "rpartition" "rsplit" "rstrip"
                    "split" "splitlines" "startswith" "strip" "title" "upper")
                  'symbols)
     . 'font-lock-builtin-face)

    ;; dict
    ;; (,(regexp-opt '("clear" "get" "items" "keys" "pop" "popitem" "setdefault" "update" "values")
    ;;               'symbols)
    ;;  . 'font-lock-builtin-face)

    ;; list
    ;; (,(regexp-opt '("append" "clear" "extend" "index" "insert" "pop" "remove")
    ;;               'symbols)
    ;;  . 'font-lock-builtin-face)

    ;; bazel specific
    (,(regexp-opt '("PACKAGE_NAME" "REPOSITORY_NAME")
                  'symbols)
     . 'font-lock-constant-face)

    (,(regexp-opt '("all" "analysis_test_transition" "aspect" "bind" "configuration_field" "depset" "existing_rules" "fail"
                    "fail" "provider" "register_execution_platforms" "register_toolchains" "repository_rule"
                    "rule" "select" "workspace")
                  'symbols)
     . 'font-lock-builtin-face)

    (,(regexp-opt '("existing_rule" "exports_files" "glob" "package_group" "package_name" "repository_name")
                  'symbols)
     . 'font-lock-builtin-face)

    (,(regexp-opt '("AppleDebugOutputs" "AppleDylibBinary" "AppleDynamicFramework" "AppleExecutableBinary"
                    "AppleLoadableBundleBinary" "AppleStaticLibrary" "CcInfo" "CcSkylarkApiProvider"
                    "CcToolchainConfigInfo" "CcToolchainInfo" "CompilationContext" "ConstraintCollection"
                    "ConstraintSettingInfo" "ConstraintValueInfo" "DefaultInfo" "FeatureFlagInfo"
                    "file_provider" "FilesToRunProvider" "GeneratedExtensionRegistryProvider" "InstrumentedFilesInfo"
                    "java" "java_compilation_info" "java_output_jars" "JavaCcLinkParamsInfo""JavaInfo" "JavaRuntimeInfo"
                    "JavaToolchainInfo" "ObjcProvider" "OutputGroupInfo" "PlatformInfo" "ProguardSpecProvider" "ProtoInfo"
                    "ProtoRegistryProvider" "PyInfo" "PyRuntimeInfo" "TemplateVariableInfo" "ToolchainInfo" "ToolchainTypeInfo"
                    "XcodeProperties" "XcodeVersionConfig")
                  'symbols)
     . 'font-lock-builtin-face)



    ;; rules_go
    (,(regexp-opt '("go_image" "go_test" "go_binary" "go_library")
                  'symbols)
     . 'font-lock-builtin-face)

    ;; rules_docker
    (,(regexp-opt '("container_image" "passwd_entry" "passwd_file" "passwd_file" "passwd_tar")
                  'symbols)
     . 'font-lock-builtin-face)

    ;; bazel_tools
    (,(regexp-opt '("git_repository" "http_archive" "pkg_tar")
                  'symbols)
     . 'font-lock-builtin-face)))

;;;###autoload
(define-derived-mode bazel-mode python-mode "Bazel"
  "Major mode for editing Bazel files."
  :group 'bazel

  (setq-local comment-use-syntax t)

  (setq-local font-lock-defaults (list bazel-mode--font-lock-keywords))

  ;; Add imenu support
  ;; Replace python-imenu-create-index with the default one
  (setq-local imenu-create-index-function #'imenu-default-create-index-function)
  ;; Simple regex over method names
  (setq-local imenu-generic-expression
              '(("Build rule" "name *= *\"\\(.*\\)\"" 1))))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.bazel\\'" . bazel-mode))
(add-to-list 'auto-mode-alist '("\\.bzl\\'" . bazel-mode))
(add-to-list 'auto-mode-alist '("BUILD\\'" . bazel-mode))
(add-to-list 'auto-mode-alist '("WORKSPACE\\'" . bazel-mode))

(provide 'bazel-mode)
;;; bazel-mode.el ends here
