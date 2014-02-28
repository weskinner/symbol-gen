# Symbol-Gen package

Adds a shortcut to generate ctags symbols file for your project.  After you generate this file
you will be able to find symbols across your project using `cmd-shift-r`.  Symbol-gen uses
the configuration [found here](https://github.com/atom/symbols-view/blob/master/lib/.ctags) by default.  However, you can use your own settings by adding
them to `~/.ctags`.

:exclamation: **Warning**: This project is still in heavy development.  The output tags file can get somewhat polluted
for larger projects and can grow in size very rapidly.

###Installing

Install using the Atom Package Manager.

`apm install symbol-gen`

###Shortcut

Hit `cmd-alt-g` to generate tags file for your project.

####Currently Developing
- Better default tags generation
- Visual tags generation progress indicator for larger projects

####On the Horizon
- Update tags file on save of any file in project
