# Magda: Minimal Agda mode for Neovim

A plugin for those who cannot leave Neovim, not even for Evil mode.

This plugin can be installed with [`vim-plug`][1].

    call plug#begin()
    Plug 'pedrominicz/magda'
    call plug#end()

As the name says, this is plugin provides _minimal_ Agda mode for Neovim (Vim not supported). This means no syntax highlighting nor anything fancy. You can only type-check a whole file and normalize expressions. This is enough for most situations.

Three commands are provided: `:AgdaLoad`, `:AgdaCompute`, and `:AgdaComputeSelection`. `:AgdaLoad` type-checks a file and needs to be run at least once before normalizing expressions. `:AgdaCompute` type-checks and normalizes an expression and displays the result. `:AgdaComputeSelection` does the same thing, but instead of prompting the user it uses the last Visual mode selection.

This means you can write expressions in comments, use blockwise Visual mode to select them, and use `:AgdaComputeSelection` to normalize them. See `Test.agda` for a simple example. It is recommended to map these commands in your `init.vim`. You can see an example how to do that in `./init.vim`.

I may add more simple features in the future.

Fun fact: the name is a mix of magma (one of the simplest group-like structures) and Agda. "Minimal Agda mode for Neovim" just makes a good tag line.

[1]: https://github.com/junegunn/vim-plug
