# Fix-Separators.ps1 — normalize all Markdown table separator rows
$f = "z:\APIM-Accelerator\docs\architecture\data-architecture.md"
[string[]]$lines = [System.IO.File]::ReadAllLines($f, [System.Text.Encoding]::UTF8)

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    # Match a markdown table separator: starts and ends with |, cells contain only dashes, colons, spaces
    if ($line -match '^\|[\-\:\| ]+\|$') {
        # Count columns by splitting on |
        $parts = $line -split '\|'
        # parts[0] = "" (before first |), parts[-1] = "" (after last |), middle are cells
        $colCount = $parts.Count - 2
        if ($colCount -gt 0) {
            $newLine = "| " + (("--- | " * $colCount).TrimEnd(' ').TrimEnd('|').TrimEnd(' ')) + " |"
            $newLine = "| " + (@("---") * $colCount -join " | ") + " |"
            $lines[$i] = $newLine
        }
    }
}

[System.IO.File]::WriteAllLines($f, $lines, [System.Text.Encoding]::UTF8)
Write-Host "Done. Lines written: $($lines.Count)"
