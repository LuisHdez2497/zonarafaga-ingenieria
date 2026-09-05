# 0010 — CI en agentes efímeros de Microsoft

**Estado:** aceptada · **Afecta a** [0008](0008-infraestructura-declarada.md) y [0009](0009-terraform-en-vez-de-bicep.md)

## Contexto

El pipeline corría en un pool propio (`ZonaRafaga-SelfHosted`), servido por un contenedor en la
computadora de quien desarrolla. Eso convierte a **una laptop encendida en requisito para entregar**:
si está apagada, ningún Pull Request se puede completar, porque el CI es política obligatoria en las
tres ramas permanentes ([0007](0007-gitflow-tres-ramas.md)).

El requisito que fuerza la decisión es de portabilidad: el trabajo debe poder continuar desde otra
computadora sin reconstruir nada que no esté en el repositorio.

## Opciones

1. **Agente propio en la computadora de trabajo.** Sin costo, minutos ilimitados, caché caliente entre
   corridas. Ata la entrega a esa máquina y hace que «pasó en mi agente» no signifique nada.
2. **Agente propio en una máquina virtual de Azure.** Quita la atadura a la laptop, pero agrega un
   servidor que parchar, un agente que actualizar y un costo continuo: una B2s en México Central son
   USD $33.43 al mes más el disco, y el agente consume ese costo aunque no se entregue nada.
3. **Agentes efímeros de Microsoft.** Cada etapa arranca en una máquina limpia que se destruye al
   terminar. El nivel gratuito de un proyecto privado da un trabajo en paralelo con 1,800 minutos al
   mes y un tope de 60 minutos por trabajo. El nivel de pago quita el tope mensual por USD $40 al mes.

## Decisión

**Agentes efímeros de Microsoft**, con el toolchain declarado en el propio pipeline y restaurado desde
caché.

La opción 2 se descarta por aritmética, no por gusto: cuesta prácticamente lo mismo que el nivel de
pago de la opción 3 y además hay que operarla. No hay escenario en que administrar un agente propio en
la nube gane.

## Consecuencias

- **Ninguna computadora es requisito para entregar.** Es el objetivo de la decisión.
- **Una máquina limpia por corrida es la única prueba honesta de reproducibilidad.** Un agente
  persistente esconde toda dependencia que alguien instaló a mano y nunca declaró.
- **El toolchain se declara con versión exacta.** La imagen de Ubuntu no trae Terraform, Flutter, pnpm
  ni semgrep, así que el pipeline los instala. Fijar la versión es lo que mantiene local y CI en el
  mismo terreno; un `stable` flotante hace que la misma entrada dé resultados distintos según el día.
- **La caché deja de ser una comodidad y pasa a ser parte del diseño.** Sin ella, cada corrida
  reinstala dependencias, SDK y herramientas. Se cachean el almacén de pnpm, la caché de Nx, el SDK de
  Flutter y el binario de Terraform.
- **Hay un techo mensual.** Con 1,800 minutos y un consumo estimado de 25 minutos por Pull Request más
  33 por mezcla, entran del orden de 24 unidades de trabajo al mes. Cuando estorbe, se quita con USD
  $40 al mes; no hay que rediseñar nada.
- **El tope de 60 minutos por trabajo es el riesgo real a futuro.** Hoy la etapa más larga estima 18
  minutos, pero crece con el producto. Si se acerca, la salida es partir la etapa en trabajos, no subir
  de nivel.
- **El nivel gratuito hay que habilitarlo.** No se otorga solo: exige ligar la organización a una
  suscripción de Azure. Ligarla no cuesta nada por sí misma.
- La definición del agente propio se conserva en `infra/agent/` como salida de emergencia y como
  referencia del toolchain, no como el camino normal.
