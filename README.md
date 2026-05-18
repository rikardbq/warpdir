![wd](wd_logo.png)

### A human friendly shell tool for moving around fast
Made to make moving between long path names easier by saving "_WarpDirs_".

Originally inspired by a tool called WarpDrive which functions in a similar way, but I decided it would be more fun to hack something of my own.\
With that said please use with care. See **[LICENSE](LICENSE.txt)** 

## Usage
**Can be used instead of _cd_ if the path is a directory**\
`$ wd ~/.wd`

**Toggle between previous and current \$PWD (if _wd_ was used to get there)**\
`$ wd`

**Show a list of supported commands and usage**\
`$ wd help`

**Saving current directory as an alias**\
`$ wd save dev`

**Listing all aliases and their targets**\
`$ wd list`\
optional sort flag, can sort on alias and target\
`$ wd list --sort target`

**Rename an alias**\
`$ wd rename dev new_dev`

**Remove an alias(will be prompted to confirm)**\
`$ wd remove new_dev`