<#
.Synopsis
   Send the top posts from a subreddit to Discord.
.DESCRIPTION
   Send the top posts from a subreddit to Discord via webhooks.
.EXAMPLE
   Send-RedditToDiscord -Subreddit all -TimePeriod year -Count 10 -BroadcastSubreddit
.EXAMPLE
    Send-RedditToDiscord -Subreddit videos
.PARAMETER Subreddit
    Specifies what subreddit to pull posts from.
.PARAMETER TimePeriod
    Specifies from what period of time top posts will be pulled from.
    Valid TimePeriods are hour, day, week, month, year, and all.
.PARAMETER IgnoreSticky
    Specifies whether stickied posts should be ignored.
    Has no effect at the time of writing because stickied posts do not appear in /top/.
.PARAMETER Count
    Specifies how many posts should be pulled.
.PARAMETER BroadcastSubreddit
    Specifies whether the subreddit from which posts are pulled should be sent in a message to Discord.
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
        [ValidateSet('hour','day','week','month','year','all')]      
        [string]$TimePeriod='month',
        [switch]$IgnoreSticky,
        [int]$Count = 25,
        [switch]$BroadcastSubreddit
    )

    Begin
    {
        $json = Invoke-RestMethod -Uri "https://old.reddit.com/r/$($subreddit)/top/.json?sort=top&t=$($TimePeriod)&limit=$($Count)"
        
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

        if($BroadcastSubreddit) {
            $payload = [PSCustomObject]@{
                content = "Sending $Count posts from /r/$Subreddit."
            }
            Invoke-RestMethod -Uri $hookUri -Method Post -Body ($payload | ConvertTo-Json) | Out-Null
        }

        foreach($url in $urls)
        {
            $payload = [PSCustomObject]@{
                content = $url
            }


            
            $Response = try {Invoke-RestMethod -Uri $hookUri -Method Post -Body ($payload | ConvertTo-Json) } catch { $_.Exception.Response }
            if($Response.StatusCode -eq 429) {
                Write-Error "We have been rate limited."
                Break
            }
            
            if($Count -gt 1) {
                Start-Sleep -Seconds 1 | Out-Null
            }
        }
    }
    End
    {
        # Fix this later to use actual count rather than requested count.
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
        $ConfigTemplate = (Get-Content .\conf.json.template | ConvertFrom-Json)
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