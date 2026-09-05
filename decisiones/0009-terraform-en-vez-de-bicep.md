# 0009 — Terraform en lugar de Bicep

**Estado:** aceptada · **Reemplaza la elección de herramienta de** [0008](0008-infraestructura-declarada.md)

## Contexto

[0008](0008-infraestructura-declarada.md) decidió declarar la infraestructura en código y validarla sin
provisionarla, y eligió Bicep por coherencia con Azure. Esa decisión no consideró un requisito que sí
existe: el proyecto es además **evidencia técnica** de competencia en infraestructura como código, y la
herramienta elegida es parte de lo que se evalúa.

## Opciones

1. **Bicep.** Nativo de Azure, sin estado que administrar, `what-if` integrado y sintaxis breve. Solo
   sirve para Azure y fuera de ese ecosistema casi no se pide.
2. **Terraform.** Funciona con cualquier proveedor, es el estándar de facto del mercado, y su modelo de
   estado y de plan es el que se pregunta en entrevistas. A cambio hay que administrar el estado y el
   bloqueo, y el proveedor de Azure va por detrás de las novedades del portal.
3. **Ambas.** Duplica el trabajo sin duplicar el aprendizaje.

## Decisión

**Terraform**, con el proveedor de Azure.

El desempate no es técnico —para desplegar en Azure, Bicep es igual de bueno y más simple— sino de
propósito: Terraform enseña conceptos que Bicep esconde (estado, dependencias explícitas, `plan` contra
`apply`, módulos reutilizables, importación de recursos existentes), y esos conceptos son transferibles
a cualquier nube.

## Consecuencias

- **Hay que resolver el estado remoto.** Sin él, el estado vive en un archivo local y el proyecto deja
  de ser reproducible. Es la primera decisión de diseño y no se puede posponer.
- El estado de Terraform **contiene secretos en claro**: cadenas de conexión, llaves. Guardarlo exige
  cifrado en reposo y acceso restringido, y eso es parte del diseño, no un detalle.
- `terraform plan` cumple el mismo papel que el `what-if` de Bicep para [0008](0008-infraestructura-declarada.md):
  se valida sin aplicar.
- Se pierde la ventaja de Bicep de no tener estado. Es un costo real y consciente.
- Los módulos se escriben pensando en que el proveedor pueda cambiar; no se abusa de recursos
  específicos de Azure donde exista una abstracción razonable.
