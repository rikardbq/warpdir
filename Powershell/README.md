## WarpDir pwsh
Put the WarpDir folder into one of the Powershell module paths, you can find them here `$env:PSModulePath`

Then in your `$PROFILE` file just add `Import-Module -Name WarpDir`

Any config will be located at `$HOME/.wd/`