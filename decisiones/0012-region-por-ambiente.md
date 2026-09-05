# 0012 — Cada ambiente vive donde le corresponde, no todos en México

**Estado:** aceptada · **Acota la elección de región de** [0011](0011-servicios-de-azure.md)

## Contexto

El ADR 0011 fijó **México Central** para todo y eligió los servicios entre los que ahí existen. La
razón era ese registro: lleva identificadores oficiales seudonimizados y datos de menores, y
sacarlo del país convierte una obligación ordinaria de la LFPDPPP en una transferencia
internacional.

Esa razón sigue en pie, pero se aplicó a los tres ambientes por igual sin preguntarse si los tres
guardan lo mismo. **`dev` y `qa` no guardan ese registro**: guardan datos sintéticos, cargados por la
API como los cargaría una persona. La obligación que ata a producción no los alcanza.

La pregunta que abre este registro es de costo: si hay una región más barata, o una capa gratuita que
deje `dev` en cero.

## Lo que se comprobó

| Afirmación                                     | Resultado                                                                                  |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------ |
| «Hay regiones mucho más baratas»               | **No.** East US sale 9% por debajo de México Central: 12.41 contra 13.65 en B1 y en B1ms.  |
| «Hay una capa gratuita que deja `dev` en cero» | **No, para esta suscripción.** Los 12 meses gratis son solo para cuentas nuevas.           |
| «App Service F1 es gratis y sirve»             | Es gratis y **sí existe** en México Central, pero **no hace integración con red virtual**. |
| «PostgreSQL tiene un nivel siempre gratis»     | **No.** El piso es B1ms. El medidor `Compute - Free vCore` es el offer de 12 meses.        |

Dos comprobaciones que conviene no repetir:

- La suscripción es `PayAsYouGo_2014-09-01`. La condición del offer es explícita: _«12 months free
  services is available only to new customers who have not previously had an Azure account»_.
- La integración con red virtual _«requires a Basic, Standard, Premium… App Service pricing tier»_.
  F1 no la tiene, así que un `dev` en F1 no alcanza una base de datos privada: ahorrar el cómputo
  costaría la red privada entera.

Y se confirma la lección del ADR 0011: **la disponibilidad se comprueba en el registro de proveedores
de ARM, no en la lista de precios**. F1 aparece con medidor en cero en México Central, y ahí sí está
—`az appservice list-locations --sku F1 --linux-workers-enabled` lo confirma—, pero el medidor por sí
solo no lo habría probado.

## Opciones

| Opción                            | Costo mensual de los tres | Qué cuesta de verdad                                                          |
| --------------------------------- | ------------------------- | ----------------------------------------------------------------------------- |
| Todo en México Central            | USD 171.45                | Nada nuevo. Es el estado del ADR 0011.                                        |
| **`dev` y `qa` a East US**        | **USD 165.15**            | Los ambientes bajos dejan de compartir región con producción.                 |
| Los tres a East US                | USD 156.09                | El registro sale del país. **Descartada**: no es una decisión de costo.         |
| Suscripción nueva de cuenta libre | ~USD 131 durante 12 meses | Otra suscripción que administrar y un reloj de 12 meses. Aplazada, no negada. |

## Decisión

**`dev` y `qa` en East US; `prod` en México Central.** La región deja de ser una constante del diseño
y pasa a ser una variable del ambiente, que es lo que ya era en el código: el módulo `stack` la
recibe, y cada ambiente la pasa.

El ahorro es de **USD 6.30 al mes**. Es poco, y decirlo importa: **esta decisión no es la que hace
barato el proyecto**. Lo que lo hace barato es que nada esté encendido cuando nadie lo mira, y eso ya
lo permite tener la infraestructura en código. Un `dev` levantado para una demo de fin de semana
cuesta USD 3.83; el mismo `dev` olvidado encendido un mes cuesta USD 38.85.

## Consecuencias

- **Los datos sintéticos dejan de ser una costumbre y pasan a ser una obligación.** Mientras los tres
  ambientes estaban en México, volcar un respaldo de producción a `qa` era una mala práctica. Ahora
  es una transferencia internacional de datos de menores. La diferencia es de tipo, no de grado: lo
  que antes se corregía, ahora se denuncia.
- **`dev` deja de parecerse a producción en un eje.** Lo que dependa de la región —disponibilidad de
  un SKU, número de zonas, latencia desde Culiacán— ya no se verifica al probar en `dev`. Sigue
  verificándose en el plan de `prod`, que corre en el mismo pipeline; pero un defecto de región
  aparecerá más tarde que antes, y con menos margen.
- **La imagen cruza regiones al bajarse.** El registro es compartido y vive donde se cree; el arranque
  de `dev` paga esa latencia y ese tráfico de salida. A este tamaño no se nota.
- **La comparación de costos entre ambientes deja de ser directa.** `dev` y `prod` ya no cuestan
  distinto solo por tamaño: también por región. El tablero de costeo lo declara.
- **La decisión se revierte cambiando una línea por ambiente.** Es lo que la hace aceptable: si el
  primer cliente pide que todo viva en México, `region` vuelve a su valor por omisión y el plan lo
  confirma.

## Origen de los datos

Precios de la API pública de precios al menudeo de Azure, modalidad de pago por consumo, en dólares,
consultada el **02/09/2026**. Tipo de cambio FIX de Banco de México **17.0147 MXN/USD**, publicado en
el DOF el **01/09/2026**. Los precios cambian sin aviso: se re-verifican antes de comprometer un
presupuesto.
