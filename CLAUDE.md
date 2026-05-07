# Global

## Vibe Workspaces

Cuando un proyecto tenga `vibe: <nombre>` en su CLAUDE.md, 
revisa siempre `~/.vibe/<nombre>/` para:
- tasks/ - tareas pendientes y en progreso
- plans/ - diseños, decisiones y execution-plan.md
- reports/ - documentación generada
- changelog/ - historial de cambios
- references/ - docs externos y snippets
- scratch/ - borradores y experimentos
- assets/ - mockups y diagramas

## Guideline: `list_tasks` en skills/commands

Toda invocación a `mcp__vibeMCP__list_tasks` debe pasar filtros explícitos. El server ya excluye `done` por default, pero declarar el `status` esperado evita responses sobredimensionados y deja la intención clara al lector.

Reglas:
- **Estado**: pasar `status` siempre. Para flujos activos (`/status`, `/vibe-run-plan`, selección de próxima task) usar lista, p.ej. `status=["pending", "in-progress"]`. Solo pasar `status="done"` o lista completa cuando el flujo lo necesite (auditorías, `/analyze`, lookup por NNN).
- **Proyecto**: pasar `project=<actual>` cuando el contexto lo conoce — nunca listar across proyectos sin razón.
- **Feature**: si la skill opera sobre una feature específica, pasar `feature=<f>`.
- **Limit**: usar `limit=1` cuando solo se necesita la primera coincidencia (selección de "next task").
- **No listar para validar duplicados antes de `tool_create_task`**: el server rechaza títulos duplicados.