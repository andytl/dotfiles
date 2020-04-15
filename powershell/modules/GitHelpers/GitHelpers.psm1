
Set-StrictMode -Version Latest

function Get-GitStatus {
    $rawStatus = @(git status --porcelain)
    foreach ($status in $rawStatus) {
        @{
            RepoPath = $status.Substring(3) -replace "/","\";
            Status = if ($status[0] -ne " ") {$status[0]} else {$status[1]};
        }
    }
}

function Get-GitDiffFiles {
    param(
        $lookback = 0
    )
    if ($lookback -gt 0) {
        $revision = "HEAD~$lookback"
    } else {
        $revision = "HEAD"
    }

    $rawDiffFiles = git diff $revision --name-status
    foreach ($rawDiffFile in $rawDiffFiles) {
        $entry = $rawDiffFile -split "\s+";
        @{
            RepoPath = $entry[1] -replace "/","\";
            Status = $entry[0]
        }
    }
}

function Get-GitModifiedFiles {
    param (
        $lookback = 0
    )
    # get untracked files from git status
    Get-GitStatus | 
    Where-Object { $_.Status -eq "?" } |
    ForEach-Object { $_.RepoPath }
    Get-GitDiffFiles $lookback |
    ForEach-Object { $_.RepoPath }
}
