# Target Recon
Reconaissance script used for enumerating subdomains, JS files, API's and perform Vulnerability scan.

## Prerequisites
Install following tools for the script :

1] Subfinder : 
```
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
```
2] Assetfinder : 
```
go get -u github.com/tomnomnom/assetfinder
```
3] Amass : 
```
go install -v github.com/owasp-amass/amass/v4/...@master
```
4] Dnsx : 
```
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
```
5] Httpx : 
```
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
```
6] Katana : 
```
CGO_ENABLED=1 go install github.com/projectdiscovery/katana/cmd/katana@latest
```
7] Gau : 
```
go install github.com/lc/gau/v2/cmd/gau@latest
```
8] Waymore : 
```
pipx install git+https://github.com/xnl-h4ck3r/waymore.git
```
9] JSfinder : 
```
go install -v github.com/kacakb/jsfinder@latest
```
10] GF : 
```
go get -u github.com/tomnomnom/gf
```
11] Nuclei : 
```
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
```
12] Dalfox : 
```
go install github.com/hahwul/dalfox/v2@latest
```
13] SecretFinder : 
```
git clone https://github.com/m4ll0k/SecretFinder.git secretfinder
cd secretfinder
sudo cp SecretFinder.py /usr/bin/
```
14] Trufflehog : 
```
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sudo sh -s -- -b /usr/bin
```
15] Mantra : 
```
go install github.com/Brosck/mantra@latest
```
- Dependencies and file location for effecient scanning :
1] Requirements for SecretFinder : We can cd into secretfinder and use 'pip install requirements.tx' but if it shows error and needs venv, use the following steps.
	- Install JSbeautifier : 
  ```
  curl -L https://files.pythonhosted.org/packages/ea/98/d6cadf4d5a1c03b2136837a435682418c29fdeb66be137128544cecc5b7a/jsbeautifier-1.15.4.tar.gz 
	tar -xvzf jsbeautifier-1.15.4.tar.gz
	cd jsbeautifier-1.15.4
	sudo python3 setup.py install
  ```
Install rest using pipx : 
  ```
  pipx install requests && pipx instal requests_file && pipx install lxml
  ```
2] We have to move the GO tools to /usr/bin/ : 
```
sudo mv ~/go/bin/* /usr/bin
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
recon.sh domain.com
```
## Tuning
- We can configure the scripts using flags like '-rl' in Nuclei for rate limiting, '-b domain.com' in Dalfox to verify external requesting in cases of blind XSS. 