# Create-Subfolders.ps1
# Creates subfolders under a target directory using folder names listed in a CSV file.
$CsvPath   = "C:\Scripts\OutputFiles\LoanFolderNames.csv"   # Path to your CSV file
$TargetDir = "\\bkofficesa.file.core.windows.net\public\IT Temp\Synergy Export"        # Path to the directory where subfolders will be created
$ColumnName = "FolderName"              # Change to match your CSV header

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

# --- Create subfolders ---
$created = 0
$skipped = 0
$failed  = 0

foreach ($row in $rows) {
    $name = $row.$ColumnName.Trim()

    if ([string]::IsNullOrWhiteSpace($name)) {
        Write-Warning "Skipping empty folder name."
        $skipped++
        continue
    }

    $fullPath = Join-Path $TargetDir $name

    if (Test-Path $fullPath) {
        Write-Host "EXISTS  : $fullPath" -ForegroundColor Yellow
        $skipped++
    } else {
        try {
            New-Item -Path $fullPath -ItemType Directory -ErrorAction Stop | Out-Null
            Write-Host "CREATED : $fullPath" -ForegroundColor Green
            $created++
        } catch {
            Write-Host "FAILED  : $fullPath - $($_.Exception.Message)" -ForegroundColor Red
            $failed++
        }
    }
}

# --- Summary ---
Write-Host ""
Write-Host "Done. Created: $created  Skipped/Exists: $skipped  Failed: $failed"