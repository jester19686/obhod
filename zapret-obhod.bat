@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM Указываем папку для хранения файлов
set "folder=bin"

REM Проверка и создание папки bin, если она не существует
if not exist "%folder%" (
    mkdir "%folder%"
)

REM Указываем файлы и их URL для загрузки
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

REM Очищаем экран перед началом загрузки
cls

REM Выводим сообщение о начале загрузки
echo Загрузка файлов...

REM Перебираем все файлы и проверяем их наличие
call :check_and_download "%file1%" "%url1%"
call :check_and_download "%file2%" "%url2%"
call :check_and_download "%file3%" "%url3%"
call :check_and_download "%file4%" "%url4%"
call :check_and_download "%file5%" "%url5%"
call :check_and_download "%file6%" "%url6%"
call :check_and_download "%file7%" "%url7%"
call :check_and_download "%file8%" "%url8%"
call :check_and_download "%file9%" "%url9%"

REM Очищаем экран перед выводом заключительного сообщения
cls

REM После завершения всех загрузок выводим сообщение об успешном завершении
echo Все файлы успешно загружены.

REM Меню выбора действия
echo.
echo Выберите код для выполнения:
echo 1. Временный обход
echo 2. Постоянный обход (автозапуск)
echo 3. Удалить обход (автозапуск)
set /p choice=Введите номер выбранного действия (1, 2, 3):

if "%choice%"=="1" (
    call :temporary_bypass
) else if "%choice%"=="2" (
    call :permanent_bypass
) else if "%choice%"=="3" (
    call :remove_bypass
) else (
    echo Неверный выбор. Завершаю программу.
    exit /b
)

REM Выход из программы
exit /b

pause
goto :eof

:check_and_download
REM Эта функция проверяет наличие файла и скачивает его при необходимости

set "file=%1"
set "url=%2"

if not exist "%file%" (
    REM Только при необходимости загрузки, выводим сообщение
    echo Файл %file% не найден. Загружаю файл...
    powershell -Command "Invoke-WebRequest -Uri %url% -OutFile %file%"
    if %ERRORLEVEL% NEQ 0 (
        echo Ошибка загрузки файла %file%. Код ошибки: %ERRORLEVEL%
        exit /b 1
    )
)

REM Проверяем успешность загрузки
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

start "zapret: general" /min "%BIN%winws.exe" --wf-tcp=80,443 --wf-udp=443,50000-50100 ^
--filter-udp=443 --hostlist="%BIN%\list-general.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN%\quic_initial_www_google_com.bin" --new ^
--filter-udp=50000-50100 --ipset="%BIN%\ipset-discord.txt" --dpi-desync=fake --dpi-desync-any-protocol --dpi-desync-cutoff=d3 --dpi-desync-repeats=6 --new ^
--filter-tcp=80 --hostlist="%BIN%\list-general.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
--filter-tcp=443 --hostlist="%BIN%\list-general.txt" --dpi-desync=fake,split --dpi-desync-autottl=2 --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-fake-tls="%BIN%\tls_clienthello_www_google_com.bin"

echo Временный обход выполнен.

REM Завершаем выполнение программы
exit /b

:permanent_bypass
REM Постоянный обход (автозапуск)

REM Добавляем код для создания сервиса

cls

echo Предупреждение: Данный файл должен быть запущен с правами администратора (ПКМ - Запустить от имени администратора).
echo Нажмите любую клавишу, чтобы продолжить создание сервиса.
pause
cls

cd /d "%~dp0"

set BIN_PATH=%~dp0bin\

:: Устанавливаем аргументы вручную как одну строку
set "ARGS=--wf-tcp=80,443 --wf-udp=443,50000-50100 --filter-udp=443 --hostlist=\"%BIN_PATH%list-general.txt\" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic=\"%BIN_PATH%quic_initial_www_google_com.bin\" --new --filter-udp=50000-50100 --ipset=\"%BIN_PATH%ipset-discord.txt\" --dpi-desync=fake --dpi-desync-any-protocol --dpi-desync-cutoff=d3 --dpi-desync-repeats=6 --new --filter-tcp=80 --hostlist=\"%BIN_PATH%list-general.txt\" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new --filter-tcp=443 --hostlist=\"%BIN_PATH%list-general.txt\" --dpi-desync=fake,split --dpi-desync-autottl=2 --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-fake-tls=\"%BIN_PATH%tls_clienthello_www_google_com.bin\""

:: Выводим финальные аргументы для проверки
echo Финальные аргументы: !ARGS!

:: Название сервиса
set SRVCNAME=zapret

:: Останавливаем и удаляем старый сервис, если он существует
echo Остановка старого сервиса, если он существует...
net stop %SRVCNAME% >nul 2>&1
sc delete %SRVCNAME% >nul 2>&1

:: Создаём новый сервис
echo Создание нового сервиса...
sc create %SRVCNAME% binPath= "\"%BIN_PATH%winws.exe\" !ARGS!" DisplayName= "zapret" start= auto >nul 2>&1
if %errorlevel% neq 0 (
    echo Ошибка при создании сервиса! Проверьте правильность путей и прав доступа.
    pause
    exit /b
)

:: Добавляем описание к сервису
sc description %SRVCNAME% "zapret DPI bypass software" >nul 2>&1

:: Запускаем сервис
echo Запуск сервиса...
sc start %SRVCNAME% >nul 2>&1
if %errorlevel% neq 0 (
    echo Ошибка при запуске сервиса! Проверьте логи и конфигурацию.
    pause
    exit /b
)

echo Сервис успешно создан и запущен.

REM Завершаем выполнение программы
exit /b

:remove_bypass
REM Удалить обход (автозапуск)

REM Очищаем экран перед выводом сообщения о необходимости прав администратора
cls

REM Проверяем, запущен ли скрипт от имени администратора
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    echo Необходимо запустить скрипт с правами администратора.
    pause
    exit /b
)

REM После проверки прав администратора продолжаем выполнение

set SRVCNAME=zapret

net stop %SRVCNAME%
sc delete %SRVCNAME%

net stop "WinDivert"
sc delete "WinDivert"
net stop "WinDivert14"
sc delete "WinDivert14"

echo Обход (автозапуск) успешно удален.

REM Завершаем выполнение программы
exit /b

