# Spec Workflow — Guía de uso

Proceso para diseñar e implementar features usando vibeMCP + claude-toolkit.

Esta guía cubre:
- Filosofía del flujo
- Cada comando en detalle (propósito, input, output, cuándo usarlo)
- Los dos modos (simple y completo) con ejemplos
- Un caso de uso end-to-end
- Cuándo saltarse pasos y cuándo no

---

## Filosofía

El flujo está pensado para **separar decisiones**. Cada documento responde a una sola pregunta:

| Documento | Pregunta que responde |
|-----------|------------------------|
| `CONSTITUTION.md` | ¿Qué siempre debe ser verdad en este sistema? |
| `plans/requirements-*.md` | ¿Qué debe hacer esta feature? |
| `specs/sdd-*.md` | ¿Cómo la vamos a construir? |
| `tasks/*.md` | ¿Qué pasos concretos ejecutamos? |
| `research/DECISIONS.md` | ¿Qué aprendimos y qué descartamos? |

Mezclar decisiones en un solo documento genera fricción: al iterar sobre la arquitectura tocás requisitos, y al cambiar requisitos perdés el razonamiento técnico. Separarlas permite evolucionar cada capa sin romper la otra.

**Regla general**: el mínimo viable es `/vibe-requirements → /vibe-spec → /vibe-task-breakdown`. Agregar pasos solo cuando aportan valor concreto, no por proceso.

---

## Los dos modos

### Modo simple (default)

Para features donde ya sabés qué construir y la solución técnica no es ambigua.

```
/vibe-requirements → /vibe-spec → /vibe-task-breakdown → /vibe-run-plan
```

Ejemplos de features simple:
- Agregar un endpoint REST que ya tiene un patrón establecido
- Sumar un campo a un modelo existente
- Implementar un validador con reglas claras

### Modo completo

Para features complejas: idea difusa, múltiples módulos afectados, decisiones de diseño no triviales.

```
/vibe-brainstorming → /vibe-requirements → /clarify → /vibe-spec → /analyze → /vibe-task-breakdown → /vibe-run-plan → /archive
```

Ejemplos de features complejas:
- Introducir un sistema de auth nuevo
- Refactorizar una capa de persistencia
- Integrar un servicio externo con impacto en múltiples features

---

## Comandos en detalle

### `/constitution`

**Propósito**: Definir los invariantes del proyecto — principios de arquitectura, estándares de código y restricciones que siempre deben cumplirse.

**Cuándo usarlo**:
- Una vez al iniciar el proyecto
- Al formalizar una decisión arquitectónica importante
- Antes de onboarding a otros agentes o devs

**Input**: decisiones del usuario a través de preguntas guiadas.

**Output**: `CONSTITUTION.md` en la raíz del proyecto.

**Secciones típicas**:
- Architecture Principles — "toda persistencia va a PostgreSQL"
- Code Standards — "Python 3.11+, type hints en toda función pública"
- Key Invariants — "toda tool call se loggea antes de ejecutarse"

**Regla**: si una decisión puede cambiar feature a feature, **no** pertenece a la constitución.

---

### `/vibe-brainstorming`

**Propósito**: Explorar una idea difusa antes de comprometerse a requisitos concretos. Es espacio creativo, no técnico.

**Cuándo usarlo**:
- La idea es vaga ("quiero algo que ayude al usuario a...")
- Hay múltiples approaches posibles y no está claro cuál elegir
- Necesitás validar suposiciones antes de invertir en un spec

**Cuándo NO usarlo**: si ya sabés qué querés construir — saltar directo a `/vibe-requirements`.

**Input**: descripción libre del usuario.

**Output**: `plans/brainstorming-*.md` con opciones exploradas, tradeoffs y recomendación.

---

### `/vibe-requirements`

**Propósito**: Definir el *qué*. Convierte una idea en requisitos priorizados y escenarios testeables.

**Cuándo usarlo**: **casi siempre**. Es el punto de entrada natural para cualquier feature.

**Input**: descripción de la feature, o un `brainstorming-*.md` si vino del paso anterior.

**Output**: `plans/requirements-*.md` con:
- Requisitos MoSCoW: **DEBE** (obligatorio), **DEBERÍA** (importante), **MAY** (opcional/futuro)
- Escenarios BDD con formato Dado/Cuando/Entonces

**Ejemplo de requisitos**:
```markdown
### DEBE
- El usuario DEBE poder adjuntar imágenes (jpg, png, gif, webp) a un mensaje
- Los archivos DEBEN validarse por tipo MIME y tamaño máximo (20MB)

### DEBERÍA
- La UI DEBERÍA mostrar preview antes de enviar

### MAY
- MAY soportar múltiples archivos por mensaje en el futuro
```

**Ejemplo de escenario**:
```markdown
### Escenario: archivo demasiado grande
Dado que el usuario selecciona un archivo > 20MB
Cuando intenta adjuntarlo
Entonces ve un error claro antes de intentar el upload
```

**Regla**: no hablar de implementación acá. "Usar S3 para almacenar" no es un requisito — es una decisión técnica que va en el spec.

---

### `/clarify`

**Propósito**: Resolver ambigüedades del requirements antes de diseñar la solución técnica.

**Cuándo usarlo**: si al leer el requirements te surgen preguntas como "¿y qué pasa si...?" que bloquearían el diseño.

**Cuándo NO usarlo**: si el requirements ya es claro y testeable.

**Input**: un `requirements-*.md` o un `sdd-*.md` existente.

**Output**: sección `## Clarifications` añadida al documento original, con preguntas y respuestas en 4 categorías:
- Alcance y límites
- Supuestos de implementación
- Criterios de éxito
- Riesgos y tradeoffs

---

### `/vibe-spec`

**Propósito**: Definir el *cómo*. Diseño técnico anclado al codebase real.

**Cuándo usarlo**: después del requirements, cuando hace falta decidir arquitectura, interfaces y plan de implementación.

**Cuándo NO usarlo**: si el cambio es trivial (ej: cambiar un literal, corregir un typo). En esos casos saltar directo a una task.

**Input**: un `requirements-*.md` en `plans/`.

**Output**: `specs/sdd-*.md` con:
- Overview — qué y por qué
- Architecture — componentes e interacciones, referenciando módulos existentes
- Interfaces — contratos públicos (endpoints, signatures)
- Implementation Plan — pasos ordenados y testeables
- Risks — solo riesgos concretos que afecten el diseño

**Secciones opcionales** (agregar solo si el scope lo justifica):
- Data Model (entidades nuevas)
- Directory Structure (organización no obvia)
- Dependencies (librerías/servicios externos nuevos)

**Regla clave**: el SDD debe leer el codebase antes de escribir. Un spec que ignora la realidad del código es ficción.

---

### `/analyze`

**Propósito**: Validar coherencia entre spec, plan y tasks antes de implementar. Solo lectura.

**Cuándo usarlo**:
- Después de crear el spec y antes de ejecutar tasks
- Después de cambios importantes al spec o al plan
- Cuando hay múltiples specs activos y querés detectar solapamientos

**Input**: todos los artefactos del proyecto (specs, plans, tasks, constitution).

**Output**: reporte en consola con:
- **Gaps** — requisitos sin tasks que los cubran
- **Tareas huérfanas** — tasks sin requisito que las justifique
- **Contradicciones** — spec dice X, plan dice Y
- **Violaciones constitucionales** — plan viola un principio de la constitución

**Regla**: este comando no modifica nada. Solo reporta. Vos decidís qué corregir.

---

### `/vibe-task-breakdown`

**Propósito**: Convertir un spec en tasks concretas y accionables.

**Cuándo usarlo**: una vez el spec está estable y validado.

**Input**: un `sdd-*.md` en `specs/`.

**Output**: múltiples archivos en `tasks/` con:
- Numeración incremental (`001-*.md`, `002-*.md`)
- Objective, Steps, Acceptance Criteria
- Status inicial: `pending`

**Regla**: cada task debe ser independientemente testeable. Si una task no se puede verificar sola, probablemente hay que partirla.

---

### `/vibe-run-plan`

**Propósito**: Ejecutar todas las tasks pendientes en secuencia.

**Modos**:
- **Autónomo** (default) — ejecuta todas sin pausar
- **Con confirmación** — pausa entre tasks para review

**Input**: tasks en estado `pending` en `tasks/`.

**Output**: código implementado + tasks marcadas como `done`.

**Regla**: si una task falla repetidamente, pausar y revisar el spec — puede haber un supuesto incorrecto.

---

### `/archive`

**Propósito**: Cerrar una feature y documentar aprendizajes.

**Cuándo usarlo**: cuando la feature está mergeada y funcionando.

**Input**: tasks completadas, spec final.

**Output**: entrada en `research/DECISIONS.md` con:
- Qué se implementó
- Qué se descartó y por qué
- Aprendizajes
- Opcional: actualización del changelog
- Tasks `done` archivadas

---

## Ejemplo end-to-end

**Feature**: agregar upload de imágenes a los mensajes del chat.

### 1. Requirements
```
/vibe-requirements
> "Quiero que los usuarios puedan adjuntar imágenes a los mensajes del chat"
```

Genera `plans/requirements-media-upload.md` con requisitos DEBE/DEBERÍA/MAY y escenarios BDD (archivo válido, archivo demasiado grande, tipo no soportado).

### 2. Clarify (opcional)
```
/clarify
```

Surgen preguntas: ¿qué pasa si el upload falla a la mitad? ¿hay límite de archivos por usuario/día? Las respuestas se agregan a `## Clarifications` en el requirements.

### 3. Spec
```
/vibe-spec
```

Lee el requirements y el codebase (modelo `Message`, servicio `ChatService`, frontend `MessageComposer`). Genera `specs/sdd-media-upload.md`:
- Overview
- Architecture: nuevo `MediaUploadService`, extiende `Message` con campo `attachments`
- Interfaces: endpoint `POST /messages/:id/attachments`
- Implementation Plan: 5 pasos ordenados

### 4. Analyze
```
/analyze
```

Reporte: ✓ sin gaps, ✓ sin contradicciones, ✓ constitución OK.

### 5. Task breakdown
```
/vibe-task-breakdown
```

Genera `tasks/001-media-upload-backend.md`, `tasks/002-media-upload-validation.md`, `tasks/003-media-upload-frontend.md`, `tasks/004-media-upload-tests.md`.

### 6. Run
```
/vibe-run-plan
```

Ejecuta las 4 tasks en orden. Cada una se marca `done` al pasar sus criterios.

### 7. Archive
```
/archive
```

Documenta en `research/DECISIONS.md`: por qué se eligió S3 sobre almacenamiento local, qué se descartó (thumbnails de video quedaron para v2), actualiza changelog.

---

## Cuándo saltar pasos

| Situación | Saltar |
|-----------|--------|
| Cambio trivial (typo, rename) | Todo — ir directo a código |
| Feature con patrón ya establecido | `brainstorming`, `clarify`, `analyze` |
| Ya hay requirements claros del stakeholder | `brainstorming` |
| Solo un desarrollador trabajando | `analyze` |
| Proyecto sin constitución aún | `analyze` (la parte constitucional) |

**Nunca saltar**:
- `/vibe-spec` en features que tocan más de un módulo
- `/vibe-task-breakdown` si vas a usar `/vibe-run-plan`

---

## Pitfalls comunes

**Escribir arquitectura en el requirements**  
Si mencionás "usar Redis" en `requirements-*.md`, estás cerrando decisiones que pertenecen al spec. Mantené el requirements agnóstico a la implementación.

**Specs abstractos**  
Un SDD que no referencia archivos, funciones o módulos reales del codebase es un documento de pizarra, no un spec. Siempre leer código antes de escribir.

**Tasks que no se pueden testear solas**  
Si una task dice "implementar feature X", probablemente hay que partirla. Cada task debe tener un criterio de verificación independiente.

**Skippear `/analyze` en features complejas**  
Cuando el spec toca múltiples módulos, las contradicciones entre spec → plan → tasks son silenciosas y caras. El análisis es barato.

**Usar `/vibe-brainstorming` para features obvias**  
Si ya sabés qué querés, saltarlo. El brainstorming es para explorar, no para proceso.
