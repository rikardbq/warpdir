## WarpDir bash
Put the `WarpDir` folder wherever you like\
Then in your `.bashrc` _(or somewhere you source your extra exports / aliases from)_ just append
```
export WD_HOME="/home/rikardbq/dev/warpdir/Bash/WarpDir/"
. "$WD_HOME/lib"
alias wd=". $WD_HOME/WarpDir.sh"
```
Any config will be located at `$HOME/.wd/`

Because cd ( change directory ) doesn't work inside a script in the sense that you won't change you current shell's directory, the only way to run this program is to source it, which is why the alias refers to a sourcing of the script and not executing it per se

## Usage
**Toggle between previous and current \$PWD (if _wd_ was used to get there)**\
`$ wd`

**Show a list of supported commands and usage**\
`$ wd help`

**Saving current directory as an alias**\
`$ wd save dev`

**Listing all aliases and their targets**\
`$ wd list`

**Rename an alias**\
`$ wd rename dev new_dev`

**Remove an alias(will be prompted to confirm)**\
`$ wd remove new_dev`
