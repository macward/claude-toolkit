# Clarify Command

Genera preguntas estructuradas para un spec antes de diseñar la solución técnica. El objetivo es resolver ambigüedades que bloquearían el diseño antes de empezar a planificar.

## PROHIBICIONES ESTRICTAS

- ❌ No implementar nada
- ❌ No crear nuevas tasks ni planes
- ❌ No modificar specs salvo para agregar la sección `## Clarifications`

## Setup

Leer `vibe: <project>` del CLAUDE.md del proyecto activo.

## Proceso

### 1. Seleccionar spec

```
mcp__vibeMCP__list_specs(project=<project>)
```

- Si hay un solo spec activo, usarlo directamente
- Si hay múltiples, preguntar al usuario cuál quiere clarificar
- Si no hay specs, informar: "No hay specs en este proyecto. Crea uno primero con `tool_create_spec`."

### 2. Leer spec y constitución

```
mcp__vibeMCP__read_doc(project=<project>, folder="specs", filename=<spec_file>)
mcp__vibeMCP__read_constitution(project=<project>)
```

### 3. Generar preguntas estructuradas

Analizar el spec y generar preguntas concretas en estas categorías. Las preguntas deben ser específicas al dominio del spec, no genéricas.

**Alcance y límites**
- ¿Qué está explícitamente fuera de scope?
- ¿Qué casos borde están contemplados y cuáles se delegan a otro componente?

**Supuestos de implementación**
- ¿Qué asume sobre la infraestructura existente?
- ¿Qué dependencias externas requiere?
- ¿Hay constraints de performance, seguridad o compatibilidad implícitos?

**Criterios de éxito**
- ¿Cómo sabremos que esto está terminado?
- ¿Qué tests automatizados validarían el comportamiento esperado?

**Riesgos y tradeoffs**
- ¿Qué podría salir mal con el approach implícito en el spec?
- ¿Qué se sacrifica al elegir esta solución sobre alternativas?

Si hay una CONSTITUTION.md, verificar también:
- ¿El spec está alineado con los principios de la constitución?
- ¿Hay principios que restringen el diseño de esta feature?

### 4. Recoger respuestas

Presentar las preguntas al usuario. Recoger respuestas por categoría. Permitir respuestas parciales ("no aplica", "TBD", etc.).

### 5. Actualizar spec con las clarificaciones

Tomar el contenido original del spec, agregar al final una sección `## Clarifications` con las preguntas y sus respuestas. Guardar usando `tool_create_spec` con el mismo filename (ya soporta upsert):

```
mcp__vibeMCP__tool_create_spec(
  project=<project>,
  title=<título_del_spec_original>,
  content=<contenido_original + "\n\n## Clarifications\n\n" + preguntas_y_respuestas>,
  filename=<spec_file>
)
```

Si el spec ya tiene `## Clarifications`, agregar las nuevas al final de esa sección.

## Formato de la sección Clarifications

```markdown
## Clarifications

_<fecha>_

### Alcance y límites
**Q: ¿Qué está fuera de scope?**
A: <respuesta del usuario>

### Supuestos de implementación
**Q: ¿Qué asume sobre la infraestructura?**
A: <respuesta del usuario>

### Criterios de éxito
**Q: ¿Cómo sabremos que está terminado?**
A: <respuesta del usuario>

### Riesgos
**Q: ¿Qué podría salir mal?**
A: <respuesta del usuario>
```

## Reglas

1. Priorizar preguntas que bloqueen el diseño técnico — no hacer preguntas triviales
2. Máximo 2-3 preguntas por categoría; calidad sobre cantidad
3. Si el usuario responde "TBD", registrarlo como pendiente explícito
4. No inferir respuestas — si el usuario no responde una pregunta, dejarla sin respuesta en el doc
