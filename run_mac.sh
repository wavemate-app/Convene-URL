#!/bin/bash

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
  exit 1
fi

# Extract latest convene URL
URL=$(strings "$LOG_PATH" | grep -o "https://aki-gm-resources-oversea[^ ]*" | tail -n 1)

if [ -z "$URL" ]; then
  echo "No valid URL found in Client.log"
  echo "Open Wuthering Waves and tap the 'Convene History' icon to generate your latest convene data."
  exit 1
fi

echo "Latest URL found:"
echo "$URL"

# Generate QR code
qrencode -o "$OUTPUT_PNG" "$URL" -s 10
echo "QR code saved to: $OUTPUT_PNG"

# Generate HTML file
cat <<EOF > "$OUTPUT_HTML"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Convene URL</title>
</head>
<body style="text-align:center; font-family:sans-serif;">
  <h2>Scan this QR code using Wavemate app</h2>
  <img src="file://$OUTPUT_PNG" alt="QR Code" width="500" height="500">
  <p>URL: <a href="$URL" target="_blank">$URL</a></p>
</body>
</html>
EOF

echo "HTML file created at: $OUTPUT_HTML"

# Open in Safari
open -a "Safari" "$OUTPUT_HTML"