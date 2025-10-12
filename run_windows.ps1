<#
    [License]
    This script is licensed under the GNU General Public License v3.0 (GPL-3.0).

    Copyright (C) 2025 Wavemate

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
    You can view the full text of the GNU General Public License at <https://www.gnu.org/licenses/>.

    [Credits]
    - Inspired by WuWa Tracker (https://wuwatracker.com)
#>

# Define constants
$OutputPng = "$env:USERPROFILE\Desktop\convene_url.png"
$OutputHtml = "$env:USERPROFILE\Desktop\convene_url.html"

# Try to auto-detect game directory first
$GameDir = $null
$PossiblePaths = @(
    "${env:ProgramFiles}\Wuthering Waves",
    "${env:ProgramFiles(X86)}\Steam\steamapps\common\Wuthering Waves",
    "C:\Wuthering Waves"
)

Write-Host "Attempting to auto-detect game directory..." -ForegroundColor Yellow

foreach ($Path in $PossiblePaths) {
    if (Test-Path $Path) {
        $TestLogPath = Join-Path $Path "Client\Saved\Logs\Client.log"
        if (Test-Path $TestLogPath) {
            $GameDir = $Path
            Write-Host "Auto-detected game directory: $GameDir" -ForegroundColor Green
            break
        }
    }
}

# If auto-detect failed, ask user
if (-not $GameDir) {
    Write-Host "Auto-detection failed. Please specify game directory." -ForegroundColor Yellow
    $GameDir = Read-Host "Enter the Wuthering Waves game directory (e.g., C:\Program Files (x86)\Steam\steamapps\common\Wuthering Waves)"
}

# Fix path handling for spaces
$LogPath = Join-Path $GameDir "Client\Saved\Logs\Client.log"

# Check if log file exists
if (-not (Test-Path $LogPath)) {
    Write-Host "Log file not found at: $LogPath" -ForegroundColor Red
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "1. The game directory is correct" -ForegroundColor Yellow
    Write-Host "2. You have opened the Convene History in-game to generate the log" -ForegroundColor Yellow
    
    # Check if directory exists
    $LogDir = Split-Path $LogPath -Parent
    if (Test-Path $LogDir) {
        Write-Host "`nLog directory exists. Available log files:" -ForegroundColor Cyan
        Get-ChildItem $LogDir -Filter "*.log" | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
    } else {
        Write-Host "`nLog directory not found: $LogDir" -ForegroundColor Red
    }
    exit 1
}

# Extract latest convene URL
$Url = $null
$LogContent = Get-Content $LogPath -ErrorAction SilentlyContinue

foreach ($Line in $LogContent) {
    if ($Line -match 'https://aki-gm-resources-oversea') {
        if ($Line -match '"url":"([^"]+)"') {
            $FullUrl = $Matches[1]
            if ($FullUrl -match '^[^,]+') {
                $Url = $Matches[0]
                break
            }
        }
    }
}

if (-not $Url) {
    Write-Host "No valid URL found in Client.log" -ForegroundColor Red
    Write-Host "Open Wuthering Waves and tap the 'Convene History' icon to generate your latest convene data." -ForegroundColor Yellow
    Write-Host "Then run this script again." -ForegroundColor Yellow
    exit 1
}

Write-Host "Latest URL found:" -ForegroundColor Green
Write-Host $Url -ForegroundColor Cyan

# Generate QR code
try {
    Write-Host "Generating QR code..." -ForegroundColor Yellow
    $EscapedUrl = [System.Uri]::EscapeDataString($Url)
    $QrApiUrl = "https://api.qrserver.com/v1/create-qr-code/?size=500x500&data=$EscapedUrl"
    Invoke-WebRequest -Uri $QrApiUrl -OutFile $OutputPng
    Write-Host "QR code saved to: $OutputPng" -ForegroundColor Green
}
catch {
    Write-Host "Error generating QR code: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Generate HTML file
$HtmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Convene URL</title>
  <style>
    body {
      margin: 0;
      padding: 0;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: linear-gradient(135deg, #00FFF7 0%, #0079FF 100%);
    }

    .card {
      background: #FFFFFF;
      padding: 40px;
      border-radius: 20px;
      box-shadow: 0 15px 40px rgba(0,0,0,0.2);
      text-align: center;
      max-width: 600px;
      width: 90%;
    }

    h2 {
      font-size: 1.8rem;
      color: #333;
      margin-bottom: 20px;
    }

    img {
      width: 300px;
      height: 300px;
      border-radius: 20px;
      box-shadow: 0 10px 20px rgba(0,0,0,0.15);
      margin-bottom: 20px;
    }

    p {
      font-size: 1rem;
      color: #555;
      word-break: break-all;
    }

    a {
      color: #007BFF;
      text-decoration: none;
      font-weight: 500;
    }

    a:hover {
      text-decoration: underline;
    }

    @media (max-width: 480px) {
      img {
        width: 80%;
        height: auto;
      }
    }
  </style>
</head>
<body>
  <div class="card">
    <h2>Scan this QR code using Wavemate app</h2>
    <img src="file://$($OutputPng.Replace('\', '/'))" alt="QR Code">
    <p>URL: <a href="$Url" target="_blank">$Url</a></p>
  </div>
</body>
</html>
"@

try {
    $HtmlContent | Out-File -FilePath $OutputHtml -Encoding UTF8
    Write-Host "HTML file created at: $OutputHtml" -ForegroundColor Green
}
catch {
    Write-Host "Error creating HTML file: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Open in default browser
try {
    Start-Process $OutputHtml
}
catch {
    Write-Host "Error opening browser: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "Please manually open: $OutputHtml" -ForegroundColor Cyan
}