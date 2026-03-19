# Fix-Separators2.ps1 — replace all remaining old-style table separator rows
$f = "z:\APIM-Accelerator\docs\architecture\data-architecture.md"
[string[]]$lines = [System.IO.File]::ReadAllLines($f, [System.Text.Encoding]::UTF8)
$changed = 0

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    # Test: line starts with |, only contains | - : space characters
    $stripped = $line -replace '[| \-:]', ''
    if ($line.StartsWith('|') -and $stripped.Length -eq 0 -and $line.Length -gt 3) {
        # Count columns: number of | minus 1
        $cols = ($line.ToCharArray() | Where-Object { $_ -eq '|' }).Count - 1
        if ($cols -gt 0) {
            $cells = [string[]]::new($cols)
            for ($j = 0; $j -lt $cols; $j++) { $cells[$j] = "---" }
            $lines[$i] = "| " + ($cells -join " | ") + " |"
            $changed++
        }
    }
}

[System.IO.File]::WriteAllText($f, ($lines -join "`n") + "`n", [System.Text.Encoding]::UTF8)
Write-Host "Fixed $changed separator rows. Total lines: $($lines.Count)"
