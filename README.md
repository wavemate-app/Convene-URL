# Convene QR for Wavemate

This tool fetches the latest **Convene History URL** from the Wuthering Waves game logs and generates a **QR code** that can be scanned with the **Wavemate** app.

---

## Features
- Automatically detects your `Client.log` file  
- Extracts the latest valid Convene History URL  
- Generates a 500×500 QR code on your Desktop  
- Creates an HTML preview with QR code and clickable link  
- Opens the HTML page automatically in Safari  
- Fully automated, no manual setup required after first run  

---

## macOS Usage

You can run the script directly from Terminal without manually downloading it.

### 1. Open Terminal
Go to `Applications > Utilities > Terminal`.

### 2. Run the script
Copy and paste this command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/wavemate-app/Convene-URL/main/run_mac.sh)
