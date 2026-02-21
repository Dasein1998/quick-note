# Quick Note for Emacs

Quick Note 是一个极简的 Emacs 单文件笔记插件。它借鉴了 Notational Velocity 和 Deft 的哲学，将“搜索”与“创建”无缝结合。结合 `orderless` 和现代补全框架（如 Vertico/Ivy），你可以实现多关键词边打字边过滤，有则跳转，无则立刻作为新笔记插入到文件开头。

## 特性 (Features)
- **单文件管理**：所有闪念和笔记集中在一个文件（默认支持 Org mode）。
- **无缝搜索与创建**：搜索匹配则高亮跳转；无匹配则直接生成新条目。
- **开箱即用的 Orderless 支持**：支持多关键词无序搜索。
- **高度可定制**：可自由修改时间戳前缀、笔记后缀及文件路径。

## 安装 (Installation)

由于目前尚未提交至 MELPA，你可以通过克隆仓库到本地进行安装，或者使用 `straight.el` / `quelpa`。

**使用 `use-package` 和 `straight.el`:**
```elisp
(use-package quick-note
  :straight (quick-note :type git :host github :repo "dasein1998/quick-note")
  :bind ("C-c n" . quick-note)
  :custom
  (quick-note-file "~/.emacs.d/quick-notes.org")
  (quick-note-prefix-format "* [%Y-%m-%d %H:%M] "))

