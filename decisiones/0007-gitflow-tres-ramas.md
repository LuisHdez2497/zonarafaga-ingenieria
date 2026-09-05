# 0007 — GitFlow con tres ramas permanentes

**Estado:** aceptada

## Contexto

El proyecto lo desarrolla una sola persona. Por tamaño de equipo, una rama única con ramas de trabajo
efímeras sería suficiente, y el principio rector del proyecto es que la solución más simple gana.

Al mismo tiempo, el proyecto debe evidenciar gestión de entregas y sostener la trazabilidad que exige
el perfil Básico de ISO/IEC 29110: qué se verificó, dónde y antes de qué entrega.

## Opciones

1. **Solo `main`** con ramas de trabajo. Lo más simple. No hay dónde verificar una entrega candidata
   antes de que llegue a producción, ni evidencia de promoción entre ambientes.
2. **`dev` y `main`.** Punto medio; sigue sin separar «terminado» de «verificado».
3. **`dev`, `qa` y `main`**, una por ambiente.

## Decisión

Tres ramas permanentes, una por ambiente: `dev` (integración), `qa` (verificación) y `main`
(producción). Nadie escribe directo en ninguna; todo entra por Pull Request.

## Consecuencias

- **Es una excepción consciente al principio KISS**, y solo se sostiene mientras existan los tres
  ambientes. Si desaparecen, esta decisión se reemplaza por una más simple.
- La rama se vuelve el mecanismo de promoción: el artefacto se construye una vez y se promueve el
  mismo, identificado por digest. Reconstruir por ambiente sería desplegar otra cosa.
- Un hotfix que no se reintegra a `dev` reaparece en la siguiente entrega. Es la falla clásica de
  GitFlow y obliga a que la reintegración sea parte del mismo turno de trabajo.
- Trabajando solo, aprobarse el propio Pull Request es inevitable; lo que da valor no es la aprobación
  sino los gates y el enlace al work item.
