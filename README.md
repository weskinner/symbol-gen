# Symbol-Gen package

Adds a shortcut to generate ctags symbols file for your project.  After you generate this file
you will be able to find symbols across your project using `cmd-shift-r`.  Symbol-gen includes
the options [found here](https://github.com/weskinner/symbol-gen/blob/master/lib/.ctags) by default.
However, you can include your own settings by adding them to `~/.ctags` on mac / linux or
`C:\ctags.conf` on windows.

###Installing

Install using the Atom Package Manager.

`apm install symbol-gen`

###Shortcut

Hit `cmd-alt-g` to generate tags file for your project.  This can take a few moments.

###Configuration

Symbol-gen will pay attention to your "Exclude VCS Ignored Paths" and "Ignored Names" atom settings.

###Caveats

The current implementation of Symbols View can take a bit to load a large (>20MB) tags file.  Be patient.
