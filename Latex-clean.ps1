<#
.SYNOPSIS
    Очистка временных файлов LaTeX в текущей папке и всех подпапках.
.DESCRIPTION
    Удаляет все файлы с расширениями, создаваемыми LaTeX-компиляторами
    (aux, log, out, toc, lof, lot, bbl, blg, idx, ind, ilg, nlo, nls,
    acn, acr, alg, glg, glo, gls, ist, synctex.gz, nav, snm, vrb, run.xml,
    bcf, dvi, ps, brf, fls, fdb_latexmk, pyg, thm, xml, ent, tmp, mtc*, maf,
    pat, mw, cls, sty, dtx, ins, bst, bib, .DS_Store, ._.DS_Store, Thumbs.db)
.EXAMPLE
    .\Clean-LaTeX.ps1
    Очищает текущую папку.
.EXAMPLE
    .\Clean-LaTeX.ps1 -Path "D:\MyProject" -Recurse $false
    Очищает только папку D:\MyProject без подпапок.
.EXAMPLE
    .\Clean-LaTeX.ps1 -WhatIf $true
    Показывает, что будет удалено, без реального удаления.
#>

param(
    [string]$Path = ".",                                         # Путь для очистки (по умолчанию текущая папка)
    [switch]$Recurse = $true,                                    # Рекурсивно по подпапкам
    [switch]$WhatIf = $false                                    # Режим просмотра (без удаления)
)

# Расширения временных файлов LaTeX (полный список)
$extensions = @(
    "*.aux", "*.log", "*.out", "*.toc", "*.lof", "*.lot",        # Основные
    "*.bbl", "*.blg",                                            # BibTeX
    "*.idx", "*.ind", "*.ilg",                                   # Индексы
    "*.nlo", "*.nls",                                            # Nomencl
    "*.acn", "*.acr", "*.alg",                                   # Acronym
    "*.glg", "*.glo", "*.gls", "*.ist",                          # Glossaries
    "*.synctex.gz", "*.synctex",                                 # SyncTeX
    "*.nav", "*.snm", "*.vrb",                                   # Beamer
    "*.run.xml", "*.bcf",                                        # Biblatex
    "*.dvi", "*.ps",                                             # Старые форматы
    "*.brf",                                                     # Hyperref
    "*.fls", "*.fdb_latexmk",                                    # Latexmk
    "*.pyg",                                                     # Pygments (minted)
    "*.thm",                                                     # Theorems
    "*.xml",                                                     # XML-вспомогательные
    "*.ent",                                                     # Мнемоники
    "*.tmp",                                                     # Временные
    "*.mtc*", "*.maf",                                           # Multitoc
    "*.pat",                                                     # Pattern
    "*.mw",                                                      # Minion
    ".DS_Store", "._.DS_Store", "Thumbs.db",                     # Системные мусорные файлы
    "*.slg", "*.slo", "*.sls",  				 # Файлы splitidx / индексов
    "*.xdy",      					         # Конфигурация xindy
    "*.synctex.gz"               				 # SyncTeX (если не удаляется)
)

Write-Host "=== Очистка временных файлов LaTeX ===" -ForegroundColor Cyan
Write-Host "Путь: $Path" -ForegroundColor Yellow
Write-Host "Рекурсивно: $Recurse" -ForegroundColor Yellow
if ($WhatIf) {
    Write-Host "РЕЖИМ ПРОСМОТРА (файлы НЕ будут удалены)" -ForegroundColor Magenta
}
Write-Host ""

$totalRemoved = 0
$totalSize = 0

foreach ($ext in $extensions) {
    $files = Get-ChildItem -Path $Path -Filter $ext -File -Recurse:$Recurse -ErrorAction SilentlyContinue
    
    foreach ($file in $files) {
        $size = [math]::Round($file.Length / 1KB, 2)
        if ($WhatIf) {
            Write-Host "[ПРОСМОТР] Будет удалён: $($file.FullName) ($size KB)" -ForegroundColor Gray
        } else {
            try {
                Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                Write-Host "[УДАЛЁН] $($file.Name) ($size KB)" -ForegroundColor Green
                $totalRemoved++
                $totalSize += $file.Length
            } catch {
                Write-Host "[ОШИБКА] Не удалось удалить $($file.Name): $_" -ForegroundColor Red
            }
        }
    }
}

Write-Host ""
if ($WhatIf) {
    Write-Host "=== ПРОСМОТР ЗАВЕРШЁН (реальных удалений не было) ===" -ForegroundColor Magenta
} else {
    Write-Host "=== ОЧИСТКА ЗАВЕРШЕНА ===" -ForegroundColor Cyan
    Write-Host "Удалено файлов: $totalRemoved" -ForegroundColor Yellow
    Write-Host "Освобождено места: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor Yellow
}

# Пауза, если скрипт запущен двойным кликом
if ($host.Name -eq "ConsoleHost" -and $PSBoundParameters.ContainsKey('Path') -eq $false) {
    Read-Host "Нажмите Enter для выхода"
}