## WarpDir bash
Put the `WarpDir` folder wherever you like\
Then in your `.bashrc` _(or somewhere you source your extra exports / aliases from)_ just append
```
export WD_HOME="/home/rikardbq/dev/warpdir/Bash/WarpDir/"
. "$WD_HOME/lib"
alias wd=". $WD_HOME/WarpDir.sh"
```
Any config will be located at `$HOME/.wd/`

Because cd ( change directory ) doesn't work inside a script in the sense that you won't change you current shell's directory, the only way to run this program is to source it, which is why the alias refers to a sourcing of the script and not executing it per se.

Works on Bash 3.2+ and depends on:
- awk
- sort
- column
- realpath

See **[/README.md](/README.md)** for usage instructions.
