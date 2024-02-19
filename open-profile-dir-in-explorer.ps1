# Open folder if it exists
if (!(Test-Path -Path ($env:userprofile + "\Documents\WindowsPowerShell"))) {
    explorer ($env:userprofile + "\Documents\WindowsPowerShell")

}
if (!(Test-Path -Path ($env:userprofile + "\Documents\Powershell"))) {
    explorer ($env:userprofile + "\Documents\Powershell")
}

