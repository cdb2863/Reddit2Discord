<#
.Synopsis
   Send the top 25 posts of the month from a subreddit to Discord.
.DESCRIPTION
   Send the top 25 posts of the month from a subreddit to Discord via webhooks.
.EXAMPLE
   Send-RedditToDiscord -Subreddit all
.EXAMPLE
    Send-RedditToDiscord -Subreddit 
#>
function Send-RedditToDiscord
{
    [CmdletBinding()]
    [Alias('r2d')]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$Subreddit,
        [bool]$IgnoreSticky = $true,
        [int]$Count = 25
    )

    Begin
    {
        $json = Invoke-RestMethod -Uri "https://old.reddit.com/r/$($subreddit)/top/.json?sort=top&t=month&limit=$($Count)"
        
        if($IgnoreSticky) {
            $urls = foreach($item in $json.data.children.data) {
                if(!$item.stickied) {
                    $item.url
                }
            }
        }
        else {
            $urls = foreach($item in $json.data.children.data) {
                $item.url
            }
        }

        $hookUri = $(Get-Content .\conf.json | ConvertFrom-Json).hookUri
    }
    Process
    {
        foreach($url in $urls)
        {
            $payload = [PSCustomObject]@{
                content = $url
            }

            Invoke-RestMethod -Uri $hookUri -Method Post -Body ($payload | ConvertTo-Json) | Out-Null
            
            if($Count -gt 1) {
                Start-Sleep -Seconds 1 | Out-Null
            }
        }
    }
    End
    {
        Write-Output "Sent $Count posts from https://old.reddit.com/r/$($subreddit) to Discord."
    }
}

<#
.Synopsis
   Set configuration for Send-RedditToDiscord
.DESCRIPTION
   Set configuration for Send-RedditToDiscord
.EXAMPLE
   Set-R2DConfig
#>
function Set-R2DConfig
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
                   [string]$HookURI
    )

    Begin
    {
        $ConfigTemplate = (Get-Content .\conf.json.example | ConvertFrom-Json)
    }
    Process
    {
        $ConfigTemplate.hookUri = $HookURI
        Set-Content .\conf.json ($ConfigTemplate | ConvertTo-Json)
    }
    End
    {
        $CheckConf = Get-Content -Path .\conf.json | ConvertFrom-Json
        if($CheckConf.hookURI -match $HookURI) {
            Write-Output "Configured and verified conf.json."
        }
        else {
            Write-Error "Unable to verify configuration."
            
        }
    }
}