# WarpDir <3
$WD_PREV_PWD = ($null, $HOME)
$WD_ROOT = ".wd"
$WD_DIRS = "dirs"
$WD_FULL_PATH = "$HOME/$WD_ROOT/$WD_DIRS"
$WD_CMDS = @{
    HELP = "help";
    SAVE = "save";
    RENAME = "rename";
    REMOVE = "remove";
    LIST = "list";
}
$WD_ERROR_KIND = @{
    ALIAS_NOT_PROVIDED = "NOT_PROVIDED";
    ALIAS_NOT_EXIST = "NOT_EXIST";
    ALIAS_ALREADY_EXIST = "ALREADY_EXIST";
    ALIAS_NOT_ALLOWED_KEYWORD_RESERVED = "NOT_ALLOWED_KEYWORD_RESERVED";
    FLAG_SORT_MISSING_ARGUMENT = "MISSING_ARGUMENT";
}

function generate_error {
    param(
        [Parameter(Mandatory = $true)]
        $error_kind,
        [Parameter(Mandatory = $false)]
        $error_meta
    )
    switch ($error_kind) {
        $WD_ERROR_KIND.ALIAS_NOT_PROVIDED {
            throw "alias not provided"
        }
        $WD_ERROR_KIND.ALIAS_NOT_EXIST {
            throw "alias does not exist"
        }
        $WD_ERROR_KIND.ALIAS_ALREADY_EXIST {
            throw "alias already exist"
        }
        $WD_ERROR_KIND.ALIAS_NOT_ALLOWED_KEYWORD_RESERVED {
            throw "alias not allowed [$error_meta] are reserved keywords"
        }
        $WD_ERROR_KIND.FLAG_SORT_MISSING_ARGUMENT {
            throw "missing flag argument, provide one of [$error_meta]"
        }
        default {
            throw "undefined error"
        }
    }
}

function get_wd_entries {
    $entries = (Get-Content -Path $WD_FULL_PATH)
    return $entries.Count -gt 0 ? $entries.Split("\r\n") : @()
}

function alias_exists {
    param (
        [Parameter(Mandatory = $true)]
        $alias
    )
    foreach ($wd_conf_line in get_wd_entries) {
        $wd_alias = $wd_conf_line.Split("|")[0]
        if ($alias -eq $wd_alias) {
            return $true
        }
    }
    return $false
}

function print_remove_prompt {
    param (
        [Parameter(Mandatory = $true)]
        $alias
    )
    Read-Host "are you sure you want to remove alias [ $alias ]? (N/y)"
}

function wd {
    param (
        [Parameter(Mandatory = $false)]
        $cmd1,
        [Parameter(Mandatory = $false)]
        $cmd2,
        [Parameter(Mandatory = $false)]
        $cmd3
    )
    if (-not (Test-Path -Path "$HOME/$WD_ROOT")) {
        New-Item -Path ~/ -Name $WD_ROOT -ItemType Directory | Out-Null
    }
    if (-not (Test-Path -Path $WD_FULL_PATH)) {
        New-Item -Path $WD_FULL_PATH -ItemType File | Out-Null
    }
    if ($cmd1) {
        if ((Test-Path -Path $cmd1)) {
            $WD_PREV_PWD[0] = $PWD.Path
            $WD_PREV_PWD[1] = $cmd1
            Set-Location $cmd1
        } else {
            switch ($cmd1) {
                $WD_CMDS.HELP {
                    Write-Output "Commands:`n`n`t<no argument> (will toggle between current and previous directory)`n`n`tlist [--sort [alias, target]]`n`n`tsave [alias]`n`n`trename [alias new_alias]`n`n`tremove [alias]`n`n"
                }
                $WD_CMDS.SAVE {
                    if (-not $cmd2) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_PROVIDED
                    }
                    if ($WD_CMDS.Values -contains $cmd2) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_ALLOWED_KEYWORD_RESERVED $($WD_CMDS.Values -join ", ")
                    }
                    if (alias_exists $cmd2) {
                        generate_error $WD_ERROR_KIND.ALIAS_ALREADY_EXIST
                    }
                    $WD_PREV_PWD[0] = $PWD.Path
                    Write-Output "$cmd2|$($PWD.Path)" >> $WD_FULL_PATH
                }
                $WD_CMDS.RENAME {
                    if (-not $cmd2 -or -not $cmd3) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_PROVIDED
                    }
                    if (-not (alias_exists $cmd2)) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_EXIST
                    }
                    if (alias_exists $cmd3) {
                        generate_error $WD_ERROR_KIND.ALIAS_ALREADY_EXIST
                    }
                    if ($WD_CMDS.Values -contains $cmd3) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_ALLOWED_KEYWORD_RESERVED $($WD_CMDS.Values -join ", ")
                    }
                    $wd_entries_mapped = get_wd_entries | ForEach-Object {
                        $wd_alias_split = $_.Split("|")
                        if ($cmd2 -eq $wd_alias_split[0]) {
                            "$cmd3|$($wd_alias_split[1])"
                        } else {
                            $_
                        }
                    }
                    Write-Output $wd_entries_mapped > $WD_FULL_PATH
                }
                $WD_CMDS.REMOVE {
                    if (-not $cmd2) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_PROVIDED
                    }
                    if (-not (alias_exists $cmd2)) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_EXIST
                    }
                    $wd_prompted = $true
                    while ($wd_prompted) {
                        $wd_alias_remove = print_remove_prompt $cmd2
                        if ($wd_alias_remove -eq "" -or $wd_alias_remove -ieq "n") {
                            Write-Output "nothing changed"
                            $wd_prompted = $false
                        } elseif ($wd_alias_remove -ieq "y") {
                            $wd_entries_filtered = get_wd_entries | Where-Object {
                                $cmd2 -ne $_.Split("|")[0]
                            }
                            Write-Output $wd_entries_filtered > $WD_FULL_PATH
                            $wd_prompted = $false
                        }
                    }
                }
                $WD_CMDS.LIST {
                    $wd_entries = get_wd_entries
                    $default_list = ($wd_entries.Count -gt 0 ? $wd_entries : @("")) | ForEach-Object {
                        $wd_alias_split = $_.Split("|")
                        [pscustomobject]@{
                            Alias = $wd_alias_split[0];
                            Target = $wd_alias_split[1];
                        }
                    }
                    switch ($cmd2) {
                        "--sort" {
                            switch ($cmd3) {
                                "alias" {
                                    return $default_list | Sort-Object { $_.Alias }
                                }
                                "target" {
                                    return $default_list | Sort-Object { $_.Target }
                                }
                                default {
                                    generate_error $WD_ERROR_KIND.FLAG_SORT_MISSING_ARGUMENT "alias, target"
                                }
                            }
                        }
                        default {
                            $default_list
                        }
                    }
                }
                default {
                    $wd_entries_filtered = get_wd_entries | Where-Object {
                        $cmd1 -eq $_.Split("|")[0]
                    }
                    if (-not $wd_entries_filtered) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_EXIST
                    }
                    $target = $wd_entries_filtered.Split("|")[1]
                    if ($PWD.Path -ne $target) {
                        $WD_PREV_PWD[0] = $PWD.Path
                        $WD_PREV_PWD[1] = $target
                    }
                    Set-Location $target
                }
            }
        }
    } elseif ($WD_PREV_PWD[0]) {
        Set-Location $WD_PREV_PWD[($PWD.Path -eq $WD_PREV_PWD[0]) ? 1 : 0]
    }
}

Register-ArgumentCompleter -CommandName wd -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    $completions = ($WD_CMDS.Values + ((get_wd_entries) | ForEach-Object {
        $cmd_split = $_.Split("|")
        if ($cmd_split.Count -eq 1) {
            $cmd_split
        } else {
            $cmd_split[0]
        }
    }) + ((Get-ChildItem -Directory).Name | ForEach-Object {
        "./$_"
    })) | Sort-Object
    $completions | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
    }
}

Export-ModuleMember -Function wd
