$ErrorActionPreference = "Stop"

if ($args.Length -eq 0) {
    Write-Error "Please give dist directory."
}

Write-Information "Generate CDN for Client"

$temp = "temp"
$dist = $args[0]

if (-not (Test-Path -Path $temp)) {
    New-Item -Path $temp -ItemType Directory
}
if (-not (Test-Path -Path $dist)) {
    New-Item -Path $dist -ItemType Directory
}

$token = $env:TOKEN |ConvertTo-SecureString -AsPlainText -Force

$cred = New-Object System.Management.Automation.PsCredential($env:USERNAME , $token)

Write-Information "Download artifacts"

$artifacts = Invoke-RestMethod https://api.github.com/repos/acblog/acblog/actions/artifacts -Authentication Basic -Credential $cred

$wasms = $artifacts.artifacts | Where-Object { $_.name -eq "wasm" }

if ($wasms.Length -eq 0) {
    Write-Error "No artifacts found."
    exit
}

$wasm = $wasms[0]

Invoke-WebRequest $wasm.archive_download_url -Authentication Basic -Credential $cred -OutFile $temp/wasm.zip

if (Test-Path $temp/wasm) {
    Remove-Item $temp/wasm -Recurse
}
Expand-Archive $temp/wasm.zip -DestinationPath $temp/wasm -Force

Copy-Item $temp/wasm/wwwroot/_framework/wasm $dist/wasm -Recurse -Force -Container:$false
Copy-Item $temp/wasm/wwwroot/_framework/_bin $dist/client/bin -Recurse -Force -Container:$false
Copy-Item $temp/wasm/wwwroot/css $dist/client/css -Recurse -Force -Container:$false
Copy-Item $temp/wasm/wwwroot/js $dist/client/js -Recurse -Force -Container:$false
Copy-Item $temp/wasm/wwwroot/lib $dist/client/lib -Recurse -Force -Container:$false
