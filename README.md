# eclim-docker

[![Build Status](https://travis-ci.org/AlexandreCarlton/eclim-docker.svg?branch=master)](https://travis-ci.org/AlexandreCarlton/eclim-docker)

A containerised [`eclim`](http://eclim.org), affording us Java completion in Vim
without having to install [`eclipse`](https://www.eclipse.org/) or [`eclim`](http://eclim.org).

# Motivation

While [`YouCompleteMe`](https://github.com/Valloric/YouCompleteMe) (a popular
Vim plugin) provides completion for many languages, it does not provide any for
Java (unless `eclim` is installed).

Rather than having to install `eclipse` and `eclim` manually, we can instead
copy across a few scripts, tweak our `.vimrc` and be ready to go.

# Implementation

## Docker

The [Dockerfile](Dockerfile) provided builds `eclim` using the Java variant of
`eclipse`.
Since `eclim` requires access to multiple folders (including our workspace,
which can be customised), a helper script [`eclimd`](eclimd) has been provided
to launch the instance for us.
Unlike [`YouCompleteMe`](https://github.com/Valloric/YouCompleteMe), this
server is only launched once, albeit manually:

```bash
$ ./eclim [--debug]
```

This helper script will read the values provided in [`~/.eclimrc`](.eclimrc),
which must also be copied into our home directory:

```bash
$ cp .eclimrc ~/.eclimrc
```
Need to tweak autoload/eclim/client/nailgun.vim:

Finally, we need a way for our vim instance to communicate with the server
(which relies on an executable provided only by `eclim`).
As such, when building the docker image we modify the function used to get the
`eclim` command by allowing the user to set the `g:EclimCommand` variable:

```vim
function! eclim#clienet#nailgun#GetEclimCommand(home)
  " let command = a:home . 'bin/eclim'
  let command = get(g:, 'EclimCommand', a:home . 'bin/eclim')
  " ...
endfunction
```

# Vim
Of course, we need some way to interact with the server from within Vim.

`eclim` provides a set of `*.vim` files so that we can communicate with Vim.
However, these are only bundled in one place after we have run the `eclim`
installer, so we cannot clone the repository via our favourite plugin manager.

Instead, we copy the bundled files from our docker container into a directory
that can be loaded by our vim instance:

```bash
$ docker cp eclim:/usr/share/vim/vimfiles/eclim ~/.vim/plugged/eclim
```

We must also have `vim` register this using a plugin manager (in this case,
[`vim-plug`](`https://github.com/junegunn/vim-plug`)):

```vim
call plug#begin('~/.vim/plugged')
" ...
Plug 'ervandew/eclim', { 'frozen': 1, 'for': 'java' }
let g:EclimCompletionMethod = 'omnifunc'
let g:EclimCommand = '/path/to/eclim'
" ...
call plug#end()
```

We set `frozen` so that we do not try to update this plugin (since we manage
this manually).

Finally, we must set the `g:EclimCommand` to the full path of the
[`eclim`](eclim) wrapper script.
This affords us access to the client executable we use to interact with our
`eclim` server.

# Upgrading

Whenever a new version is released, we must adjust the `ECLIM_VERSION`
variables provided in the [`eclimd`](eclimd), [`eclim`](eclim) and
[`Makefile`](Makefile) files.

Once we have restarted the `eclimd` container, we must replace the files we
copied across into our bundled folder:

```bash
$ rm -rf ~/.vim/plugged/eclim
$ docker cp eclim:/usr/share/vim/vimfiles/eclim ~/.vim/plugged/eclim
```
