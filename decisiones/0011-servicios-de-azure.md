# 0011 — Qué servicio de Azure sostiene cada pieza

**Estado:** aceptada · **Corrige la elección de servicios de** [0008](0008-infraestructura-declarada.md)

## Contexto

La infraestructura declaraba **Azure Container Apps** para la API y **Azure Cache for Redis Basic**
para la caché, en la región **México Central**. Ninguna de las dos elecciones se había comprobado
contra lo que Azure realmente ofrece en esa región, porque el `terraform plan` del pipeline está
condicionado a que exista estado remoto y nunca corrió.

Al comprobarlo aparecieron dos defectos:

- **Container Apps no se ofrece en México Central.** El registro de ARM lista 43 regiones para
  `Microsoft.App/managedEnvironments` y ninguna es de México. Existen medidores de precio para la
  región, que es lo que hace engañosa la comprobación por precios: un medidor puede existir antes que
  el servicio. La plantilla no se podía aplicar.
- **El nivel Basic de la caché no tiene réplica ni SLA.** Producción quedaba con una caché de un solo
  nodo cuyo reinicio vacía tanto la caché como las colas de trabajo.

## La restricción que manda: los datos se quedan en México

El activo del producto es un **registro nacional de personas**, con identificadores oficiales
seudonimizados y con menores de edad. Sacar esos datos del país convierte una obligación ordinaria
de la LFPDPPP en una transferencia internacional que hay que justificar y consentir.

Eso convierte «qué región» en la primera decisión, no en la última: **la región se fija en México
Central y los servicios se eligen entre los que ahí existen**, no al revés. La alternativa —quedarse
con Container Apps y mover todo a Texas— se descarta por esto, no por precio.

## Decisión

| Pieza                    | Servicio                                               | Por qué ese y no otro                                                                            |
| ------------------------ | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| API                      | **App Service Linux**, contenedor por digest           | Es el cómputo de contenedores que sí existe en la región, y sale más barato para carga sostenida |
| Consola y superficie web | **Apps extra en el mismo plan**                        | El cómputo se paga por plan, no por app: la segunda app cuesta cero                              |
| Base de datos            | PostgreSQL Flexible, nivel ampliable                   | Ya era la elección correcta; se arranca en el escalón chico                                      |
| Caché y colas            | **Azure Cache for Redis Standard**, solo en producción | Standard trae réplica y SLA; Basic no. Los otros ambientes operan sin caché gestionada           |
| Imágenes                 | Container Registry Basic                               | Una imagen, promovida por digest                                                                 |
| Secretos                 | Key Vault, leído con identidad administrada            | Sin credencial propia de la aplicación                                                           |
| Observabilidad           | Log Analytics + Application Insights                   | La app manda sus trazas por cadena de conexión                                                   |

Sobre el cómputo, la comparación que decide: **una réplica de 0.5 vCPU y 1 GiB siempre viva cuesta
USD $36.29 al mes en Container Apps y USD $13.65 en un plan B1 de App Service**, que además da un
vCPU entero y 1.75 GiB. El modelo de consumo gana cuando el servicio pasa el día apagado; esta API no.

## Consecuencias

- **La plantilla ahora se puede aplicar.** Era el defecto más caro de los dos, porque no se veía.
- **Los ambientes que no son producción pierden la caché gestionada.** La aplicación degrada con
  elegancia —el contador de versión de sesión falla abierto—, así que dejarla fuera de `dev` y `qa`
  no rompe nada y ahorra dos instancias ociosas.
- **Producción sube de nivel de caché.** Cuesta más que antes y es correcto que cueste más: el modelo
  anterior estaba cotizando producción sin SLA.
- **Se pierde el escalado a cero.** Un plan de App Service se paga esté o no atendiendo tráfico. A
  cambio desaparece el arranque en frío, que en una app con conexiones a base de datos no es gratis.
- **Azure Managed Redis sería mejor y más barato** —Balanced B0 son USD $12.85 al mes, con réplica y
  SLA— pero el proveedor `azurerm` 4.81 **todavía no expone el recurso**: solo el obsoleto
  `azurerm_redis_enterprise_cluster`, limitado a SKUs `Enterprise_*`. Cuando lo exponga, cambia el
  recurso dentro del módulo de caché y el resto del stack no se entera. Es la primera optimización
  pendiente, y vale USD $31.31 al mes.
- **Static Web Apps no está disponible en la región**, así que la superficie estática se sirve desde
  el mismo plan de App Service en lugar de su nivel gratuito.
- **Un medidor de precios no prueba disponibilidad.** El registro de proveedores de ARM sí. Toda
  elección de servicio se comprueba ahí antes de declararla.
