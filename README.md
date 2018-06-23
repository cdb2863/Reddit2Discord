# Reddit2Discord
> PowerShell function to pull top urls from a subreddit and push them to a Discord channel.

## Installation and configuration.
1. Clone the repo.
2. Execute the following command and substitute your Discord Hook URI for [HOOK_URI].
```PowerShell
Set-R2DConf -HookURI [HOOK_URI]
```

## Parameters
Subreddit
> Specifies what subreddit to pull posts from.

TimePeriod
> Specifies from what period of time top posts will be pulled from. 
> Valid TimePeriods are hour, day, week, month, year, and all.

IgnoreSticky
> Specifies whether stickied posts should be ignored.
> Has no effect at the time of writing because stickied posts do not appear in /top/.

Count
> Specifies how many posts should be pulled.

BroadcastSubreddit
> Specifies whether the subreddit from which posts are pulled should be sent in a message to Discord.

## Examples
Get posts from /r/all.
```PowerShell
Send-Reddit2Discord -Subreddit all
```
Specifiy a period of time from which top posts will be pulled.
Valid TimePeriod values:
- hour
- day
- week
- month
- year
- all
```PowerShell
Send-Reddit2Discord -Subreddit all -TimePeriod year
```
Use the function's alias to get one post from /r/videos.
```PowerShell
r2d videos -Count 1
```
