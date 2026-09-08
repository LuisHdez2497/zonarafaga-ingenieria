# 0013 · Un solo verificador, y el pipeline lo llama

**Estado:** Aceptada

## Contexto

La secuencia de gates vivía en **dos sitios**: la regla de validación la describía y el YAML del pipeline
la ejecutaba. Nadie los sincronizaba, y al leerlos juntos habían divergido:

- El pipeline **nunca corría el formateador**, aunque la regla lo declara gate sobre todo el árbol.
- **Nunca corría las pruebas de integración contra Postgres**, que son las únicas que verifican el
  aislamiento entre negocios de verdad.
- Instalaba el analizador estático **con `pip` y sin fijar versión**, cuando la regla manda la imagen de
  contenedor precisamente para que dé el mismo resultado en cualquier máquina.
- El análisis de la infraestructura tampoco fijaba versión.

**Nadie lo había notado porque las dos salían verdes.** Una lista de gates que solo alguien mantiene
sincronizada no es una garantía: es una intención con dos copias.

El mismo problema, resuelto en el repositorio hermano que ya tiene el producto en producción, destapó
**tres defectos más** al obligar a que local y CI corrieran el mismo código. Los tres eran la misma
familia: un verde que se apoyaba en un artefacto que solo existía en la máquina de trabajo.

## Opciones

| Opción                                                         | Costo real                                                                                                           |
| -------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Sincronizar las dos listas a mano y revisarlo en cada cambio   | Es lo que ya se hacía. Divergieron sin que nada lo dijera, y el fallo es silencioso por construcción.                |
| Un guardia de deriva que compare el YAML con la regla          | Compara texto contra texto: sabría decir que difieren, no cuál de los dos es correcto, y hay que mantenerlo también. |
| **Un script que sea la secuencia, y que el pipeline llame**    | Un archivo más. La paridad deja de depender de nadie: es el mismo código en los dos lados.                           |
| Que el pipeline sea la única fuente y en local se copie a mano | Invierte el problema: quien trabaja no puede correr los gates sin reproducir el YAML, así que no los corre.          |

## Decisión

**`tools/verificar.mjs` es la fuente única de la secuencia de gates, y el pipeline lo invoca en vez de
repetirlo.**

- **Se descubre a sí mismo** en vez de llevar el repositorio escrito: lee el paquete del API y sus
  librerías del workspace, la app de Flutter del espacio de trabajo de pub, y si existen `infra/` y un
  arnés de navegador. Por eso **el mismo archivo sirve sin cambios en los repositorios hermanos**.
- **Apaga las fases que no aplican** leyendo el diff, y lo que cambia _cómo se verifica_ —el pipeline, el
  toolchain o el propio verificador— **enciende todo**, porque cambia la vara con la que se mide el resto.
- **Se detiene en la primera fase roja**, y el resumen distingue tres estados: verde, no aplica y
  **omitida por bandera**. Lo tercero existe porque «no se pudo correr» y «pasó» se ven igual en un
  reporte mal escrito.
- **Las versiones de las herramientas se fijan** en `.toolchain`, incluidas las del analizador estático y
  el de infraestructura.
- **El análisis estático se acota a los archivos que cambiaron.** Medido: seis segundos sobre tres
  archivos contra más de quince minutos sin terminar sobre el árbol completo. Un secreto solo puede
  entrar por un cambio, así que mirar el cambio basta — y un gate que tarda quince minutos es un gate que
  se salta.

Las etapas de calidad, seguridad e infraestructura **se colapsan en una sola**. El nivel gratuito da un
solo trabajo en paralelo, así que las etapas corren en serie y cada una paga su propio arranque de agente;
cuatro etapas lo pagarían cuatro veces. La etapa de empaquetado se queda como estaba, tras su interruptor
de compilación.

## Consecuencias

- **Un gate nuevo se añade en un solo sitio.** Y aparece a la vez en la máquina y en el pipeline.
- **La legibilidad no se pierde:** cada fase se emite como sección plegable del log, con su nombre y su
  tiempo, y la roja se reporta como error de la corrida.
- **El verificador ve el trabajo sin commitear**, porque compara la base contra el árbol de trabajo y
  cuenta los archivos nuevos sin añadir. Uno que solo mirara lo commiteado sería inútil justo cuando se
  usa.
- **Este pipeline todavía no ha corrido.** El diseño se probó de punta a punta en el repositorio hermano
  —doce fases verdes en un agente limpio— y aquí se espera que la primera corrida encuentre algo: la
  imagen de base local es propia y un agente no puede bajarla, así que la paridad de la fase de
  integración no es exacta.
- **La regla de validación deja de listar comandos** y pasa a describir el verificador. Dos documentos que
  decían lo mismo pasan a ser uno que manda y otro que lo explica.
