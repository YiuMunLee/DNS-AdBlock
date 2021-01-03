# DNS-AdBlock

Simple script to edit window host files to redirect ad servers to localhost.

## Usage

Launch via powershell and enter integer option according to menu.

```sh
*** DNS-AdBlocker ***
sources from __web sources__
Select Function; Leave Empty to Exit

1: Update DNS
2: Revert to original
3: Switch to local sources
>:
```

### Explanation

1. `Update DNS`: downloads and appends to host file from sources
2. `Revert to original`: reverts the host file back to the backup
3. `Switch to local sources`: Prompts user for local file containing urls

### Prerequisite

Running unsigned powershell scripts will require editing the execution policy. Execute the following in powershell administrator shell to change:

`Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine`

Set "Bypass" to "Default" to revert (<https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.1>).

## Sources

Currently using files from:

* <https://adaway.org/hosts.txt>
* <https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext>
* <https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts>
