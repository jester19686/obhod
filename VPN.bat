@echo off
chcp 65001 >nul
SetLocal EnableExtensions EnableDelayedExpansion
mode con: cols=70 lines=6

:: Настройка заголовка и цвета консоли
powershell -command " $Host.UI.RawUI.WindowTitle = 'VPN Connection'; $Host.UI.RawUI.BackgroundColor = 'Black'; $Host.UI.RawUI.ForegroundColor = 'Green'; Clear-Host"

:: Настройки VPN
set "VPN_NAME=СлучайныйVPN"
set "PROTOCOL=L2TP" 
set "L2TP_PSK=vpn"  
set "USERNAME=vpn"   
set "PASSWORD=vpn"   

:: Список IP-адресов для случайного выбора
set IP_ADDRESSES=(219.100.37.55 219.100.37.206 219.100.37.53 219.100.37.123 219.100.37.26 219.100.37.32 153.232.5.11 219.100.37.8 219.100.37.49 219.100.37.201 222.110.134.26 217.138.212.58 162.254.224.218 162.254.224.214 162.254.224.221 162.254.224.215 162.254.224.213)

:: Символы для прогресс-бара
set "prLineChar=█"
set "prBackChar=░"
set prWidth=65
set prFreq=20
set prStatus=0
set prPosMax=%prWidth%

:: Конвертация IP_ADDRESSES в массив
setlocal enabledelayedexpansion
set count=0
for %%a in %IP_ADDRESSES% do (
    set /a count+=1
    set "ip_!count!=%%a"
)

:: Проверка, что список IP не пустой
if %count% EQU 0 (
    echo Ошибка: Список IP-адресов пустой.
    pause
    exit /b
)

:: Выбор случайного IP-адреса
set /a "rand=%random% %% %count% + 1"
set "SERVER_ADDRESS=!ip_%rand%!"

:: Проверка, что IP-адрес выбран
if "%SERVER_ADDRESS%"=="" (
    echo Ошибка: Не удалось выбрать случайный IP-адрес.
    pause
    exit /b
)

call :updateProgress

:: Удаление существующего подключения, если оно уже создано
powershell -Command "if (Get-VpnConnection -Name '%VPN_NAME%' -ErrorAction SilentlyContinue) { Remove-VpnConnection -Name '%VPN_NAME%' -Force }"
call :updateProgress

:: Создание VPN-подключения
powershell -Command "Add-VpnConnection -Name '%VPN_NAME%' -ServerAddress '%SERVER_ADDRESS%' -TunnelType '%PROTOCOL%' -L2tpPsk '%L2TP_PSK%' -AuthenticationMethod MSChapv2 -EncryptionLevel Required -Force -RememberCredential"
call :updateProgress

:: Установка логина и пароля (подавление вывода)
powershell -Command "cmdkey /add:%SERVER_ADDRESS% /user:%USERNAME% /pass:%PASSWORD%" >nul 2>&1
call :updateProgress

:: Подключение к VPN
powershell -Command "rasdial '%VPN_NAME%' %USERNAME% %PASSWORD%" >nul 2>&1
call :updateProgress

:: Ожидание завершения
echo Нажмите любую клавишу для завершения работы и отключения VPN...
pause >nul

:: Отключение VPN
powershell -Command "rasdial '%VPN_NAME%' /disconnect" >nul 2>&1
powershell -Command "cmdkey /delete:%SERVER_ADDRESS%" >nul 2>&1
exit /b

:: Функция для обновления прогресс-бара
:updateProgress
set /a prStatus+=%prFreq%
if %prStatus% gtr 100 set prStatus=100
set /a prLineCur=(prStatus * prPosMax / 100)
set "prLineCurrent="
For /L %%C in (0,1,%prLineCur%) do set "prLineCurrent=!prLineCurrent!%prLineChar%"
For /L %%C in (!prLineCur!,1,%prWidth%) do set "prLineCurrent=!prLineCurrent!%prBackChar%"

cls
if %prStatus% lss 100 (
    echo Запуск VPN-соединения...
) else (
    echo Подключение установлено с сервером: %SERVER_ADDRESS%
)
echo %prStatus% %% выполнено
echo.
echo !prLineCurrent!
echo.
timeout /nobreak /t 1 >nul
exit /b



