## WarpDir pwsh
Put the WarpDir folder into one of the Powershell module paths, you can find them here `$env:PSModulePath`\
Then in your `$PROFILE` file just add `Import-Module -Name WarpDir`\
Any config will be located at `$HOME/.wd/`

## Breaking change in commit dc09d6a (added timestamps)
In order to migrate the conf to the new format, run the following:

`$ cp ~/.wd/dirs ~/.wd/dirs_bkp`

`$wd_map = (Get-Content -Path "$HOME/.wd/dirs").Split("\r\n") | ForEach-Object { if ($_ -ne "///WD_PWSH_2026") { "$([System.DateTimeOffset]::Now.ToUnixTimeMilliseconds())|$_" } else { "$_" }}`

`Write-Output $wd_map > ~/.wd/dirs`