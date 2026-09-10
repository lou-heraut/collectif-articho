# collectif-articho : contexte projet

Site vitrine du collectif ARTI/CHÔ. Site statique **généré par un script R**, sans
framework ni build system : `make_projet.R` lit une arborescence de contenu et écrit
directement des `.html` finis, committés dans le dépôt.

Les problèmes connus et le plan d'action ne sont pas ici, voir `PLAN.md`.

## Conventions de rédaction

**Ne pas utiliser le tiret cadratin (`—`)**, ni dans les fichiers du dépôt, ni dans
les messages de commit, ni dans les réponses. C'est un marqueur de texte écrit par
une IA, et ça agace les gens qui lisent. Reformuler la phrase plutôt que de
substituer un autre signe : le cadratin remplace presque toujours un deux-points,
une virgule, une parenthèse ou un point, donc trancher. Dans un titre du genre
`## P1.2 — Métadonnées absentes` il ne porte aucun sens et disparaît sans
remplacement. Le tiret demi-cadratin (`–`) et le trait d'union sont libres.

## Le dossier `drive/` est un miroir en lecture seule

`drive/` est la **copie d'un dossier de travail partagé de l'association**, et c'est
la **source de vérité du contenu**. Il est suivi par git (539 fichiers, 1,3 Go) et
contient 26 `.DS_Store`, preuve qu'il est synchronisé depuis un poste macOS.

**Conséquences, et c'est structurant :**

1. Ne jamais corriger le contenu en éditant `drive/`. Une resynchronisation
   écraserait la correction, et ça ferait diverger du dossier de l'association.
2. Tout correctif vit donc dans `make_projet.R`. Le script doit **encaisser le
   contenu tel qu'il arrive** : espaces parasites, casse incohérente, ponctuation
   typographique, normalisation Unicode variable. Ne jamais demander à
   l'association de formater ses titres.
3. C'est l'association qui renomme ses dossiers et ses titres, quand elle veut.
   **Les renommages sont un régime permanent, pas un incident.** Tout ce qui dérive
   une URL d'un titre doit être pensé avec ça en tête.

## Pipeline de génération

```
drive/<NN_Onglet>/<NN_SousOnglet>/<NN_Projet>/   ──[ make_projet.R ]──>   pages/**.html
    titre.txt  soustitre.txt  info.txt  text.txt                         resources/images/**
    1.jpg 2.jpg …                           (copie des images)
```

- Le préfixe `NN_` des dossiers `drive/` ne sert qu'à **ordonner** : il est retiré du
  nom affiché (`gsub("[[:digit:]]+[_]", "", basename(...))`), et les `_` redeviennent
  des espaces. C'est donc le nom du dossier qui donne le libellé d'onglet.
- Le **nom de la page** et celui du **répertoire d'images**, eux, viennent du contenu
  de `titre.txt`, pas du nom de dossier.
- `info.txt` est parsé en `clé: valeur` ligne par ligne ; `text.txt` devient un `<p>`
  par ligne non vide. Les lignes vides sont ignorées partout.
- Sous-onglet **`Ligne de mobilier`** : branche de code à part (galerie avec carrousel,
  prix, modalités, dimensions, matériaux) qui génère **une seule page** listant tous
  les meubles, sans page de détail par meuble.
- Tous les autres sous-onglets : une page de détail par projet, plus une page de
  listing en vignettes.

## Normalisation Unicode du contenu

Le miroir macOS livre les accents sous **deux formes mélangées**, parce que macOS
décompose (NFD) là où Linux et le web précomposent (NFC) :

| | NFC précomposé | NFD décomposé |
|---|---|---|
| noms de dossiers `drive/` | 2 | **23** |
| contenus des `titre.txt` | 17 | 1 |

En NFD, `é` est stocké `e` suivi de U+0301, un accent combinant séparé. Les deux
formes s'affichent identiquement mais n'ont pas les mêmes octets, donc **tout slug
dérivé d'un titre doit neutraliser la différence**, sinon le même titre apparent
peut produire deux fichiers distincts. `iconv //TRANSLIT` de la glibc absorbe
correctement les deux, mais son comportement dépend de la plateforme, donc retirer
explicitement les marques combinantes (`gsub("[̀-ͯ]", "", s)`) avant
l'`iconv`. `stringi` est installé si une normalisation NFC franche est préférée.

Trace en production de ce piège : `pages/projets/signaletiques/` contient
`caapp_a_cite` + U+0301 + `.html`, une URL qui **s'affiche** `caapp_a_cité.html`
dans la barre d'adresse alors que ses octets disent `caapp_a_cite` suivi d'un accent
flottant.

## Conventions de slug (état actuel du code)

Deux fonctions distinctes, c'est la clé pour comprendre le code :

| ce qui est slugifié | fonction utilisée | résultat |
|---|---|---|
| onglet / sous-onglet (donc les répertoires) | `to_link()` : `iconv //TRANSLIT` + `tolower` + espaces vers `_` | ASCII, `snake_case` |
| page projet / répertoire d'images | `tolower(gsub(" ", "_", titre))` | titre **brut** minusculisé |

Convention de fait dans les chemins : `snake_case`, tirets conservés quand le
libellé en contient (`ateliers_sur-mesures`, `mini-serres`). La cible décidée est le
`kebab-case` intégral, voir `PLAN.md`.

## Gabarits

`pages/default_projet.html`, `default_projets.html`, `default_mobiliers.html`.
Substitution par `gsub()` sur des jetons `$NOM$` :

| jeton | remplacé par |
|---|---|
| `$TITLE$` `$SUBTITLE$` | titre / sous-titre |
| `$MAIN_IMG$` `$IMG$` | 1ʳᵉ image / toutes les suivantes |
| `$INFO$` `$P$` | bloc `info.txt` / paragraphes `text.txt` |
| `$PROJET$` | grille de vignettes (pages de listing) |
| `$CSS$` `$JS$` `$TABBAR$` | injections d'en-tête |

⚠️ Les jetons `$INFO$`, `$P$`, `$IMG$`, `$PROJET$`, `$CSS$`, `$JS$`, `$TABBAR$` sont
remplacés avec le motif `".*[$]JETON[$]"`, donc **toute la ligne est écrasée**, pas
seulement le jeton. Garder ces jetons seuls sur leur ligne dans les gabarits.
`$TITLE$` et `$SUBTITLE$` (branche projet) sont, eux, remplacés en place.

## Généré vs écrit à la main

**Régénéré à chaque run, donc à ne jamais éditer à la main :**

```
pages/projets.html                      pages/<onglet>/<sous-onglet>.html
pages/<onglet>/<sous-onglet>/*.html     resources/images/{projets,mobiliers,ateliers}/**
```

**Maintenu à la main :**

```
index.html              pages/ateliers.html      pages/mobiliers.html
components/*.html       pages/a_propos.html      pages/contact.html
resources/css/*         pages/ateliers/notre_offre.html
resources/js/*          pages/mentions_legales.html  pages/conditions_generales.html
resources/statics/*     CNAME  Makefile
```

`pages/ateliers.html` et `pages/mobiliers.html` sont à la main parce que le script
saute volontairement la page d'onglet pour ces deux-là :
`if (!(tab %in% c("Mobiliers", "Ateliers")))`. `pages/projets.html`, lui, est généré.

## Le script est destructif

Au début de chaque sous-onglet :

```r
unlink(folders_dir, recursive=TRUE) ; dir.create(folders_dir, recursive=TRUE)
```

`pages/<onglet>/<sous-onglet>/` est **intégralement vidé** à chaque exécution, et
`resources/images/<onglet>/<sous-onglet>/<projet>/` l'est par projet.

**Conséquence pratique** : tout fichier ajouté à la main dans ces répertoires
disparaît au prochain `Rscript make_projet.R`. Tout ce qui doit y vivre, redirections
comprises, doit être **émis par le script**.

## Navigation

- `resources/js/script.js` injecte `components/header.html`, `footer.html` et les
  `*_tab.html` via `fetch()` dans les `<div id="header">`, `<div id="footer">` et
  `<div id="*_tab">`, **puis** appelle `checkURL()`.
- `checkURL()` déduit l'onglet actif de `window.location.pathname` via une **chaîne
  de `else if` sur les slugs en dur** (12 branches) et ajoute la classe `selected`
  à des ids `header_tab-*`, `header_subtab-*`, `*_subtab-*`.
- Donc **les slugs d'onglet et de sous-onglet sont dupliqués** en trois endroits :
  les `href` des composants, les `id` des composants, et les branches de `script.js`.
- Dépendances externes par CDN : jQuery 3.7.1 (requis par `checkURL()`) et
  Material Icons (Google Fonts).

### Liens internes codés en dur

10 fichiers maintenus à la main portent des slugs d'onglet en dur : `index.html`,
les 5 `components/*.html`, `pages/ateliers.html`, `pages/mobiliers.html`,
`pages/default_mobiliers.html` et `resources/js/script.js`. Les 30 liens de
`pages/projets.html` sont générés, ils ne comptent pas.

Le garde-fou à relancer après tout changement de slug :

```sh
grep -rhoE '(href|src)="/[^"]+"' index.html pages components resources/js \
  | sed -E 's/.*="\/([^"]+)"/\1/' | sort -u \
  | while read -r p; do [ -e "$p" ] || echo "LIEN MORT: /$p"; done
```

## Hébergement

| | |
|---|---|
| remote | `git@github.com:louis-heraut/collectif-articho.git`, branche `main` |
| hébergeur | **GitHub Pages** (`server: GitHub.com`), publie la racine de `main` |
| domaine | `collectifarticho.com` via `CNAME` ; `www` vers `lou-heraut.github.io` |
| DNS | **Google Domains** (`ns-cloud-d*.googledomains.com`), A vers `185.199.10{8,9,10,11}.153` |
| CDN | Fastly (celui de GitHub). **Pas de Cloudflare devant.** |

Ce que ça implique : pas de `.htaccess`, pas de `_redirects`, aucune réécriture ni
redirection HTTP côté serveur. Une redirection ne peut être qu'un **fichier HTML
stub** (`meta refresh` plus `link canonical`), servi en 200. Déployer, c'est
`git push` ; le build Pages prend environ une minute.

## Commandes

```sh
Rscript make_projet.R    # regenere tout depuis drive/
make local               # python3 -m http.server (a la racine, sert / correctement)
git push                 # = deployer
```

Le serveur local est nécessaire pour tester : les `fetch()` de `script.js` et tous
les chemins sont **absolus** (`/components/…`, `/resources/…`), donc ouvrir un
`.html` en `file://` casse l'en-tête, le pied de page et le CSS.

## Inventaire

72 pages HTML, 59 projets dans `drive/` dont 5 meubles en page unique,
`resources/images` à environ **1,4 Go** (recopié depuis `drive/` à chaque run).
