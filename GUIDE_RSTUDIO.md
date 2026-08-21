# Guide d’intégration — package mecore dans RStudio

Tout le code de cette archive a été **écrit puis réellement exécuté et
testé** (R 4.3.3 + S7 0.2.2.9000, environnement Linux) avant d’être
livré. Quatre bugs ont été trouvés et corrigés pendant les tests (voir
§9 de `ARCHITECTURE.md`) : la faute de casse `class_date`/`class_Date`,
la collision `validate()` avec
[`S7::validate()`](https://rconsortium.github.io/S7/reference/validate.html),
un bug de validation sur une chaîne vide (`unit=""`), et un **bug
d’ordre de chargement des fichiers** (`dashboard_report.R` référence
`me_project`, chargé après lui par ordre alphabétique) — corrigé en
préfixant les fichiers `R/` par un numéro (`00_generics.R`,
`01_conditions.R`, …) et en ajoutant un champ `Collate:` dans
`DESCRIPTION` en double sécurité. Ce dernier bug ne s’est révélé qu’à
l’usage réel de `devtools::load_all()` de ton côté — merci de l’avoir
signalé, c’est corrigé dans cette version.

Avec RStudio 4.6.1 (plus récent), le comportement doit être identique.

## 1. Préparer le projet

Si `mecore` n’est pas encore un projet RStudio structuré comme package :

``` r

install.packages(c("usethis", "devtools", "S7", "testthat", "roxygen2"))
usethis::create_package("chemin/vers/mecore")   # si le package n'existe pas encore
```

Si le package existe déjà (comme décrit dans ton rapport d’avancement),
ouvre-le simplement dans RStudio (`File > Open Project`).

## 2. Copier les fichiers

Copie le contenu de cette archive dans ton projet :

- `R/*.R` → dans le dossier `R/` de ton package (remplace/complète
  l’existant)
- `tests/testthat/test-domain-model.R` → dans `tests/testthat/`
- `DESCRIPTION` → à fusionner avec ton `DESCRIPTION` existant (ne pas
  écraser si tu as déjà des champs personnalisés — garde `Package`,
  `Version`, etc. et ajoute simplement `Imports: S7` et les `Suggests`)
- `walking_skeleton.R` → où tu veux (ex. à la racine, ou dans `dev/`)

## 3. Installer S7

``` r

install.packages("S7")
```

## 4. Charger et tester

``` r

devtools::load_all(".")     # charge le package en développement
source("walking_skeleton.R") # doit afficher "Walking skeleton OK"
```

Puis lance les tests :

``` r

devtools::test()
```

## 5. Vérifier qu’aucune fonction n’est masquée

``` r

devtools::load_all(".")
conflicts <- conflicts(detail = TRUE)
print(conflicts)
```

C’est cette vérification qui aurait immédiatement révélé la collision
`validate()`/[`S7::validate()`](https://rconsortium.github.io/S7/reference/validate.html)
— bon réflexe à prendre systématiquement après l’ajout de tout nouveau
générique.

## 6. Documenter

``` r

devtools::document()   # génère NAMESPACE + fichiers .Rd depuis les commentaires roxygen2
devtools::check()      # R CMD check complet
```

## 7. Prochaine étape suggérée

Une fois ceci intégré et `devtools::check()` propre : 1. Committer avec
un message clair (ex.
`feat: implement domain model (mecore) per ARCHITECTURE.md`). 2. Ouvrir
`ARCHITECTURE.md` en v1.0 (retirer le statut DRAFT) puisque le Walking
Skeleton (§7) est maintenant validé. 3. Commencer `meindicator` en
suivant les règles de dépendances du §4.
