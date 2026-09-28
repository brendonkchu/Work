# Remove-Subfolders.ps1
$CsvPath    = "C:\Scripts\OutputFiles\DeleteLoanFolderNames.csv"   # Path to your CSV file
$TargetDir  = "\\bkofficesa.file.core.windows.net\public\IT Temp\Synergy Export"        # Path to the parent directory containing the subfolders
$ColumnName = "FolderName"               # Change to match your CSV header

# --- Validate inputs ---
if (-not (Test-Path $CsvPath -PathType Leaf)) {
    Write-Error "CSV file not found: $CsvPath"
    exit 1
}

if (-not (Test-Path $TargetDir -PathType Container)) {
    Write-Error "Target directory not found: $TargetDir"
    exit 1
}

# --- Read CSV ---
$rows = Import-Csv -Path $CsvPath

if (-not ($rows | Get-Member -Name $ColumnName -ErrorAction SilentlyContinue)) {
    $available = ($rows[0].PSObject.Properties.Name) -join ', '
    Write-Error "Column '$ColumnName' not found in CSV. Available columns: $available"
    exit 1
}

# --- Remove subfolders ---
$removed  = 0
$skipped  = 0
$notfound = 0
$failed   = 0

foreach ($row in $rows) {
    $name = $row.$ColumnName.Trim()

    if ([string]::IsNullOrWhiteSpace($name)) {
        Write-Warning "Skipping empty folder name."
        $skipped++
        continue
    }

    $fullPath = Join-Path $TargetDir $name

    # Check if folder exists
    if (-not (Test-Path $fullPath -PathType Container)) {
        Write-Host "NOT FOUND : $fullPath" -ForegroundColor DarkYellow
        $notfound++
        continue
    }

    # Check if folder contains any files (including files in subfolders)
    $hasFiles = (Get-ChildItem -Path $fullPath -Recurse -File | Select-Object -First 1).Count -gt 0

    if ($hasFiles) {
        Write-Host "HAS FILES : $name -- Skipping, folder is not empty." -ForegroundColor Cyan
        $skipped++
    } else {
        try {
            Remove-Item -Path $fullPath -Recurse -Force -ErrorAction Stop
            Write-Host "REMOVED   : $fullPath" -ForegroundColor Green
            $removed++
        } catch [System.IO.FileNotFoundException], [System.IO.DirectoryNotFoundException] {
            Write-Host "NOT FOUND : $name" -ForegroundColor DarkYellow
            $notfound++
        } catch {
            Write-Host "FAILED    : $fullPath - $($_.Exception.Message)" -ForegroundColor Red
            $failed++
        }
    }
}

# --- Summary ---
Write-Host ""
Write-Host "Done. Removed: $removed  Skipped (has files): $skipped  Not Found: $notfound  Failed: $failed"