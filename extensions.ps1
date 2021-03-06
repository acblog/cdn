$ErrorActionPreference = "Stop"

if ($args.Length -eq 0) {
    Write-Error "Please give dist directory."
}

Write-Information "Generate CDN for Extensions"

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

$artifacts = Invoke-RestMethod https://api.github.com/repos/acblog/extensions/actions/artifacts -Authentication Basic -Credential $cred

$packages = $artifacts.artifacts | Where-Object { $_.name -eq "packages" }

if ($packages.Length -eq 0) {
    Write-Error "No artifacts found."
    exit
}

$package = $packages[0]

Invoke-WebRequest $package.archive_download_url -Authentication Basic -Credential $cred -OutFile $temp/packages-extention.zip

$pkgroot = Join-Path $temp packages-extention

if (Test-Path $pkgroot) {
    Remove-Item $pkgroot -Recurse
}
Expand-Archive $temp/packages-extention.zip -DestinationPath $pkgroot -Force

function GenWithPkg {
    param (
        
    )
    $name = $args[0]
    $item = (Get-ChildItem $pkgroot | Where-Object { $_.Name.StartsWith($name) })[0]
    Copy-Item $item.FullName $temp/package.zip -Force

    $outpath = Join-Path $temp $name

    Expand-Archive $temp/package.zip -DestinationPath $outpath -Force

    $distpkg = Join-Path $dist $name
    if (Test-Path $outpath/staticwebassets) {
        Copy-Item $outpath/staticwebassets $distpkg/lib -Recurse -Force -Container:$false
    }
    if (Test-Path $outpath/lib/netstandard2.1) {
        Copy-Item $outpath/lib/netstandard2.1 $distpkg/bin -Recurse -Force -Container:$false
    }
}

# GenWithPkg "AcBlog.Extensions.Core"
