[CmdletBinding()]
param(
  [string]$ConfigPath
)

$ErrorActionPreference = "Stop"

if (-not $ConfigPath) {
  $appDataPath = [Environment]::GetFolderPath(
    [Environment+SpecialFolder]::ApplicationData
  )
  $ConfigPath = Join-Path $appDataPath "mcp-ark\.env"
}

function ConvertTo-DotEnvValue {
  param([AllowEmptyString()][string]$Value)

  $escaped = $Value.Replace('\', '\\').Replace('"', '\"')
  $escaped = $escaped.Replace("`r", '\r').Replace("`n", '\n')
  return '"' + $escaped + '"'
}

function Read-RequiredValue {
  param([string]$Label)

  do {
    $value = (Read-Host $Label).Trim()
  } while (-not $value)
  return $value
}

$defaultUrl = "https://ark.gestionveterinariaark.es/ark/rest"
$baseUrl = (Read-Host "URL base de la API de ARK [$defaultUrl]").Trim()
if (-not $baseUrl) {
  $baseUrl = $defaultUrl
}
$parsedBaseUrl = $null
if (-not [Uri]::TryCreate($baseUrl, [UriKind]::Absolute, [ref]$parsedBaseUrl) -or
    $parsedBaseUrl.Scheme -notin @("https", "http")) {
  throw "La URL de ARK no es válida. Debe empezar por https:// o http:// (valor recibido: '$baseUrl')."
}

$tenant = Read-RequiredValue "Código de empresa/tenant de ARK"
$username = Read-RequiredValue "Usuario de ARK"
$securePassword = Read-Host "Contraseña de ARK" -AsSecureString
$terminalId = (Read-Host "ID del terminal/caja (opcional)").Trim()
$employeeId = (Read-Host "ID numérico del empleado (opcional)").Trim()
if ($terminalId -and $terminalId -notmatch '^\d+$') {
  throw "El ID del terminal debe ser un número entero."
}
if ($employeeId -and $employeeId -notmatch '^\d+$') {
  throw "El ID del empleado debe ser un número entero."
}

$passwordPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
try {
  $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPtr)
  if (-not $password) {
    throw "La contraseña no puede estar vacía."
  }

  $lines = @(
    "# Configuración local de MCP ARK. No compartir ni subir a git."
    "ARK_BASE_URL=$(ConvertTo-DotEnvValue $baseUrl)"
    "ARK_TENANT=$(ConvertTo-DotEnvValue $tenant)"
    "ARK_USERNAME=$(ConvertTo-DotEnvValue $username)"
    "ARK_PASSWORD=$(ConvertTo-DotEnvValue $password)"
  )
  if ($terminalId) {
    $lines += "ARK_TERMINAL_ID=$(ConvertTo-DotEnvValue $terminalId)"
  }
  if ($employeeId) {
    $lines += "ARK_EMPLEADO_ID=$(ConvertTo-DotEnvValue $employeeId)"
  }

  $configDirectory = Split-Path -Parent $ConfigPath
  New-Item -ItemType Directory -Path $configDirectory -Force | Out-Null
  Set-Content -LiteralPath $ConfigPath -Value $lines -Encoding utf8
}
finally {
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPtr)
}

Write-Host "Configuración guardada en: $ConfigPath"
Write-Host "Reinicia Codex o abre una tarea nueva para recargar el servidor ARK."
