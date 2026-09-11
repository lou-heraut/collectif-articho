# Plan d'action : URL et redirection du QR code

Audit du 2026-09-10, recadré le 2026-09-11. Contexte technique (pipeline,
miroir `drive/`, hébergement, généré vs manuel) dans `CLAUDE.md`, non répété ici.

> ## État au 2026-09-11
>
> **P0 est fait, fusionné dans `main` et publié** (commit de travail `cff5fba`,
> merge `9ca5bf3`). Faits au passage : **P1.1**, **P1.4**, **P2.1**.
>
> **Vérifié en ligne après le build Pages** (215 s, sans erreur) : l'ancienne URL du
> QR `…/agencements/tpmobile.html` rend 200 et redirige vers
> `…/tpmob-theatre-public-mobile.html`, qui rend 200 avec le bon titre ; les
> **418 ressources** référencées par le site répondent sur `collectifarticho.com` ;
> les anciennes URL rendent 404, comme convenu. Reste le seul test qui compte :
> **scanner le QR code papier**.
>
> Restent ouverts, par ordre de rentabilité : **P1.2** métadonnées des pages projet,
> **P1.3** page 404 maison, **P2.2** validation du contenu entrant, **P2.3**
> échappement de `$TITLE$`, **P2.4** noms de fichiers d'images, puis les **P3**.
>
> Deux choses découvertes en implémentant, à ne pas reperdre :
> - 6 fichiers maintenus à la main vivaient dans l'arborescence d'images générée,
>   dont la plaquette PDF. Voir P0.5 et `CLAUDE.md` § *Le script est destructif*.
> - Le dépôt a changé de nom côté GitHub, `louis-heraut` devient `lou-heraut`. Le
>   remote local a été recalé.
>
> Pour reprendre : P1.2 a le meilleur rapport visible sur effort, et P1.3 complète
> naturellement ce commit puisque toutes les anciennes URL sont maintenant mortes.

## Cadrage validé avec l'association

- **Une seule URL compte** : celle du QR code déjà imprimé. Elle doit rediriger.
- **Toutes les autres URL peuvent changer**, l'association s'en moque. Pas de
  redirections à traîner.
- Les nouvelles URL suivent les **standards web modernes** (`kebab-case`, ASCII).
- Pour l'historique, **git suffit** : `pages/` est committé depuis le début, donc
  toute URL jamais publiée est retrouvable. Un fichier d'inventaire généré rend cet
  historique lisible sans fouiller (voir P0.5).

Ce cadrage supprime d'un coup le gros du travail envisagé la veille : pas de table
de correspondance à maintenir, pas de mécanisme d'historique de slugs, pas de
redirections en masse. **Un seul stub de redirection, et un sanitizer propre.**

---

# P0. Action prioritaire

Un commit. Trois changements dans `make_projet.R`, une reprise scriptée des liens
en dur, un fichier de redirection à une ligne.

## P0.1 Le constat

Le nom de page vient de `titre.txt` **sans assainissement** (voir le tableau des
deux fonctions de slug dans `CLAUDE.md`). Le titre brut part donc dans l'URL :

| ce qui passe aujourd'hui | exemple d'URL produite | pourquoi c'est cassé |
|---|---|---|
| `é è ê â à î` | `bibliothèques.html` | %-encodé en UTF-8 (`biblioth%C3%A8ques`), illisible et indictable au téléphone |
| accent combinant NFD | `caapp_a_cite` + U+0301 | **le pire cas** : s'affiche `caapp_a_cité.html` mais les octets disent autre chose. Deux URL visuellement identiques dont une seule existe |
| `’` U+2019 | `bord’ha_bureaux.html` | qui retape l'URL tape `'`, donc 404 |
| `[` `]` | `tpmob_[théâtre_public_mobile].html` | *gen-delims* RFC 3986, illégaux dans un path. Navigateurs tolérants, mais les linkifiers SMS, WhatsApp, Instagram et certains lecteurs QR tronquent à l'accolade |
| `!` | `la_ruche_qui_dit_oui!_.html` | souvent exclu des auto-liens |
| espace final dans `titre.txt` | `…_biodiversité_.html` | `_` parasite en fin de slug, et espace parasite dans le `<h1>` affiché |

**23 pages sur 72** touchées, ainsi que les répertoires d'images correspondants.

Quatre titres portent un espace final (`LABYRINTHE DE LA BIODIVERSITÉ `,
`MOBILIER MODULABLE EXTÉRIEUR `, `ESPACE JEUNESSE MARC LANVIN `,
`LA RUCHE QUI DIT OUI! `). **Ne pas les corriger dans `drive/`**, qui est un miroir
en lecture seule : le nettoyage se fait en R par `trimws()` à la lecture, ce qui
corrige l'URL **et** le titre affiché.

## P0.2 Le sanitizer

Remplacer `to_link()` **et les deux** `folder_name = tolower(gsub(" ", "_", ...))`
(branche « Ligne de mobilier » et branche « Projet ») par un unique :

```r
to_slug = function (str) {
    s = gsub("[‘’ʼ´`]", "-", str)            # apostrophes : converties en tiret
    s = gsub("[̀-ͯ]", "", s)                  # marques combinantes (NFD macOS)
    t = iconv(s, "UTF-8", "ASCII//TRANSLIT")
    s = ifelse(is.na(t), s, t)                          # garde-fou : iconv peut rendre NA
    s = tolower(s)
    s = gsub("[^a-z0-9]+", "-", s)                      # tout le reste devient un tiret
    s = gsub("-{2,}", "-", s)
    gsub("^-+|-+$", "", s)                              # trim
}
```

Le retrait des marques combinantes avant l'`iconv` traite le mélange NFD/NFC du
miroir. Testé : les deux formes de `CAAPP A CITÉ` convergent vers `caapp-a-cite`.
Le `ifelse(is.na(t), ...)` évite de produire un `NA.html` silencieux si `iconv`
échoue.

**Vérifié sur les 59 titres réels :** 53 pages projet, **0 collision**, **0
caractère non conforme** dans les URL produites.

```
tpmob_[théâtre_public_mobile].html   ->  tpmob-theatre-public-mobile.html
caapp_a_cite + U+0301 .html            ->  caapp-a-cite.html
bord’ha_bureaux.html                  ->  bord-ha-bureaux.html
la_ruche_qui_dit_oui!_.html             ->  la-ruche-qui-dit-oui.html
labyrinthe_de_la_biodiversité_.html    ->  labyrinthe-de-la-biodiversite.html
lycée_de_demain_-_s4.html              ->  lycee-de-demain-s4.html
```

Choix tranché : les apostrophes deviennent un **tiret**, pas une suppression.
`L'ATELIER DU QUARTIER` donne `l-atelier-du-quartier`, `PUPITRE D'ENTREPRISE` donne
`pupitre-d-entreprise`, `BORD'HA bureaux` donne `bord-ha-bureaux`. Les CMS
suppriment plutôt l'apostrophe (`latelier`, `bordha`), mais la lisibilité gagne ici,
en particulier pour une marque comme BORD'HA que `bordha` rendait méconnaissable.

## P0.3 La redirection du QR code

```
66686ba  2026-09-09  "update tpmob"
  R074  pages/mobiliers/agencements/tpmobile.html
     -> pages/mobiliers/agencements/tpmob_[théâtre_public_mobile].html
```

Vérifié en ligne : l'ancienne URL rend **404**, la nouvelle **200**.

GitHub Pages sans proxy ne sait pas faire de 301, donc la seule option est un
**stub HTML** (`meta refresh` plus `canonical`), ce que fait le plugin
`jekyll-redirect-from`. Google traite `canonical` plus refresh 0 s comme un 301.

**Contrainte structurelle** : `make_projet.R` vide `pages/<onglet>/<sous-onglet>/`
à chaque run (voir `CLAUDE.md`, § *Le script est destructif*). Un stub posé à la
main y serait détruit au run suivant, donc **la redirection doit être émise par le
script**.

`redirects.txt` à la racine, séparateur **tabulation** (les chemins peuvent contenir
des espaces, pas des tabulations) :

```
# ancienne_url<TAB>nouvelle_url, chemins absolus depuis la racine du site
# QR code imprime, ne jamais retirer cette ligne
/pages/mobiliers/agencements/tpmobile.html	/pages/mobiliers/agencements/tpmob-theatre-public-mobile.html
```

À ajouter **à la fin** de `make_projet.R`, après la boucle principale, sinon le
`unlink` efface les stubs :

```r
## ---- REDIRECTIONS -------------------------------------------------
## GitHub Pages ne sait pas faire de 301 : on ecrit un stub a l'ancienne URL.
## Les cibles sont des slugs assainis, donc ASCII pur, donc aucun %-encodage requis.
write_redirect = function (from_path, to_url) {
    dir.create(dirname(from_path), recursive=TRUE, showWarnings=FALSE)
    writeLines(c(
        '<!DOCTYPE html>', '<html lang="fr">', '    <head>',
        '	<meta charset="UTF-8">',
        paste0('	<meta http-equiv="refresh" content="0; url=', to_url, '">'),
        paste0('	<link rel="canonical" href="https://collectifarticho.com', to_url, '">'),
        '	<meta name="robots" content="noindex, follow">',
        '	<title>ARTI/CHÔ</title>',
        paste0('	<script>location.replace("', to_url, '");</script>'),
        '    </head>',
        paste0('    <body><p>Cette page a déménagé : <a href="',
               to_url, '">', to_url, '</a></p></body>'),
        '</html>'), from_path)
}

redirects_path = "redirects.txt"
if (file.exists(redirects_path)) {
    Redirect = readLines(redirects_path, warn=FALSE)
    Redirect = Redirect[nchar(trimws(Redirect)) > 0 &
                        !grepl("^[[:space:]]*#", Redirect)]
    for (redirect in Redirect) {
        field = trimws(unlist(strsplit(redirect, "\t")))
        if (length(field) != 2) {
            warning("redirects.txt : ligne ignoree : ", redirect) ; next
        }
        from_path = sub("^/", "", field[1])
        if (file.exists(from_path)) {      # ne jamais masquer une vraie page
            warning("redirection ignoree, page reelle : ", field[1]) ; next
        }
        if (!file.exists(sub("^/", "", field[2]))) {
            warning("redirection vers une cible inexistante : ", field[2])
        }
        write_redirect(from_path, field[2])
    }
}
```

Le mécanisme accepte plusieurs lignes, mais **une seule est nécessaire**. Il resservira
au prochain QR imprimé, sans rien à maintenir entre-temps.

## P0.4 Reprendre les liens en dur

Le `kebab-case` change **4 des 8 répertoires de sous-onglet** :

```
projets/chantiers_participatifs  ->  projets/chantiers-participatifs
projets/demarche_experimentale   ->  projets/demarche-experimentale
mobiliers/ligne_de_mobilier      ->  mobiliers/ligne-de-mobilier
ateliers/ateliers_sur-mesures    ->  ateliers/ateliers-sur-mesures
```

Plus, pour la cohérence, les 4 pages écrites à la main : `a_propos`,
`mentions_legales`, `conditions_generales`, `notre_offre`.

Soit **43 occurrences dans 10 fichiers** : `index.html`, les 5 `components/*.html`,
`pages/ateliers.html`, `pages/mobiliers.html`, `pages/default_mobiliers.html`,
`resources/js/script.js`. Reprise scriptée par `sed`, puis `git mv` pour les 4 pages
manuelles. Ce qui rend l'opération sûre n'est pas la prudence, c'est le test de liens
morts de P0.5 : il valide d'un coup que chaque `href` interne pointe sur un fichier
existant.

`script.js` demande une attention particulière : les slugs y apparaissent à la fois
dans les branches `else if` de `checkURL()` et dans les ids construits. Au passage,
**`demarche_experimentale` est absent de `checkURL()`** (vérifié, 0 occurrence), donc
ce sous-onglet ne s'est jamais surligné. La branche est à ajouter pendant qu'on y est.

## P0.5 Nettoyer l'ancienne arborescence

**Le piège d'exécution de ce commit.** Le script ne sait supprimer que le
**nouveau** nom d'un répertoire (`unlink(folders_dir)` où `folders_dir` est calculé
avec le slug courant). Comme le `kebab-case` renomme 4 répertoires de sous-onglet,
les anciens noms **survivraient intacts** et resteraient publiés :

```
pages/projets/chantiers_participatifs/        11 pages obsoletes, toujours en ligne
pages/projets/chantiers_participatifs.html    listing obsolete
pages/projets/demarche_experimentale/ + .html
pages/mobiliers/ligne_de_mobilier/ + .html
pages/ateliers/ateliers_sur-mesures/ + .html
resources/images/projets/chantiers_participatifs/   etc.
```

Résultat sans nettoyage : le site servirait deux jeux de pages en parallèle, les
anciennes restant indexées, avec des vignettes pointant vers des images dupliquées.
Ce serait pire que le problème de départ.

**Nettoyage explicite avant régénération.** Inventaire vérifié de ce qui est généré
et de ce qui ne l'est pas :

```sh
# 100 % genere
rm -rf pages/projets pages/projets.html
rm -rf pages/mobiliers
rm -rf pages/ateliers/ateliers_sur-mesures pages/ateliers/ateliers_sur-mesures.html

# images : UNIQUEMENT les sous-onglets, jamais le niveau onglet (voir ci-dessous)
rm -rf resources/images/projets/*/ resources/images/mobiliers/*/ resources/images/ateliers/*/
```

⚠️ **Piège dans le piège.** Un `rm -rf resources/images/{projets,mobiliers,ateliers}`
aurait détruit **6 fichiers maintenus à la main** qui vivent au milieu de
l'arborescence générée, dont la plaquette PDF de l'association :

```
resources/images/mobiliers/{1,2}.jpg                      utilises par pages/mobiliers.html
resources/images/ateliers/{1,2}.jpg                       utilises par pages/ateliers.html
resources/images/ateliers/plaquette_ARTICHO.pdf           telechargee depuis notre-offre
resources/images/mobiliers/ligne_de_mobilier/Delphine QUEME ….jpg   illustration du gabarit
```

Les 5 premiers sont au **niveau onglet**, que le script ne touche jamais : il suffit
de ne pas les supprimer. Le 6ᵉ était au niveau **sous-onglet**, donc dans la zone que
le nouveau `unlink` de P1.1 nettoie, et il a été déplacé :

```sh
git mv "resources/images/mobiliers/ligne_de_mobilier/Delphine QUEME pour Maison Montreau_5.jpg" \
       "resources/images/mobiliers/ligne-de-mobilier-intro.jpg"
```

Ce déplacement règle aussi une URL à espaces et capitales, cohérent avec le reste du
commit. Référence mise à jour dans `pages/default_mobiliers.html`.

À préserver absolument : `pages/ateliers.html`, `pages/mobiliers.html`, les 4 pages
statiques, les 3 `pages/default_*.html`, `resources/images/{articles,slideshow,thumbnail}`
(78 Mo) et les 5 fichiers au niveau onglet ci-dessus.

Le `rm -rf` des trois répertoires d'images supprime environ 1,29 Go que le script
recopie depuis `drive/`. Git n'y verra aucun changement là où les octets sont
identiques, seulement les répertoires renommés.

### Rendre ce nettoyage durable : sortir `notre_offre.html`

La seule raison pour laquelle `pages/ateliers/` ne peut pas être supprimé d'un bloc
est que `notre_offre.html`, écrit à la main, vit au milieu de l'arborescence générée.
C'est ce qui force une liste de protection fragile dans tout futur nettoyage.

**Correctif recommandé, à faire dans ce commit** : déplacer la page hors de
l'arborescence générée, là où vivent déjà ses semblables écrites à la main.

```sh
git mv pages/ateliers/notre_offre.html pages/notre-offre.html
```

Après ça, `pages/projets/`, `pages/mobiliers/` et `pages/ateliers/` sont générés à
100 %, donc le script peut les vider lui-même au démarrage sans aucune liste
d'exception, et P1.1 devient un effet de bord gratuit. Les 8 références à
`notre_offre` font déjà partie des 43 occurrences de P0.4, donc ça ne coûte rien de
plus. La branche `notre_offre` de `checkURL()` doit juste matcher le nouveau slug.

## P0.6 Exécution et validation

Travailler sur une branche, pour pouvoir jeter le résultat sans discussion si le
diff part de travers : `git switch -c kebab-urls`.

**Modifier le script** (rien n'est encore régénéré à ce stade)

1. `to_slug()` remplace les 3 sites d'appel, plus `[1]` et `trimws()` à la lecture
   des `.txt` (P0.2, et P2.1 réglé au passage)
2. remonter le `unlink` des images au niveau sous-onglet (P1.1)
3. corriger l'injection `$JS$` : `''` au lieu du `projets_tab.js` inexistant, et
   retirer le `</script>` orphelin (P1.4)
4. ajouter `write_redirect()` et la boucle `redirects.txt` **à la fin** du script
   (P0.3)
5. facultatif, 3 lignes : écrire `urls.tsv` (voir plus bas)

**Préparer les fichiers manuels**

6. `git mv pages/ateliers/notre_offre.html pages/notre-offre.html` (P0.5)
7. reprise des 43 occurrences dans les 10 fichiers manuels, plus la branche
   `demarche-experimentale` manquante dans `checkURL()` (P0.4)
8. créer `redirects.txt`, une ligne active

**Régénérer**

9. nettoyage explicite de l'ancienne arborescence (les 4 `rm -rf` de P0.5)
10. `Rscript make_projet.R`, en lisant les `warning()` éventuels
11. dérouler les 3 tests de validation ci-dessous jusqu'à sortie propre

**Publier**

12. `git add -A`, relire `git status` en entier, vérifier qu'aucun fichier manuel
    n'a disparu, commit
13. merge dans `main`, `git push`
14. build Pages environ une minute, puis
    `curl -I https://collectifarticho.com/pages/mobiliers/agencements/tpmobile.html`
    doit rendre **200** avec le `meta refresh` dans le corps
15. vérifier à la main une page de chaque onglet, en cliquant dans la navigation,
    puisque c'est ce que les 43 occurrences ont touché
16. **scanner le QR code papier pour de vrai**, le seul test qui compte vraiment

Validation :

```sh
# 1. aucun caractere non conforme ne subsiste dans un nom de fichier
find pages resources/images | LC_ALL=C grep -P '[^\x20-\x7E]|[][!()&+,_\x20]'
echo "^ doit etre vide"

# 2. tout lien interne pointe sur un fichier existant
grep -rhoE '(href|src)="/[^"]+"' index.html pages components resources/js \
  | sed -E 's/.*="\/([^"]+)"/\1/' | sort -u \
  | while read -r p; do [ -e "$p" ] || echo "LIEN MORT: /$p"; done

# 3. le stub existe et cible la bonne page
grep -l 'tpmob-theatre-public-mobile' pages/mobiliers/agencements/tpmobile.html
```

Le test 2 est le garde-fou réutilisable, à relancer après tout changement de slug.
Lancé sur l'état actuel du dépôt il remonte déjà 2 liens morts préexistants
(`projets_tab.js`, `ateliers_tab.js`), qui sont le § P1.4 : tant qu'il n'est pas
corrigé, la sortie attendue est **ces deux lignes et rien d'autre**. Le test 1
remonte 186 chemins non conformes aujourd'hui et doit être vide après P0 plus P1.1.

### Revenir en arrière si besoin

Le merge est un commit de fusion, donc le retour en arrière prend un `-m 1` :

```sh
git revert -m 1 9ca5bf3 && git push     # remet les anciennes URL en ligne
```

À n'envisager que si quelque chose de visible casse. Ça remettrait l'URL du QR code
en 404, donc ce serait un échange d'un problème contre l'autre : mieux vaut corriger
en avant.

### L'inventaire des URL, pour l'historique

Plutôt qu'une table de redirections, faire générer par le script un fichier
`urls.tsv` committé, une ligne par page : dossier `drive/` d'origine, puis URL
produite. La liste est déjà en mémoire dans `Folders_path`, donc c'est environ
3 lignes de R.

Intérêt : `git log -p urls.tsv` donne l'état des lieux de **quelle URL a changé et
quand**, lisible d'un coup, sans archéologie dans l'historique de `pages/`. Si un
jour une ancienne URL doit être retrouvée, elle est là. C'est la réponse légère à
« git pourrait suffire » : git suffit, et ce fichier rend sa réponse lisible.

---

# Backlog, par ordre de rentabilité

## P1.1 Répertoires d'images orphelins 🔴 ✅ fait

`resources/images/mobiliers/agencements/tpmobile` pèse **15 Mo** et n'est plus
référencé par aucune page. Le script fait `unlink()` sur le **nouveau** nom de projet
seulement, donc chaque renommage laisse un orphelin, et P0 va en créer **53 d'un
coup** puisque tous les slugs changent. Plusieurs centaines de Mo, sur 1,4 Go déjà.

**C'est le seul point du backlog à traiter dans le même commit que P0**, sinon le
dépôt gonfle inutilement. Correctif : remonter le `unlink` au niveau sous-onglet,
juste à côté du `unlink(folders_dir)` existant :

```r
subtab_resource_dir = file.path(resource_dir, to_slug(tab), to_slug(subtab))
unlink(subtab_resource_dir, recursive=TRUE)
dir.create(subtab_resource_dir, recursive=TRUE)
```

Puis supprimer le `unlink(folder_resource_dir, ...)` par projet, en gardant le
`dir.create`. Les renommages deviennent auto-nettoyants. Pas de régression de perf :
le script recopie déjà tout à chaque run, et `git` ne voit rien si les octets sont
identiques.

## P1.2 Métadonnées absentes sur les pages projet 🟠

`default_projet.html` a `<title>ARTI/CHÔ</title>` **en dur**, aucune
`meta description`, aucun `og:`. Donc tous les onglets du navigateur portent le même
nom, Google affiche le même titre pour 53 pages, et tout partage d'un projet sur un
réseau social sort un aperçu générique **sans image**.

Or le script a déjà `title_text`, `subtitle_text` et la 1ʳᵉ image sous la main.
Correctif d'environ 6 lignes : ajouter `$HEAD$` au gabarit et injecter `<title>`,
`meta description` (depuis `soustitre.txt`), `og:title`, `og:description`,
`og:image` (l'image principale, en URL absolue, car les `og:` exigent de l'absolu ;
celui d'`index.html` est d'ailleurs relatif, donc probablement ignoré).

Meilleur rapport visible sur effort du backlog après P0.

## P1.3 Pas de `404.html` 🟠

Les URL mortes tombent sur la 404 générique de GitHub, hors charte. Une `404.html` à
la racine (GitHub Pages la sert automatiquement) dans le design du site, avec les
liens vers les 3 onglets, rattrape proprement toutes les URL cassées par P0 sans
aucune table de redirection. C'est exactement le filet que le cadrage appelle :
l'association accepte que les anciennes URL cassent, autant qu'elles cassent avec
élégance.

Option utile : si le chemin ressemble à `/pages/<onglet>/<sous-onglet>/<slug>.html`,
proposer en JS la page de listing `/pages/<onglet>/<sous-onglet>.html` plutôt
qu'une impasse.

## P1.4 Résidus de refactor dans l'injection `$JS$` 🟠 ✅ fait

Deux bugs réels, confirmés en production, trouvés par le test 2 :

**a) 404 à chaque visite de la page Projets.** La branche page d'onglet émet encore :

```r
paste0('	<script src="/resources/js/', to_link(tab), '_tab.js"></script>')
```

`pages/projets.html:23` charge donc `/resources/js/projets_tab.js`, **qui n'existe
pas** (`resources/js/` ne contient que `gallery.js` et `script.js`). Vérifié en
ligne : **404**. Les deux autres branches ont été migrées vers `script.js`, celle-ci
a été oubliée. Correctif : injecter `''`, comme la branche projet juste au-dessus.

**b) Balise `</script>` orpheline.** La branche « Ligne de mobilier » émet
`paste0('	</script>\n', ...)`, dont le `</script>` de tête ne ferme rien.
`pages/mobiliers/ligne_de_mobilier.html:23` contient donc une balise fermante
orpheline dans le `<head>`. La récupération d'erreur des navigateurs l'ignore, donc
rien ne casse visiblement, mais le HTML est invalide. Correctif : supprimer le
`'</script>\n'`.

Après correction, `grep -rn '_tab.js' pages/` ne doit plus rien rendre. La seule
occurrence restante, dans `pages/ateliers/notre_offre.html:21`, est en commentaire
HTML, inoffensive, à nettoyer au passage.

## P2.1 Fragilité `readLines` sur les fichiers de contenu 🟡 ✅ fait

`folder_name = tolower(gsub(" ", "_", readLines(".../titre.txt")))` : si un
`titre.txt` contient 2 lignes, `folder_name` devient un **vecteur**, donc
`folder_path` aussi, et `writeLines(folder, folder_path)` part en erreur ou écrit au
mauvais endroit. Idem pour `soustitre.txt`.

Vérifié, tous les `titre.txt` sont sur une ligne **aujourd'hui**. C'est une bombe à
retardement côté association, pas un bug actuel. Le `[1]` et le `trimws()` de P0.5
règlent les deux sujets d'un coup.

## P2.2 Aucune validation du contenu entrant 🟡

`readLines(file.path(folder_drive_path, "titre.txt"))` échoue avec une erreur R brute
si le fichier manque. L'association ajoute un projet sans `soustitre.txt` ou sans
`info.txt` et tout le run casse, sans dire lequel des 59 dossiers est en cause.

Correctif : une boucle de pré-vol qui vérifie la présence des 4 `.txt` et d'au moins
une image dans chaque dossier `drive/`, et liste **tous** les manques d'un coup avant
de générer quoi que ce soit. C'est le point qui fera gagner le plus de temps le jour
où quelqu'un d'autre que toi lancera le script.

## P2.4 Noms de fichiers d'images non assainis 🟡

Les **répertoires** d'images sont maintenant propres, mais les **noms de fichiers**
sont recopiés verbatim depuis `drive/` (`img = basename(img_path)`), donc 15 d'entre
eux portent des espaces, des accents ou un `©` :

```
©MarcelaBarrios__0322.jpg      Capture d’écran 2025-05-20 à 14.38.06.png
PERMIS VEGETAL (4).jpg         célébration 1.jpg
372593-Residence artistique Clos Saint-Lazare-Jeremy Piot   Plaine Commune.jpg
```

Vérifié : les 418 ressources référencées par le site répondent, ces 15 incluses, une
fois l'URL percent-encodée, ce que les navigateurs font seuls. Donc rien n'est cassé,
et personne ne partage ni n'imprime l'URL d'une image.

Laissé en dehors de P0 volontairement : renommer à la copie ajouterait un risque de
collision sur 1,4 Go d'images pour un gain invisible. Si on y vient, passer le
`basename` dans `to_link()` en préservant l'extension, et vérifier l'absence de
collision par dossier avant d'écrire.

## P2.3 `$TITLE$` injecté sans échappement 🟡

Les titres passent dans `gsub(pattern, replacement, ...)` en position de
*remplacement*, donc un `\` dans un `titre.txt` serait interprété comme une
backréférence et corromprait la page. Aucun titre actuel n'en contient.
Correctif : `fixed=TRUE` là où c'est possible, ou échapper les `\`.

## P3.1 Pas de `sitemap.xml` ni de `robots.txt` 🔵

Trivial à générer dans le même script, la liste des pages est déjà en mémoire dans
`Folders_path`. Aiderait Google à absorber d'un coup le changement complet d'URL de
P0 et à désindexer les anciennes.

## P3.2 Slugs d'onglet dupliqués en 3 endroits 🔵

Un slug de sous-onglet est écrit dans les `href` des composants, dans leurs `id` et
dans les branches `else if` de `checkURL()`. Rien ne garantit la cohérence, et on en
voit déjà deux traces : `id="projets_subtab-signaletique"` au singulier au milieu de
`signaletiques` partout ailleurs (ça marche parce que `script.js` reproduit la même
faute de frappe), et la branche `demarche_experimentale` purement absente.

Correctif propre : générer `components/header.html` et la table de `checkURL()`
depuis l'arborescence `drive/`, comme le reste. C'est le dernier morceau du site
encore écrit à la main alors qu'il est entièrement déductible des données, et ça
supprimerait d'emblée tout le travail de P0.4.

## P3.3 `resources/images` à environ 1,4 Go dans git 🔵

Les images sont committées **et** présentes dans `drive/`, donc le dépôt porte deux
copies de chaque photo, et chaque run réécrit les fichiers. Un clone est lourd et
l'historique ne dégonflera jamais. Rien d'urgent pour un site qui marche, mais à
garder en tête avant d'ajouter beaucoup de projets.

## P3.4 Hygiène dépôt 🔵

`tmp.txt` et `.directory` ne sont ni suivis ni ignorés (`tmp.txt~` l'est via `*~`).
À ajouter au `.gitignore` ou à supprimer. Les 26 `.DS_Store` de `drive/`, eux, sont
committés : ils viennent du miroir macOS et peuvent être ignorés sans risque.

---

# Pérennité des URL : piste gardée pour plus tard

**Hors périmètre de P0, documenté pour ne pas le reperdre.** Décidé le 2026-09-11 :
on assume des URL dérivées des titres, et on traite le cas du QR par une redirection.
La question de la pérennité se posera quand il y aura plus de supports imprimés.

## Le constat de fond

Une URL dérivée d'un titre est structurellement fragile, c'est l'argument de
*Cool URIs don't change* : ne pas mettre dans une URI ce qui est susceptible de
changer. Or l'association renomme ses titres quand elle veut (voir `CLAUDE.md`,
§ *Le dossier `drive/` est un miroir en lecture seule*). Chaque renommage casse une
URL. Pour un site web ça n'a pas d'importance, l'association l'a dit. Pour un support
**imprimé**, c'est irréversible.

## Pourquoi pas des UUID dans les URL

L'idée de mettre un identifiant fixe en base de données dans l'URL est légitime dans
l'absolu, c'est ce que font Zenodo, Dataverse, les DOI, les ARK et les Handle. Mais
elle ne transpose pas ici, pour une raison rédhibitoire :

**un UUID ne résout pas le problème d'identité, il le déplace.** Un UUID doit être
stocké et lié à un projet. Pas dans `drive/`, qui est en lecture seule, donc dans un
fichier de correspondance du dépôt, indexé par le chemin du dossier `drive/`, c'est-à-dire
par la clé fragile elle-même. Le jour où l'association renomme `02_TPMob` en
`03_TPMobile`, la clé casse, le script ne reconnaît plus le projet, frappe un nouvel
UUID, et l'URL change. On aurait payé des URL illisibles sans acheter la permanence.

Un UUID n'est permanent que si l'identifiant vit **avec** l'objet. C'est ce qui fait
marcher un DOI : l'identifiant fait partie de l'enregistrement. Ici ça voudrait dire
demander à l'association de maintenir un `uuid.txt` dans chaque dossier de son Drive,
donc exactement ce qu'on a décidé de ne pas faire.

Accessoirement, le site est une vitrine et pas un dépôt : les URL descriptives
portent du référencement, se lisent à voix haute et se partagent, et un UUID de 36
caractères densifie inutilement un QR code, donc le rend moins scannable imprimé
petit.

## Ce qui se transplante vraiment : le résolveur

PURL, ARK et DOI ne marchent pas grâce à l'opacité de leurs identifiants, mais parce
qu'ils **séparent l'identifiant du localisateur**. Un identifiant court et stable
*résout* vers l'endroit où la chose se trouve actuellement. Ça s'implémente en
statique :

```
/p/tpmob                                                  identifiant permanent (stub)
    └──> /pages/mobiliers/agencements/tpmob-theatre-public-mobile     page reelle, lisible
```

On imprime `/p/tpmob` sur tout support physique, on utilise l'URL descriptive en
ligne. Quand le titre change, seule la cible du stub est régénérée, et le QR imprimé
ne casse jamais. C'est la même fonction `write_redirect()` que P0.3, donc le coût
marginal est presque nul.

**Vérifié en ligne** : GitHub Pages sert les URL sans extension. `/pages/contact`
rend 200, `/pages/mobiliers/agencements/totems` aussi. Donc le permalien s'écrit
`collectifarticho.com/p/tpmob`, servi par un fichier `p/tpmob.html` : court, sans
extension, sans encodage, peu de modules dans le QR, dictable au téléphone.

## Si on y vient un jour

- Frapper un permalien **seulement pour ce qui part à l'impression**, jamais pour les
  53 pages. Un fichier curé à la main où l'on remarque qu'une ligne demande attention
  vaut mieux que 53 identifiants auto-frappés sur une clé fragile.
- Code mnémotechnique (`tpmob`) plutôt qu'opaque : l'opacité ne sert qu'à éviter de
  suggérer du sens, ce qui n'est pas le cas ici, alors qu'un code lisible se recopie
  depuis une affiche.
- Le point à accepter : `/p/tpmob` est permanent parce que **personne ne le dérive de
  quoi que ce soit**. Sa stabilité vient d'un engagement humain, pas d'une propriété
  de l'identifiant. C'est le vrai enseignement de *Cool URIs*, et c'est ce que
  l'UUID fait croire à tort qu'on peut obtenir par la technique.
