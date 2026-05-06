## (BREAKING) _**ff261de**_ (removed timestamps)
## 2026/05/06
This commit changed the config format from:
- timestamp|alias|target -> alias|target
- if your config follows the format "timestamp|alias|target" then please manually remove the timestamp from the config or run the following to make a backup of the wd dirs file and then rewrite the config to not include the timestamps.
```
cp ~/.wd/dirs ~/.wd/dirs_bkp && Write-Output $((Get-Content -Path "$HOME/.wd/dirs").Split("\r\n") | ForEach-Object {$sp = $_.Split("|");if ($sp.Count -eq 3){"$($sp[1])|$($sp[2])"} else {$_}}) > ~/.wd/dirs | Out-Null
```

## (BREAKING) _**dc09d6a**_ (added timestamps)
## 2026/04/28
This commit changed the config format from:
- alias|target -> timestamp|alias|target