---
name: setup
description: Configurar por primera vez la conexión de este plugin a la clínica del usuario, reparar el acceso o cambiar de clínica. Úsala al ejecutar la configuración inicial de ARK.
---

# Configurar ARK

La configuración pertenece al usuario y se guarda fuera del plugin. No hay acceso a ninguna clínica por defecto.

1. Comprueba si la herramienta `ark_empresa` ya funciona. Si funciona, muestra el nombre del centro y pregunta si quiere conservarlo antes de sustituir la configuración. No abras ni muestres archivos con credenciales.
2. En Windows, localiza `scripts/configure-ark-gui.ps1` junto a esta skill (desde `skills/setup`, subir dos directorios hasta la raíz del plugin). Abre el formulario usando Windows PowerShell con `-NoProfile -STA -File` y esa ruta absoluta. Si lo lanzas con `Start-Process`, usa `-WindowStyle Hidden` para ocultar la consola; el formulario debe seguir visible. El usuario introduce su contraseña en el formulario, nunca en el chat ni en argumentos de comandos.
3. El formulario pide URL API, código de empresa/tenant, usuario y contraseña; terminal y empleado son opcionales. Verifica el inicio de sesión antes de guardar. Si no conoce el tenant, debe obtenerlo de su proveedor de ARK; no lo inventes. No reutilices el acceso de otra clínica.
4. En Windows se guarda en `%APPDATA%/mcp-ark/.env`. Las actualizaciones del plugin conservan este archivo. La contraseña queda en un archivo local con permisos limitados al usuario; no se sincroniza con GitHub. En otros sistemas no hay formulario automático en esta versión: usa `.env.example` como plantilla para el archivo de usuario `~/.config/mcp-ark/.env` (o `$XDG_CONFIG_HOME/mcp-ark/.env`) y que el usuario introduzca los secretos localmente, con permisos solo para él.
5. Comprueba Node.js 24 o posterior. Si falta, guía su instalación desde la distribución oficial; no afirmes que el MCP funciona sin este requisito. El servidor viene compilado: el usuario no necesita npm ni compilar.
6. Después de guardar, abre un chat nuevo o recarga el MCP; si aún no puede iniciarse, reinicia la aplicación. Comprueba `ark_empresa` y `ark_terminales` y muestra la clínica y los centros disponibles. No registres compras para probar la conexión. No afirmes que está conectado hasta que responda una consulta.

Este es un plugin con ejecución local: orienta al usuario a Codex de escritorio. Una conversación de ChatGPT web sin ejecución local no puede arrancar este MCP por instalar el repositorio.
