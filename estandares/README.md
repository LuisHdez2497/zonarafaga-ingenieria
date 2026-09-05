# Estándares de ingeniería

> **Qué es.** Un **resumen** de los estándares que gobiernan el desarrollo de ZonaRafaga. El
> cuerpo normativo completo es propiedad de su autor y no se publica; lo que sigue describe
> **qué se exige y por qué**, no el texto de cada regla.

Son 28 estándares versionados en el repositorio privado. Cada uno es **fuente única** de su tema:
ningún estándar repite lo que otro ya define, y una regla que cambia se reescribe en presente en
lugar de acumular notas de historia.

## Principios que atraviesan todo

**KISS gana ante cualquier conflicto.** Cuando dos estándares se contradicen, la solución más simple
que funcione es la correcta.

**El código no lleva comentarios.** Ni de línea, ni de bloque, ni docstrings, ni `TODO`. Los nombres
explican; la única excepción son las anotaciones que el framework exige. Al editar un archivo, los
comentarios de las líneas que se tocan se eliminan.

**Tipado estricto.** `any`, `@ts-ignore` y `@ts-expect-error` están prohibidos, incluidas las pruebas.

**Cero valores sueltos.** URLs, identificadores, secretos y números mágicos viven en constantes,
variables de entorno o configuración.

## Arquitectura

Clean Architecture **modular por dominio**, con cuatro capas y la misma forma en los tres stacks
(API, consola web, app móvil). La estructura de carpetas nombra el negocio, no el framework.

| Capa | Responsabilidad | No puede |
|---|---|---|
| `domain` | Entidades y contratos de repositorio | Depender de nadie |
| `application` | Casos de uso, orquestación, validación | Tocar HTTP ni UI |
| `infrastructure` | Implementar los contratos; hablar con la base o la API | Contener reglas de dominio |
| `presentation` | Exponer endpoints o renderizar UI | Llamar a la API ni tener lógica de dominio |

La regla de dependencias apunta siempre hacia adentro, y **no es una convención de palabra**: se hace
cumplir con ESLint (`import/no-restricted-paths`) entre capas y con las fronteras de Nx entre
paquetes. Un `domain` que importe `application` no compila.

Patrones obligatorios: **repositorio** (interfaz en `domain`, implementación en `infrastructure`) e
**inyección de dependencias**.

## Módulos componibles

Cada módulo declara en un manifiesto su identidad, sus dependencias, los permisos que define y los
límites numéricos que hace cumplir. Eso permite **encender y apagar el producto por instalación** sin
tocar código, y hace que el catálogo de permisos se **genere** desde los manifiestos en lugar de
mantenerse a mano.

Las dependencias se clasifican en **duras** (el módulo no funciona sin el otro) y **blandas** (se
integra si el otro está activo, y opera igual si no). El principio es minimizar las duras: cuantas
menos haya, más combinaciones de venta son válidas. Una dependencia blanda nunca importa el módulo
del otro; consulta un puerto de activación con default seguro y degrada con elegancia.

Un módulo que un producto derivado no necesita **se apaga, no se borra**.

## Puertas de validación

Ninguna tarea está terminada hasta que **todos** los gates pasan con **cero errores y cero
advertencias**. Corren en local antes de subir y en CI sobre lo afectado.

| Puerta | Qué exige |
|---|---|
| Lint | ESLint con `--max-warnings 0`, incluidas las reglas de capas |
| Tipos | Compilación sin emitir, sin `any` |
| Pruebas | Unitarias con umbral de cobertura que **nunca baja** |
| Build | Compilación limpia |
| SAST | Semgrep sobre TypeScript, JavaScript y secretos |
| Dependencias | Auditoría sin vulnerabilidades altas ni críticas |
| Infraestructura | Validación de plantillas, análisis estático y plan de cambios |

## Pruebas

**Una prueba que no puede fallar no es una prueba.** Antes de cerrar, se deshace el arreglo y se
comprueba que la prueba se pone en rojo; si pasa igual, no cubría el defecto.

Otras exigencias que la práctica hizo necesarias:

- Las fixtures de **datos** se construyen completas y anotadas con su tipo, para que el compilador
  haga cumplir la completitud. Los dobles de **colaboradores** sí pueden ser parciales.
- Las afirmaciones sobre un objeto completo usan comparación estricta, porque la comparación laxa
  ignora las propiedades en `undefined` y deja pasar un campo que el servidor dejó de enviar.
- Nada enfocado ni saltado a mano: apaga el resto del archivo en silencio y el gate sale en verde con
  una fracción de la suite corriendo. El único salto permitido es el gobernado por entorno.

## Seguridad

Las invariantes que no se relajan:

- **Aislamiento multi-tenant por Row Level Security**, con la aplicación conectada a un rol sin
  privilegio de omisión. El contexto se fija por transacción; las políticas son *fail-closed*: sin
  contexto, cero filas.
- **Rotación de tokens de refresco con detección de reúso**; solo se almacena su hash.
- **Autorización en el servidor.** El guard del cliente es comodidad; la autoridad es la base.
- Cero secretos en el repositorio o en la imagen: entran por configuración del entorno.
- No se registran contraseñas ni tokens; la auditoría sanitiza los datos sensibles.

## Interfaz

Base normativa **WCAG 2.2 AA**, obligatoria. Todo control sale de una escala única de tamaños
declarada como tokens, y los estados de interacción se definen una vez como utilidades semánticas:
dos controles con el mismo rol se sienten idénticos porque son el mismo código.

El microcopy es **cero-técnico**: la jerga de arquitectura no aparece nunca en pantalla. Un error
dice qué pasó y cómo se arregla, con las palabras del negocio.

La verificación no se fía del juicio: un barrido automatizado abre cada pantalla en cuatro anchos,
dos idiomas y dos temas, y mide desbordes, contraste, tamaño de objetivo y duplicación de elementos.

## Proceso y trazabilidad

El ciclo de vida sigue el **perfil Básico de ISO/IEC 29110** — implementado, no certificado. El
estándar no añade documentos: nombra los que el trabajo ya produce.

- **GitFlow con tres ramas permanentes**, porque la rama es el mecanismo de promoción entre
  ambientes. Nadie escribe directo en una rama permanente, ni trabajando solo.
- **Todo cambio entra por Pull Request** ligado a su work item. Un PR sin work item rompe la
  trazabilidad y no se mezcla.
- **Toda decisión estructural deja registro** antes de implementarse, con contexto, alternativas
  evaluadas y consecuencias.
- **Las horas reales se capturan al cerrar la tarea.** Sin ellas no hay control, solo un pronóstico.
- **Una desviación no se corrige en silencio**: se anota con su causa.

Idiomas: el código, las ramas y los commits en inglés; los Pull Requests, las revisiones y los work
items en español. *El «qué hace el código» va en inglés; el «qué le contamos al equipo», en español.*

## Investigar antes de suponer

Nada se afirma de memoria ni por parecido. Antes de escribir código sobre un hecho se comprueba: se
lee el archivo, se corre el comando, se consulta el esquema.

Una suposición correcta y una comprobación se ven idénticas en el resultado; la diferencia aparece
cuando la suposición es falsa, y para entonces ya hay código construido encima. Cuando algo no se
puede comprobar, se marca explícitamente como no verificado en lugar de rellenarlo.

---

*El texto normativo completo es propiedad de su autor. Este resumen se publica como evidencia del
método, no como material reutilizable — ver [LICENSE](../LICENSE).*
