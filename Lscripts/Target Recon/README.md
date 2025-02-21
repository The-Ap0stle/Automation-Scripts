# Target Recon
Reconaissance script used for enumerating subdomains, subdirectories, JS files and API's.
Tools Used in script include Subfinder, Assetfinder, crt.sh, httpx, xargs, [Recuzzer](https://github.com/The-Ap0stle/Recuzzer), [Katana](https://github.com/projectdiscovery/katana) and [Mantra](https://github.com/brosck/mantra)

## Prerequisites
- Install https and xargs : 
```
sudo apt install -y httpx xargs
```
- Install Subfinder, Assetfinder and jq :
```
sudo apt install -y subfinder assetfinder jq
```
- Install GO :
```
  sudo apt install golang-go -y
```
- Install Katana and Mantra :
```
go install github.com/projectdiscovery/katana/cmd/katana@latest
go install github.com/Brosck/mantra@latest
sudo mv go/bin/katana go/bin/mantra /usr/bin
```
- Get Recuzzer's script integration :
```
sudo curl -o /usr/bin/rec.py https://raw.githubusercontent.com/The-Ap0stle/Recuzzer/refs/heads/Integrate/int.py
```
## Usage 
- Save the recon script : 
```
sudo curl -o /usr/bin/recon.sh https://raw.githubusercontent.com/The-Ap0stle/Automation-Scripts/refs/heads/main/Lscripts/Target%20Recon/recon.sh
```
- Make the script executable :
```
sudo chmod +x /usr/bin/recon.sh
```
- Run the script :
```
.\recon.sh
```