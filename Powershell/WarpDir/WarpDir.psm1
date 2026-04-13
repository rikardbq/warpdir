# WarpDir <3
$global:WD_PREV_PWD = ($null, $null)

$ERROR_ALIAS_NOT_PROVIDED = "alias not provided"
$ERROR_ALIAS_NOT_EXIST = "alias does not exist"
$ERROR_ALIAS_ALREADY_EXIST = "alias already exist"
$WD_ROOT = ".wd"
$WD_DIRS = "dirs"
$WD_HEADER = "///WD_PWSH_2026"

function Warp {
    param (
        [Parameter(Mandatory = $false)]
        $cmd1,
        [Parameter(Mandatory = $false)]
        $cmd2
    )
    if (-not (Test-Path -Path "$HOME/$WD_ROOT")) {
        New-Item -Path ~/ -Name $WD_ROOT -ItemType "Directory" | Out-Null
    }
    if (-not (Test-Path -Path "$HOME/$WD_ROOT/$WD_DIRS")) {
        Write-Output $WD_HEADER >> "$HOME/$WD_ROOT/$WD_DIRS"
    }
    if ($cmd1) {
        if ((Test-Path -Path $cmd1)) {
            Set-Location $cmd1
        } else {
            $wd_conf = (Get-Content -Path "$HOME/$WD_ROOT/$WD_DIRS").Split("\r\n")
            switch ($cmd1) {
                "save" {
                    if (-not $cmd2) {
                        throw $ERROR_ALIAS_NOT_PROVIDED
                    }
                    foreach ($wd_conf_line in $wd_conf) {
                        $wd_alias = $wd_conf_line.Split("|")[0]
                        if ($cmd2 -eq $wd_alias) {
                            throw $ERROR_ALIAS_ALREADY_EXIST
                        }
                    }
                    $global:WD_PREV_PWD[0] = $PWD
                    Write-Output "$cmd2|$PWD" >> "$HOME/$WD_ROOT/$WD_DIRS"
                }
                "remove" {
                    if (-not $cmd2) {
                        throw $ERROR_ALIAS_NOT_PROVIDED
                    }
                    $wd_conf_filtered = $wd_conf | Where-Object {
                        $cmd2 -ne $_.Split("|")[0]
                    }
                    if (-join $wd_conf_filtered -eq -join $wd_conf) {
                        throw $ERROR_ALIAS_NOT_EXIST
                    }
                    Write-Output $wd_conf_filtered > "$HOME/$WD_ROOT/$WD_DIRS"
                }
                "list" {
                    (($wd_conf.Length -gt 1) ? $wd_conf[1..($wd_conf.Length - 1)] : ("")) | ForEach-Object {
                        $wd_alias_split = $_.Split("|")
                        [pscustomobject]@{
                            Alias = $wd_alias_split[0];
                            Target = $wd_alias_split[1];
                        }
                    } | Format-Table
                }
                default {
                    $wd_conf_filtered = $wd_conf | Where-Object {
                        $cmd1 -eq $_.Split("|")[0]
                    }
                    if (-not $wd_conf_filtered) {
                        throw $ERROR_ALIAS_NOT_EXIST
                    }
                    $global:WD_PREV_PWD[0] = $PWD
                    $global:WD_PREV_PWD[1] = $wd_conf_filtered.Split("|")[1]
                    Set-Location $global:WD_PREV_PWD[1]
                }
            }
        }
    } elseif ($global:WD_PREV_PWD[0]) {
        Set-Location $global:WD_PREV_PWD[($PWD.ToString() -eq $global:WD_PREV_PWD[0].ToString()) ? 1 : 0]
    }
}
Export-ModuleMember -Function Warp
