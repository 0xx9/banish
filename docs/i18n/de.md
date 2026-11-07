<p align="center">
  <a href="../../README.md"><img alt="English" src="https://img.shields.io/badge/English-3A3A3C?style=for-the-badge"></a>
  <a href="./ar.md"><img alt="Arabic" src="https://img.shields.io/badge/%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9-3A3A3C?style=for-the-badge"></a>
  <a href="./es.md"><img alt="Spanish" src="https://img.shields.io/badge/Espa%C3%B1ol-3A3A3C?style=for-the-badge"></a>
  <a href="./fr.md"><img alt="French" src="https://img.shields.io/badge/Fran%C3%A7ais-3A3A3C?style=for-the-badge"></a>
  <a href="./de.md"><img alt="German" src="https://img.shields.io/badge/Deutsch-0A84FF?style=for-the-badge"></a>
  <a href="./pt.md"><img alt="Portuguese" src="https://img.shields.io/badge/Portugu%C3%AAs-3A3A3C?style=for-the-badge"></a>
  <a href="./tr.md"><img alt="Turkish" src="https://img.shields.io/badge/T%C3%BCrk%C3%A7e-3A3A3C?style=for-the-badge"></a>
  <a href="./zh.md"><img alt="Chinese" src="https://img.shields.io/badge/%E4%B8%AD%E6%96%87-3A3A3C?style=for-the-badge"></a>
  <a href="./ja.md"><img alt="Japanese" src="https://img.shields.io/badge/%E6%97%A5%E6%9C%AC%E8%AA%9E-3A3A3C?style=for-the-badge"></a>
  <a href="./ko.md"><img alt="Korean" src="https://img.shields.io/badge/%ED%95%9C%EA%B5%AD%EC%96%B4-3A3A3C?style=for-the-badge"></a>
</p>

# Banish

**Die App, und alles, was sie zurückgelassen hat.**

Eine App in den Papierkorb zu ziehen entfernt nur das Symbol. Einstellungen, Caches, Container, Protokolle und Startagenten bleiben in der Library. Sie belegen weiter Platz und kommen bei der nächsten Installation zurück.

Banish findet diese Dateien, zeigt sie, bevor irgendetwas verschoben wird, und schickt nur deine Auswahl in den Papierkorb. Jedes Element lässt sich zurücklegen. Nichts wird endgültig gelöscht.

<p><img src="../images/library.png" alt="Installierte Apps in Banish" width="920"></p>

## Was du siehst

Die Seitenleiste listet installierte Apps mit Version und Größe. Ein grüner Punkt bedeutet, dass die App läuft. Die Suche nimmt einen Namen oder eine Bundle-ID, zum Beispiel `com.google.Chrome`.

Drei Zahlen erscheinen: die Größe der App, die Größe der zugehörigen Dateien und die Größe dessen, was ausgewählt ist und in den Papierkorb geht.

**Zugehörige Dateien** passen zur Bundle-ID und sind vorausgewählt. **Namens­treffer** teilen nur den Namen und bleiben abgewählt, bis du den Pfad prüfst.

<p><img src="../images/detail.png" alt="Chrome in Banish mit zugehörigen Dateien" width="920"></p>

## Nichts bewegt sich ohne Bestätigung

**Move to Trash** öffnet ein Blatt mit Anzahl und Größe. Der Knopf ist nicht der Standardknopf, deshalb bestätigt die Eingabetaste nicht aus Versehen.

Apps in `/Applications` gehören macOS, und ein normales Verschieben wird abgelehnt. Das Blatt sagt, dass dein Passwort nötig sein kann. Danach fragt macOS einmal, und Banish legt die Auswahl in den Papierkorb.

<p><img src="../images/confirm.png" alt="Bestätigung, bevor Chrome in den Papierkorb geht" width="920"></p>

Bricht du den Passwortdialog ab, stoppt der Vorgang. Was nicht verschoben wurde, bleibt liegen. Was im Papierkorb liegt, kannst du zurückholen.

## Wo es sucht

Banish durchsucht nicht die ganze Platte. Es sieht in die bekannten Library-Ordner, nur ein oder zwei Ebenen tief: Einstellungen, Application Support, Caches, Protokolle, Container, Webdaten bei passender ID, Startagenten und den gesicherten Zustand.

Ein starker Treffer nutzt die Bundle-ID. `com.foo.app` sammelt nicht `com.foo.application` und nicht `com.foo.app2`. `Google/Chrome` kann zu Chrome gehören. `Google/Earth` nicht, nur weil ein Wort gleich ist.

## Was es nicht anfasst

Systemorte wie `/System`, `/usr`, `/bin` und `/private`. Dokumente, Schreibtisch, Downloads, Bilder und Musik. Mail, Nachrichten, Fotos, Safari, Schlüsselbunde, Kalender und Notizen. `~/.ssh` und den Papierkorb selbst als Löschquelle. Symbolische Links. Und die laufende Kopie von Banish: die App kann sich nicht selbst verschieben.

Zentrale Apple-Apps wie Finder, Safari und Mail bleiben gesperrt. Optionale Apple-Apps wie Keynote, Pages und Numbers lassen sich mit einem klaren Hinweis entfernen. System-Apps sind zuerst ausgeblendet und lassen sich über das Menü Darstellung oder die Einstellungen zeigen.

## Rechte

Ein **Administratorpasswort** wird nur verlangt, wenn macOS eine App nicht aus dem Programme-Ordner lassen will. Der Dialog ist der Systemdialog und nennt Banish.

**Voller Festplattenzugriff** ist optional. Damit liest Banish Container und Caches, die macOS sonst verbirgt. Ohne ihn funktioniert die Liste weiter, und ein Hinweis erscheint, wenn ein Ordner nicht lesbar ist.

Systemeinstellungen → Datenschutz & Sicherheit → Voller Festplattenzugriff

## Sprache in der App

Das Fenster folgt der Sprache des Mac, bei Arabisch von rechts nach links. In den Einstellungen lassen sich Arabisch oder Englisch festlegen.

<p><img src="../images/settings.png" alt="Einstellungen von Banish" width="540"></p>

## Bauen

macOS 14 oder neuer und Swift 6. Keine Bibliotheken von Dritten.

```bash
./Scripts/build-app.sh
open build/Banish.app
```

Oder `make app` und `make run`. Tests laufen mit `make test`. Die signierte App liegt in `build/Banish.app`.
