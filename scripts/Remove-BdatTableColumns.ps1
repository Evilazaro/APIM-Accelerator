#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Removes Source, Evidence, Maturity, and Confidence columns from all Markdown
    tables in BDAT architecture documents.

.DESCRIPTION
    Scans one or more Markdown files for pipe-delimited tables and removes any
    columns whose headers match (case-insensitive):
        • Source
        • Source File
        • Evidence
        • Maturity
        • Maturity Level
        • Confidence
        • Avg Confidence

    The script preserves all other columns, all content outside tables, all
    Mermaid fenced code blocks, and all HTML comment blocks.

.PARAMETER InputPath
    Path to the Markdown file (or glob pattern for multiple files) to process.

.PARAMETER OutputPath
    Optional. Path for the output file. If omitted the input file is updated
    in-place after a .bak backup is created next to the original.

.PARAMETER BackupSuffix
    Suffix appended to the backup file name. Default: ".bak"

.PARAMETER WhatIf
    Preview mode — show what would change without writing any files.

.EXAMPLE
    .\Remove-BdatTableColumns.ps1 -InputPath ".\docs\architecture\business-architecture.md"

.EXAMPLE
    .\Remove-BdatTableColumns.ps1 -InputPath ".\docs\architecture\*.md" -WhatIf

.EXAMPLE
    .\Remove-BdatTableColumns.ps1 `
        -InputPath  ".\docs\architecture\business-architecture.md" `
        -OutputPath ".\docs\architecture\business-architecture-clean.md"
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
    [string]$InputPath,

    [Parameter()]
    [string]$OutputPath,

    [Parameter()]
    [string]$BackupSuffix = '.bak'
)

begin {
    # Column names to remove (case-insensitive exact match on trimmed header cell)
    $RemoveHeaders = @(
        'source',
        'source file',
        'evidence',
        'maturity',
        'maturity level',
        'target maturity',
        'current maturity',
        'confidence',
        'avg confidence'
    )

    function Get-ColumnIndiciesToRemove {
        param([string[]]$HeaderCells)
        $indices = [System.Collections.Generic.List[int]]::new()
        for ($i = 0; $i -lt $HeaderCells.Count; $i++) {
            $cell = $HeaderCells[$i].Trim().ToLowerInvariant()
            if ($RemoveHeaders -contains $cell) {
                $indices.Add($i)
            }
        }
        return $indices
    }

    function Remove-Columns {
        param(
            [string[]]$RowCells,
            [System.Collections.Generic.List[int]]$DropIndices
        )
        $kept = [System.Collections.Generic.List[string]]::new()
        for ($i = 0; $i -lt $RowCells.Count; $i++) {
            if (-not $DropIndices.Contains($i)) {
                $kept.Add($RowCells[$i])
            }
        }
        return $kept
    }

    function Split-TableRow {
        param([string]$Line)
        # Remove leading/trailing pipes, then split on |
        $inner = $Line.Trim()
        if ($inner.StartsWith('|')) { $inner = $inner.Substring(1) }
        if ($inner.EndsWith('|')) { $inner = $inner.Substring(0, $inner.Length - 1) }
        return $inner -split '\|'
    }

    function Join-TableRow {
        param([System.Collections.Generic.List[string]]$Cells)
        return '| ' + ($Cells | ForEach-Object { $_.Trim() } | Join-String -Separator ' | ') + ' |'
    }

    function Is-SeparatorRow {
        param([string]$Line)
        # Separator rows contain only |, -, :, and spaces
        return $Line -match '^\|[\s\-\:\|]+\|$'
    }

    function Build-SeparatorRow {
        param([System.Collections.Generic.List[string]]$Cells)
        $seps = [System.Collections.Generic.List[string]]::new()
        foreach ($cell in $Cells) {
            $c = $cell.Trim()
            # Preserve alignment markers
            if ($c -match '^:-+:$') { $seps.Add(':---:') }
            elseif ($c -match '^:-+$') { $seps.Add(':---') }
            elseif ($c -match '^-+:$') { $seps.Add('---:') }
            else { $seps.Add('---') }
        }
        return '| ' + ($seps | Join-String -Separator ' | ') + ' |'
    }

    function Process-MarkdownContent {
        param([string]$Content)

        $lines = $Content -split "`n"
        $output = [System.Collections.Generic.List[string]]::new()
        $inFence = $false
        $fenceMarker = ''
        $dropIndices = $null   # null = not inside a table
        $tablesFixed = 0

        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]

            # ── Track fenced code blocks (``` or ~~~) ──────────────────────
            if (-not $inFence) {
                if ($line -match '^(\s*)(```|~~~)') {
                    $inFence = $true
                    $fenceMarker = $Matches[2]
                    $output.Add($line)
                    continue
                }
            }
            else {
                if ($line -match "^\s*$([regex]::Escape($fenceMarker))(\s|$)") {
                    $inFence = $false
                }
                $output.Add($line)
                continue
            }

            # ── Inside a table ─────────────────────────────────────────────
            if ($line.Trim().StartsWith('|')) {
                $cells = Split-TableRow $line

                if ($null -eq $dropIndices) {
                    # First row of a new table → discover header columns to drop
                    $dropIndices = Get-ColumnIndiciesToRemove $cells
                    if ($dropIndices.Count -gt 0) { $tablesFixed++ }
                }

                if ($dropIndices.Count -eq 0) {
                    # Nothing to remove in this table
                    $output.Add($line)
                }
                elseif (Is-SeparatorRow $line) {
                    $kept = Remove-Columns $cells $dropIndices
                    $output.Add((Build-SeparatorRow $kept))
                }
                else {
                    $kept = Remove-Columns $cells $dropIndices
                    $output.Add((Join-TableRow $kept))
                }
                continue
            }

            # ── Not a table row → reset table state ───────────────────────
            $dropIndices = $null
            $output.Add($line)
        }

        return [PSCustomObject]@{
            Content     = $output | Join-String -Separator "`n"
            TablesFixed = $tablesFixed
        }
    }
}

process {
    $resolvedPaths = Resolve-Path -Path $InputPath -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path

    if (-not $resolvedPaths) {
        Write-Error "No files matched: $InputPath"
        return
    }

    foreach ($filePath in $resolvedPaths) {
        Write-Host "Processing: $filePath" -ForegroundColor Cyan

        $originalContent = Get-Content -Path $filePath -Raw -Encoding UTF8

        $result = Process-MarkdownContent -Content $originalContent

        if ($result.TablesFixed -eq 0) {
            Write-Host "  ✅ No target columns found — file unchanged." -ForegroundColor Green
            continue
        }

        Write-Host "  🔧 Tables modified: $($result.TablesFixed)" -ForegroundColor Yellow

        if ($PSCmdlet.ShouldProcess($filePath, 'Remove Source/Evidence/Maturity/Confidence columns')) {
            $destination = if ($OutputPath) { $OutputPath } else { $filePath }

            # Create backup when updating in-place
            if (-not $OutputPath) {
                $backupPath = "$filePath$BackupSuffix"
                Copy-Item -Path $filePath -Destination $backupPath -Force
                Write-Host "  💾 Backup: $backupPath" -ForegroundColor Gray
            }

            [System.IO.File]::WriteAllText($destination, $result.Content, [System.Text.Encoding]::UTF8)
            Write-Host "  ✅ Written: $destination" -ForegroundColor Green
        }
    }
}
