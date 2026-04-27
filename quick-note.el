;;; quick-note.el --- Single file note taking and searching -*- lexical-binding: t; -*-

;; Author: Your Name <dasein1998@gmail.com>
;; Version: 0.1.1
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

(require 'pulse)

;; ==========================================
;; Customization (用户配置区)
;; ==========================================

(defgroup quick-note nil
  "Minimalist single-file note taking and searching."
  :group 'convenience
  :prefix "quick-note-")

(defcustom quick-note-file (expand-file-name "quick-notes.org" user-emacs-directory)
  "存放所有快速笔记的单个文件路径。"
  :type 'file
  :group 'quick-note)

(defcustom quick-note-prefix-format "* [%Y-%m-%d %H:%M] "
  "新笔记插入时的前缀格式。"
  :type 'string
  :group 'quick-note)

(defcustom quick-note-timestamp-regexp "^[0-9]\\{8\\}T[0-9]\\{6\\}"
  "匹配笔记开头的正则表达式（对应 %Y%m%dT%H%M%S）。"
  :type 'string
  :group 'quick-note)

(defcustom quick-note-suffix-format "\n\n"
  "新笔记插入时的后缀格式。"
  :type 'string
  :group 'quick-note)

;; ==========================================
;; Core Functions (核心功能区)
;; ==========================================

;;;###autoload
(defun quick-note-move-to-top ()
  "将当前光标下的笔记块（以时间戳开头）移动到文件最顶部。"
  (interactive)
  (unless (derived-mode-p 'text-mode)
    (user-error "请在文本文件或笔记文件中使用此命令"))
  
  (save-excursion
    (let ((timestamp-re quick-note-timestamp-regexp)
          begin end note-content)
      
      ;; 1. 定位当前块的开始位置
      (save-excursion
        (if (re-search-backward timestamp-re nil t)
            (setq begin (point))
          (setq begin (point-min))))
      
      ;; 2. 定位当前块的结束位置（下一个时间戳之前）
      (save-excursion
        (goto-char begin)
        ;; 跳过当前的匹配项，寻找下一个
        (forward-char 1) 
        (if (re-search-forward timestamp-re nil t)
            (setq end (match-beginning 0))
          (setq end (point-max))))
      
      ;; 3. 提取并移动
      (setq note-content (buffer-substring-no-properties begin end))
      (delete-region begin end)
      (goto-char (point-min))
      (insert note-content)
      
      ;; 4. 确保文件开头只有必要的空行
      (unless (looking-at-p "\n\n")
        (insert "\n"))))
  
  (save-buffer)
  (pulse-momentary-highlight-one-line (point-min))
  (message "笔记已置顶并保存"))

;;;###autoload
(defun quick-note ()
  "在单文件笔记中搜索或添加。"
  (interactive)
  (let ((dir (file-name-directory quick-note-file)))
    (unless (file-exists-p dir)
      (make-directory dir t)))
  
  (unless (file-exists-p quick-note-file)
    (write-region "" nil quick-note-file))

  (let* ((buf (find-file-noselect quick-note-file))
         (lines (with-current-buffer buf
                  (string-lines (buffer-string) t)))
         (selection (completing-read "Quick Note (Search/Add): " lines nil nil)))

    (when (not (string-empty-p (string-trim selection)))
      (pop-to-buffer buf)
      (widen)
      (if (member selection lines)
          (progn
            (goto-char (point-min))
            (search-forward selection nil t)
            (goto-char (match-beginning 0))
            (pulse-momentary-highlight-one-line (point))
            (recenter)
            (message "跳转到笔记: %s" (truncate-string-to-width selection 30 nil nil "...")))
        
        (goto-char (point-min))
        (insert (format-time-string quick-note-prefix-format) 
                "\n"
                selection 
                quick-note-suffix-format)
        (save-buffer)
        (goto-char (point-min))
        (message "已添加新笔记！")))))

(provide 'quick-note)
;;; quick-note.el ends here