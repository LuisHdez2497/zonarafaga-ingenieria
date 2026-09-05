# 0008 — Infraestructura declarada y validada, sin provisionar

**Estado:** aceptada

## Contexto

El producto no tiene clientes todavía. Un ambiente vivo —base de datos, caché, cómputo y
almacenamiento— cuesta todos los meses, aunque nadie lo use. Al mismo tiempo, sin infraestructura no
hay forma de evidenciar la cadena completa de entrega ni de saber si el despliegue funcionaría.

## Opciones

1. **Nada de infraestructura.** Costo cero y ninguna evidencia; el día que haya cliente, todo el
   trabajo de despliegue está por empezar y sin validar.
2. **Un ambiente vivo.** Evidencia contundente y costo mensual continuo, más el tiempo de operarlo.
3. **Declarada y validada, no aplicada.** Las plantillas compilan, el plan de cambios se revisa en
   cada entrega, y no hay recursos corriendo.

## Decisión

La infraestructura se declara en código, y cada entrega compila las plantillas y produce el plan de
cambios del ambiente destino. Ningún recurso se provisiona.

## Consecuencias

- Costo cero y evidencia real: el plan de cambios es verificable y se revisa como cualquier otro
  artefacto de la entrega.
- **Un plan validado no es un despliegue probado.** Fallos de permisos, cuotas o dependencias entre
  recursos solo aparecen al aplicar. Es una limitación conocida y hay que declararla como tal, no
  presentar el plan como si fuera un despliegue exitoso.
- El día que haya cliente, encender un ambiente es aplicar el plan, no escribirlo.
- Obliga a que el código no se acople a un proveedor: la configuración va por `env` y los servicios se
  hablan por sus interfaces.
