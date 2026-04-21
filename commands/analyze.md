# Analyze Command

Cross-check spec → plan → tasks para encontrar gaps y tareas huérfanas antes de implementar. Solo genera un reporte — no crea ni modifica nada.

## PROHIBICIONES ESTRICTAS

- ❌ No crear tasks, specs ni planes
- ❌ No modificar ningún documento
- ❌ No implementar nada

## Setup

Leer `vibe: <project>` del CLAUDE.md del proyecto activo.

## Proceso

### 1. Recopilar todos los artefactos

```
mcp__vibeMCP__list_specs(project=<project>)
mcp__vibeMCP__list_plans(project=<project>)
mcp__vibeMCP__list_tasks(project=<project>)
mcp__vibeMCP__read_constitution(project=<project>)
```

Leer el contenido de los specs activos y del plan principal:

```
mcp__vibeMCP__read_doc(project=<project>, folder="specs", filename=<spec_file>)
mcp__vibeMCP__get_plan(project=<project>)
```

### 2. Extraer requisitos del spec

Identificar todas las líneas que contienen palabras clave de requisito:
- **DEBE / MUST** — requisitos obligatorios
- **DEBERÍA / SHOULD** — requisitos recomendados
- **PUEDE / MAY** — requisitos opcionales

Cada requisito se convierte en un ítem a verificar.

### 3. Analizar cobertura en cuatro dimensiones

**A. Gaps — requisitos sin tasks**

Por cada requisito DEBE/DEBERÍA del spec, verificar si hay al menos una task en estado `pending`, `in-progress` o `done` que lo cubra (buscar por nombre de task o keywords del requisito).

Listar los requisitos sin cobertura evidente.

**B. Tareas huérfanas — tasks sin requisito**

Por cada task en estado `pending` o `in-progress`, verificar si hay un requisito en el spec que la justifique.

Listar las tasks cuyo origen no es rastreable al spec.

**C. Contradicciones — plan vs spec**

Leer el plan técnico y comparar con los requisitos del spec:
- ¿El plan propone una solución que contradice algún requisito?
- ¿El plan asume algo que el spec no contempla?

**D. Validez constitucional — plan vs CONSTITUTION.md**

Si existe CONSTITUTION.md, verificar:
- ¿El plan viola algún principio de arquitectura?
- ¿Alguna decisión técnica del plan contradice los Key Invariants?

Si no existe CONSTITUTION.md, omitir esta sección e informar que no hay constitución.

### 4. Presentar reporte

```
## Analyze Report — <project>
_<fecha>_

### Gaps (requisitos sin cobertura de tasks)
- [ ] [sdd-<spec>.md] "DEBE hacer X" — sin task correspondiente
- [ ] [sdd-<spec>.md] "DEBERÍA hacer Y" — sin task correspondiente

### Tareas huérfanas (sin requisito en spec)
- <task-file>.md — no hay requisito en specs que la justifique

### Contradicciones spec ↔ plan
- Plan propone <X>, pero spec requiere <Y>

### Violaciones constitucionales
- Plan usa <tecnología A>, CONSTITUTION dice "<principio que lo restringe>"

### Cobertura
<N> de <M> requisitos con cobertura completa (<porcentaje>%)
```

Si no hay gaps ni problemas, decirlo explícitamente: "✓ Sin gaps detectados. El plan cubre todos los requisitos del spec."

### 5. Sugerir acciones (sin ejecutarlas)

Al final del reporte, listar acciones sugeridas:
- Para cada gap: "Crear task para cubrir el requisito '<X>'"
- Para cada tarea huérfana: "Confirmar si <task> corresponde a algún requisito implícito, o eliminarla"
- Para cada contradicción: "Resolver entre spec y plan antes de implementar"

## Reglas

1. Este comando es de solo lectura — nunca modifica nada
2. Si no hay specs, informar: "No hay specs en este proyecto. Crear uno con `tool_create_spec` antes de analizar."
3. El análisis es heurístico — reportar como posible problema, no como certeza
4. Si hay múltiples specs, analizar todos juntos
