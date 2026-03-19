# Final-Validate.ps1
$f = "z:\APIM-Accelerator\docs\architecture\data-architecture.md"
$lines = [System.IO.File]::ReadAllLines($f, [System.Text.Encoding]::UTF8)

Write-Host "=== FINAL VALIDATION REPORT ==="
Write-Host "Total lines: $($lines.Count)"

$secs = @($lines | Where-Object { $_ -match '^## .* Section [0-9]+:' })
Write-Host "Sections: $($secs.Count) / 9 $(if($secs.Count -eq 9){'PASS'}else{'FAIL'})"

$mm = @($lines | Where-Object { $_ -eq '```mermaid' })
Write-Host "Mermaid diagrams: $($mm.Count) / 4 $(if($mm.Count -ge 4){'PASS'}else{'FAIL'})"

$toc = @($lines | Where-Object { $_ -match 'Quick Table of Contents' })
Write-Host "Quick TOC: $(if($toc.Count -gt 0){'PASS'}else{'FAIL'})"

$dm = @($lines | Where-Object { $_ -match 'Data Domain Map' })
Write-Host "Domain Map diagram: $(if($dm.Count -gt 0){'PASS'}else{'FAIL'})"

$badSep = @($lines | Where-Object { $_ -match '^\| -{10,}' })
Write-Host "Old wide separators: $($badSep.Count) $(if($badSep.Count -eq 0){'PASS'}else{'FAIL'})"

$acct = @($lines | Where-Object { $_ -match 'accTitle:' })
Write-Host "accTitle present: $($acct.Count) (need 4) $(if($acct.Count -ge 4){'PASS'}else{'FAIL'})"

$sfCol = @($lines | Where-Object { $_ -match '^\| (Source File|Evidence|Maturity|Confidence)' })
Write-Host "Stray Source File/Evidence col headers: $($sfCol.Count) $(if($sfCol.Count -eq 0){'PASS'}else{'FAIL'})"

$audit = @($lines | Where-Object { $_ -match 'SECTION COUNT AUDIT.*PASS' })
Write-Host "Audit comment: $(if($audit.Count -gt 0){'PASS'}else{'FAIL'})"

$secNames = $secs | ForEach-Object { $_ }
Write-Host ""
Write-Host "Section headings:"
$secNames | ForEach-Object { Write-Host "  $_" }
