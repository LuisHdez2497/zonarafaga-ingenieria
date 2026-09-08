# ZonaRafaga · Evidencia de ingeniería

Documentación de ingeniería e infraestructura de **ZonaRafaga**, una plataforma SaaS multi-tenant
para la administración de torneos deportivos.

Este repositorio existe por una sola razón: **hacer verificable** cómo se diseña, se declara y se
entrega ese producto. No es el producto.

> ### Qué NO está aquí
>
> **El código fuente de ZonaRafaga es privado y no se publica.** Tampoco su modelo de datos, su
> diseño de dominio, su documento de arquitectura, su backlog ni el cuerpo normativo completo de sus
> estándares. Todo eso es propiedad de su autor y se muestra, cuando corresponde, en entrevista.
>
> Lo que sí está aquí son las decisiones de plataforma, la infraestructura como código y la cadena de
> entrega: la parte del trabajo que se puede enseñar sin regalar el producto.

---

## Qué demuestra

| Señal                                              | Dónde se comprueba                                                                                                            |
| -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Arquitectura de soluciones en Azure**            | [`decisiones/`](decisiones/) — seis decisiones registradas con alternativas evaluadas y su costo                              |
| **Infraestructura como código**                    | [`infraestructura/`](infraestructura/) — siete módulos de Terraform reutilizables                                             |
| **Entrega automatizada con controles**             | [`entrega/`](entrega/) — un verificador compartido que el pipeline llama, con análisis estático y revisión de infraestructura |
| **Método y proceso formal**                        | [`estandares/`](estandares/) — resumen de los 28 estándares · [`documentos/`](documentos/) — el documento de plataforma       |
| **Desarrollo dirigido por especificación, con IA** | [`metodo/`](metodo/) — el ciclo completo: requisito, especificación, procedimiento y los guardrails que lo hacen fiable       |

## La idea que sostiene la cadena de entrega

**El pipeline no repite la lista de gates: la llama.**

Mientras la lista de verificaciones vivió en dos sitios —un estándar y un YAML— divergieron sin que nada
lo dijera: CI no corría el formateador, ni las pruebas de integración contra la base, e instalaba el
analizador estático sin fijar versión. **Nadie lo notó porque las dos salían verdes.**

Ahora hay un solo archivo, `verificar.mjs`, y el pipeline lo invoca. **Se descubre a sí mismo** —lee el
paquete del API, sus librerías, la app de Flutter y si existe infraestructura declarada—, así que el
mismo archivo sirve sin cambios en los repositorios hermanos. El detalle y su costo están en el
[ADR 0013](decisiones/0013-un-solo-verificador.md).

## Contenido

```
decisiones/        Registros de decisión de arquitectura (ADR 0007–0012)
estandares/        Resumen de los estándares de ingeniería
metodo/            Desarrollo dirigido por especificación, asistido por IA
infraestructura/   Módulos de Terraform: red, cómputo, base de datos, caché,
                   almacén, secretos, observabilidad y el stack que los compone
entrega/           Pipeline de Azure DevOps, sus plantillas y el verificador
                   que corre igual en la máquina y en CI
documentos/        Documento de plataforma de entrega y operación (PDF)
```

## Las decisiones, en una línea cada una

| ADR                                                  | Decisión                                              | Por qué importa                                                   |
| ---------------------------------------------------- | ----------------------------------------------------- | ----------------------------------------------------------------- |
| [0007](decisiones/0007-gitflow-tres-ramas.md)        | GitFlow con tres ramas permanentes                    | La rama es el mecanismo de promoción entre ambientes              |
| [0008](decisiones/0008-infraestructura-declarada.md) | Infraestructura declarada y validada, sin provisionar | Se audita la cadena completa sin pagar cómputo ocioso             |
| [0009](decisiones/0009-terraform-en-vez-de-bicep.md) | Terraform en lugar de Bicep                           | El código no se acopla a un solo proveedor                        |
| [0010](decisiones/0010-ci-en-agentes-efimeros.md)    | CI en agentes efímeros                                | Una dependencia instalada a mano falla en CI en vez de esconderse |
| [0011](decisiones/0011-servicios-de-azure.md)        | Qué servicio sostiene cada pieza                      | App Service sobre Container Apps, con números                     |
| [0012](decisiones/0012-region-por-ambiente.md)       | Cada ambiente vive donde le corresponde               | Residencia de datos en producción; costo en los demás             |
| [0013](decisiones/0013-un-solo-verificador.md)       | Un solo verificador, y el pipeline lo llama           | Lo que antes eran dos listas de gates que divergieron en silencio |

## Cómo está construida la infraestructura

Siete módulos componibles, un ambiente por juego de variables. El plano de datos vive en **red
privada**: la base de datos y la caché no tienen dirección pública, y el cómputo entra por
integración de red virtual.

Los valores de cada ambiente (identificadores de suscripción, nombres de recurso, dimensionamiento)
**no se publican** — son configuración de despliegue, no arquitectura.

Las plantillas se validan en cada entrega con análisis estático de seguridad y un plan de cambios
revisable antes de aplicar.

## Cómo está construida la entrega

Cuatro etapas, y **solo se ejecuta lo afectado** por los cambios:

1. **Calidad** — lint, tipos, pruebas y build sobre los proyectos afectados
2. **Seguridad** — análisis estático y auditoría de dependencias
3. **Infraestructura** — validación de plantillas, análisis estático y plan de cambios
4. **Empaquetado** — imagen inmutable identificada por digest

Las versiones del toolchain se declaran en un archivo único ([`entrega/.toolchain`](entrega/)) que
leen el pipeline y el contenedor de desarrollo. Una versión que solo vive en un lugar se desincroniza
sin que nadie se entere.

## Estado

La infraestructura está **declarada y validada, no provisionada**. Es una decisión deliberada
([ADR 0008](decisiones/0008-infraestructura-declarada.md)): un ambiente existe cuando su plantilla
compila, su plan de cambios se puede revisar y el pipeline lo publicaría sin intervención manual.
Provisionarlo es una decisión de negocio, no un requisito técnico.

Donde este material describe algo que todavía no está corriendo, lo dice.

---

**Autor:** Luis Alfonso Hernández Núñez · [Portafolio](https://portfolio-luisalfonsohernandez.web.app)

Material propietario publicado como evidencia técnica. Se puede leer y citar; no se puede reutilizar.
Ver [LICENSE](LICENSE).
