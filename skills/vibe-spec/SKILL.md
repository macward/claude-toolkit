---
name: spec
description: "Use when the user wants to create a Software Design Document (SDD) for a feature or component. Reads a requirements document from plans/ (produced by /vibe-requirements) and analyzes the codebase to produce a technical spec in specs/. Typically follows /vibe-requirements or /clarify, and leads into /vibe-task-breakdown. Requires vibeMCP tools."
---

# Spec

Create a technical Software Design Document (SDD) from a requirements document or feature description. Defines the *cómo* — arquitectura, interfaces, estructura — anclado al codebase real.

## Flow

```
/vibe-requirements (plans/) → [spec] (specs/) → /vibe-task-breakdown (tasks/)
```

- El input principal es un `requirements-*.md` en `plans/` (producido por `/vibe-requirements`). Léelo primero.
- Si no existe requirements, aceptar una descripción directa del usuario como fallback.
- Después del spec, sugerir `/analyze` para validar coherencia o `/vibe-task-breakdown` para implementar.

## Prerequisites

- vibeMCP server con tools: `list_specs`, `list_plans`, `read_doc`, `tool_create_spec`

Si vibeMCP no está conectado, informar al usuario y parar.

## Setup

1. Leer `vibe: <project>` del CLAUDE.md del proyecto activo
2. Si no hay project, preguntar

## Process

### 1. Check existing specs

```
list_specs(project)
```

Si ya existe un spec para el mismo tema, informar al usuario y ofrecer opciones (extender, renombrar, reemplazar). No duplicar.

### 2. Leer requirements

```
list_plans(project)
read_doc(project, "plans", <requirements-file>)
```

Si hay múltiples requirements, preguntar cuál. Si no hay ninguno, preguntar al usuario qué quiere construir (una sola pregunta, no más).

Extraer del requirements:
- Requisitos DEBE/DEBERÍA/MAY
- Escenarios BDD (funcionan como criterios de aceptación para el spec)

**No re-preguntar** lo que ya está en el requirements.

### 3. Analizar el codebase

Leer los archivos relevantes para entender:
- Arquitectura actual y patrones en uso
- Interfaces existentes con las que la feature interactuará
- Convenciones de naming y organización
- Constraints del stack

**Este paso es crítico**: el SDD debe estar anclado al codebase real, no ser abstracto.

### 4. Draft the SDD

Generar el documento con esta estructura. **Adaptar al scope**: omitir secciones que no apliquen (y mencionarlo explícitamente).

```markdown
# SDD: <Título>

## Metadata
- Date: YYYY-MM-DD
- Status: draft
- Source: plans/<requirements-file>.md

## Overview
<Qué se construye y por qué. 1-2 párrafos. Referenciar el requirements como fuente del *qué*.>

## Architecture
<Componentes, responsabilidades e interacciones. Referenciar módulos existentes
que se tocan o extienden. Incluir diagrama de texto si ayuda.>

## Interfaces
<Contratos públicos: endpoints, signatures, protocolos. Ejemplos de request/response.
Omitir si es refactor puramente interno.>

## Implementation Plan
<Pasos ordenados. Cada paso debe ser independientemente testeable.
Incluir criterio de verificación por paso.>

## Risks
<Solo riesgos concretos que afecten el diseño. Omitir si no hay.>
```

**Secciones opcionales** (agregar solo si el scope lo justifica):
- **Data Model** — cuando se introducen entidades o tablas nuevas
- **Directory Structure** — cuando la organización de archivos no es obvia
- **Dependencies** — cuando se agregan librerías o servicios externos

### 5. Presentar resumen

Antes de escribir:
```
SDD: <Título>
Secciones incluidas: <lista>
Secciones omitidas: <lista + razón>
Archivo: sdd-<slug>.md

¿Escribo en specs/?
```

Esperar confirmación.

### 6. Guardar

```
tool_create_spec(project, title=<título>, content=<contenido>)
```

El tool auto-genera el filename como `sdd-<slug>.md`.

### 7. Sugerir siguiente paso

```
Creado: specs/sdd-<slug>.md

Siguiente:
- /clarify — si hay ambigüedades que resolver antes de implementar
- /analyze — para validar coherencia con plan y tasks existentes
- /vibe-task-breakdown — para convertir esto en tasks accionables
```

## Error Handling

| Error | Acción |
|-------|--------|
| vibeMCP no conectado | Informar al usuario y parar |
| Spec duplicado | Mostrar opciones (extender, renombrar, reemplazar) |
| No hay requirements ni descripción | Preguntar al usuario qué construir (una vez) |
| Lectura del codebase falla | Anotar qué archivos no se pudieron leer, continuar con lo disponible |
| tool_create_spec falla | Mostrar error, ofrecer reintentar |

## Key Principles

- **El requirements define el *qué*, este skill define el *cómo*** — no redefinir requisitos acá
- **Codebase-grounded** — leer código relevante antes de escribir. Un SDD que ignora el codebase real es ficción
- **Adaptive structure** — un cambio de 20 líneas no necesita una sección Data Model. Omitir lo que no aplique y decirlo
- **Draft status** — todo SDD arranca como draft
- **Siempre usar MCP tools** — nunca escribir specs con Write/Edit directamente
- **No duplicar input** — si el requirements ya lo dice, no re-preguntar
