# claude-toolkit

Repositorio central para todo lo relacionado con Claude Code: skills, reglas, prompts y notas de investigación.

## Estructura

```
claude-toolkit/
├── skills/       # SKILL.md organizados por tipo (pptx, docx, pdf, etc.)
├── commands/     # Comandos slash para Claude Code
├── agents/       # Subagentes especializados
├── rules/        # Reglas y CLAUDE.md por lenguaje/plataforma
│   ├── swift/
│   └── python/
├── prompts/      # Prompts reutilizables
└── research/     # Notas sobre agentes, Claude Code, workflows
```

## Uso

Las skills se pueden copiar directamente a `.claude/` o `.skills/` en cualquier proyecto.
Las reglas se usan como base para los archivos `CLAUDE.md` de cada repo.

Correr `./install.sh` instala skills, commands y agents en `~/.claude/`.

## Spec Workflow

Este toolkit incluye un flujo de spec-driven development integrado con vibeMCP. Ver [SPEC-WORKFLOW.md](SPEC-WORKFLOW.md) para la guía completa con ejemplos y casos de uso.

Flujo mínimo:

```
/vibe-requirements → /vibe-spec → /vibe-task-breakdown → /vibe-run-plan
```
