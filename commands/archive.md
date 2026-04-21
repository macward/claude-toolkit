# Archive Command

Cierra un feature completado: documenta las decisiones tomadas en `DECISIONS.md` y archiva las tasks. El objetivo es que el contexto del feature quede registrado para sesiones futuras.

## Setup

Leer `vibe: <project>` del CLAUDE.md del proyecto activo.

## Proceso

### 1. Identificar el feature a archivar

Mostrar las tasks done recientes:

```
mcp__vibeMCP__list_tasks(project=<project>, status="done")
```

Preguntar al usuario:
- "¿Qué feature querés archivar?"
- "¿Cuáles de estas tasks pertenecen a ese feature?"

### 2. Leer contexto del feature

Para cada task del feature, leer su contenido:

```
mcp__vibeMCP__read_doc(project=<project>, folder="tasks", filename=<task_file>)
```

Si hay un spec relacionado, leerlo también:

```
mcp__vibeMCP__list_specs(project=<project>)
mcp__vibeMCP__read_doc(project=<project>, folder="specs", filename=<spec_file>)
```

### 3. Recoger el relato de decisiones

Preguntar al usuario:

1. **¿Qué se implementó?** — resumen de lo que quedó en producción
2. **¿Qué se descartó y por qué?** — alternativas evaluadas y razón por la que no se eligieron (este es el contexto más valioso)
3. **¿Qué aprendizajes quedan?** — cosas que cambiarías, problemas encontrados, insights

### 4. Escribir entrada en DECISIONS.md

Construir la entrada y guardarla. `tool_save_research` append-ea automáticamente si `DECISIONS.md` ya existe:

```
mcp__vibeMCP__tool_save_research(
  project=<project>,
  topic="DECISIONS",
  content=<entrada_formateada>
)
```

### 5. Actualizar changelog (opcional)

Preguntar si el feature merece entrada en el changelog. Si sí:

```
mcp__vibeMCP__tool_log_change(
  project=<project>,
  title=<nombre_del_feature>,
  changes=[<lista_de_cambios_notables>],
  task=<task_file_principal>
)
```

### 6. Archivar las tasks

Para cada task done del feature:

```
mcp__vibeMCP__tool_archive_task(project=<project>, task_file=<task_file>)
```

Confirmar con el usuario antes de archivar si hay más de 3 tasks.

## Formato de entrada en DECISIONS.md

```markdown
---

## <YYYY-MM-DD> — <Nombre del Feature>

### Implementado
- <qué quedó en producción>

### Descartado
- **<Alternativa A>**: <por qué se descartó>
- **<Alternativa B>**: <por qué se descartó>

### Aprendizajes
- <aprendizaje o insight clave>
```

## Reglas

1. **Siempre documentar lo descartado** — es el contexto más difícil de recuperar en el futuro
2. La entrada en DECISIONS.md no debe superar 20 líneas — ser conciso
3. Solo archivar tasks en estado `done` — preguntar al usuario si hay tasks `in-progress` o `blocked`
4. Si no hay nada que archivar (ninguna task done), informarlo y salir
5. El changelog es opcional — solo sugerirlo si el feature tiene impacto externo o rompe compatibilidad
