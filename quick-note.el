;;; quick-note.el --- Single file note taking and searching -*- lexical-binding: t; -*-

;; Author: Your Name <your.email@example.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords: convenience, text, matching
;; URL: https://github.com/yourusername/quick-note

;;; Commentary:
;;
;; Quick Note provides a minimalist, Deft-like experience for managing
;; a single file of notes. It allows you to search through existing notes
;; using your preferred completion framework (with Orderless support)
;; and instantly append new notes if no match is found.

;;; Code:

(require 'pulse) ; 用于高亮跳转的行

;; ==========================================
;; Customization (用户配置区)
;; ==========================================

(defgroup quick-note nil
  "Minimalist single-file note taking and searching."
  :group 'convenience
  :prefix "quick-note-")

(defcustom quick-note-file (expand-file-name "quick-notes.org" user-emacs-directory)
  "存放所有快速笔记的单个文件路径。默认为 ~/.emacs.d/quick-notes.org。"
  :type 'file
  :group 'quick-note)

(defcustom quick-note-prefix-format "* [%Y-%m-%d %H:%M] "
  "新笔记插入时的前缀格式，支持 `format-time-string' 的时间格式。"
  :type 'string
  :group 'quick-note)

(defcustom quick-note-suffix-format "\n\n"
  "新笔记插入时的后缀格式，默认插入两个换行符以分隔段落。"
  :type 'string
  :group 'quick-note)

;; ==========================================
;; Core Functions (核心功能区)
;; ==========================================

;;;###autoload
(defun quick-note ()
  "在单文件笔记中搜索或添加。
如果选择已有的行，则跳转过去；如果输入新内容，则将其作为新段落插入文件开头。"
  (interactive)
  ;; 确保文件所在的目录存在
  (let ((dir (file-name-directory quick-note-file)))
    (unless (file-exists-p dir)
      (make-directory dir t)))
  
  ;; 确保文件存在
  (unless (file-exists-p quick-note-file)
    (write-region "" nil quick-note-file))

  (let* ((buf (find-file-noselect quick-note-file))
         ;; 提取非空行
         (lines (with-current-buffer buf
         ;; 第一个参数是字符串，第二个参数 t 表示忽略空行
         (string-lines (buffer-string) t)))
         ;; 获取用户输入或选择
         (selection (completing-read "Quick Note (Search/Add): " lines nil nil)))

    ;; 过滤掉空输入
    (when (not (string-empty-p (string-trim selection)))
      (pop-to-buffer buf)
      (widen)
      (goto-char (point-min))

      (if (member selection lines)
          ;; 找到了（跳转逻辑）
          (progn
            (search-forward selection nil t)
            (goto-char (match-beginning 0))
            (pulse-momentary-highlight-one-line (point))
            (recenter)
            (message "跳转到笔记: %s" (truncate-string-to-width selection 30 nil nil "...")))
        
        ;; 没找到（新建逻辑）
        (goto-char (point-min))
        (insert (format-time-string quick-note-prefix-format) 
                selection 
                quick-note-suffix-format)
        (save-buffer)
        (goto-char (point-min))
        (message "已添加新笔记！")))))

(provide 'quick-note)
;;; quick-note.el ends here