# Tell IndexNow (Bing, Yandex, Seznam and friends) about pages that changed.
# Usage:
#   ./indexnow.ps1                                   # submit every URL in sitemap.xml
#   ./indexnow.ps1 https://bajahaw.com/blogs/new.html
#   ./indexnow.ps1 @("https://bajahaw.com/a.html", "https://bajahaw.com/b.html")

param([string[]]$Url)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$hostName = "bajahaw.com"

$keyFile = Get-ChildItem -Path $root -Filter "*.txt" |
    Where-Object { $_.Name -match "^[0-9a-f]{32}\.txt$" } |
    Select-Object -First 1

if (-not $keyFile) {
    throw "No IndexNow key file found. Expected <32 hex chars>.txt in $root"
}

$key = (Get-Content $keyFile.FullName -Raw).Trim()

if (-not $Url) {
    [xml]$sitemap = Get-Content (Join-Path $root "sitemap.xml") -Raw
    $Url = @($sitemap.urlset.url.loc)
}

$payload = @{
    host        = $hostName
    key         = $key
    keyLocation = "https://$hostName/$($keyFile.Name)"
    urlList     = @($Url)
} | ConvertTo-Json -Depth 4

$response = Invoke-WebRequest -Uri "https://api.indexnow.org/indexnow" `
    -Method Post `
    -ContentType "application/json; charset=utf-8" `
    -Body $payload

"$($response.StatusCode) - submitted $($Url.Count) URL(s)"
$Url | ForEach-Object { "  $_" }
