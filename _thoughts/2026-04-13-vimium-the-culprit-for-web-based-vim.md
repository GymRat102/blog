---
date: 2026-04-13 23:07:29 +0800
---

在一些基于网页的 shell 的 Vim 里，我一直不能正常用 Esc 来返回 Normal 模式：之前在 kodecloud 的网页练习 lab 里遇到过，今天在 leetcode 里又遇到了，按下 Esc 就会从当前的编辑窗口失焦。原因原来是使用了 Vimium 插件，关掉就好了，不解决的话真是一个 bummer。

解决方法的出处在这里：https://github.com/LeetCode-Feedback/LeetCode-Feedback/issues/22680#issuecomment-2160584248，是用 Dia 内置的 AI 找到的。用 AI 当搜索工具还是快，自己找不知道啥时候才能解决。
