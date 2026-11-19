---
layout: post
title: 如何快速复制上一次执行的 shell 命令
date: 2026-11-19 13:36 +0800
tags:
    - TIL
    - 命令行
---

有时候经常需要复制命令行里刚刚执行过的命令，比如在验证成功之后发送给别人，或者设置成一个 alias 后续使用。当命令很长的时候，复制起来就有些麻烦。如果使用 oh-my-zsh 的话，可以使用它自带的 copybuffer 插件来解决这个问题：

```sh
# 在你的 oh-my-zsh 配置文件里加上

plugins=(
    ...
    copybuffer
)
```

然后就可以使用 ctrl-o 快捷键来复制当前命令行上的内容。这样，复制上一次执行过的 shell 命令，只需要按「上 + ctrl-o」两次按键即可完成。

[copybuffer 插件的源码](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/copybuffer/copybuffer.plugin.zsh) 其实并不复杂，是通过定义一个 shell 函数，然后快捷键绑定上去实现的：
```sh
# copy the active line from the command line buffer
# onto the system clipboard

copybuffer () {
  if builtin which clipcopy &>/dev/null; then
    printf "%s" "$BUFFER" | clipcopy
  else
    zle -M "clipcopy not found. Please make sure you have Oh My Zsh installed correctly."
  fi
}

zle -N copybuffer

bindkey -M emacs "^O" copybuffer
bindkey -M viins "^O" copybuffer
bindkey -M vicmd "^O" copybuffer
```

这里面用到了几个和 oh-my-zsh, zsh 特定的工具：
- `clipcopy` 是 oh-my-zsh 自带的，对于不同平台剪切板 cli 的封装，在 macOS 下它会调用 `pbcopy`。
- `zle`（Zsh Line Editor） 是 Zsh 内置的命令行编辑器，对应于 Bash 中的 Readline。它提供了 zsh 里面命令行编辑的相关功能，比如 ctrl-a 移动到行首，ctrl-u 删除整行，都是由 zle 实现的。`zle -N` 可以用来自定义一个 widget（就是一个 shell 函数）。

因此，如果不用 oh-my-zsh 或 zsh 的话，也可以快速实现一个同样的功能。
