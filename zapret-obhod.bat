@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM Устанавливаем рабочую папку и лог-файл
set "folder=bin"
set "logfile=%folder%\update_log.txt"

REM Создаем папку для хранения файлов, если она не существует
if not exist "%folder%" (
    mkdir "%folder%"
)

REM Проверка прав администратора
call :check_admin

REM Проверка обновлений
call :update_check

REM Скачивание необходимых файлов
call :download_files

REM Главное меню выбора действия
call :main_menu

REM Завершаем выполнение программы
exit /b

REM ==================================================
REM Функция проверки прав администратора
REM ==================================================
:check_admin
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo Требуются права администратора. Перезапуск...
    powershell -Command "Start-Process cmd -ArgumentList '/c, %~f0' -Verb RunAs"
    exit /b
)
goto :eof

REM ==================================================
REM Функция проверки обновлений
REM ==================================================
:update_check
set "url=https://raw.githubusercontent.com/jester19686/obhod/main/zapret-obhod.bat"
set "tempFile=%TEMP%\zapret-obhod-temp.bat"
set "currentFile=%~f0"

REM Загружаем новый скрипт для сравнения
powershell -command "(New-Object Net.WebClient).DownloadFile('%url%', '%tempFile%')"
fc /b "%currentFile%" "%tempFile%" >nul
if %errorlevel% neq 0 (
    echo Обнаружено обновление. Обновляемся...
    copy /y "%tempFile%" "%currentFile%"
    echo Скрипт обновлен. Перезапуск...
    start "" "%currentFile%"
    exit
) else (
    echo Обновлений нет. Продолжаем выполнение.
)
del "%tempFile%"
goto :eof

REM ==================================================
REM Функция скачивания необходимых файлов
REM ==================================================
:download_files
REM Список файлов и URL-адресов для загрузки
set "files_urls=WinDivert.dll https://raw.githubusercontent.com/jester19686/obhod/main/bin/WinDivert.dll
                 WinDivert64.sys https://raw.githubusercontent.com/jester19686/obhod/main/bin/WinDivert64.sys
                 cygwin1.dll https://raw.githubusercontent.com/jester19686/obhod/main/bin/cygwin1.dll
                 ipset-discord.txt https://raw.githubusercontent.com/jester19686/obhod/main/bin/ipset-discord.txt
                 list-discord.txt https://raw.githubusercontent.com/jester19686/obhod/main/bin/list-discord.txt
                 list-general.txt https://raw.githubusercontent.com/jester19686/obhod/main/bin/list-general.txt
                 quic_initial_www_google_com.bin https://raw.githubusercontent.com/jester19686/obhod/main/bin/quic_initial_www_google_com.bin
                 tls_clienthello_www_google_com.bin https://raw.githubusercontent.com/jester19686/obhod/main/bin/tls_clienthello_www_google_com.bin
                 winws.exe https://raw.githubusercontent.com/jester19686/obhod/main/bin/winws.exe
                 COD_FIXv2.bat https://raw.githubusercontent.com/jester19686/obhod/main/COD_FIXv2.bat"

REM Перебираем и загружаем файлы
for %%A in (%files_urls%) do (
    call :check_and_download "%folder%\%%A" "%%B"
)
goto :eof

REM ==================================================
REM Функция проверки и скачивания файла
REM ==================================================
:check_and_download
set "file=%1"
set "url=%2"

if not exist "%file%" (
    set /a attempts=3
    :retry_download
    echo Загружаю %file%...
    powershell -Command "Invoke-WebRequest -Uri %url% -OutFile %file%"
    if %errorlevel% neq 0 (
        set /a attempts-=1
        if %attempts% gtr 0 (
            echo Повторная попытка загрузки %file%...
            goto retry_download
        ) else (
            echo Не удалось загрузить %file% после нескольких попыток.
            exit /b 1
        )
    )
)
goto :eof

REM ==================================================
REM Главное меню выбора действия
REM ==================================================
:main_menu
cls
mode con: cols=52 lines=16
color 0B
echo ==================================================
echo Выберите код для выполнения:
echo ==================================================

echo 1. Временный обход
echo 2. Постоянный обход (автозапуск)
echo 3. Удалить обход (автозапуск)
echo 4. Warzone (фикс-костыль)
echo 5. Обновление баз данных
echo ==================================================
echo Запускать только от имени Администратора
echo ==================================================

set /p choice=Введите номер выбранного действия:
if "%choice%"=="1" (
    call :temporary_bypass
) else if "%choice%"=="2" (
    call :permanent_bypass
) else if "%choice%"=="3" (
    call :remove_bypass
) else if "%choice%"=="4" (
    call :warzone_fix
) else if "%choice%"=="5" (
    call :update_bases
) else (
    echo Неверный выбор. Завершаю программу.
    exit /b
)
goto :eof

REM ==================================================
REM Подпрограммы для различных действий
REM ==================================================

:temporary_bypass
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
timeout /t 2 /nobreak >nul
goto :eof

:permanent_bypass
echo Создание постоянного обхода...
set BIN_PATH=%~dp0bin\
set "ARGS=--wf-tcp=80,443 --wf-udp=443,50000-50100 --filter-udp=443 --hostlist=\"%BIN_PATH%list-general.txt\" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic=\"%BIN_PATH%quic_initial_www_google_com.bin\" --new --filter-udp=50000-50100 --ipset=\"%BIN_PATH%ipset-discord.txt\" --dpi-desync=fake --dpi-desync-any-protocol --dpi-desync-cutoff=d3 --dpi-desync-repeats=6 --new --filter-tcp=80 --hostlist=\"%BIN_PATH%list-general.txt\" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new --filter-tcp=443 --hostlist=\"%BIN_PATH%list-general.txt\" --dpi-desync=fake,split --dpi-desync-autottl=2 --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-fake-tls=\"%BIN_PATH%tls_clienthello_www_google_com.bin\""
set SRVCNAME=zapret
net stop %SRVCNAME% >nul 2>&1
sc delete %SRVCNAME% >nul 2>&1
sc create %SRVCNAME% binPath= "\"%BIN_PATH%winws.exe\" !ARGS!" DisplayName= "zapret" start= auto >nul 2>&1
sc description %SRVCNAME% "zapret DPI bypass software" >nul 2>&1
sc start %SRVCNAME% >nul 2>&1
echo Сервис успешно создан и запущен.
timeout /t 5 /nobreak >nul
goto :eof

:remove_bypass
echo Удаление постоянного обхода...
set SRVCNAME=zapret
net stop %SRVCNAME%
sc delete %SRVCNAME%
net stop "WinDivert"
sc delete "WinDivert"
net stop "WinDivert14"
sc delete "WinDivert14"
echo Обход (автозапуск) успешно удален.
timeout /t 5 /nobreak >nul
goto :eof

:warzone_fix
echo Выполняется фикс для Warzone...
if not exist "%file10%" (
    powershell -Command "Invoke-WebRequest -Uri %url10% -OutFile %file10%"
)
if exist "%file10%" (
    call "%file10%"
) else (
    echo Ошибка загрузки файла COD_FIXv2.bat
)
timeout /t 2 /nobreak >nul
goto :eof

:update_bases
echo Обновление баз данных...
call :check_and_download "%folder%\ipset-discord.txt" "https://raw.githubusercontent.com/jester19686/obhod/main/bin/ipset-discord.txt"
call :check_and_download "%folder%\list-discord.txt" "https://raw.githubusercontent.com/jester19686/obhod/main/bin/list-discord.txt"
call :check_and_download "%folder%\list-general.txt" "https://raw.githubusercontent.com/jester19686/obhod/main/bin/list-general.txt"
echo Обновление баз завершено.
timeout /t 2 /nobreak >nul
goto :eof
