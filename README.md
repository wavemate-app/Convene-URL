# Convene QR for Wavemate

This tool fetches the latest **Convene History URL** from the Wuthering Waves game logs and generates a **QR code** that can be scanned with the **Wavemate** app.

---

## Windows Usage
### 1. Open PowerShell
Press Win + S and type PowerShell.
Right-click Windows PowerShell and select Run as administrator (optional, only if needed for file access).

### 2. Run the script
Copy and paste this command:

```bash
powershell -ExecutionPolicy Bypass -NoProfile -Command "& {Invoke-Expression (Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/wavemate-app/Convene-URL/main/run_windows.ps1').Content}"
```

If you get an Access is denied or powershell.exe failed to run error
This usually happens on restricted or secured Windows systems.
Run this instead inside the same PowerShell window:

```bash
Invoke-Expression (Invoke-WebRequest “https://raw.githubusercontent.com/wavemate-app/Convene-URL/main/run_windows.ps1” -UseBasicParsing).Content
```


## macOS Usage

### 1. Open Terminal
Go to `Applications > Utilities > Terminal`.

### 2. Run the script
Copy and paste this command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/wavemate-app/Convene-URL/main/run_mac.sh)
```

If it’s not working, you can reach us by **[email](mailto:support@wavemate.app)** or join our **[Discord](https://discord.gg/Y7guZsj4DK)**.

