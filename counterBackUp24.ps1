param(
    [string]$folderPath,
    [int]$minutes = 15
)

# Проверка наличия аргумента пути до папки
if (-not $folderPath) {
    Write-Host "Необходимо указать путь до папки."
    exit
}

# Проверка существования папки
if (-not (Test-Path $folderPath -PathType Container)) {
    Write-Host "Указанная папка не существует."
    exit
}

# Проверка второго аргумента на корректность
if ($minutes -le 0) {
    Write-Host "Количество минут должно быть положительным числом."
    exit
}

# Переменная для лога
$logMessage = ""

# Путь к лог-файлу
$logPath = "C:\Util\log.txt"

# Проверка существования лог-файла и создание, если он не существует
if (-not (Test-Path $logPath -PathType Leaf)) {
    New-Item -Path $logPath -ItemType File | Out-Null
}

# Проверка размера лога и очистка, если необходимо
if ((Get-Item $logPath).Length -gt 10kb) {
    Clear-Content $logPath
}

# Добавление разделителя между запусками в лог
Add-Content -Path $logPath -Value "---------------"
Add-Content -Path $logPath -Value ""

foreach ($subfolder in (Get-ChildItem $folderPath -Directory)) {
    # Получение списка файлов в подпапке
    $files = Get-ChildItem $subfolder.FullName -File

    # Фильтрация файлов, измененных в последние указанное количество минут
    $recentlyModifiedFiles = $files | Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-$minutes) }

    # Проверка количества измененных файлов
    if ($recentlyModifiedFiles.Count -ne 1) {
        $logMessage += "$(Get-Date) - Ошибка в подпапке $($subfolder.FullName): количество измененных файлов не равно 1.`n"
    }
}

# Запись ошибок в лог
if ($logMessage -ne "") {
    Add-Content -Path $logPath -Value $logMessage
    Write-Host "Ошибки были записаны в лог: $logPath"
} else {
    Write-Host "Ошибок не обнаружено."
}