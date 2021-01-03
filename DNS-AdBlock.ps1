# # [twitch.tv]
# 0.0.0.0 cdn-a.amazon-adsystem.com
# 0.0.0.0 vaes.amazon-adsystem.com
# 0.0.0.0 vq-fe-us-west-2.amazon-adsystem.com

# if not running as admin, run the same file again but in admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" `"$args`"" -Verb RunAs
    exit
}

Set-Variable -Name hosts_location -Value "C:\Windows\System32\drivers\etc\" -Option Constant, AllScope -Force
Set-Variable -Name web_source -Value "https://raw.githubusercontent.com/YiuMunLee/DNS-AdBlock/master/sources.txt" -Option Constant, AllScope -Force
Set-Variable -Name local_source -Value $false -Option AllScope

function update{
    if($local_source){
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
            InitialDirectory = $PSScriptRoot
        }
        $null = $FileBrowser.ShowDialog()

        Write-Host "Retreiving host sources from $($FileBrowser.FileName)"
        $sources = get-content -path $FileBrowser.FileName
        
    }else{
        Write-Host "Retreiving host sources from $web_source"
        $sources = (iwr $web_source).content.split("`n")
    }
    
    # if backup does _not_ exist
    if(!(Test-Path "$($hosts_location)\hosts.old" -PathType Leaf)){
        # $current_date = get-date -format "yyyMMddTHHmmss"
        # Copy-Item "$($hosts_location)\hosts" -Destination "$($hosts_location)\hosts_$($current_date).old"

        Copy-Item "$($hosts_location)\hosts" -Destination "$($hosts_location)\hosts.old"
    }

    Remove-Item -Path "$($hosts_location)\hosts"
    Copy-Item "$($hosts_location)\hosts.old" -Destination "$($hosts_location)\hosts"
    # appends to host file
    $sources | % {write-host * Adding $_ ; Add-Content -path "$($hosts_location)\hosts" -value (iwr "$($_)").Content}

    Clear-DnsClientCache # prob dont need this idfk
    Write-Host "Sucessfully updated host file"
}

function revert(){
    #if old version exist
    if(Test-Path "$($hosts_location)\hosts.old" -PathType Leaf){
        do{
            $Failed = $false
            Try{
                Remove-Item -Path "$($hosts_location)\hosts" -ErrorAction stop
                $Failed = $false
            }Catch{ 
                $Failed = $true
                write-host $_
                Write-Host "Trying again in 15 seconds`n"
                start-sleep 15
            }
        } while ($Failed)
    
        Copy-Item "$($hosts_location)\hosts.old" -Destination "$($hosts_location)\hosts"
        Remove-Item -Path "$($hosts_location)\hosts.old"
        Clear-DnsClientCache
        Write-Host "Sucessfully reverted to host.old"
    }else{
        Write-Host "No host.old file found. Cannot revert."
    }
}

while($true){
    Clear-Host
    Write-Host "*** DNS-AdBlocker ***"
    write-host "sources from __$(if($local_source){"local files"}else{"web sources"})__"
    Write-Host "Select Function; Leave Empty to Exit`n"
    
    $choice = Read-Host "1: Update DNS`n2: Revert to original`n3: Switch to local sources`n>"
    if($choice -ne ""){$choice = $choice.split(' ') | % {iex $_}}
    switch ($choice)
    {
        1{update}   
        2{revert}
        3{write-host "Using Local Sources" ; $local_source = $true}
        Default{exit}
    }
    write-host ""
    pause
}
