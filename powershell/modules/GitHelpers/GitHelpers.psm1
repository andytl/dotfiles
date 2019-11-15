
Set-StrictMode -Version Latest

function Get-GitStatus {
    $rawStatus = @(git status --porcelain)
    foreach ($status in $rawStatus) {
        @{
            RepoPath = $status.Substring(3)  -replace "/","\";
            IndexStatus = $status[0];
            TreeStatus = $status[1]
        }
    }
}

function Get-GitModifiedFiles {
    $modifiedFlags = "M", "A"
    Get-GitStatus | 
    Where-Object { $_.IndexStatus -in $modifiedFlags -or $_.TreeStatus -in $modifiedFlags } |
    Select-Object { $_.RepoPath }
}
