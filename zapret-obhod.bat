@echo off >nul
chcp 65001 >nul
setlocal enabledelayedexpansion >nul

cls
mode con: cols=70 lines=10 >nul
REM ASCII-надпись

color 0A
cls
echo ================================================================
echo  __     ______  ______     ______   __  __     __   __   _____  
echo /\ \   /\  == \/\  __ \   /\  ___\ /\ \/\ \   /\ "-.\ \ /\  __-. 
echo \ \ \  \ \  __<\ \  __ \  \ \  __\ \ \ \_\ \  \ \ \-.  \\ \ \/\ \
echo  \ \_\  \ \_\ \_\ \_\ \_\  \ \_\    \ \_____\  \ \_\\"\_\\ \____-
echo   \/_/   \/_/ /_/\/_/\/_/   \/_/     \/_____/   \/_/ \/_/ \/____/
echo                                                                  
echo ========================== YTAZH52 ==============================

timeout /t 2 >nul

mode con: cols=52 lines=10

REM URL для обновления скрипта
set "url=https://raw.githubusercontent.com/jester19686/obhod/main/zapret-obhod.bat"
set "tempFile=%TEMP%\zapret-obhod-temp.bat"
set "currentFile=%~f0"

REM Проверка на обновление скрипта
powershell -command "(New-Object Net.WebClient).DownloadFile('%url%', '%tempFile%')"

fc /b "%currentFile%" "%tempFile%" >nul
if %errorlevel% neq 0 (

    cls
    echo ================================================================
    echo Обнаружено обновление. Обновляемся...
    echo ================================================================
    timeout /t 2 /nobreak >nul
    copy /y "%tempFile%" "%currentFile%"
    cls
    echo ================================================================
    echo Скрипт обновлен. Перезапуск...
    echo ========================== YTAZH52 =============================
    timeout /t 2 /nobreak >nul
    start "" "%currentFile%"
    exit
) else (
    echo Обновлений нет. Продолжаем выполнение скрипта.
)

del "%tempFile%"


REM Указываем папку для хранения файлов
set "folder=bin"

REM Проверка и создание папки bin, если она не существует
if not exist "%folder%" (
    mkdir "%folder%"
)

REM Путь к файлу-флагу
set "flag_file=%~dp0bin\first_run_flag.txt"

REM Проверяем, существует ли файл флага
if not exist "%flag_file%" (
     mode con: cols=64 lines=12
     cls
    color 0A
    echo ======================================================
    echo  Это первый запуск программы
    echo  Перезапустите программу без прав администратора.
    echo ======================================================
    echo.
    echo.
    echo ======================================================
    echo Программа автоматически закроется через 5 секунд.
    echo ======================================================
    echo This is the first run. > "%flag_file%"
    timeout /t 5 /nobreak >nul
    exit /b
) else (
    :: Это не первый запуск, проверяем, есть ли права администратора
    openfiles >nul 2>nul
    if '%errorlevel%' NEQ '0' (
        :: Если прав нет, перезапускаем скрипт с правами администратора
        cls
        color 0C
        echo ======================================================
        echo  Необходимы права администратора
        echo  Перезапускаю с правами администратора...
        echo ======================================================
        powershell -Command "Start-Process cmd -ArgumentList '/c, %~f0' -Verb RunAs"
        exit /b
    )
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

set "file10=COD_FIXv2.bat"
set "url10=https://raw.githubusercontent.com/jester19686/obhod/main/COD_FIXv2.bat"

REM Очищаем экран перед началом загрузки
cls

REM Выводим сообщение о начале загрузки
cls
color 0B
echo ================================
echo Загрузка файлов...
echo ================================

REM Перебираем все файлы и проверяем их наличие
call :check_and_download "%file1%" "%url1%" >nul
call :check_and_download "%file2%" "%url2%" >nul
call :check_and_download "%file3%" "%url3%" >nul 
call :check_and_download "%file4%" "%url4%" >nul
call :check_and_download "%file5%" "%url5%" >nul
call :check_and_download "%file6%" "%url6%" >nul
call :check_and_download "%file7%" "%url7%" >nul
call :check_and_download "%file8%" "%url8%" >nul 
call :check_and_download "%file9%" "%url9%" >nul

REM Очищаем экран перед выводом заключительного сообщения
cls

REM После завершения всех загрузок выводим сообщение об успешном завершении

color 0B
echo ================================
echo Все файлы успешно загружены.
echo ================================

REM Меню выбора действия

mode con: cols=52 lines=16

cls
color 0B

echo ==================================================
echo Выберите код для выполнения:
echo ==================================================
timeout /t 1 /nobreak >nul
echo 1. Временный обход
echo.
echo 2. Постоянный обход (автозапуск)
echo.
timeout /t 1 /nobreak >nul
echo 3. Удалить обход (автозапуск)
echo.
echo 4. Warzone (фикс-костыль)
echo.
echo 5. Обновление баз данных
timeout /t 1 /nobreak >nul
echo ==================================================
echo Запусать только от именни Администратора
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


REM Проверяем, запущен ли скрипт от имени администратора
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    cls
    color 0A
    echo =====================================================
    echo НЕОБХОДИМО ЗАПУСТИТЬ СКРИПТ С ПРАВАМИ АДМИНИСТРАТОРА!
    echo =====================================================
    echo.
    timeout /t 4 /nobreak >nul
    exit /b
)


mode con: cols=48 lines=4

cls
color 0A
echo ================================
echo Выполняется временный обход...
echo ================================
  
timeout /t 1 /nobreak >nul

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



cls

mode con: cols=48 lines=4

echo ================================
echo Временный обход выполнен.
echo ================================

timeout /t 2 /nobreak >nul



REM Завершаем выполнение программы
exit /b

:permanent_bypass
REM Постоянный обход (автозапуск)

REM Добавляем код для создания сервиса

REM Очищаем экран перед выводом сообщения о необходимости прав администратора
cls

REM Проверяем, запущен ли скрипт от имени администратора
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    cls
    color 0A
    echo =====================================================
    echo НЕОБХОДИМО ЗАПУСТИТЬ СКРИПТ С ПРАВАМИ АДМИНИСТРАТОРА!
    echo =====================================================
    echo.
    pause
    exit /b
)

cls

cd /d "%~dp0"

set BIN_PATH=%~dp0bin\

:: Устанавливаем аргументы вручную как одну строку
set "ARGS=--wf-tcp=80,443 --wf-udp=443,50000-50100 --filter-udp=443 --hostlist=\"%BIN_PATH%list-general.txt\" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic=\"%BIN_PATH%quic_initial_www_google_com.bin\" --new --filter-udp=50000-50100 --ipset=\"%BIN_PATH%ipset-discord.txt\" --dpi-desync=fake --dpi-desync-any-protocol --dpi-desync-cutoff=d3 --dpi-desync-repeats=6 --new --filter-tcp=80 --hostlist=\"%BIN_PATH%list-general.txt\" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new --filter-tcp=443 --hostlist=\"%BIN_PATH%list-general.txt\" --dpi-desync=fake,split --dpi-desync-autottl=2 --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-fake-tls=\"%BIN_PATH%tls_clienthello_www_google_com.bin\""

:: Выводим финальные аргументы для проверки
echo Финальные аргументы: !ARGS!

:: Название сервиса
set SRVCNAME=zapret

mode con: cols=48 lines=4

:: Останавливаем и удаляем старый сервис, если он существует
cls
color 0A
    echo ================================================
    echo Остановка старого сервиса, если он существует...
    echo ================================================
net stop %SRVCNAME% >nul 2>&1
sc delete %SRVCNAME% >nul 2>&1
timeout /t 1 /nobreak >nul

:: Создаём новый сервис
cls
color 0A
    echo ================================================
    echo Создание нового сервиса...
    echo ================================================
sc create %SRVCNAME% binPath= "\"%BIN_PATH%winws.exe\" !ARGS!" DisplayName= "zapret" start= auto >nul 2>&1
if %errorlevel% neq 0 (
    echo Ошибка при создании сервиса! Проверьте правильность путей и прав доступа.
    pause
    exit /b
)
timeout /t 1 /nobreak >nul

:: Добавляем описание к сервису
sc description %SRVCNAME% "zapret DPI bypass software" >nul 2>&1

:: Запускаем сервис
cls
color 0A
    echo ================================================
    echo Запуск сервиса...
    echo ================================================
sc start %SRVCNAME% >nul 2>&1
if %errorlevel% neq 0 (
    echo Ошибка при запуске сервиса! Проверьте логи и конфигурацию.
    pause
    exit /b
)
timeout /t 1 /nobreak >nul

cls
color 0A
    echo ================================================
    echo Сервис успешно создан и запущен.
    echo ================================================

timeout /t 5 /nobreak >nul

REM Завершаем выполнение программы
exit /b

:remove_bypass
REM Удалить обход (автозапуск)

cls

mode con: cols=48 lines=4

REM Очищаем экран перед выводом сообщения о необходимости прав администратора
cls

REM Проверяем, запущен ли скрипт от имени администратора
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    cls
    color 0A
    echo =====================================================
    echo НЕОБХОДИМО ЗАПУСТИТЬ СКРИПТ С ПРАВАМИ АДМИНИСТРАТОРА!
    echo =====================================================
    echo.
    timeout /t 4 /nobreak >nul
    exit /b
)


color 0A
    echo ================================================
    echo Выполняем удаление обхода (автозапуска)
    echo================================================

timeout /t 2 /nobreak >nul

REM После проверки прав администратора продолжаем выполнение

set SRVCNAME=zapret

net stop %SRVCNAME%
sc delete %SRVCNAME%

net stop "WinDivert"
sc delete "WinDivert"
net stop "WinDivert14"
sc delete "WinDivert14"


color 0A
    echo ================================================
    echo Обход (автозапуск) успешно удален.
    echo=================================================

timeout /t 5 /nobreak >nul

REM Завершаем выполнение программы
exit /b


:warzone_fix
cls
REM Скачиваем и проверяем наличие файла COD_FIXv2.bat, если его нет, скачиваем

mode con: cols=75 lines=42

cls
REM Проверяем, запущен ли скрипт от имени администратора
openfiles >nul 2>nul
cls
if '%errorlevel%' NEQ '0' (
    
    mode con: cols=80 lines=25
    
    cls
    color 0A
    echo =====================================================
    echo НЕОБХОДИМО ЗАПУСТИТЬ СКРИПТ С ПРАВАМИ АДМИНИСТРАТОРА!
    echo =====================================================
    echo.
         
    timeout /t 4 /nobreak >nul
    exit /b
)

mode con: cols=52 lines=4

color 0A
    echo ===================================================
    echo Скачиваю и проверяю наличие файла COD_FIXv2.bat...
    echo====================================================

timeout /t 2 /nobreak >nul

if not exist "%file10%" (
    echo Файл %file10% не найден. Загружаю файл...
    powershell -Command "Invoke-WebRequest -Uri %url10% -OutFile %file10%"
    if %ERRORLEVEL% NEQ 0 (
        echo Ошибка загрузки файла %file10%. Код ошибки: %ERRORLEVEL%
        timeout /t 2 /nobreak >nul
        exit /b 1
    )
)


cls
REM Проверяем успешность загрузки
if not exist "%file10%" (
    color 0A
    echo ===================================================
    echo Файл %file10% не был загружен. Завершаю программу.
    echo====================================================
    timeout /t 2 /nobreak >nul
    exit /b 1
)


mode con: cols=52 lines=4

cls
REM Запуск файла COD_FIXv2.bat
color 0A
    echo ===================================================
    echo Файл COD_FIXv2.bat найден, выполняю...
    echo====================================================
    timeout /t 2 /nobreak >nul
call "%file10%"
timeout /t 2 /nobreak >nul

REM Завершаем выполнение программы
exit /b


:update_bases
REM Обновление баз из GitHub

REM Проверяем, запущен ли скрипт от имени администратора
openfiles >nul 2>nul
if '%errorlevel%' NEQ '0' (
    cls
    color 0A
    echo =====================================================
    echo НЕОБХОДИМО ЗАПУСТИТЬ СКРИПТ С ПРАВАМИ АДМИНИСТРАТОРА!
    echo =====================================================
    echo.
    timeout /t 4 /nobreak >nul
    exit /b
)


cls
color 0B
echo ================================
echo Обновление баз...
echo ================================

timeout /t 1 /nobreak >nul



REM Скачиваем файлы заново
set "file4=%folder%\ipset-discord.txt"
set "url4=https://raw.githubusercontent.com/jester19686/obhod/main/bin/ipset-discord.txt"

set "file5=%folder%\list-discord.txt"
set "url5=https://raw.githubusercontent.com/jester19686/obhod/main/bin/list-discord.txt"

set "file6=%folder%\list-general.txt"
set "url6=https://raw.githubusercontent.com/jester19686/obhod/main/bin/list-general.txt"

REM Проверяем и скачиваем каждый файл
call :check_and_download "%file4%" "%url4%" >nul
call :check_and_download "%file5%" "%url5%" >nul
call :check_and_download "%file6%" "%url6%" >nul

mode con: cols=32 lines=6

cls
color 0B
echo ================================
echo Обновление баз завершено.
echo ================================

timeout /t 2 /nobreak >nul

exit /b
