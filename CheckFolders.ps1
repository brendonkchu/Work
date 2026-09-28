# Check-Subfolders.ps1
$CsvPath    = "C:\Scripts\OutputFiles\LoanFolderNames.csv"   # Path to your CSV file
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

# --- Check subfolders ---
$hasFiles  = 0
$empty     = 0
$notfound  = 0
$skipped   = 0
$results   = @()

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
        Write-Host "NOT FOUND : $name" -ForegroundColor DarkYellow
        $notfound++
        $results += [PSCustomObject]@{ FolderName = $name; FullPath = $fullPath; Status = "Not Found"; FileCount = 0; FileNames = "" }
        continue
    }

    # Check if folder contains any files (including files in subfolders)
    $files = Get-ChildItem -Path $fullPath -Recurse -File

    if ($files.Count -gt 0) {
        Write-Host "HAS FILES : $name ($($files.Count) file(s) found)" -ForegroundColor Cyan
        $hasFiles++
        $fileNames = ($files | ForEach-Object { $_.Name }) -join " | "
        $results += [PSCustomObject]@{ FolderName = $name; FullPath = $fullPath; Status = "Has Files"; FileCount = $files.Count; FileNames = $fileNames }
    } else {
        Write-Host "EMPTY     : $name" -ForegroundColor Green
        $empty++
        $results += [PSCustomObject]@{ FolderName = $name; FullPath = $fullPath; Status = "Empty"; FileCount = 0; FileNames = "" }
    }
}

# --- Summary ---
Write-Host ""
Write-Host "Done. Has Files: $hasFiles  Empty: $empty  Not Found: $notfound  Skipped: $skipped"

# --- Export results to CSV ---
$timestamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$exportPath = Join-Path "C:\Scripts\OutputFiles\" "FolderCheck_$timestamp.csv"
$results | Export-Csv -Path $exportPath -NoTypeInformation
Write-Host ""
Write-Host "Results exported to: $exportPath" -ForegroundColor White