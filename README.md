# Reddit2Discord
> Advanced PowerShell function to pull top urls from a subreddit and push them to a Discord channel.

## Installation and configuration.
1. Clone the repo.
2. Copy conf.json.example to conf.json.
3. Edit conf.json and set hookUrl to your discord webhook URL, then save.

## Use
```PowerShell
Send-Reddit2Discord -Subreddit all
```