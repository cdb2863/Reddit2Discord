# Reddit2Discord
> Advanced PowerShell function to pull top urls from a subreddit and push them to a Discord channel.

## Installation and configuration.
1. Clone the repo.
2. Execute the following command and substitute your Discord Hook URI for [HOOK_URI].
```PowerShell
Set-R2DConf -HookURI [HOOK_URI]
```

## Use
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
