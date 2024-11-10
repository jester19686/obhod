@echo off
chcp 65001 >nul
SetLocal EnableExtensions EnableDelayedExpansion
mode con: cols=70 lines=6
nircmd win settopmost class ConsoleWindowClass 1

powershell -command " $Host.UI.RawUI.WindowTitle = 'Warzone™ - FIX'; $Host.UI.RawUI.BackgroundColor = 'Black'; $Host.UI.RawUI.ForegroundColor = 'Green'; $Host.UI.RawUI.SetBufferContents([System.Management.Automation.Host.Coordinates]::new(0,0), 'Your custom text here');"




:: Символы для прогрессбара
set "prLineChar=█"        :: Символ прогресса
set "prBackChar=░"        :: Символ фона
set prWidth=65            :: Ширина прогрессбара
set prFreq=10             :: Частота обновлений прогресса (каждые N%)
set prStatus=0            :: Изначальный статус
set prPosMax=%prWidth%    :: Максимальная позиция прогресса (ширина бару)
set prSameChars=1.5      :: Количество выводимых символов за раз

:: Создание начальной строки для прогрессбара
set prLine=  
For /L %%C in (1,1,%prSameChars%) do set "prLine=!prLine!%prLineChar%" 

:: Основной процесс
cd /d "%~dp0"
set BIN=%~dp0bin\


set SRVCNAME=zapret
net stop %SRVCNAME% >nul 2>&1
sc delete %SRVCNAME% >nul 2>&1

net stop "WinDivert" >nul 2>&1
sc delete "WinDivert" >nul 2>&1
net stop "WinDivert14" >nul 2>&1
sc delete "WinDivert14" >nul 2>&1

timeout /t 1 /nobreak >nul

:: Шаг 1 - Запуск программы

start "zapret: general" /min "%BIN%winws.exe" ^
  --wf-tcp=80,443 --wf-udp=443,50000-50100 ^
  --filter-udp=443 --hostlist="%BIN%list-general.txt" ^
  --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" ^
  --new --filter-udp=50000-50100 --ipset="%BIN%ipset-discord.txt" ^
  --dpi-desync=fake --dpi-desync-any-protocol --dpi-desync-cutoff=d3 --dpi-desync-repeats=6 ^
  --new --filter-tcp=80 --hostlist="%BIN%list-general.txt" ^
  --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig ^
  --new --filter-tcp=443 --hostlist="%BIN%list-general.txt" ^
  --dpi-desync=fake,split --dpi-desync-autottl=2 --dpi-desync-repeats=6 ^
  --dpi-desync-fooling=badseq --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin"



:: Обновление прогресс-бара после Шага 1
set /a prStatus+=%prFreq%
call :updateProgress

set /a prStatus+=%prFreq%
call :updateProgress


:: Шаг 2 - Завершение процесса Discord
taskkill /IM Discord.exe /F >nul 2>&1
taskkill /F /IM Discord.exe >nul 2>&1

set /a prStatus+=%prFreq%
call :updateProgress


:: Обновление прогресс-бара после Шага 2
set /a prStatus+=%prFreq%
call :updateProgress

:: Шаг 3 - Задержка и запуск Discord
timeout 1 >nul
start "" "%LocalAppData%\Discord\Update.exe" --processStart Discord.exe
timeout /t 10 /nobreak >nul

set /a prStatus+=%prFreq%
call :updateProgress

nircmd win settopmost class ConsoleWindowClass 1


:: Обновление прогресс-бара после Шага 3
set /a prStatus+=%prFreq%
call :updateProgress

:: Шаг 4 - Завершение процесса winws
timeout 6 >nul
taskkill /IM winws.exe /F >nul 2>&1
taskkill /F /IM winws.exe >nul 2>&1

:: Обновление прогресс-бара после Шага 4
set /a prStatus+=%prFreq%
call :updateProgress

:: Шаг 5 - Удаление служб
set SRVCNAME=zapret
net stop %SRVCNAME% >nul 2>&1
sc delete %SRVCNAME% >nul 2>&1

net stop "WinDivert" >nul 2>&1
sc delete "WinDivert" >nul 2>&1
net stop "WinDivert14" >nul 2>&1
sc delete "WinDivert14" >nul 2>&1

:: Обновление прогресс-бара после Шага 5
set /a prStatus+=%prFreq%
call :updateProgress

set /a prStatus+=%prFreq%
call :updateProgress

timeout 1 >nul


:: Обновление прогресс-бара после Шага 6
set /a prStatus+=%prFreq%
call :updateProgress

:: Финальное сообщение, когда прогресс достигает 100%
if %prStatus% geq 100 (
    cls
    echo Программа выполнена.
    echo >nul
    echo >nul
    echo Запуск Call of Duty: Warzone
    
)


:: Шаг 6 - Завершающий этап
timeout 5 >nul
start "" "steam://run/1962663"

exit

:: Функция для обновления прогресс-бара
:updateProgress
set /a prLineCur=(prStatus * prPosMax / 100)
set "prLineCurrent="
For /L %%C in (0,1,%prLineCur%) do set "prLineCurrent=!prLineCurrent!%prLineChar%" 
For /L %%C in (!prLineCur!,1,%prWidth%) do set "prLineCurrent=!prLineCurrent!%prBackChar%" 

cls
echo Запуск программы...
echo %prStatus% %% выполнино
echo.
echo !prLineCurrent!
echo.
timeout /nobreak /t 1 >nul
exit /b
