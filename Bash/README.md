## WarpDir bash
### \#\#\# WiP \#\#\#
Because cd ( change directory ) doesn't work inside a script in the sense that you wont change you current shell's directory, the only way to run this program is to source it, which is why the alias refers to a sourcing of the script and not executing it per se
```
alias wd=". ~/dev/warpdir/Bash/WarpDir.sh"
```