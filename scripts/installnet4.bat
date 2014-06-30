@@echo off
:CheckPowerShellExecutionPolicy
@@FOR /F "tokens=*" %%i IN ('powershell -noprofile -command Get-ExecutionPolicy') DO Set PSExecMode=%%i
@@if /I "%PSExecMode%"=="unrestricted" goto :RunPowerShellScript
@@if /I "%PSExecMode%"=="remotesigned" goto :RunPowerShellScript

@@NET FILE 1>NUL 2>NUL
@@if not "%ERRORLEVEL%"=="0" (
@@echo Elevation required to change PowerShell execution policy from [%PSExecMode%] to RemoteSigned
@@powershell -NoProfile -Command "start-process -Wait -Verb 'RunAs' -FilePath 'powershell.exe' -ArgumentList '-NoProfile Set-ExecutionPolicy RemoteSigned'"
@@) else (
@@powershell -NoProfile Set-ExecutionPolicy RemoteSigned
@@)

:RunPowerShellScript
@@set POWERSHELL_BAT_ARGS=%*
@@if defined POWERSHELL_BAT_ARGS set POWERSHELL_BAT_ARGS=%POWERSHELL_BAT_ARGS:"=\"%
@@PowerShell -Command Invoke-Expression $('$args=@(^&{$args} %POWERSHELL_BAT_ARGS%);'+[String]::Join([Environment]::NewLine,$((Get-Content '%~f0') -notmatch '^^@@^|^^:'))) & goto :EOF

{
# Start PowerShell
$NetFx4ClientUrl = 'http://download.microsoft.com/download/5/6/2/562A10F9-C9F4-4313-A044-9C94E0A8FAC8/dotNetFx40_Client_x86_x64.exe'
$NetFx4FullUrl = 'http://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe'
$NetFx4Path = 'c:\vagrant\resources\NetFx4'
$NetFx4InstallerFile = 'dotNetFx40.exe'
$NetFx4Installer = Join-Path $NetFx4Path $NetFx4InstallerFile

function Is64Bit { [IntPtr]::Size -eq 8 }

function Enable-Net40 {
    if(Is64Bit) {$fx="framework64"} else {$fx="framework"}
    if(!(test-path "$env:windir\Microsoft.Net\$fx\v4.0.30319")) {
        if (!(Test-Path $NetFx4Path)) {
          Write-Host "Creating folder `'$NetFx4Path`'"
          $null = New-Item -Path "$NetFx4Path" -ItemType Directory
        }

        if (!(Test-Path $NetFx4Installer)) {
            Write-Host "Downloading `'$NetFx4ClientUrl`' to `'$NetFx4Installer`'"
            (New-Object Net.WebClient).DownloadFile("$NetFx4ClientUrl","$NetFx4Installer")
        }

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.WorkingDirectory = "$NetFx4Path"
        $psi.FileName = "$NetFx4InstallerFile"
        $psi.Arguments = "/q /norestart /repair /log `'$NetFx4Path\NetFx4Install.log`'"
        #$psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Minimized;

        Write-Host "Installing `'$NetFx4Installer`'"
        $s = [System.Diagnostics.Process]::Start($psi);
        $s.WaitForExit();
        # if ($s.ExitCode -ne 0) {
        # Write-Error ".NET Framework install failed with exit code `'$($s.ExitCode)`'."
        # }
    }
}

Enable-Net40
# End PowerShell
}.Invoke($args)
