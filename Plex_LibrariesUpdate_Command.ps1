﻿clear

$plexAccount = [string]"[YourAccountEmail]"
$plexPassword = [string]"[YourPassword]"
$plexIPAddress = [string]"[PlexMediaServerIPAddress]"
$plexPort = [string]"[Port- by default it is 32400]"
$plexFullAddress = $plexIPAddress+":"+$plexPort

Write-Host "Updating Plex libraries..."
Write-Host "Plex account used: $plexAccount"
Write-Host "Plex server address: $plexFullAddress"

$url = "https://plex.tv/users/sign_in.xml"
$BB = [System.Text.Encoding]::UTF8.GetBytes($plexAccount+":"+$plexPassword)
$EncodedPassword = [System.Convert]::ToBase64String($BB)
$headers = @{}
$headers.Add("Authorization","Basic $($EncodedPassword)") | out-null
$headers.Add("X-Plex-Client-Identifier","TESTSCRIPTV1") | Out-Null
$headers.Add("X-Plex-Product","Test script") | Out-Null
$headers.Add("X-Plex-Version","V1") | Out-Null
[xml]$res = Invoke-RestMethod -Headers:$headers -Method Post -Uri:$url
$token = $res.user.authenticationtoken
Write-Host "Token: $token"
[xml]$doc = (New-Object System.Net.WebClient).DownloadString("http://$plexFullAddress/library/sections?X-Plex-Token="+$token)
$directories = $doc.MediaContainer.Directory
foreach($directory in $directories)
{
    $id = $directory.Location.id
    $libraryTitle = $directory.title

    $updateURL = "http://$plexFullAddress/library/sections/$id/refresh?force=1&X-Plex-Token=$token"
    Invoke-RestMethod -Method Get -Uri $updateURL
    Write-Host "Successfully sent the Refresh command for the library $libraryTitle [ID: $id]"
}