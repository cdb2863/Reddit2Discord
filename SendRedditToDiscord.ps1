<#
.Synopsis
   Send the top 25 posts of the month from a subreddit to Discord.
.DESCRIPTION
   Send the top 25 posts of the month from a subreddit to Discord via webhooks.
.EXAMPLE
   Send-RedditToDiscord -Subreddit all
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

        $hookUrl = $(Get-Content .\conf.json | ConvertFrom-Json).hookUrl
    }
    Process
    {
        foreach($url in $urls)
        {
            $payload = [PSCustomObject]@{
                content = $url
            }

            Invoke-RestMethod -Uri $hookUrl -Method Post -Body ($payload | ConvertTo-Json) | Out-Null
            
            if($Count -gt 1) {
                Start-Sleep -Seconds 1 | Out-Null
            }
        }
    }
    End
    {

    }
}