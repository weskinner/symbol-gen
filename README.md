# Symbol-Gen package

Adds a shortcut to generate ctags symbols file for your project.  After you generate this file
you will be able to find symbols across your project using `cmd-shift-r`.

## Installation

Install using the Atom Package Manager.

    apm install symbol-gen

## Shortcut

Hit `cmd-alt-g`/`ctrl-alt-g` to generate tags file for your project. This can take a few moments.

## Configuration

Symbol-gen will pay attention to your "Exclude VCS Ignored Paths" and "Ignored Names" Atom settings.

By default, the options [found here](https://github.com/weskinner/symbol-gen/blob/master/lib/.ctags)
are passed to the `ctags` executable. You can add a configuration file to your project root or home
directory to pass custom options. [Read more](http://ctags.sourceforge.net/ctags.html) in the ctags
manual under FILES.

#### Linux and macOS

    /etc/ctags.conf
    /usr/local/etc/ctags.conf
    $HOME/.ctags
    $PROJECTROOT/.ctags

#### Windows

    C:\ctags.cnf
    %HOMEPATH%\ctags.cnf
    %PROJECTROOT%\ctags.cnf

## Caveats

The current implementation of Symbols View can take a bit to load a large (>20MB) tags file.  Be patient.
