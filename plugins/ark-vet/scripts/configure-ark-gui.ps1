[CmdletBinding()]
param([string]$ConfigPath)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
if (-not $ConfigPath) { $ConfigPath = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'mcp-ark\.env' }
$form = New-Object Windows.Forms.Form
$form.Text = 'Configurar ARK'
$form.ClientSize = New-Object Drawing.Size(570,430)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$intro = New-Object Windows.Forms.Label
$intro.Text = 'Introduce el acceso a TU clínica. La contraseña se guarda solo en este equipo.'
$intro.SetBounds(20,15,530,40)
$form.Controls.Add($intro)
$fields = [ordered]@{ARK_BASE_URL='Dirección API de ARK';ARK_TENANT='Código de empresa / clínica';ARK_USERNAME='Usuario de ARK';ARK_PASSWORD='Contraseña';ARK_TERMINAL_ID='ID de terminal (opcional)';ARK_EMPLEADO_ID='ID de empleado (opcional)'}
$inputs = @{}
$row = 0
foreach ($key in $fields.Keys) {
  $label = New-Object Windows.Forms.Label
  $label.Text = $fields[$key]
  $label.SetBounds(20,(65+45*$row),200,25)
  $box = New-Object Windows.Forms.TextBox
  $box.SetBounds(225,(62+45*$row),320,25)
  if ($key -eq 'ARK_PASSWORD') { $box.UseSystemPasswordChar = $true }
  if ($key -eq 'ARK_BASE_URL') { $box.Text = 'https://ark.gestionveterinariaark.es/ark/rest' }
  $inputs[$key] = $box
  $form.Controls.Add($label)
  $form.Controls.Add($box)
  $row++
}
$status = New-Object Windows.Forms.Label
$status.SetBounds(20,340,530,35)
$form.Controls.Add($status)
$save = New-Object Windows.Forms.Button
$save.Text = 'Comprobar y guardar'
$save.SetBounds(305,385,150,30)
$cancel = New-Object Windows.Forms.Button
$cancel.Text = 'Cancelar'
$cancel.SetBounds(465,385,80,30)
$cancel.DialogResult = 'Cancel'
$form.Controls.Add($save)
$form.Controls.Add($cancel)
$form.CancelButton = $cancel
$save.Add_Click({
  $save.Enabled = $false
  try {
    $values = @{}
    foreach ($key in $fields.Keys) { $values[$key] = $inputs[$key].Text }
    foreach ($key in @('ARK_TENANT','ARK_USERNAME','ARK_PASSWORD')) {
      if ([string]::IsNullOrWhiteSpace($values[$key])) { throw 'Completa código de clínica, usuario y contraseña.' }
    }
    $api = $null
    if (-not [Uri]::TryCreate($values.ARK_BASE_URL.Trim(),[UriKind]::Absolute,[ref]$api) -or $api.Scheme -notin @('https','http') -or $api.UserInfo -or $api.Query -or $api.Fragment) { throw 'Introduce una dirección API http/https válida, sin usuario ni parámetros.' }
    foreach ($key in @('ARK_TERMINAL_ID','ARK_EMPLEADO_ID')) {
      if ($values[$key] -and ($values[$key] -notmatch '^[1-9][0-9]*$')) { throw 'Terminal y empleado deben ser números positivos, o quedar vacíos.' }
    }
    $status.Text = 'Comprobando acceso a ARK…'
    $form.Refresh()
    $body = @{tenant=$values.ARK_TENANT.Trim();username=$values.ARK_USERNAME.Trim();password=$values.ARK_PASSWORD} | ConvertTo-Json -Compress
    try {
      $response = Invoke-RestMethod -Uri ($api.AbsoluteUri.TrimEnd('/')+'/auth/signin') -Method Post -ContentType 'application/json' -Body ([Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 25
      if (-not $response.accessToken) { throw 'No se recibió una sesión válida.' }
    } catch { throw 'No se pudo verificar el acceso. Revisa dirección, código, usuario, contraseña y conexión. No se guardó ningún cambio.' }
    if ((Test-Path -LiteralPath $ConfigPath) -and [Windows.Forms.MessageBox]::Show('Ya hay una configuración de ARK en este equipo. ¿Sustituirla por la que acabas de comprobar?','Configurar ARK','YesNo','Question') -ne 'Yes') { return }
    $lines = @('# Configuración local. No compartir ni subir a GitHub.')
    foreach ($key in $fields.Keys) {
      if ($values[$key]) {
        $value = $values[$key].Replace('\','\\').Replace('"','\"').Replace("`r",'\r').Replace("`n",'\n')
        $lines += $key+'="'+$value+'"'
      }
    }
    $directory = Split-Path -Parent $ConfigPath
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    [IO.File]::WriteAllLines($ConfigPath,$lines,(New-Object Text.UTF8Encoding($false)))
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    $acl = Get-Acl -LiteralPath $ConfigPath
    $acl.SetAccessRuleProtection($true,$false)
    $rule = New-Object Security.AccessControl.FileSystemAccessRule($identity,'FullControl','Allow')
    $acl.SetAccessRule($rule)
    Set-Acl -LiteralPath $ConfigPath -AclObject $acl
    $response = $null
    $body = $null
    $inputs.ARK_PASSWORD.Clear()
    [Windows.Forms.MessageBox]::Show('Acceso comprobado y configuración guardada. Reinicia Codex o abre un chat nuevo para cargar ARK.','ARK configurado','OK','Information') | Out-Null
    $form.DialogResult = 'OK'
    $form.Close()
  } catch {
    $status.Text = $_.Exception.Message
  } finally { $save.Enabled = $true }
})
[void]$form.ShowDialog()
$form.Dispose()
