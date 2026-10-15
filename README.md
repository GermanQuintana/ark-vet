# ARK Gestión Veterinaria

Plugin para Codex de escritorio con servidor MCP local y skills de clínica, almacén, compras y configuración inicial. Versión 0.5.0.

## Instalar

En Codex puedes pedir: «Instala el plugin de https://github.com/GermanQuintana/ark-vet y ayúdame a configurar mi ARK». Acepta la instalación y ejecuta **Configurar ARK**. El asistente te ayudará con los pasos; no publiques tu contraseña en el chat.

Si necesitas registrar el catálogo desde Codex CLI:

```powershell
codex plugin marketplace add GermanQuintana/ark-vet
```

Después abre Plugins y selecciona **ARK Gestión Veterinaria** dentro de **ARK Veterinaria** para instalarlo. La disponibilidad de instalación y de configuración depende de las funciones habilitadas en tu versión de Codex y de las políticas de tu cuenta.

Necesitas **Node.js 24 o posterior**, conexión a tu ARK y sus credenciales. El servidor ya está compilado en el repositorio; no necesitas compilarlo ni instalar dependencias. El formulario gráfico está disponible en Windows. macOS/Linux requieren configurar el archivo de usuario manualmente, siguiendo la skill de configuración.

## Configurar por primera vez en Windows

Pulsa la configuración inicial del plugin o pide «Configura mi ARK». También puedes ejecutar desde la raíz de este repositorio:

```powershell
powershell -NoProfile -STA -ExecutionPolicy Bypass -File .\plugins\ark-vet\scripts\configure-ark-gui.ps1
```

El formulario solicita URL de la API, código de empresa/tenant, usuario y contraseña. Terminal y empleado son opcionales. Comprueba la autenticación sin modificar datos clínicos y guarda en `%APPDATA%/mcp-ark/.env`, con permisos del usuario. Si existe una configuración, pide confirmación antes de sustituirla. Recarga el MCP o abre un chat nuevo; reinicia Codex si fuera necesario. Verifica la clínica consultando los datos de empresa.

Las credenciales se guardan **localmente en texto**, protegidas por permisos de archivo; no se cifran ni se suben a GitHub. No compartas el archivo. Cada persona usa su propio acceso. Este repositorio no incluye credenciales, pacientes, facturas ni albaranes.

## Uso

- «Busca este artículo y dime sus existencias».
- «Consulta el historial de esta mascota».
- «Prepara esta compra en el centro que te indique».

Las escrituras requieren vista previa y confirmación expresa del centro. Las compras introducen las líneas desde la última hasta la primera, incluso con varias páginas, para conservar el orden visible del documento original.

## Actualizar

```powershell
codex plugin marketplace upgrade ark-vet
```

Actualiza o recarga el plugin desde tu cliente y abre un chat nuevo cuando sea necesario. Publicar en GitHub no actualiza instantáneamente todos los equipos. El perfil de acceso está fuera de la carpeta del plugin y se conserva.

## Mantener el código

Desde `plugins/ark-vet/mcp-server`: `npm ci`, `npm run build`, `npm run test:smoke`. El smoke test usa credenciales ficticias y no conecta con una clínica. Publica juntos código, bundle compilado y nueva versión. No copies archivos `.env` al repositorio.

## Adaptaciones privadas

Las referencias a centros, empleados y convenciones de una clínica concreta deben mantenerse en una adaptación privada. El nombre del autor identifica al desarrollador y no es una configuración de acceso.

Para compartir, usa el repositorio público. La variante privada se identifica por un marketplace distinto; no actives ambas variantes simultáneamente en el mismo chat.
