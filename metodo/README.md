# Desarrollo dirigido por especificación, asistido por IA

> **Qué es.** Cómo se construye ZonaRafaga: **la especificación es el artefacto de trabajo y la
> inteligencia artificial ejecuta un procedimiento escrito**, no improvisa el código.

La diferencia con «usar un asistente de IA» es la dirección del control. Pedirle código a un modelo y
revisarlo después deja la decisión en la generación, y el revisor descubre el enfoque cuando ya está
construido. Aquí el orden es el inverso: **primero se escribe qué se quiere y cómo se va a lograr, y
el procedimiento que ejecuta la IA está versionado en el repositorio** junto al código.

## Las tres capas

| Capa | Qué fija | Dónde vive |
|---|---|---|
| **Requisito** | *Qué* hay que construir | Work item, con siete bloques y criterios verificables |
| **Especificación** | *Cómo* se va a construir | Documento por unidad, solo cuando el cómo no es obvio |
| **Procedimiento** | *Con qué pasos* se construye | Skills versionadas, con sus herramientas acotadas |

**La especificación nunca repite el requisito.** El work item dice qué; la especificación dice cómo.
Duplicar el qué produce dos documentos que se contradicen en la primera corrección.

## El requisito: nada ambiguo llega al código

Una unidad no arranca sin siete bloques resueltos: historia en lenguaje de negocio, alcance —y sobre
todo **qué no entra**—, reglas de negocio, validaciones campo por campo con el mensaje que ve la
persona, **efectos en cascada**, permisos y estados de vacío, carga y error.

Los criterios de aceptación van en **Dado / Cuando / Entonces**, verificables por separado y medibles:
«responde en menos de 2 segundos», no «responde rápido». Se escriben **antes** de construir. Entre
tres y seis por historia: si pasan de seis, la historia es demasiado grande y se parte.

El bloque que más se olvida es el de **efectos en cascada**, y es la primera fuente de defectos en
producción. Toda unidad que cree o relacione datos declara qué pasa al crear, editar, desactivar y
borrar. Desactivar antes que borrar; nunca se borra en cascada un dato con historia.

## La especificación: el filtro que evita el proceso ceremonial

Escribir un documento de diseño para cada cambio es burocracia; no escribir ninguno es reconstruir dos
veces. La salida es un **filtro de tres preguntas**, contestadas antes de escribir nada:

- **A** — ¿se puede describir el cambio en una frase?
- **B** — ¿se conoce el código afectado y el enfoque no está en duda?
- **C** — ¿es reversible sin migración de datos?

| Situación | Ruta | Qué se escribe |
|---|---|---|
| A=No · B=Sí · C=Sí | **Corta** | El qué y el cómo juntos, con nombres de archivo y función |
| B=No | **Investigar primero** | Nada todavía: se diagnostica con evidencia medida y se para |
| C=No | **Completa** | El diseño entero, con alternativas, migración y reversión |
| A=Sí · B=Sí · C=Sí | **Directa** | Nada. Se dice por qué y se va al código |

**La ruta se declara en la primera línea del documento**, con su razón en media línea, para que quien
revise pueda discutir la decisión en vez de descubrirla al final.

Algunos cambios van **siempre** por la ruta completa, por pequeños que parezcan: los que tocan datos
personales —con más razón de menores—, los que tocan el aislamiento entre clientes, y los que tocan la
captura sin conexión. Comparten que **el error no se nota al construir: se nota en producción y ya no
se puede deshacer**.

Cuando aparece una decisión estructural, no se resuelve dentro de la especificación: se redacta su
propio registro de decisión, con alternativas evaluadas y consecuencias.

## El procedimiento: la IA ejecuta lo que está escrito

El ciclo está descompuesto en procedimientos versionados. Cada uno declara qué hace, cuándo se salta y
**qué herramientas tiene permitido usar** — un procedimiento de diseño no puede escribir código, y uno
de auditoría no puede editar.

| Procedimiento | Qué hace | Cuándo se salta |
|---|---|---|
| Reconstruir estado | Lee repositorio y tablero, y dice qué sigue | Nunca al abrir sesión |
| Especificar | Decide la ruta y, si toca, escribe el cómo | Nunca: puede resolver «directa» en una línea |
| Investigar | Rastrea un defecto hasta su causa, con evidencia medida | Si el enfoque no está en duda |
| Construir | Implementa la unidad y corre la batería completa | Nunca; es el trabajo |
| Revisar | Pasada de calidad al diff antes de subir | Nunca antes de un Pull Request |
| Entregar | Rama, commits, Pull Request ligado al work item | Nunca |
| Promover | Verifica criterios uno por uno y levanta el acta | Solo cuando hay entrega candidata |
| Auditar seguridad | Verifica las invariantes contra el diff | Nunca en cambios de identidad o datos |

Que el procedimiento esté escrito y versionado tiene una consecuencia que importa más que la
automatización: **una corrección al proceso se hace una vez y aplica a todo el trabajo siguiente**.
Cuando una trampa cuesta una sesión, se anota en el procedimiento y no vuelve a costarla.

## Los guardrails: por qué esto no es «confiar en el modelo»

La velocidad de generación no sirve de nada si el resultado hay que verificarlo a mano. Lo que hace
utilizable el ciclo es que **la verificación también está automatizada y es bloqueante**:

- **Puertas de validación** en local y en integración continua, con cero advertencias toleradas.
- **Fronteras de arquitectura** que hace cumplir el linter: una capa que importe lo que no debe, no
  compila. La regla no depende de que alguien la recuerde.
- **Ganchos locales** que bloquean el commit y el push directos a una rama permanente.
- **Políticas en el repositorio remoto**: revisión obligatoria, work item ligado, comentarios resueltos
  y mezcla sin aplastar.
- **Pruebas que se comprueban a sí mismas**: antes de cerrar se deshace el arreglo y se verifica que la
  prueba se pone en rojo. Una prueba que no puede fallar no es una prueba.
- **Investigar antes de suponer**: nada se afirma de memoria. Un hallazgo se reporta con el archivo y
  la línea, o con el comando y su salida.

## Qué gana el proceso formal

El ciclo de vida sigue el perfil Básico de **ISO/IEC 29110** — implementado, no certificado. Ese
estándar exige artefactos: enunciado de trabajo, plan, registro de avance, especificación de
requisitos, diseño, trazabilidad, informe de pruebas, acta de verificación y registro de aceptación.

Producirlos a mano es la burocracia que hace que los equipos pequeños abandonen el proceso formal. El
punto de este método es que **casi todos salen del trabajo mismo**: el requisito es el work item, el
diseño es la especificación, el informe de pruebas es la salida de las puertas, la configuración es el
repositorio con sus etiquetas, y la aceptación es el Pull Request aprobado.

Lo que el estándar sí obliga a añadir son tres piezas, y son justo las que dan trazabilidad: el
**registro de decisiones**, el **registro de trazabilidad** que liga requisito con rama, Pull Request,
pruebas y versión, y el **acta de verificación** por entrega.

**La IA absorbe el costo de redacción de esos artefactos, no el criterio.** Redacta el borrador desde
lo que ya ocurrió en el repositorio y en el tablero; decidir qué es correcto sigue siendo humano, y
por eso cada artefacto pasa por una revisión que puede rechazarlo.

## Lo que este método no resuelve

- **El juicio de producto.** Si una regla de negocio es la correcta, ninguna puerta lo mide.
- **El requisito mal escrito.** Un work item ambiguo produce una implementación ambigua, más rápido.
- **La decisión estructural.** Se registra y se defiende con números; no se delega.

---

*Ver también: [decisiones/](../decisiones/) para las decisiones registradas y
[estandares/](../estandares/) para el resumen de los estándares que este ciclo hace cumplir.*
