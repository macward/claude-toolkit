# Constitution Command

Crea o actualiza la `CONSTITUTION.md` del proyecto activo. La constitución define principios de arquitectura, estándares de código e invariantes del sistema que aplican en cada sesión de trabajo.

## ÚNICA TOOL DE ESCRITURA PERMITIDA

```
mcp__vibeMCP__tool_save_constitution(project=<project>, content=<content>)
```

## Setup

Leer `vibe: <project>` del CLAUDE.md del proyecto activo.

## Proceso

### 1. Leer constitución existente

```
mcp__vibeMCP__read_constitution(project=<project>)
```

### 2a. Si NO existe: crear desde cero

Guiar al usuario por tres secciones con preguntas dirigidas.

**Principios de arquitectura** — decisiones técnicas no negociables:
- "¿Qué decisiones de arquitectura NO se pueden cambiar en este proyecto?"
- Ejemplos: "todo state va en SQLite", "el LLM nunca escribe YAML sin validar", "auth pasa siempre por el Policy Engine"

**Estándares de código** — convenciones obligatorias:
- "¿Qué lenguaje/framework/librerías son mandatorios?"
- "¿Hay guías de estilo, linters o patrones que siempre se siguen?"

**Invariantes clave** — comportamientos que nunca deben romperse:
- "¿Qué cosas en el sistema deben ser siempre verdad?"
- Ejemplos: "todos los tool calls se loggean", "nunca exponer datos de usuario sin auth", "las migraciones siempre son reversibles"

Recoger respuestas del usuario y construir el documento. Guardar con:

```
mcp__vibeMCP__tool_save_constitution(project=<project>, content=<content>)
```

### 2b. Si existe: proponer actualización

Mostrar la constitución actual al usuario.

Preguntar:
- "¿Qué secciones quieres actualizar?"
- "¿Hay principios nuevos que agregar?"
- "¿Algún principio ya no aplica?"

Incorporar los cambios y guardar.

## Formato del documento

```markdown
# <project> Constitution

## Architecture Principles

- <decisión no negociable>
- <decisión no negociable>

## Code Standards

- <estándar obligatorio>
- <estándar obligatorio>

## Key Invariants

- <comportamiento que siempre debe ser verdad>
- <comportamiento que siempre debe ser verdad>
```

## Reglas

1. La constitución debe ser concisa — máximo una página
2. Cada punto debe ser accionable: "siempre X" o "nunca Y", no "intentar Z"
3. No incluir implementación ni detalles técnicos de features — solo principios
4. Si el usuario no tiene respuestas claras para una sección, dejarla como placeholder con un ejemplo comentado
5. Confirmar el contenido final con el usuario antes de guardar
