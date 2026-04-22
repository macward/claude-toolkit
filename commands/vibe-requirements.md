# Requirements Command

Genera un documento de requisitos con formato MoSCoW y escenarios BDD para una feature. Es el paso previo al spec técnico (`vibe-spec`).

## PROHIBICIONES ESTRICTAS

- ❌ No diseñar arquitectura ni soluciones técnicas
- ❌ No crear tasks ni specs
- ❌ No implementar nada

## Setup

Leer `vibe: <project>` del CLAUDE.md del proyecto activo.

## Proceso

### 1. Recibir la feature

El usuario describe la feature en su mensaje. Si la descripción es demasiado vaga (menos de una oración), hacer **una sola pregunta** para aclarar el objetivo principal. No preguntar más de una vez.

### 2. Generar el documento

Producir el documento siguiendo esta estructura. Adaptar al scope — no forzar secciones que no aplican.

```markdown
# <Nombre de la Feature>

## Requisitos

### DEBE
- El usuario DEBE poder...
- El sistema DEBE validar...

### DEBERÍA
- La UI DEBERÍA mostrar...
- El sistema DEBERÍA notificar...

### MAY
- MAY soportar... en el futuro

## Escenarios

### Escenario: <nombre del caso feliz>
Dado que <contexto>
Cuando <acción>
Entonces <resultado esperado>

### Escenario: <nombre del caso de error>
Dado que <contexto>
Cuando <acción>
Entonces <resultado esperado>
```

**Reglas para los requisitos:**
- DEBE → obligatorio para el MVP
- DEBERÍA → importante pero no bloqueante
- MAY → opcional, a futuro
- Redactar desde la perspectiva del usuario o del sistema, no de la implementación

**Reglas para los escenarios:**
- Cubrir el caso feliz siempre
- Cubrir al menos un caso de error o borde relevante
- Concretos y testeables — evitar escenarios vagos

### 3. Presentar y confirmar

Mostrar el documento al usuario y preguntar:
```
¿Lo guardo en plans/ como requirements-<slug>.md?
```

Esperar confirmación antes de guardar.

### 4. Guardar

```
mcp__vibeMCP__tool_create_plan(
  project=<project>,
  title=<título>,
  content=<contenido>,
  filename=requirements-<slug>.md
)
```

### 5. Sugerir siguiente paso

```
Guardado: plans/requirements-<slug>.md

Siguiente: `/vibe-spec` leerá este documento para diseñar la solución técnica.
```

## Reglas

1. Este comando define el *qué*, no el *cómo* — sin arquitectura, sin decisiones técnicas
2. Si el usuario ya tiene requisitos escritos, usarlos como base y completar lo que falta
3. Máximo una pregunta de clarificación antes de generar
