
function TabExpansion2
{
    [CmdletBinding(DefaultParameterSetName = 'ScriptInputSet')]
    [OutputType([System.Management.Automation.CommandCompletion])]
    Param
    (
        [Parameter(ParameterSetName = 'ScriptInputSet', Mandatory = $true, Position = 0)]
        [AllowEmptyString()]
        [string] $inputScript,

        [Parameter(ParameterSetName = 'ScriptInputSet', Position = 1)]
        [int] $cursorColumn = $inputScript.Length,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 0)]
        [System.Management.Automation.Language.Ast] $ast,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 1)]
        [System.Management.Automation.Language.Token[]] $tokens,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 2)]
        [System.Management.Automation.Language.IScriptPosition] $positionOfCursor,

        [Parameter(ParameterSetName = 'ScriptInputSet', Position = 2)]
        [Parameter(ParameterSetName = 'AstInputSet', Position = 3)]
        [Hashtable] $options = $null
    )

    End
    {
        if ($psCmdlet.ParameterSetName -eq 'ScriptInputSet')
        {
            $result = [System.Management.Automation.CommandCompletion]::CompleteInput(
                <#inputScript#>  $inputScript,
                <#cursorColumn#> $cursorColumn,
                <#options#>      $options)
        }
        else
        {
            $result = [System.Management.Automation.CommandCompletion]::CompleteInput(
                <#ast#>              $ast,
                <#tokens#>           $tokens,
                <#positionOfCursor#> $positionOfCursor,
                <#options#>          $options)
        }

        #$seen = @{}
        #$result.CompletionMatches | ForEach-Object { $seen[$_.CompletionText] = $true }
#
        #$commands = @(
        #    #Get-Command -CommandType ExternalScript *$inputScript* | Where-Object { $_.Source.StartsWith($env:USERPROFILE) }
        #    Get-Command -CommandType ExternalScript | Where-Object { $_.Source.StartsWith($env:USERPROFILE) }
        #    # User commands don't have source or helpfile arguments
        #    #Get-Command -CommandType function *$inputScript* | Where-Object { -not $_.Source -and -not $_.HelpFile }
        #    Get-Command -CommandType Function | Where-Object { -not $_.Source -and -not $_.HelpFile }
        #)
        #$commands | ForEach-Object {
        #    $command = $_.Name
        #    if (-not $seen[$command])
        #    {
        #        $limit = 200
        #        $description = if ($_.Source) { $_.Source } else { $_.Definition.Trim() }
        #        if ($description.Length -gt $limit)
        #        {
        #            $description = $description.SubString(0, $limit)
        #        }
        #        $result.CompletionMatches.Add(
        #            #[System.Management.Automation.CompletionResult]::new($command));
        #            [System.Management.Automation.CompletionResult]::new($command, $command, [System.Management.Automation.CompletionResultType]::Command, $description));
        #    }
        #}
        return $result
    }
}