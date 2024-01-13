:: This file is licensed under the Microsoft Reciprocal License (MS-RL).
:: A copy of this license is provided in the file LICENSE-SCRIPTS.txt.

@echo off
setlocal EnableDelayedExpansion
cd /D "%~dp0"
::---------------------------------------------------------------
:GetAdministrator
net session >nul 2>&1 || (
	echo Requesting administrative privileges...
	Files\elevate_%PROCESSOR_ARCHITECTURE% %0 || (
		echo Unable to grant administrative privileges. Please run the file as administrator.
		echo.
		pause
	)
	exit /B
)
::---------------------------------------------------------------

if exist "Temp\" rd /s /q "Temp\"
md "Temp"

:Check2
title Checking compatibility ...
echo  - Checking Windows Build ...
for /f "tokens=3" %%a in ('Reg Query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild ^| findstr /r /i "REG_SZ"') do set "WinBuild=%%a"
if %WinBuild% LSS 9600 (
	rd /s /q Temp\
	echo This Windows version is not supported by WFAv7 Installer.
	echo Please use Windows 8.1+ ^(Build 9600+^) 
	echo Current OS build: %WinBuild%
	pause
	exit /B
)

echo  - Checking Windows Powershell ...
Powershell /? >nul 2>&1
set "PLV=%Errorlevel%"
if %PLV% NEQ 0 (
	rd /s /q Temp\
	echo Powershell cannot be found. Please enable Powershell and try again.
	echo Error code: %PLV%
	pause
	exit /B
)

echo  - Checking Cmdlets ...
Powershell -C "(Get-Command).name" > Temp\Commands.txt
findstr /X /C:"Get-Date" Temp\Commands.txt >nul || goto MissingCommand
findstr /X /C:"Get-Volume" Temp\Commands.txt >nul || goto MissingCommand
findstr /X /C:"Get-Partition" Temp\Commands.txt >nul || goto MissingCommand
findstr /X /C:"New-Partition" Temp\Commands.txt >nul || goto MissingCommand
findstr /X /C:"Resize-Partition" Temp\Commands.txt >nul || goto MissingCommand
findstr /X /C:"Remove-Partition" Temp\Commands.txt >nul || goto MissingCommand
findstr /X /C:"Get-CimInstance" Temp\Commands.txt >nul || goto MissingCommand
findstr /X /C:"Get-PartitionSupportedSize" Temp\Commands.txt >nul || goto MissingCommand
findstr /X /C:"Add-PartitionAccessPath" Temp\Commands.txt >nul || goto MissingCommand

del Temp\Commands.txt
goto SkipMissingCommand

:MissingCommand
rd /s /q Temp\
echo Required powershell cmdlets are not found.
echo Please use Official Windows 8.1 or Windows 10.
pause
exit /B

:SkipMissingCommand
:: Enable ansicon
if %WinBuild% LSS 10586 Files\ansicon_%PROCESSOR_ARCHITECTURE% -p
set "ESC="

goto Disclaimer

::---------------------------------------------------------------
:PrintLabel
echo  %ESC%[93m//////////////////////////////////////////////////////////////////////////////////////////////
echo  //                           %ESC%[97mWindows 10 for ARMv7 Installer 3.1%ESC%[93m                             //
echo  //                                   %ESC%[97mby RedGreenBlue123%ESC%[93m                                     //
echo  //                    %ESC%[97mThanks to: @Gus33000, @FadilFadz01, @Heathcliff74%ESC%[93m                     //
echo  //////////////////////////////////////////////////////////////////////////////////////////////%ESC%[0m
echo.
goto :EOF

::---------------------------------------------------------------
:Disclaimer
cls
color 07
title Windows 10 for ARMv7 Installer 3.1
echo.
echo.
echo                            %ESC%[97mWelcome to Windows 10 for ARMv7 Installer%ESC%[0m
echo.
echo                     %ESC%[93m=======================================================%ESC%[0m
echo.
echo                                           %ESC%[91mDISCLAIMER:%ESC%[0m
echo.
echo    %ESC%[36m+----------------------------------------------------------------------------------------+
echo    ^|                                                                                        ^|
echo    ^|%ESC%[95m  * I'm not responsible for bricked devices, dead SD cards,                             %ESC%[36m^|
echo    ^|%ESC%[95m    thermonuclear war, or you getting fired because the alarm app failed.               %ESC%[36m^|
echo    ^|                                                                                        ^|
echo    ^|%ESC%[95m  * YOU are choosing to make these modifications,                                       %ESC%[36m^|
echo    ^|%ESC%[95m    and if you point the finger at me for messing up your device, I will laugh at you.  %ESC%[36m^|
echo    ^|                                                                                        ^|
echo    ^|%ESC%[95m  * Your warranty will be void if you tamper with any part of your device / software.   %ESC%[36m^|
echo    ^|                                                                                        ^|
echo    +----------------------------------------------------------------------------------------+%ESC%[0m
echo.
set /p "Disclaimer=%ESC%[97m   Do you agree with the DISCLAIMER? %ESC%[93m[%ESC%[92mY%ESC%[93m/%ESC%[91mN%ESC%[93m]%ESC%[0m "
if not defined Disclaimer goto Disclaimer
set "Disclaimer=%Disclaimer:"=%"
if /i "%Disclaimer%" EQU "N" (
	rd /s /q Temp\
	cls
	call :PrintLabel
	echo  %ESC%[91mYou MUST agree with the DISCLAIMER to use WFAv7 Installer.%ESC%[0m
	echo.
	pause
	exit /b
)
if /i "%Disclaimer%" NEQ "Y" goto Disclaimer

::---------------------------------------------------------------
:ChooseDev
set "Model="
cls
call :PrintLabel
echo %ESC%[92mChoose your device model below:
echo  %ESC%[36m1) %ESC%[97mLumia 930
echo  %ESC%[36m2) %ESC%[97mLumia 929 (Icon)
echo  %ESC%[36m3) %ESC%[97mLumia 1520
echo  %ESC%[36m4) %ESC%[97mLumia 1520 AT^&T
echo  %ESC%[36m5) %ESC%[97mLumia 830 Global
echo  %ESC%[36m6) %ESC%[97mLumia 735 Global
echo  %ESC%[36m7) %ESC%[97mLumia 650
echo  %ESC%[36m8) %ESC%[97mLumia 640 XL LTE Global
echo  %ESC%[36m9) %ESC%[97mLumia 640 XL LTE AT^&T
echo  %ESC%[36mA) %ESC%[97mLumia 520
echo  %ESC%[36mB) %ESC%[97mLumia 920
echo  %ESC%[36mC) %ESC%[97mLumia 1020
echo  %ESC%[36mD) %ESC%[97mLumia 1020 AT^&T
set /p "Model=%ESC%[92mDevice:%ESC%[0m "
if not defined Model goto ChooseDev
set "Model=%Model:"=%"

if "%Model%" EQU "1" set "DevSpec=B" & set "HasCameraBtn=1" & set "LargeStorage=1" & goto Preparation
if "%Model%" EQU "2" set "DevSpec=B" & set "HasCameraBtn=1" & set "LargeStorage=1" & goto Preparation
if "%Model%" EQU "3" set "DevSpec=B" & set "HasCameraBtn=1" & set "LargeStorage=1" & goto Preparation
if "%Model%" EQU "4" set "DevSpec=B" & set "HasCameraBtn=1" & set "LargeStorage=1" & goto Preparation
if "%Model%" EQU "5" set "DevSpec=B" & set "HasCameraBtn=1" & set "LargeStorage=1" & goto Preparation
if "%Model%" EQU "6" set "DevSpec=B" & set "HasCameraBtn=0" & set "LargeStorage=0" & goto Preparation
if "%Model%" EQU "7" set "DevSpec=B" & set "HasCameraBtn=0" & set "LargeStorage=1" & goto Preparation
if "%Model%" EQU "8" set "DevSpec=B" & set "HasCameraBtn=0" & set "LargeStorage=0" & goto Preparation
if "%Model%" EQU "9" set "DevSpec=B" & set "HasCameraBtn=0" & set "LargeStorage=0" & goto Preparation
if /i "%Model%" EQU "A" set "DevSpec=A" & set "HasCameraBtn=0" & set "LargeStorage=0" & goto Preparation
if /i "%Model%" EQU "B" set "DevSpec=A" & set "HasCameraBtn=1" & set "LargeStorage=1" & goto Preparation
if /i "%Model%" EQU "C" set "DevSpec=A" & set "HasCameraBtn=1" & set "LargeStorage=1" & goto Preparation
if /i "%Model%" EQU "D" set "DevSpec=A" & set "HasCameraBtn=1" & set "LargeStorage=1" & goto Preparation
goto ChooseDev


::---------------------------------------------------------------
:Preparation
cls
call :PrintLabel
echo %ESC%[97m PREPARATION:
echo   - Read README.md and instruction before using this Installer.
echo   - Make sure your phone have enough battery for this installation.
echo   - Windows Phone 8.1 or Windows 10 Mobile (1607 or older) installed.
echo   * Highly recommend you to flash the original FFU before installation.
echo %ESC%[0m
pause

::---------------------------------------------------------------
:CheckReqFiles
cls
if "%Model%" EQU "1" (if not exist "Drivers\Lumia930" goto MissingDrivers)
if "%Model%" EQU "2" (if not exist "Drivers\LumiaIcon" goto MissingDrivers)
if "%Model%" EQU "3" (if not exist "Drivers\Lumia1520" goto MissingDrivers)
if "%Model%" EQU "4" (if not exist "Drivers\Lumia1520-AT&T" goto MissingDrivers)
if "%Model%" EQU "5" (if not exist "Drivers\Lumia830" goto MissingDrivers)
if "%Model%" EQU "6" (if not exist "Drivers\Lumia735" goto MissingDrivers)
if "%Model%" EQU "7" (if not exist "Drivers\Lumia650" goto MissingDrivers)
if "%Model%" EQU "8" (if not exist "Drivers\Lumia640XL" goto MissingDrivers)
if "%Model%" EQU "9" (if not exist "Drivers\Lumia640XL-AT&T" goto MissingDrivers)
if /i "%Model%" EQU "A" (if not exist "Drivers\Lumia520" goto MissingDrivers)
if /i "%Model%" EQU "B" (if not exist "Drivers\Lumia920" goto MissingDrivers)
if /i "%Model%" EQU "C" (if not exist "Drivers\Lumia1020" goto MissingDrivers)
if /i "%Model%" EQU "D" (if not exist "Drivers\Lumia1020-AT&T" goto MissingDrivers)
if not exist "%~dp0\install.wim" (
	cls
	call :PrintLabel
	echo  %ESC%[91mPlace install.wim in the Installer folder then try again.%ESC%[0m
	echo.
	pause
	goto ChooseDev
)
goto MOSAutoDetect

:MissingDrivers
cls
call :PrintLabel
echo  %ESC%[91mDrivers not found.
echo  Please download drivers for your device using Driver Downloader then try again.%ESC%[0m
echo.
pause
goto ChooseDev
::---------------------------------------------------------------

:MOSAutoDetect
cls
call :PrintLabel
echo %ESC%[97m Trying to detect MainOS ...%ESC%[91m

:: DiskNumber

for /f %%i in ('Powershell -C "(Get-CimInstance Win32_DiskDrive | ? {$_.PNPDeviceID -Match 'VEN_MSFT&PROD_PHONE_MMC_STOR'}).Index 2>$null"') do set "DiskNumber=%%i"
if "%DiskNumber%" EQU "" (for /f %%i in ('Powershell -C "(Get-CimInstance Win32_DiskDrive | ? {$_.PNPDeviceID -Match 'VEN_QUALCOMM&PROD_MMC_STORAGE'}).Index 2>$null"') do set "DiskNumber=%%i")
if "%DiskNumber%" EQU "" goto MOSAutoDetectFail

:: Search for MainOS in the GPT

Files\dsfo \\.\PHYSICALDRIVE%DiskNumber% 1024 16384 Temp\GPT >nul
for /l %%i in (0,1,47) do (
	set /a "Offset=128*%%i"

	Files\dsfo Temp\GPT !Offset! 128 Temp\GPT-PartEntry >nul
	Files\dsfo Temp\GPT-PartEntry 56 72 Temp\GPT-PartName >nul
	
	fc /T /U Temp\GPT-PartName Files\MainOS-PartName.bin >nul && goto PartitionNumber
	
	del Temp\GPT-PartName
	del Temp\GPT-PartEntry
)

:MOSAutoDetectFail
del Temp\GPT* 2>nul
echo %ESC%[91m Unable to auto detect MainOS.%ESC%[97m
goto MOSPath

:PartitionNumber
Files\dsfo Temp\GPT-PartEntry 16 16 Temp\GPT-PartUUID >nul
for /f "usebackq delims=" %%g in (`Powershell -C "([System.IO.File]::ReadAllBytes('Temp\GPT-PartUUID') | ForEach-Object { '{0:x2}' -f $_ }) -join ' ' 2>$null"`) do set "UuidHex=%%g"
for /f "tokens=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16" %%a in ("%UuidHex%") do (
	set "Uuid=%%d%%c%%b%%a-%%f%%e-%%h%%g-%%i%%j-%%k%%l%%m%%n%%o%%p"
)

for /f %%p in ('Powershell -C "(Get-Partition | ? { $_.Guid -eq '{%Uuid%}'}).PartitionNumber 2>$null"') do set "PartitionNumber=%%p"
for /f %%d in ('Powershell -C "(Get-Partition | ? { $_.Guid -eq '{%Uuid%}'}).DriveLetter 2>$null"') do set "DriveLetter=%%d"
if not exist %DriveLetter%:\EFIESP goto MOSAutoDetectFail
if not exist %DriveLetter%:\Data goto MOSAutoDetectFail

del Temp\GPT*
set "DLMOS=%DriveLetter%"
set "MainOS=%DriveLetter%:"

echo %ESC%[97m Detected MainOS at %DriveLetter%:%ESC%[0m
goto Win10MountCheck
::---------------------------------------------------------------

:MOSPath
set "MainOS="
echo.
set /p "MainOS=%ESC%[97m Enter MainOS Path: %ESC%[0m"
if not defined MainOS goto MOSPath
set "MainOS=%MainOS:"=%"

echo "%MainOS%"| findstr /I "^\"[A-Z][:]\"$" >nul || (
	echo %ESC%[91m Not a valid MainOS partition. Example: H: %ESC%[0m
	goto MOSPath
)

if not exist "%MainOS%\EFIESP" (
	echo %ESC%[91m Not a valid MainOS partition. Example: H: %ESC%[0m
	goto MOSPath
)
if not exist "%MainOS%\Data" (
	echo %ESC%[91m Not a valid MainOS partition. Example: H: %ESC%[0m
	goto MOSPath
)
set "DLMOS=%MainOS:~0,-1%"

echo %ESC%[97m Getting MainOS infos ...%ESC%[91m
for /f %%i in ('Powershell -C "(Get-Partition -DriveLetter %DLMOS%).DiskNumber 2>$null"') do set "DiskNumber=%%i"
for /f %%i in ('Powershell -C "(Get-Partition -DriveLetter %DLMOS%).PartitionNumber 2>$null"') do set "PartitionNumber=%%i"
goto Win10MountCheck

::---------------------------------------------------------------
:Win10MountCheck
if exist "%MainOS%\Windows10\" (
	echo %ESC%[91m Please remove/rename %MainOS%\Windows10.%ESC%[0m
	pause
	if exist "%MainOS%\Windows10\" goto Win10MountCheck
)

::PartitionInfo
echo %ESC%[97m Getting partitions' infos ...%ESC%[91m
for /f %%i in ('Powershell -C "(Get-Partition | ? { $_.AccessPaths -eq '%MainOS%\DPP\' }).PartitionNumber 2>$null"') do set "PartitionNumberDPP=%%i"
for /f %%i in ('Powershell -C "(Get-Partition | ? { $_.AccessPaths -eq '%MainOS%\EFIESP\' }).PartitionNumber 2>$null"') do set "PartitionNumberEFIESP=%%i"
for /f %%i in ('Powershell -C "(Get-Partition | ? { $_.AccessPaths -eq '%MainOS%\Data\' }).PartitionNumber 2>$null"') do set "PartitionNumberData=%%i"
:: TODO: ERROR HANDLING & LOGGING

::---------------------------------------------------------------
:: Prompts
if %LargeStorage% EQU 1 (
	call :DualbootPrompt
) else (
	set "Dualboot=N"
)	
if /i "%Dualboot%" EQU "N" call :ChargeThresholdPrompt
if /i "%Dualboot%" EQU "Y" call :StorageSpacePrompt
call :KernelDebugPrompt

echo.
echo %ESC%[93m WARNING:
if /i "%Dualboot%" EQU "N" echo   * This will permanently remove Windows Phone.
echo   * After pressing any key, the installation process will begin.
echo     This cannot be cancelled properly which may cause damage to your device.
echo   * If you want to cancel the installation, close this console RIGHT NOW.
echo.
pause >nul | set /p "=%ESC%[97m Press any key to begin installing ...%ESC%[0m "
goto BeginInstall

::---------------------------------------------------------------
:DualbootPrompt
set "Dualboot="
echo.
set /p "Dualboot=%ESC%[97m Use dual-boot? [Y/N]%ESC%[0m "
if not defined Dualboot goto DualbootPrompt
set "DualBoot=%DualBoot:"=%"
if /i "%Dualboot%" NEQ "Y" if /i "%Dualboot%" NEQ "N" goto DualbootPrompt
goto :EOF

::---------------------------------------------------------------
:StorageSpacePrompt
set "Win10SizeMB="
echo.
set /p "Win10SizeMB=%ESC%[97m Storage space for Windows 10 ARM in MBs: %ESC%[0m"
if not defined Win10SizeMB goto StorageSpacePrompt
set "Win10SizeMB=%Win10SizeMB:"=%"

echo "%Win10SizeMB%"| findstr "^\"[1-9][0-9]*\"$ ^\"0\"$" >nul || (
	echo  %ESC%[91mPlease enter a natural number.%ESC%[0m
	goto StorageSpacePrompt
)

if %Win10SizeMB% LSS 6144 (
	echo  %ESC%[91mYou need at least 6144 MB for Windows 10 ARM.%ESC%[0m
	goto StorageSpacePrompt
)

:: For spec A, use Get-PartitionSupportedSize
:: For spec B, use Get-Volume

if "%DevSpec%" EQU "A" for /f %%i in ('Powershell -C "[Math]::Floor(((Get-Partition -DiskNumber %DiskNumber% -PartitionNumber %PartitionNumberData% | Get-Volume).SizeRemaining) / 1MB) 2>$null"') do set "FreeSpace=%%i"
if "%DevSpec%" EQU "B" for /f %%i in ('Powershell -C "$Partition = Get-Partition -DiskNumber %DiskNumber% -PartitionNumber %PartitionNumberData%; [Math]::Floor((($Partition | Get-Volume).Size - ($Partition | Get-PartitionSupportedSize).SizeMin) / 1MB) 2>$null"') do set "FreeSpace=%%i"
if %Win10SizeMB% GTR %FreeSpace% (
	echo  %ESC%[91mNot enough storage space is available.
	echo  %ESC%[91mYou only have %FreeSpace% MB of storage space.%ESC%[0m
	goto StorageSpacePrompt
)
goto :EOF

::---------------------------------------------------------------
:KernelDebugPrompt
set "DebugEnabled="
echo.
set /p "DebugEnabled=%ESC%[97m Enable kernel debug? [Y/%ESC%[4mN%ESC%[0m%ESC%[97m]%ESC%[0m "
if not defined DebugEnabled (
	set "DebugEnabled=N"
	goto :EOF
)
set "DebugEnabled=%DebugEnabled:"=%"

if /i "%DebugEnabled%" NEQ "N" (
	if /i "%DebugEnabled%" NEQ "Y" goto KernelDebugPrompt
) 
goto :EOF

::---------------------------------------------------------------
:ChargeThresholdPrompt
set "ChargeThreshold="
echo.
set /p "ChargeThreshold=%ESC%[97m Specify minimum battery percentage to boot (0 to 99): %ESC%[0m"
if not defined ChargeThreshold goto ChargeThresholdPrompt
set "ChargeThreshold=%ChargeThreshold:"=%"

echo "%ChargeThreshold%"| findstr "^\"[1-9][0-9]*\"$ ^\"0\"$" >nul || (
	echo  %ESC%[91mPlease enter a natural number.%ESC%[0m
	goto ChargeThresholdPrompt
)

if %ChargeThreshold% GTR 99 (
	goto ChargeThresholdPrompt
)
goto :EOF

::--------------------------------------------------------------- UNINTERRUPTABLE INSTALL PROCESS
:BeginInstall
cls
call :PrintLabel

:: Generate log file name
if not exist Logs\NUL del Logs /Q 2>nul
if not exist Logs\ md Logs
cd Logs
for /f %%d in ('Powershell Get-Date -format "dd-MMM-yy 2>$null"') do set "Date1=%%d"
if not exist "%Date1%.log" set "LogName=Logs\%Date1%.log" & goto LoggerInit
if not exist "%Date1%-1.log" set "LogName=Logs\%Date1%-1.log" & goto LoggerInit
set "LogNum=1"

:LogName
if exist "%Date1%-*.log" (
    if exist "%Date1%-%LogNum%.log" (
        set /a "LogNum+=1"
        goto LogName
    ) else (
        set "LogName=Logs\%Date1%-%LogNum%.log"
    )
)

:LoggerInit
cd ..
set "ErrNum=0"
set Logger=2^>Temp\CurrentError.log ^>^> "%LogName%" ^&^
 set "Err=^!Errorlevel^!" ^&^
 (for /f "tokens=*" %%a in (Temp\CurrentError.log) do echo [ERR ] %%a) ^>^> Temp\ErrorConsole.log ^&^
 (if exist Temp\ErrorConsole.log type Temp\ErrorConsole.log) ^&^
 type Temp\CurrentError.log ^>^> "%LogName%" ^&^
 (if exist Temp\ErrorConsole.log del Temp\ErrorConsole.log) ^&^
 (if ^^!Err^^! NEQ 0 (set /a "ErrNum+=1" ^& echo %ESC%[93m[WARN] An error has occurred, installation will continue.%ESC%[91m))

set SevLogger=2^>Temp\CurrentError.log ^>^> "%LogName%" ^&^
 set "SevErr=^!Errorlevel^!" ^&^
 (for /f "tokens=*" %%a in (Temp\CurrentError.log) do echo [ERR ] %%a) ^>^> Temp\ErrorConsole.log ^&^
 (if exist Temp\ErrorConsole.log type Temp\ErrorConsole.log) ^&^
 type Temp\CurrentError.log ^>^> "%LogName%" ^&^
 (if exist Temp\ErrorConsole.log del Temp\ErrorConsole.log) ^&^
 (if ^^!SevErr^^! NEQ 0 (set /a "ErrNum+=1" ^>nul ^& goto SevErrFound))

::---------------------------------------------------------------

set "StartTime=%Time%"
echo.
echo %ESC%[97m[INFO] Installation was started at %StartTime%
echo #### INSTALLATION WAS STARTED AT %StartTime% #### >>"%LogName%"
echo ========================================================= >>"%LogName%"
echo ## Device is %Model%  ## >>"%LogName%"
echo ## MainOS is %MainOS% ## >>"%LogName%"
echo. >>"%LogName%"
if not exist Temp\ md Temp\

echo ## MainOS DriveLetter is %MainOS% ## >>"%LogName%"
echo ## DPP PN is %PartitionNumberDPP% ## >>"%LogName%"
echo ## EFIESP PN is %PartitionNumberEFIESP% ## >>"%LogName%"
echo ## Data PN is %PartitionNumberData% ## >>"%LogName%"
echo ## Dualboot is %Dualboot% ## >>"%LogName%"
if /i "%Dualboot%" EQU "Y" echo ## Win10SizeMB is %Win10SizeMB% ## >>"%LogName%"
if /i "%Dualboot%" EQU "N" echo ## ChargeThreshold is %ChargeThreshold% ## >>"%LogName%"
if /i "%Dualboot%" EQU "N" echo ## DebugEnabled is %DebugEnabled% ## >>"%LogName%"

echo %ESC%[97m[INFO] Checking partition for errors ...%ESC%[91m
chkdsk /f /x %MainOS%\Data %Logger%
chkdsk /f /x %MainOS% %Logger%

if /i "%Dualboot%" EQU "Y" (
	
	md %MainOS%\Windows10\ %Logger%
	
	if "%DevSpec%" EQU "A" (
		
		echo %ESC%[97m[INFO] Creating Windows 10 ARM VHDX ...%ESC%[91m
		Files\vhdxtool create -f "%MainOS%\Data\Windows10.vhdx" -s %Win10SizeMB%MB -v %SevLogger%

		:: Unfortunately New-VHD requires Hyper-V to be enabled
		echo>Temp\diskpart.txt sel vdisk file=%MainOS%\Data\Windows10.vhdx
		echo>>Temp\diskpart.txt attach vdisk
		echo>>Temp\diskpart.txt convert gpt
		echo>>Temp\diskpart.txt create par pri
		echo>>Temp\diskpart.txt format quick fs=ntfs
		echo>>Temp\diskpart.txt assign mount=%MainOS%\Windows10\
		diskpart /s Temp\diskpart.txt %SevLogger%
		del Temp\diskpart.txt

	) else (
		
		echo %ESC%[97m[INFO] Creating Windows 10 ARM Partition ...%ESC%[91m
		
		for /f %%i in ('Powershell -C "[Math]::Floor((Get-Partition -DiskNumber %DiskNumber% -PartitionNumber %PartitionNumberData%).Size / 1MB) - %Win10SizeMB% 2>>'%LogName%'"') do set "DataPartSizeMB=%%i"

		echo ## Resize-Partition ## >>"%LogName%"
		Powershell -C "Resize-Partition -DiskNumber %DiskNumber% -PartitionNumber %PartitionNumberData% -Size !DataPartSizeMB!MB; exit $Error.count" %SevLogger%
		
		echo ## New-Partition ## >>"%LogName%"
		powershell -C "New-Partition -DiskNumber %DiskNumber% -UseMaximumSize | Add-PartitionAccessPath -AccessPath '%MainOS%\Windows10\'; exit $Error.count" %SevLogger%
		
	)
	set "Win10Drive=%MainOS%\Windows10"
	
) else (

	echo %ESC%[97m[INFO] Resizing MainOS Partition ...%ESC%[91m
	echo ## Remove-Partition ## >>"%LogName%"
	Powershell -C "Remove-Partition -DiskNumber %DiskNumber% -PartitionNumber %PartitionNumberData% -confirm:$false; exit $Error.count" %SevLogger%
	echo ## Resize-Partition ## >>"%LogName%"
	Powershell -C "Resize-Partition -DriveLetter %DLMOS% -Size (Get-PartitionSupportedSize -DriveLetter %DLMOS%).sizeMax; exit $Error.count" %SevLogger%
	set "Win10Drive=%MainOS%"

)
echo ## Windows 10 drive is %Win10Drive% ## >>"%LogName%"
echo %ESC%[97m[INFO] Formatting Windows 10 ARM partition ...%ESC%[91m
format %Win10Drive% /FS:NTFS /V:Windows10 /Q /C /Y %SevLogger%

::---------------------------------------------------------------
echo ========================================================= >>"%LogName%"
echo %ESC%[97m[INFO] Installing Windows 10 ARM ...%ESC%[91m
if %WinBuild% LSS 10240 (
	Files\wimlib-imagex apply install.wim 1 %Win10Drive%\ --compact=lzx %SevLogger%
) else (
	Files\DISM\dism /Apply-Image /ImageFile:".\install.wim" /Index:1 /ApplyDir:%Win10Drive%\ /Compact %SevLogger%
)

::---------------------------------------------------------------
echo %ESC%[97m[INFO] Installing Drivers ...%ESC%[91m
echo %ESC%[93m[WARN] Error outputs will not be showed here.%ESC%[91m
if "%Model%" EQU "1" Files\DISM\dism /Image:%Win10Drive%\ /Add-Driver /Driver:".\Drivers\Lumia930" /Recurse %Logger%
if "%Model%" EQU "2" Files\DISM\dism /Image:%Win10Drive%\ /Add-Driver /Driver:".\Drivers\LumiaIcon" /Recurse %Logger%
if "%Model%" EQU "3" Files\DISM\dism /Image:%Win10Drive%\ /Add-Driver /Driver:".\Drivers\Lumia1520" /Recurse %Logger%
if "%Model%" EQU "4" Files\DISM\dism /Image:%Win10Drive%\ /Add-Driver /Driver:".\Drivers\Lumia1520-AT&T" /Recurse %Logger%
if "%Model%" EQU "5" Files\DISM\dism /Image:%Win10Drive%\ /Add-Driver /Driver:".\Drivers\Lumia830" /Recurse %Logger%
if "%Model%" EQU "6" Files\DISM\dism /Image:%Win10Drive%\ /Add-Driver /Driver:".\Drivers\Lumia735" /Recurse %Logger%
if "%Model%" EQU "7" Files\DISM\dism /Image:%Win10Drive%\ /Add-Driver /Driver:".\Drivers\Lumia650" /Recurse %Logger%
if "%Model%" EQU "8" Files\DISM\dism /Image:%Win10Drive%\ /Add-Driver /Driver:".\Drivers\Lumia640XL" /Recurse %Logger%
if "%Model%" EQU "9" Files\DISM\dism /Image:%Win10Drive%\ /Add-Driver /Driver:".\Drivers\Lumia640XL-AT&T" /Recurse %Logger%
if /i "%Model%" EQU "A" Files\DISM\dism /Image:%Win10Drive%\ /Add-Driver /Driver:".\Drivers\Lumia520" /Recurse %Logger%
if /i "%Model%" EQU "B" Files\DISM\dism /Image:%Win10Drive%\ /Add-Driver /Driver:".\Drivers\Lumia920" /Recurse %Logger%
if /i "%Model%" EQU "C" Files\DISM\dism /Image:%Win10Drive%\ /Add-Driver /Driver:".\Drivers\Lumia1020" /Recurse %Logger%
if /i "%Model%" EQU "D" Files\DISM\dism /Image:%Win10Drive%\ /Add-Driver /Driver:".\Drivers\Lumia1020-AT&T" /Recurse %Logger%

::---------------------------------------------------------------
echo ========================================================= >>"%LogName%"
echo %ESC%[97m[INFO] Mounting EFIESP and DPP ...%ESC%[91m
md %Win10Drive%\EFIESP
md %Win10Drive%\DPP
echo>Temp\diskpart1.txt sel dis %DiskNumber%
echo>>Temp\diskpart1.txt sel par %PartitionNumberEFIESP%
echo>>Temp\diskpart1.txt assign mount=%Win10Drive%\EFIESP
echo>>Temp\diskpart1.txt sel par %PartitionNumberDPP%
echo>>Temp\diskpart1.txt assign mount=%Win10Drive%\DPP
diskpart /s Temp\diskpart1.txt %Logger%
del Temp\diskpart1.txt

echo %ESC%[97m[INFO] Installing Mass Storage Mode UI ...%ESC%[91m
xcopy .\Files\MassStorage %MainOS%\EFIESP\Windows\System32\Boot\ui /E /H /I /Y %Logger%

echo %ESC%[97m[INFO] Adding BCD Entry ...
echo %ESC%[93m[WARN] Error outputs will not be showed here.%ESC%[91m
set "bcdLoc=%MainOS%\EFIESP\EFI\Microsoft\Boot\BCD"
echo ## BCD Path is %bcdLoc% ## >>"%LogName%" 
set "id={703c511b-98f3-4630-b752-6d177cbfb89c}"

Files\bcdedit /store "%bcdLoc%" /create %id% /d "Windows 10 ARM" /application "osloader" %SevLogger%

if "%DevSpec%" EQU "A" (
	if /i "%Dualboot%" EQU "Y" (
		Files\bcdedit /store "%bcdLoc%" /set %id% "device" "vhd=[%MainOS%\Data]\Windows10.vhdx" %SevLogger%
		Files\bcdedit /store "%bcdLoc%" /set %id% "osdevice" "vhd=[%MainOS%\Data]\Windows10.vhdx" %SevLogger%
	) else (
		Files\bcdedit /store "%bcdLoc%" /set %id% "device" "partition=%Win10Drive%" %SevLogger%
		Files\bcdedit /store "%bcdLoc%" /set %id% "osdevice" "partition=%Win10Drive%" %SevLogger%
	)
) else (
	Files\bcdedit /store "%bcdLoc%" /set %id% "device" "partition=%Win10Drive%" %SevLogger%
	Files\bcdedit /store "%bcdLoc%" /set %id% "osdevice" "partition=%Win10Drive%" %SevLogger%
)

Files\bcdedit /store "%bcdLoc%" /set %id% "path" "\Windows\System32\winload.efi" %SevLogger%
Files\bcdedit /store "%bcdLoc%" /set %id% "systemroot" "\Windows" %SevLogger%
Files\bcdedit /store "%bcdLoc%" /set %id% "locale" "en-US" %Logger%
Files\bcdedit /store "%bcdLoc%" /set %id% "testsigning" Yes %SevLogger%
Files\bcdedit /store "%bcdLoc%" /set %id% "nointegritychecks" Yes %Logger%
Files\bcdedit /store "%bcdLoc%" /set %id% "inherit" "{bootloadersettings}" %Logger%
Files\bcdedit /store "%bcdLoc%" /set %id% "bootmenupolicy" "Standard" %Logger%
Files\bcdedit /store "%bcdLoc%" /set %id% "detecthal" Yes %Logger%
Files\bcdedit /store "%bcdLoc%" /set %id% "winpe" No %Logger%
Files\bcdedit /store "%bcdLoc%" /set %id% "ems" No %Logger%
Files\bcdedit /store "%bcdLoc%" /set %id% "bootdebug" No %Logger%

if /i "%DebugEnabled%" EQU "N" (
	Files\bcdedit /store "%bcdLoc%" /set %id% "debug" No %Logger%
) else (
	Files\bcdedit /store "%bcdLoc%" /set %id% "debug" Yes %Logger%
)

Files\bcdedit /store "%bcdLoc%" /set {dbgsettings} "debugtype" USB %Logger%
Files\bcdedit /store "%bcdLoc%" /set {dbgsettings} "targetname" "WOATARGET" %Logger%

:: Boot entry display
if /i "%Dualboot%" EQU "N" (
	Files\bcdedit /store "%bcdLoc%" /default %id% %Logger%
	Files\bcdedit /store "%bcdLoc%" /displayorder %id% %Logger%
) else (
	Files\bcdedit /store "%bcdLoc%" /set {default} description "Windows Phone" %Logger%
	Files\bcdedit /store "%bcdLoc%" /displayorder %id% {default} %Logger%

	if %HasCameraBtn% EQU 1 (
		Files\bcdedit /store "%bcdLoc%" /deletevalue {bootmgr} customactions %Logger%
	) else (
		Files\bcdedit /store "%bcdLoc%" /set {bootmgr} customactions 0x1000048000001 0x54000001 0x1000050000001 0x54000002 %Logger%
		Files\bcdedit /store "%bcdLoc%" /set {bootmgr} custom:0x54000001 {703c511b-98f3-4630-b752-6d177cbfb89c} %Logger%
	)
)

:: Charge threshold
if /i "%Dualboot%" EQU "N" Files\bcdedit /store "%bcdLoc%" /set {globalsettings} "chargethreshold" %ChargeThreshold% %Logger%

Files\bcdedit /store "%bcdLoc%" /set {bootmgr} "nointegritychecks" Yes %Logger%
Files\bcdedit /store "%bcdLoc%" /set {bootmgr} "testsigning" Yes %Logger%
Files\bcdedit /store "%bcdLoc%" /set {bootmgr} "booterrorux" Standard %Logger%
Files\bcdedit /store "%bcdLoc%" /set {bootmgr} "displaybootmenu" Yes %SevLogger%
Files\bcdedit /store "%bcdLoc%" /set {bootmgr} "timeout" 5 %Logger%

::---------------------------------------------------------------
echo ========================================================= >>"%LogName%"
echo %ESC%[97m[INFO] Setting up ESP ...%ESC%[91m
md %MainOS%\EFIESP\EFI\Microsoft\Recovery\ %Logger%
Files\bcdedit /createstore %MainOS%\EFIESP\EFI\Microsoft\Recovery\BCD %SevLogger%

echo>Temp\diskpart.txt sel dis %DiskNumber%
echo>>Temp\diskpart.txt sel par %PartitionNumberEFIESP%
echo>>Temp\diskpart.txt set id=c12a7328-f81f-11d2-ba4b-00a0c93ec93b override
diskpart /s Temp\diskpart.txt %Logger%
del Temp\diskpart.txt

copy "Files\PostInstall\PostInstall.cmd" "%Win10Drive%\PostInstall.cmd" %Logger%

:: Unmount VHDX
if "%DevSpec%" EQU "A" (
	if /i "%Dualboot%" EQU "Y" (
		echo %ESC%[97m[INFO] Unmounting VHDX ...%ESC%[91m
		echo>Temp\diskpart.txt sel vdisk file=%MainOS%\Data\Windows10.vhdx
		echo>>Temp\diskpart.txt detach vdisk
		diskpart /s Temp\diskpart.txt %Logger%
		del Temp\diskpart.txt
	)
)

rd /s /q Temp\
goto MissionCompleted
::---------------------------------------------------------------

:SevErrFound
echo ========================================================= >>"%LogName%"
echo.
echo #### INSTALLATION FAILED ####>>"%LogName%"
rd /s /q Temp\
echo %ESC%[91m[INFO] Installation is cancelled because a severe error has occurred.
echo %ESC%[93m[WARN] Please check installation log in Logs folder.%ESC%[0m
echo.
pause
exit /B

:MissionCompleted
echo.
if %ErrNum% GTR 0 (
	echo #### INSTALLATION COMPLETED WITH ERROR^(S^) #### >>"%LogName%"
	echo %ESC%[93m[WARN] Installation has completed with %ErrNum% error^(s^)!
	echo %ESC%[93m[WARN] Please check installation log in Logs folder.%ESC%[0m
) else (
	echo #### INSTALLATION COMPLETED SUCCESSFULLY #### >>"%LogName%"
	echo %ESC%[97m[INFO] Installation has completed successfully!%ESC%[0m
)
echo.
pause

cls
call :PrintLabel
echo  %ESC%[92mWindows 10 ARM has been installed on your phone.%ESC%[0m
echo  %ESC%[0m- Now, reboot your phone.%ESC%[0m

if /i "%Dualboot%" EQU "Y" (
	if %HasCameraBtn% EQU 1 (
		echo  %ESC%[0m- At the boot menu, press volume up / down to move selection %ESC%[0m
		echo  %ESC%[0m  then press the camera key to select.%ESC%[0m
	) else (
		echo  %ESC%[0m- At the boot menu, press volume up to boot into Windows 10 ARM. %ESC%[0m
	)
)

echo  %ESC%[0m- Boot and setup Windows 10 (may reboot several times).%ESC%[0m
echo  %ESC%[0m- After getting to the desktop, run "PostInstall.cmd" in the system drive%ESC%[0m
echo  %ESC%[0m  as administrator to finish installation.%ESC%[0m
echo.
pause
exit /b
