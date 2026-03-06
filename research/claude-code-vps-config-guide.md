# Guía Completa: Configuración de Claude Code en un VPS

**Archivos, permisos, MCP servers y buenas prácticas para entornos de servidor**

---

Si instalaste Claude Code en tu VPS y te encontraste con servidores MCP que no configuraste, archivos de configuración que parecen duplicados, o permisos que no sabés dónde van — esta guía es para vos. Todo lo que sigue viene de experiencia directa configurando Claude Code en un VPS con Ubuntu.

## La jerarquía de archivos de configuración

Claude Code distribuye su configuración en varios archivos, cada uno con un propósito específico. Esto es lo primero que hay que entender:

| Archivo | Propósito |
|---|---|
| `~/.claude.json` | Config principal del CLI. Acá van los MCP servers con scope `user`, datos de cuenta, stats de proyectos y configuración general. Es donde escribe `claude mcp add --scope user`. |
| `~/.claude/settings.json` | Settings internas/managed. Flags globales como `skipDangerousModePermissionPrompt` y permisos de herramientas. |
| `~/.claude/settings.local.json` | Override local de settings. Tiene prioridad sobre `settings.json` — lo que pongas acá sobreescribe el base. |
| `<proyecto>/.mcp.json` | MCP servers compartidos con el equipo (scope `project`). Se versiona en git. |
| `<proyecto>/.claude/settings.local.json` | Settings locales por proyecto. |

La confusión más común es pensar que `~/.claude/settings.json` y `~/.claude.json` son el mismo archivo. No lo son — el primero está *dentro* del directorio `.claude/`, el segundo está directamente en el home.

### Regla de oro

Si editás a mano, asegurate de estar tocando el archivo correcto. Si usás el CLI (`claude mcp add`, etc.), dejá que él decida dónde escribir.

## MCP Servers: ¿De dónde salen?

Al correr `claude mcp list` podés ver servidores que nunca configuraste. Hay tres fuentes posibles:

### 1. Connectors de claude.ai (prefijo `claude.ai`)

Si tenés connectors habilitados en tu cuenta de claude.ai (Settings → Connectors), estos se sincronizan automáticamente con Claude Code. Los identificás por el prefijo `claude.ai` en el listado:

```
claude.ai Supabase: https://mcp.supabase.com/mcp - ! Needs authentication
claude.ai sosumi: https://sosumi.ai/mcp - ✓ Connected
```

Estos no se configuran ni se sacan desde el VPS — se gestionan desde la interfaz web de claude.ai.

### 2. MCP servers de usuario (en `~/.claude.json`)

Son los que agregás vos con `claude mcp add --scope user` o editando `~/.claude.json` directamente. Están disponibles en todos los proyectos de esa máquina.

### 3. MCP servers de proyecto (en `.mcp.json`)

Definidos en el directorio del proyecto. Se comparten con cualquiera que clone el repo. Útil para herramientas específicas del equipo.

### Cómo agregar un MCP server correctamente

Usá siempre el CLI para evitar problemas de formato:

```bash
# Server SSE (como un MCP remoto)
claude mcp add miServer --transport sse --scope user \
  "https://mi-mcp-server.com/sse" \
  --header "Authorization: Bearer mi_token"

# Server HTTP
claude mcp add miServer --transport http --scope user \
  "https://mi-mcp-server.com/mcp"
```

Verificá con:

```bash
claude mcp list
```

Y dentro de Claude Code:

```
/mcp
```

## Configuración de permisos

### La diferencia entre Mac y VPS

En tu Mac de desarrollo, los permisos típicamente incluyen herramientas de Xcode, Swift y desarrollo iOS. En un VPS, necesitás herramientas de administración de servidor.

**Ejemplo de permisos para desarrollo iOS (Mac):**

```json
{
  "permissions": {
    "allow": [
      "Bash(swift:*)",
      "Bash(xcodebuild:*)",
      "Bash(xcrun:*)",
      "Bash(git:*)",
      "Bash(python:*)",
      "Bash(npm:*)"
    ],
    "deny": []
  }
}
```

**Ejemplo de permisos para VPS:**

```json
{
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(gh:*)",
      "Bash(python:*)",
      "Bash(pip:*)",
      "Bash(uv:*)",
      "Bash(docker:*)",
      "Bash(docker-compose:*)",
      "Bash(npm:*)",
      "Bash(npx:*)",
      "Bash(node:*)",
      "Bash(cat:*)",
      "Bash(ls:*)",
      "Bash(find:*)",
      "Bash(grep:*)",
      "Bash(head:*)",
      "Bash(tail:*)",
      "Bash(wc:*)",
      "Bash(jq:*)",
      "Bash(mkdir:*)",
      "Bash(cp:*)",
      "Bash(mv:*)",
      "Bash(touch:*)",
      "Bash(curl:*)",
      "Bash(caddy:*)",
      "Bash(systemctl:*)",
      "Bash(journalctl:*)",
      "Bash(ssh:*)",
      "Bash(scp:*)",
      "Bash(chmod:*)",
      "Bash(chown:*)",
      "Bash(sed:*)",
      "Bash(awk:*)"
    ],
    "deny": []
  }
}
```

### Permisos para MCP servers

Para permitir que Claude use herramientas de un MCP server específico sin pedir confirmación:

```json
"mcp__vibeMCP__*"
```

Para permitir **todos** los MCP servers (actuales y futuros):

```json
"mcp__*"
```

### Dónde poner los permisos

Para un VPS personal donde sos el único usuario, lo más simple es poner todo junto en `~/.claude/settings.json`:

```json
{
  "skipDangerousModePermissionPrompt": true,
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(gh:*)",
      "Bash(python:*)",
      "Bash(pip:*)",
      "Bash(uv:*)",
      "Bash(docker:*)",
      "Bash(docker-compose:*)",
      "Bash(npm:*)",
      "Bash(npx:*)",
      "Bash(node:*)",
      "Bash(cat:*)",
      "Bash(ls:*)",
      "Bash(find:*)",
      "Bash(grep:*)",
      "Bash(head:*)",
      "Bash(tail:*)",
      "Bash(wc:*)",
      "Bash(jq:*)",
      "Bash(mkdir:*)",
      "Bash(cp:*)",
      "Bash(mv:*)",
      "Bash(touch:*)",
      "Bash(curl:*)",
      "Bash(caddy:*)",
      "Bash(systemctl:*)",
      "Bash(journalctl:*)",
      "Bash(ssh:*)",
      "Bash(scp:*)",
      "Bash(chmod:*)",
      "Bash(chown:*)",
      "Bash(sed:*)",
      "Bash(awk:*)",
      "mcp__*"
    ],
    "deny": []
  }
}
```

## Buenas prácticas para VPS

### 1. Mantené el JSON válido

Un error tan simple como una coma al final causa que Claude Code ignore todo el archivo sin decirte exactamente qué pasó:

```json
// ❌ MAL — coma al final
{
  "skipDangerousModePermissionPrompt": true,
}

// ✅ BIEN
{
  "skipDangerousModePermissionPrompt": true
}
```

Validá siempre con `jq`:

```bash
jq . ~/.claude/settings.json
jq . ~/.claude.json
```

### 2. No edites `~/.claude.json` a mano (si podés evitarlo)

Este archivo contiene estadísticas, caches, datos de sesión y mucho más. Usá el CLI para los MCP servers:

```bash
claude mcp add ...
claude mcp remove ...
claude mcp list
```

### 3. Separá permisos por entorno

No copies la misma config de tu Mac al VPS. Cada entorno tiene herramientas distintas. `xcodebuild` no tiene sentido en un servidor Linux, y `systemctl` no tiene sentido en macOS.

### 4. Usá `deny` cuando sea necesario

Si hay comandos que querés bloquear explícitamente (por ejemplo, `rm -rf` en producción):

```json
{
  "permissions": {
    "allow": ["Bash(git:*)", "..."],
    "deny": ["Bash(rm:*)"]
  }
}
```

### 5. Verificá después de cada cambio

Después de modificar cualquier archivo de configuración:

```bash
# Verificar MCP servers
claude mcp list

# Dentro de Claude Code
/mcp
```

### 6. Cuidado con `skipDangerousModePermissionPrompt`

Esta flag hace que Claude Code no pida confirmación para *ninguna* acción. Es cómodo para desarrollo pero peligroso en producción. Si tu VPS maneja servicios críticos, considerá usar permisos granulares en vez de saltear todo.

## Diagnóstico rápido

Si algo no funciona, este es el checklist:

```bash
# 1. Verificar que el JSON sea válido
jq . ~/.claude/settings.json
jq . ~/.claude.json

# 2. Ver MCP servers registrados
claude mcp list

# 3. Ver archivos de config que existen
ls -la ~/.claude.json ~/.claude/settings.json ~/.claude/settings.local.json 2>/dev/null

# 4. Ver versión de Claude Code
claude --version

# 5. Debug de conexión MCP
claude --mcp-debug
```

## Resumen

La configuración de Claude Code parece compleja al principio porque distribuye settings en múltiples archivos con diferentes prioridades. Una vez que entendés que `~/.claude.json` es para el CLI, `~/.claude/settings.json` es para settings/permisos, y que los connectors de claude.ai se sincronizan automáticamente, todo cobra sentido. Adaptá los permisos al entorno donde estés trabajando y usá el CLI siempre que puedas en vez de editar archivos a mano.
