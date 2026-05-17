## WarpDir pwsh
Put the WarpDir folder into one of the Powershell module paths, you can find them here `$env:PSModulePath`\
Then in your `$PROFILE` file just add `Import-Module -Name WarpDir`\
Any config will be located at `$HOME/.wd/`

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
