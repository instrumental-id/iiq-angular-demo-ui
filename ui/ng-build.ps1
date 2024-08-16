Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-OutGreen {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host $Message -ForegroundColor Green
}

function Write-OutRed {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host $Message -ForegroundColor Red
}

function Dump-Config {
    Write-OutGreen "CONFIGURATION"

    Write-Host ("NPM".PadRight(25) + $NPM.Path)
    Write-Host ("NPX".PadRight(25) + $NPX.Path)
    Write-Host ("Plugin UI Folder".PadRight(25) + $UI_DIR)
    Write-Host ("Plugin JS Folder".PadRight(25) + $JS_DIR)
    Write-Host ("Plugin CSS Folder".PadRight(25) + $CSS_DIR)
    Write-Host ("Angular app Folder".PadRight(25) + $APP_DIR)
    Write-Host ("page.xhtml template".PadRight(25) + $TEMPLATE)
    Write-Host ("page.xhtml target".PadRight(25) + $PAGE)
    Write-Host ""
}

$NPM = Get-Command npm -ErrorAction SilentlyContinue
$NPX = Get-Command npx -ErrorAction SilentlyContinue

if (-not $NPM) {
    Write-OutRed "The 'npm' executable is not on the execution path."
    exit 1
}

if (-not $NPX) {
    Write-OutRed "The 'npx' executable is not on the execution path."
    exit 1
}

$UI_DIR = Convert-Path .

$PAGE = Join-Path $UI_DIR "page.xhtml"
$TEMPLATE = Join-Path $UI_DIR "page-template.xhtml"

$JS_DIR = Join-Path $UI_DIR "js"
$CSS_DIR = Join-Path $UI_DIR "css"

$jsDir = New-Item -Path (Join-Path $JS_DIR "app") -ItemType Directory -Force
$cssDir = New-Item -Path (Join-Path $CSS_DIR "app") -ItemType Directory -Force

$APP_DIR = Join-Path $UI_DIR "app/angular-plugin-ui"
$SRC_DIR = Join-Path $APP_DIR "src"
$DIST_DIR = Join-Path $APP_DIR "dist/angular-plugin-ui/browser"

if (-not (Test-Path $TEMPLATE)) {
    Write-OutRed "This script must be run with 'ui' as its working directory"
    exit 2
}

if (-not (Test-Path $APP_DIR)) {
    Write-OutRed "The Angular app directory '${APP_DIR}' does not appear to exist in the working directory"
    exit 2
}

Dump-Config

Get-ChildItem -Path $CSS_DIR -Filter "styles*.css" -Recurse | Remove-Item -Force
Remove-Item -Path (Join-Path $JS_DIR "app") -Recurse -Force

$appDir = New-Item -Path (Join-Path $JS_DIR "app") -ItemType Directory -Force

[void](Push-Location -Path $APP_DIR)

Write-OutGreen "Executing Angular build (pwsh version)..."

& $NPM.Path i
& $NPM.Path run ng-dev

if (-not (Test-Path $DIST_DIR)) {
    Write-OutRed "After 'ng build', the '${DIST_DIR}' directory does not seem to exist??"
    exit 2
}

Write-OutGreen "Copying files to '${JS_DIR}/app' directories..."

Copy-Item -Path (Join-Path $DIST_DIR "assets\*") -Destination (Join-Path $JS_DIR "app") -Recurse
Copy-Item -Path (Join-Path $DIST_DIR "*.js") -Destination (Join-Path $JS_DIR "app")
Copy-Item -Path (Join-Path $DIST_DIR "styles*.css") -Destination (Join-Path $CSS_DIR "app")
Copy-Item -Path (Join-Path $DIST_DIR "styles*.css.map") -Destination (Join-Path $CSS_DIR "app")

Pop-Location

Write-OutGreen "Generating page.xhtml..."

$content = (Get-Content -Path (Join-Path $APP_DIR "dist/angular-plugin-ui/browser/index.html") -Raw)

$content = $content -replace '</body></html>', '' `
            -replace '<html><body>', '' `
            -replace 'src="', 'src="#{plugins.requestContextPath}/plugin/IDWAngularDemo/ui/js/app/' `
            -replace 'href="', 'href="#{plugins.requestContextPath}/plugin/IDWAngularDemo/ui/css/app/' `
            -replace '(<link.*?>)', '${1}</link>'

Write-Host "Generating page.xhtml with substitutions..."

$template = (Get-Content -Path $TEMPLATE -Raw)

($template -replace '<ui:remove>NG INSERT</ui:remove>', $content) | Out-File -FilePath $PAGE

Write-OutGreen "Done."

exit 0
