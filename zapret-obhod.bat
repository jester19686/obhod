@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Путь к текущему файлу
set "this_file=%~f0"

:: URL к версии файла на GitHub
set "url_self=https://raw.githubusercontent.com/jester19686/obhod/main/zapret-obhod.bat"

:: Временный файл для загрузки
set "temp_file=%temp%\zapret-obhod_temp.bat"
cls
:: Проверка, существует ли локальная версия
echo Проверка обновлений для %this_file%...

:: Загружаем текущую версию с GitHub
powershell -Command "Invoke-WebRequest -Uri %url_self% -OutFile %temp_file%"

:: Если файл успешно загружен
if exist "%temp_file%" (
    :: Сравниваем локальную версию с удалённой
    fc /b "%temp_file%" "%this_file%" >nul
    if errorlevel 1 (
        echo Обнаружено обновление! Загружаем новую версию...
        copy /y "%temp_file%" "%this_file%"
        echo Программа обновлена. Перезапуск.
        del "%temp_file%"
        exit /b
    ) else (
        echo Обновлений нет.
    )
) else (
    echo Ошибка загрузки файла с GitHub.
)

:: Папка и файлы для загрузки
set "folder=bin"
set "flag_file=%~dp0bin\first_run_flag.txt"

:: Проверка и создание папки bin
if not exist "%folder%" (
    mkdir "%folder%"
)

:: Проверка первого запуска
if not exist "%flag_file%" (
    cls
    echo Это первый запуск программы. Перезапустите программу не от имени администратора.
    echo Программа автоматически закроется через 5 секунд.
    echo This is the first run. > "%flag_file%"
    timeout /t 5 /nobreak >nul
    exit /b
) else (
    openfiles >nul 2>nul
    if '%errorlevel%' NEQ '0' (
        echo Необходимы права администратора. Перезапускаю скрипт с правами администратора...
        powershell -Command "Start-Process cmd -ArgumentList '/c, %~f0' -Verb RunAs"
        exit /b
    )
)

:: Указываем файлы и их URL для загрузки
set "file1=%folder%\WinDivert.dll"
set "url1=https://raw.githubusercontent.com/jester19686/obhod/main/bin/WinDivert.dll"

set "file2=%folder%\WinDivert64.sys"
set "url2=https://raw.githubusercontent.com/jester19686/obhod/main/bin/WinDivert64.sys"

set "file3=%folder%\cygwin1.dll"
set "url3=https://raw.githubusercontent.com/jester19686/obhod/main/bin/cygwin1.dll"

set "file4=%folder%\ipset-discord.txt"
set "url4=https://raw.githubusercontent.com/jester19686/obhod/main/bin/ipset-discord.txt"

set "file5=%folder%\list-discord.txt"
set "url5=https://raw.githubusercontent.com/jester19686/obhod/main/bin/list-discord.txt"

set "file6=%folder%\list-general.txt"
set "url6=https://raw.githubusercontent.com/jester19686/obhod/main/bin/list-general.txt"

set "file7=%folder%\quic_initial_www_google_com.bin"
set "url7=https://raw.githubusercontent.com/jester19686/obhod/main/bin/quic_initial_www_google_com.bin"

set "file8=%folder%\tls_clienthello_www_google_com.bin"
set "url8=https://raw.githubusercontent.com/jester19686/obhod/main/bin/tls_clienthello_www_google_com.bin"

set "file9=%folder%\winws.exe"
set "url9=https://raw.githubusercontent.com/jester19686/obhod/main/bin/winws.exe"

set "file10=COD_FIXv2.bat"
set "url10=https://raw.githubusercontent.com/jester19686/obhod/main/COD_FIXv2.bat"

cls
echo Загрузка файлов...

:: Проверка и загрузка файлов
call :check_and_download "%file1%" "%url1%"
call :check_and_download "%file2%" "%url2%"
call :check_and_download "%file3%" "%url3%"
call :check_and_download "%file4%" "%url4%"
call :check_and_download "%file5%" "%url5%"
call :check_and_download "%file6%" "%url6%"
call :check_and_download "%file7%" "%url7%"
call :check_and_download "%file8%" "%url8%"
call :check_and_download "%file9%" "%url9%"

:: Завершаем программу
echo Все файлы успешно загружены.
pause
exit /b

:check_and_download
set "file=%1"
set "url=%2"

if not exist "%file%" (
    echo Файл %file% не найден. Загружаю файл...
    powershell -Command "Invoke-WebRequest -Uri %url% -OutFile %file%"
    if %ERRORLEVEL% NEQ 0 (
        echo Ошибка загрузки файла %file%. Код ошибки: %ERRORLEVEL%
        exit /b 1
    )
)

if not exist "%file%" (
    echo Файл %file% не был загружен. Завершаю программу.
    exit /b 1
)
goto :eof

:temporary_bypass
REM Временный обход
echo Выполняется временный обход...

cd /d "%~dp0"
set BIN=%~dp0bin\

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

echo Временный обход выполнен.

REM Завершаем выполнение программы
exit /b

:permanent_bypass
REM Постоянный обход (автозапуск)

cls

cd /d "%~dp0"

set BIN_PATH=%~dp0bin\

:: Устанавливаем аргументы вручную как одну строку
set "ARGS=--wf-tcp=80,443 --wf-udp=443,50000-50100 --filter-udp=443 --hostlist=\"%BIN_PATH%list-general.txt\" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic=\"%BIN_PATH%quic_initial_www_google_com.bin\" --new --filter-udp=50000-50100 --ipset=\"%BIN_PATH%ipset-discord.txt\" --dpi-desync=fake --dpi-desync-any-protocol --dpi-desync-cutoff=d3 --dpi-desync-repeats=6 --new --filter-tcp=80 --hostlist=\"%BIN_PATH%list-general.txt\" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new --filter-tcp=443 --hostlist=\"%BIN_PATH%list-general.txt\" --dpi-desync=fake,split --dpi-desync-autottl=2 --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-fake-tls=\"%BIN_PATH%tls_clienthello_www_google_com.bin\""

:: Название сервиса
set SRVCNAME=zapret

:: Останавливаем и удаляем старый сервис, если он существует
echo Остановка старого сервиса, если он существует...
net stop %SRVCNAME% >nul 2>&1
sc delete %SRVCNAME% >nul 2>&1

:: Создаём новый сервис
echo Создание нового сервиса...
sc create %SRVCNAME% binPath= "\"%BIN_PATH%winws.exe\" !ARGS!" DisplayName= "%SRVCNAME%" start= auto

:: Запуск нового сервиса
echo Запуск нового сервиса...
net start %SRVCNAME%

echo Сервис запущен.

exit /b
