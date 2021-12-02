<#
    .SYNOPSIS
    Creates VMs for some reason

    .DESCRIPTION
    Creates virtual machines for testing things.

    .EXAMPLE
    .\CreateVM -VMName "VM1", "VM2", "VM3"

    .NOTES
    Author: Michael Hanson 
#>

#Requires -Modules hyper-V

[CmdletBinding()]
param (
    [Parameter()]
    [String[]]
    $VMName,

    [Parameter()]
    [String]
    $VMServer = 'ITPR10404'
)

$BootISO = "E:\ISOs\windows.iso"

if (($null -eq $VMName) -or ($VMName -eq "")) {
    $VMName = Read-Host -Prompt "Enter 1 or more names for the VMs"
}

$VMName = $VMName.ToUpper()

$confirm = Read-Host "Are you sure you want to create the following VMs `n`n$($VMName | Out-String)(y/n)"

if ($confirm -eq 'y') {
    foreach ($Name in $VMName) {

        $VMparms = @{
            ComputerName       = $VMServer
            Name               = $Name
            MemoryStartupBytes = 8589934592
            BootDevice         = "VHD"
            NewVHDPath         = "E:\Hyper-V\$Name\Virtual Hard Disks\$Name.VHDX"
            NewVHDSizeBytes    = 136365211648
            Path               = "E:\Hyper-V\$Name"
            Generation         = 2
            Switch             = (Get-VMSwitch -ComputerName $VMServer).Name[0]
        }  
    
        if (!(Get-VM -name $Name -ErrorAction SilentlyContinue)) {
            Write-Host -NoNewline "Creating Virtual Machine [$Name]"
            
            # if VHD exists but VM Doesnt, rename old VHDX
            $Server = "\\$VMServer\E$"
            $VMDataLocation = "$Server\Hyper-V\$Name\"
            if (Test-Path -Path $VMDataLocation) {
                $confirm = Read-Host " - Found VMData ($VMDataLocation) Do you want to delete it? (y/n)"
                if ($confirm -eq 'y') {
                    Write-Host -NoNewline -ForegroundColor Yellow " - Removing $VMDataLocation VM files"
                    Remove-Item -Path $VMDataLocation -Recurse -Verbose
                }
                else {
                    "Skipping $Name due to $VMDataLocation existing"
                }
            }
            try {
                New-VM @VMparms
            }
            catch {
                Write-Erorr " - Failed to create VM [$Name] Reason: $_"
                exit
            }
            
            ADD-VMDvdDrive -ComputerName $VMServer -VMName $Name -Path $BootISO
            Set-VMProcessor -ComputerName $VMServer -VMName $Name -Count 4 -Reserve 10 -Maximum 75 -RelativeWeight 100
            Start-VM -ComputerName $VMServer -Name $Name
        }
        else {
            Write-Host -ForegroundColor Yellow " - $Name already exists"
        }
    }
}
else { 
    Write-Host "Terminating"
}