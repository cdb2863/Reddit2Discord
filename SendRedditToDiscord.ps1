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
        [string]$Subreddit
    )

    Begin
    {
        $subreddit = "$Subreddit"
        $json = Invoke-RestMethod -Uri "https://old.reddit.com/r/$($subreddit)/top/.json?sort=top&t=month"
        $urls = $json.data.children[0..25].data.url
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
            Start-Sleep -Seconds 1 | Out-Null
        }
    }
    End
    {
    }
}