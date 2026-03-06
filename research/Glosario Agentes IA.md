# Glosario: Arquitectura de Agentes de IA

---

## Conceptos Fundamentales

### Agent (Agente)
Un LLM con un loop de ejecución. En vez de responder una sola vez, el modelo decide qué herramienta usar, observa el resultado, y decide el siguiente paso. Repite hasta considerar la tarea completa.

### Agent Loop (Loop de Ejecución)
El ciclo central de un agente: recibir input → razonar → actuar (tool call) → observar resultado → razonar de nuevo → repetir o terminar. Es lo que diferencia un agente de un simple prompt-response.

### Orchestrator (Orquestador)
El proceso o componente que gestiona el ciclo de vida de los agentes: los crea, les asigna tareas, evalúa sus resultados, decide cuándo parar, reintentar o escalar. Es el "director de orquesta" del sistema.

### Tool / Function Calling
Capacidad del LLM para invocar funciones externas (APIs, filesystem, bases de datos) con parámetros estructurados. El agente decide cuál tool usar y con qué argumentos basándose en el contexto.

### System Prompt
El prompt inicial que define la personalidad, capacidades, restricciones y contexto del agente. Es el equivalente a un "job description" que determina cómo se comporta el agente.

---

## Patrones Arquitectónicos

### ReAct (Reasoning + Acting)
Patrón donde el agente alterna entre razonamiento ("necesito buscar X") y acción (ejecutar una tool). Es el patrón más común en agentes como Claude Code.

### Plan-and-Execute
El agente primero genera un plan completo (lista de pasos) y luego ejecuta cada paso secuencialmente, revisando el plan si algo falla. Más estructurado que ReAct pero menos adaptable en tiempo real.

### Multi-Agent / Swarm
Múltiples agentes trabajando en paralelo o secuencialmente sobre un problema. Cada uno tiene su propio system prompt, tools y especialización. Pueden colaborar, competir o ambos.

### Hierarchical Process
Un agente "manager" distribuye tareas a agentes "worker", revisa resultados y coordina. Emula la estructura jerárquica de un equipo humano.

### Sequential Process
Los agentes se ejecutan en orden: el output del Agente 1 es el input del Agente 2, y así sucesivamente. Predecible y fácil de debuggear.

---

## Memoria de Agentes

### Statelessness (Sin Estado)
Propiedad fundamental de los LLMs: cada llamada es independiente, el modelo no "recuerda" nada entre invocaciones. Toda la memoria es simulada mediante inyección de contexto.

### Memoria Episódica
Log estructurado de cada ejecución del agente: qué se le pidió, qué decidió, qué pasó, y qué se aprendió. Almacenada típicamente en SQLite o bases relacionales. Es el "diario" del agente.

### Memoria Semántica
Experiencias pasadas almacenadas como embeddings en un vector DB (ChromaDB, Qdrant, Pinecone). Permite buscar por similaridad: "¿cuándo enfrenté algo parecido a esto?". No requiere categorización manual.

### Memoria Estratégica
Reglas destiladas de muchos episodios. Se refinan periódicamente usando un LLM que analiza patrones en las lecciones acumuladas. Se inyectan directamente en el system prompt como "reglas aprendidas".

### Lesson Extraction
Proceso de usar un LLM para analizar una ejecución completada y generar un resumen conciso de qué funcionó y qué no. Comprime datos crudos en conocimiento reutilizable.

### Context Window
La cantidad limitada de tokens que un LLM puede procesar en una sola llamada. Gestionar el context window es crítico en agentes que iteran muchas veces, ya que el contexto crece rápido.

### Sliding Window
Estrategia para manejar el context window: mantener solo los N mensajes más recientes, descartando o resumiendo los anteriores. Previene que el agente se quede sin espacio de contexto.

---

## Evolución y Aprendizaje

### Fitness Function (Función de Aptitud)
La métrica que determina qué tan bien está funcionando un agente. Debe ser medible y automática. Ejemplos: P&L en trading, tasa de tests pasados en código, tiempo de resolución en incidentes.

### Scoring Automático
Capacidad de evaluar el rendimiento de un agente sin intervención humana. Es el requisito fundamental para que el loop de aprendizaje funcione a escala.

### Evolución / Genetic Algorithm (aplicado a agentes)
Patrón donde una población de agentes compite, los menos aptos "mueren", y nuevos agentes se crean heredando estrategias de los mejores + lecciones de los fracasos + mutaciones propias.

### Post-Mortem Automático
Análisis generado por LLM cuando un agente falla o "muere". Extrae patrones de fracaso y genera recomendaciones que se heredan al siguiente agente.

### Mutación
Variaciones introducidas deliberadamente al crear nuevos agentes para explorar estrategias no probadas. Previene que el sistema converja en un óptimo local.

### Replay Buffer
Colección de experiencias pasadas que el agente puede "reproducir" para aprender de ellas. Concepto tomado de reinforcement learning.

### Rule Distillation (Destilación de Reglas)
Proceso periódico donde un LLM analiza múltiples lecciones episódicas y las consolida en reglas concisas y accionables. Comprime N experiencias en un set manejable de principios.

---

## Consenso y Coordinación

### Confidence-Weighted Voting
Mecanismo de decisión donde el voto de cada agente se pondera según su track record histórico. Un agente con mejor accuracy en situaciones similares tiene más peso.

### Debate Rounds
Rondas donde agentes con opiniones divergentes presentan argumentos. Permite reconsideración antes de tomar una decisión final.

### Veto Power
Capacidad de un agente especializado (típicamente el risk manager) de bloquear una decisión independientemente del consenso. Mecanismo de seguridad.

### Context Sharing
Mecanismo por el cual los agentes comparten información entre sí. Puede ser explícito (pasar output como input) o implícito (memoria compartida).

### Delegation
Capacidad de un agente de asignar subtareas a otros agentes. Requiere que el agente delegador entienda las capacidades de los demás.

---

## Infraestructura

### MCP (Model Context Protocol)
Protocolo que desacopla las capacidades (tools) de un agente de su implementación. Un MCP server expone funcionalidades que cualquier cliente compatible puede usar sin conocer los detalles internos.

### Vector Database
Base de datos optimizada para almacenar y buscar embeddings (representaciones numéricas de texto). Permite búsqueda por similaridad semántica. Ejemplos: ChromaDB, Qdrant, Pinecone.

### Embeddings
Representaciones numéricas (vectores) de texto generadas por modelos especializados. Textos semánticamente similares producen vectores cercanos en el espacio, permitiendo búsqueda por similaridad.

### RAG (Retrieval-Augmented Generation)
Patrón donde antes de generar una respuesta, el agente recupera información relevante de una base de conocimiento externa y la inyecta en el prompt. Combina retrieval con generación.

### Human-in-the-Loop
Patrón donde un humano interviene en ciertos puntos del pipeline del agente, típicamente para validación, scoring, o decisiones críticas. Más lento pero más confiable que full autonomía.

### Rails / Guardrails
Validaciones que se ejecutan entre cada paso del agente para verificar que no se desvió del objetivo. Pueden ser checks programáticos, otro LLM evaluando, o reglas hardcodeadas.

---

## Frameworks

### CrewAI
Framework Python para orquestación multi-agente basado en roles. Cada agente tiene rol, goal y backstory. Soporta procesos secuenciales y jerárquicos. Arquitectura de Crews (autonomía) + Flows (control preciso).

### LangGraph
Modela agentes como grafos de estados. Los nodos son funciones y las aristas definen el flujo de ejecución. Bueno para workflows complejos con branching y loops.

### AutoGen (Microsoft)
Framework orientado a conversaciones entre agentes. Bueno para escenarios de debate, brainstorming y revisión donde agentes "discuten" para llegar a un resultado.

---

## Anti-Patrones y Riesgos

### Overfitting a Memoria
Cuando el agente "aprende" patrones que fueron coincidencia (ruido), no señal. Se mitiga con suficiente volumen de datos y validación cruzada.

### LLM Hallucination en Datos Numéricos
Los LLMs no son confiables leyendo números precisos de gráficos o haciendo cálculos exactos. Requiere tools especializadas para estos casos.

### Context Overflow
Cuando el historial de ejecución del agente supera el context window. Se mitiga con resumen de intermedios, truncamiento, o sliding window.

### Token Cost Explosion
Correr múltiples agentes con múltiples LLM calls por decisión escala costos rápidamente. Un pipeline de 5 agentes puede costar 5-10x más que uno solo.

### Regime Change / Drift
El entorno cambia y lo que el agente "aprendió" deja de ser válido. Se mitiga con decay en la memoria (dar menos peso a experiencias antiguas) y re-evaluación periódica de reglas.
