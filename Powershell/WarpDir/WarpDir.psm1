# WarpDir <3
$WD_PREV_PWD = ($HOME, $null)
$WD_ROOT = ".wd"
$WD_DIRS = "dirs"
$WD_FULL_PATH = "$HOME/$WD_ROOT/$WD_DIRS"
$WD_CMDS = @("help", "save", "rename", "remove", "list")
$WD_LIST_FLAGS = @("--sort")
$WD_SORT_ARGS = @("alias", "target")
$WD_BAD_CHARACTERS = @(".", "/", "~", "\")
$WD_ERROR_KIND = @{
    ALIAS_NOT_PROVIDED = "NOT_PROVIDED";
    ALIAS_NOT_EXIST = "NOT_EXIST";
    ALIAS_ALREADY_EXIST = "ALREADY_EXIST";
    ALIAS_NOT_ALLOWED_KEYWORD_RESERVED = "NOT_ALLOWED_KEYWORD_RESERVED";
    ALIAS_NOT_ALLOWED_NAME_MALFORMED = "ALIAS_NOT_ALLOWED_NAME_MALFORMED";
    COMMAND_FLAG_NOT_SUPPORTED = "COMMAND_FLAG_NOT_SUPPORTED";
    FLAG_SORT_MISSING_ARGUMENT = "MISSING_ARGUMENT";
}
$CMD_MAP = @{}
foreach ($v in $WD_CMDS) {
    $CMD_MAP.Add($v.ToUpper(), $v)
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
            throw "alias not allowed, keywords [ $error_meta ] are reserved"
        }
        $WD_ERROR_KIND.ALIAS_NOT_ALLOWED_NAME_MALFORMED {
            throw "alias not allowed, characters [ $error_meta ] may not be in the name"
        }
        $WD_ERROR_KIND.COMMAND_FLAG_NOT_SUPPORTED {
            throw "flag not supported, provide one of [ $error_meta ]"
        }
        $WD_ERROR_KIND.FLAG_SORT_MISSING_ARGUMENT {
            throw "missing flag argument, provide one of [ $error_meta ]"
        }
        default {
            throw "undefined error"
        }
    }
}

function get_wd_entries {
    $entries = @(Get-Content -Path $WD_FULL_PATH)
    if ($entries.Count -eq 0) {
        return @()
    }    
    return $entries.Split("\r\n")
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

function contains_bad_characters {
    param (
        [Parameter(Mandatory = $true)]
        $alias
    )
    foreach ($c in $WD_BAD_CHARACTERS) {
        if ($alias.Contains($c)) {
            return $true
        }
    }
    return $false
}

function is_qualified_path {
    param (
        [Parameter(Mandatory = $true)]
        $path
    )
    return $path -match "^[.]{2}" -or 
        $path -match "^[~.][/\\]" -or 
        $path -match "^[a-zA-Z]:[/\\]" -or 
        $path -match "^\\\\" -or 
        $path -match "^[/\\]"
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
        if (is_qualified_path $cmd1) {
            if (Test-Path -Path $cmd1) {
                $real_path = (Resolve-Path $cmd1).Path
                if (-not ($real_path -match ":[\\]$")) {
                    $real_path = $real_path.TrimEnd("\")
                }
                if (-not ($real_path -eq "/")) {
                    $real_path = $real_path.TrimEnd("/")
                }
                if ($PWD.Path -ne $real_path) {
                    $WD_PREV_PWD[0] = $PWD.Path
                    $WD_PREV_PWD[1] = $real_path
                }
                Set-Location $real_path
            } else {
                throw "no such directory: $cmd1"
            }
        } else {
            switch ($cmd1) {
                $CMD_MAP.HELP {
                    Write-Output "Commands:`n`n`t<no argument> (will toggle between current and previous directory)`n`n`tlist [--sort [alias|target]]`n`n`tsave [alias]`n`n`trename [alias new_alias]`n`n`tremove [alias]`n`n"
                }
                $CMD_MAP.SAVE {
                    if (-not $cmd2) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_PROVIDED
                    } elseif ($WD_CMDS -contains $cmd2) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_ALLOWED_KEYWORD_RESERVED $WD_CMDS
                    } elseif (contains_bad_characters $cmd2) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_ALLOWED_NAME_MALFORMED $WD_BAD_CHARACTERS
                    } elseif (alias_exists $cmd2) {
                        generate_error $WD_ERROR_KIND.ALIAS_ALREADY_EXIST
                    }
                    $WD_PREV_PWD[1] = $PWD.Path
                    Write-Output "$cmd2|$($PWD.Path)" >> $WD_FULL_PATH
                }
                $CMD_MAP.RENAME {
                    if (-not $cmd2 -or -not $cmd3) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_PROVIDED
                    } elseif (-not (alias_exists $cmd2)) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_EXIST
                    } elseif (alias_exists $cmd3) {
                        generate_error $WD_ERROR_KIND.ALIAS_ALREADY_EXIST
                    } elseif ($WD_CMDS -contains $cmd3) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_ALLOWED_KEYWORD_RESERVED $WD_CMDS
                    } elseif (contains_bad_characters $cmd3) {
                        generate_error $WD_ERROR_KIND.ALIAS_NOT_ALLOWED_NAME_MALFORMED $WD_BAD_CHARACTERS
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
                $CMD_MAP.REMOVE {
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
                $CMD_MAP.LIST {
                    $wd_entries = get_wd_entries
                    $default_list = @()
                    if ($wd_entries.Count -gt 0) {
                        $default_list = $wd_entries | ForEach-Object {
                            $wd_alias_split = $_.Split("|")
                            [pscustomobject]@{
                                Alias  = $wd_alias_split[0];
                                Target = $wd_alias_split[1];
                            }
                        }
                    }
                    if ($cmd2) {
                        if ($cmd2 -eq "--sort") {
                            switch ($cmd3) {
                                "alias" {
                                    return $default_list | Sort-Object { $_.Alias }
                                }
                                "target" {
                                    return $default_list | Sort-Object { $_.Target }
                                }
                                default {
                                    generate_error $WD_ERROR_KIND.FLAG_SORT_MISSING_ARGUMENT $WD_SORT_ARGS
                                }
                            }
                        } else {
                            generate_error $WD_ERROR_KIND.COMMAND_FLAG_NOT_SUPPORTED $WD_LIST_FLAGS
                        }
                    } else {
                        $default_list
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
    } elseif ($WD_PREV_PWD[1]) {
        if ($PWD.Path -ieq $WD_PREV_PWD[1]) {
            Set-Location $WD_PREV_PWD[0]    
        } else {
            Set-Location $WD_PREV_PWD[1]
        }
    }
}

Register-ArgumentCompleter -CommandName wd -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    $completions = (@("..") + ((Get-ChildItem -Directory).Name | ForEach-Object {
        "./$_"
    }) + $WD_CMDS + ((get_wd_entries) | ForEach-Object {
        $cmd_split = $_.Split("|")
        if ($cmd_split.Count -eq 1) {
            $cmd_split
        } else {
            $cmd_split[0]
        }
    }))
    $completions | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
    }
}

Export-ModuleMember -Function wd
