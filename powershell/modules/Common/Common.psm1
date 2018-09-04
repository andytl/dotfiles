
Set-StrictMode -Version Latest

# Text Manipulation

function Read-AnswerToBool {
    param(
        [string] $userAnswerText
    )
    $userAnswerText -cin @("yes", "y", "t", "true", "on")
}

function Get-EscapedRegex {
    param (
        [string] $stringForRegex
    )
    [System.Text.RegularExpressions.Regex]::Escape($stringForRegex)
}

# Coding and build

function Set-CodeAnalysisMode {
    param (
        [bool] $mode
    )
    $caFile = Get-Content -Raw ".\build.props"
    $newCaFile = $caFile -replace "<RunCodeAnalysis>\w*</RunCodeAnalysis>", "<RunCodeAnalysis>$mode</RunCodeAnalysis>"
    Set-Content -Path ".\build.props" -Value $newCaFile -Force
}