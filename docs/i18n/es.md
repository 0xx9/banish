<p align="center">
  <a href="../../README.md"><img alt="English" src="https://img.shields.io/badge/English-3A3A3C?style=for-the-badge"></a>
  <a href="./ar.md"><img alt="Arabic" src="https://img.shields.io/badge/%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9-3A3A3C?style=for-the-badge"></a>
  <a href="./es.md"><img alt="Spanish" src="https://img.shields.io/badge/Espa%C3%B1ol-0A84FF?style=for-the-badge"></a>
  <a href="./fr.md"><img alt="French" src="https://img.shields.io/badge/Fran%C3%A7ais-3A3A3C?style=for-the-badge"></a>
  <a href="./de.md"><img alt="German" src="https://img.shields.io/badge/Deutsch-3A3A3C?style=for-the-badge"></a>
  <a href="./pt.md"><img alt="Portuguese" src="https://img.shields.io/badge/Portugu%C3%AAs-3A3A3C?style=for-the-badge"></a>
  <a href="./tr.md"><img alt="Turkish" src="https://img.shields.io/badge/T%C3%BCrk%C3%A7e-3A3A3C?style=for-the-badge"></a>
  <a href="./zh.md"><img alt="Chinese" src="https://img.shields.io/badge/%E4%B8%AD%E6%96%87-3A3A3C?style=for-the-badge"></a>
  <a href="./ja.md"><img alt="Japanese" src="https://img.shields.io/badge/%E6%97%A5%E6%9C%AC%E8%AA%9E-3A3A3C?style=for-the-badge"></a>
  <a href="./ko.md"><img alt="Korean" src="https://img.shields.io/badge/%ED%95%9C%EA%B5%AD%EC%96%B4-3A3A3C?style=for-the-badge"></a>
</p>

# Banish

**La app, y todo lo que dejó atrás.**

Arrastrar una app a la Papelera solo quita el icono. Preferencias, cachés, contenedores, registros y agentes de arranque se quedan en la biblioteca. Siguen ocupando espacio y vuelven al reinstalar.

Banish encuentra esos archivos, los muestra antes de mover nada y envía a la Papelera solo lo que eliges. Puedes recuperar cada elemento. Nada se borra para siempre.

<p><img src="../images/library.png" alt="Lista de aplicaciones en Banish" width="920"></p>

## Qué ves

La barra lateral muestra las apps instaladas, con versión y tamaño. Un punto verde significa que la app está en ejecución. La búsqueda acepta un nombre o un identificador, como `com.google.Chrome`.

Al elegir una app aparecen tres cifras: el tamaño de la app, el de los archivos relacionados y el de lo que está seleccionado e irá a la Papelera.

Los **archivos relacionados** coinciden por el identificador y empiezan marcados. Las **coincidencias de nombre** solo comparten el nombre, así que quedan sin marcar hasta que revises la ruta.

<p><img src="../images/detail.png" alt="Chrome en Banish, con sus archivos relacionados" width="920"></p>

## Nada se mueve hasta que confirmas

**Move to Trash** abre una hoja con el número de elementos y el tamaño. El botón de mover no es el botón por defecto, así que Retorno no confirma por accidente.

Las apps de `/Applications` pertenecen a macOS y un traslado normal se rechaza. La hoja avisa de que puede hacer falta tu contraseña. Después de confirmar, macOS pregunta una vez y Banish mueve la selección a la Papelera.

<p><img src="../images/confirm.png" alt="Confirmación antes de mover Chrome a la Papelera" width="920"></p>

Si cancelas el diálogo de la contraseña, el traslado se detiene. Lo que no se movió se queda donde estaba. Lo que llegó a la Papelera se puede restaurar.

## Dónde mira

Banish no recorre todo el disco. Mira en las carpetas conocidas de la biblioteca, a poca profundidad: preferencias, Application Support, cachés, registros, contenedores, datos web cuando el identificador coincide, agentes de arranque y el estado guardado.

Una coincidencia fuerte usa el identificador. `com.foo.app` no recoge `com.foo.application` ni `com.foo.app2`. `Google/Chrome` puede pertenecer a Chrome. `Google/Earth` no, solo porque comparten una palabra.

## Qué no toca

Ubicaciones del sistema como `/System`, `/usr`, `/bin` y `/private`. Tus documentos, el Escritorio, Descargas, fotos y música. Mail, Mensajes, Fotos, Safari, llaveros, Calendario y Notas. `~/.ssh`, y la propia Papelera como origen de un borrado. Los enlaces simbólicos. Y la copia de Banish que está en ejecución: la app no puede moverse a sí misma.

Las apps básicas de Apple, como Finder, Safari y Mail, permanecen bloqueadas. Las opcionales, como Keynote, Pages y Numbers, se pueden quitar con un aviso claro. Las apps del sistema empiezan ocultas. Se muestran desde el menú Vista o desde Ajustes.

## Permisos

La **contraseña de administrador** solo se pide cuando macOS se niega a sacar una app de la carpeta Aplicaciones. El diálogo es el del sistema y nombra a Banish.

**Acceso total al disco** es opcional. Permite leer contenedores y cachés que macOS oculta. Sin él, la lista sigue funcionando y aparece un aviso si una carpeta no se puede leer.

Ajustes del Sistema → Privacidad y seguridad → Acceso total al disco

## Idioma dentro de la app

La ventana sigue el idioma del Mac, de derecha a izquierda en árabe. En Ajustes puedes fijar árabe o inglés.

<p><img src="../images/settings.png" alt="Ajustes de Banish" width="540"></p>

## Compilar

macOS 14 o posterior, y Swift 6. Sin bibliotecas de terceros.

```bash
./Scripts/build-app.sh
open build/Banish.app
```

O `make app` y `make run`. Las pruebas se ejecutan con `make test`. La app firmada queda en `build/Banish.app`.
