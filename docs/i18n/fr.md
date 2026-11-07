<p align="center">
  <a href="../../README.md"><img alt="English" src="https://img.shields.io/badge/English-3A3A3C?style=for-the-badge"></a>
  <a href="./ar.md"><img alt="Arabic" src="https://img.shields.io/badge/%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9-3A3A3C?style=for-the-badge"></a>
  <a href="./es.md"><img alt="Spanish" src="https://img.shields.io/badge/Espa%C3%B1ol-3A3A3C?style=for-the-badge"></a>
  <a href="./fr.md"><img alt="French" src="https://img.shields.io/badge/Fran%C3%A7ais-0A84FF?style=for-the-badge"></a>
  <a href="./de.md"><img alt="German" src="https://img.shields.io/badge/Deutsch-3A3A3C?style=for-the-badge"></a>
  <a href="./pt.md"><img alt="Portuguese" src="https://img.shields.io/badge/Portugu%C3%AAs-3A3A3C?style=for-the-badge"></a>
  <a href="./tr.md"><img alt="Turkish" src="https://img.shields.io/badge/T%C3%BCrk%C3%A7e-3A3A3C?style=for-the-badge"></a>
  <a href="./zh.md"><img alt="Chinese" src="https://img.shields.io/badge/%E4%B8%AD%E6%96%87-3A3A3C?style=for-the-badge"></a>
  <a href="./ja.md"><img alt="Japanese" src="https://img.shields.io/badge/%E6%97%A5%E6%9C%AC%E8%AA%9E-3A3A3C?style=for-the-badge"></a>
  <a href="./ko.md"><img alt="Korean" src="https://img.shields.io/badge/%ED%95%9C%EA%B5%AD%EC%96%B4-3A3A3C?style=for-the-badge"></a>
</p>

# Banish

**L’app, et tout ce qu’elle a laissé derrière elle.**

Glisser une app vers la Corbeille ne retire que l’icône. Préférences, caches, conteneurs, journaux et agents de lancement restent dans la bibliothèque. Ils occupent encore de l’espace et réapparaissent à la réinstallation.

Banish trouve ces fichiers, les montre avant tout déplacement, et n’envoie à la Corbeille que ce que vous choisissez. Chaque élément peut être remis en place. Rien n’est supprimé définitivement.

<p><img src="../images/library.png" alt="Liste des applications dans Banish" width="920"></p>

## Ce que vous voyez

La barre latérale liste les apps installées, avec la version et la taille. Un point vert signifie que l’app est lancée. La recherche accepte un nom ou un identifiant, comme `com.google.Chrome`.

Trois chiffres apparaissent : la taille de l’app, celle des fichiers liés, et celle de la sélection qui partira à la Corbeille.

Les **fichiers liés** correspondent à l’identifiant et sont cochés d’emblée. Les **correspondances de nom** ne partagent que le nom, donc elles restent décochées tant que vous n’avez pas regardé le chemin.

<p><img src="../images/detail.png" alt="Chrome dans Banish, avec ses fichiers liés" width="920"></p>

## Rien ne bouge avant la confirmation

**Move to Trash** ouvre une feuille avec le nombre d’éléments et la taille. Le bouton n’est pas le bouton par défaut : Retour ne confirme pas par erreur.

Les apps de `/Applications` appartiennent à macOS, et un déplacement ordinaire est refusé. La feuille prévient qu’un mot de passe peut être demandé. Après confirmation, macOS demande une fois, puis Banish déplace la sélection vers la Corbeille.

<p><img src="../images/confirm.png" alt="Confirmation avant d’envoyer Chrome à la Corbeille" width="920"></p>

Annuler le dialogue du mot de passe arrête le déplacement. Ce qui n’a pas bougé reste en place. Ce qui est arrivé dans la Corbeille peut en revenir.

## Où il cherche

Banish ne parcourt pas tout le disque. Il regarde les dossiers connus de la bibliothèque, sur un ou deux niveaux : préférences, Application Support, caches, journaux, conteneurs, données web si l’identifiant correspond, agents de lancement et état enregistré.

Une correspondance forte utilise l’identifiant. `com.foo.app` ne ramasse pas `com.foo.application` ni `com.foo.app2`. `Google/Chrome` peut appartenir à Chrome. `Google/Earth` non, même si un mot est commun.

## Ce qu’il ne touche pas

Les emplacements système comme `/System`, `/usr`, `/bin` et `/private`. Vos documents, le Bureau, Téléchargements, les photos et la musique. Mail, Messages, Photos, Safari, les trousseaux, Calendrier et Notes. `~/.ssh`, et la Corbeille elle-même comme source d’une suppression. Les liens symboliques. Et la copie de Banish en cours d’exécution : l’app ne se déplace pas elle-même.

Les apps Apple essentielles, dont Finder, Safari et Mail, restent verrouillées. Les apps Apple facultatives, comme Keynote, Pages et Numbers, peuvent être retirées avec un avertissement. Les apps système sont d’abord masquées. On les affiche depuis le menu Présentation ou les réglages.

## Autorisations

Le **mot de passe administrateur** n’est demandé que lorsque macOS refuse de sortir une app du dossier Applications. Le dialogue est celui du système, et il nomme Banish.

L’**accès complet au disque** est facultatif. Il permet de lire des conteneurs et des caches que macOS cache. Sans lui, la liste fonctionne encore, et une bannière apparaît si un dossier est illisible.

Réglages Système → Confidentialité et sécurité → Accès complet au disque

## Langue dans l’app

La fenêtre suit la langue du Mac, de droite à gauche pour l’arabe. Les réglages peuvent fixer l’arabe ou l’anglais.

<p><img src="../images/settings.png" alt="Réglages de Banish" width="540"></p>

## Compiler

macOS 14 ou plus récent, et Swift 6. Aucune bibliothèque tierce.

```bash
./Scripts/build-app.sh
open build/Banish.app
```

Ou `make app` puis `make run`. Les tests se lancent avec `make test`. L’app signée est `build/Banish.app`.
