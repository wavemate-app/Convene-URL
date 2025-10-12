#!/bin/bash
: '
[License]
This script is licensed under the GNU General Public License v3.0 (GPL-3.0).

Copyright (C) 2025 Wavemate

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the Free Software Foundation, 
either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
You can view the full text of the GNU General Public License at https://www.gnu.org/licenses/.

[Credits]
'

set -e

# Define constants
BREW_INSTALLER="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
QR_PACKAGE="qrencode"
LOG_PATH="$HOME/Library/Containers/com.kurogame.wutheringwaves.global/Data/Library/Logs/Client/Client.log"
OUTPUT_PNG="$HOME/Desktop/convene_url.png"
OUTPUT_HTML="$HOME/Desktop/convene_url.html"

# Ensure Homebrew is installed
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL $BREW_INSTALLER)"
fi

# Ensure qrencode is installed
if ! command -v qrencode &>/dev/null; then
  echo "Installing $QR_PACKAGE..."
  brew install "$QR_PACKAGE"
fi

# Check if log file exists
if [ ! -f "$LOG_PATH" ]; then
  echo "Log file not found at: $LOG_PATH"
  echo "Please check:"
  echo "1. The game directory is correct"
  echo "2. You have opened the Convene History in-game to generate the log"
  exit 1
fi

# Extract latest convene URL
URL=$(strings "$LOG_PATH" | grep -o "https://aki-gm-resources-oversea[^ ]*" | tail -n 1)

if [ -z "$URL" ]; then
  echo "No valid URL found in Client.log"
  echo "Open Wuthering Waves and tap the 'Convene History' icon to generate your latest convene data."
  echo "Then run this script again."
  exit 1
fi

echo "Latest URL found:"
echo "$URL"

# Generate QR code
echo "Generating QR code..."
qrencode -o "$OUTPUT_PNG" "$URL" -s 10
echo "QR code saved to: $OUTPUT_PNG"

# Generate HTML file
cat <<EOF > "$OUTPUT_HTML"
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
    <img src="file://$OUTPUT_PNG" alt="QR Code">
    <p>URL: <a href="$URL" target="_blank">$URL</a></p>
  </div>
</body>
</html>
EOF

echo "HTML file created at: $OUTPUT_HTML"

# Open in Safari
open -a "Safari" "$OUTPUT_HTML"