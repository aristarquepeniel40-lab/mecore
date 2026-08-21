# mecore

[![R-CMD-check](https://github.com/aristarquepeniel40-lab/mecore/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/aristarquepeniel40-lab/mecore/actions/workflows/R-CMD-check.yaml)

**Fondations de l’écosystème [MEverse](#l%C3%A9cosyst%C3%A8me-meverse)
pour le suivi-évaluation (M&E).**

`mecore` définit les classes de base — `Project`, `Metadata`, `Dataset`,
`Indicator`, `Logframe`, `Dashboard`, `Report` — utilisées par tous les
autres packages MEverse. Il ne contient aucune logique métier (pas de
calcul d’indicateurs, pas de génération de rapport) : uniquement la
structure et les conventions communes.

Architecture inspirée du [tidyverse](https://www.tidyverse.org/) : un
écosystème de packages interopérables plutôt qu’un package monolithique.
Construit avec [S7](https://rconsortium.github.io/S7/), le système objet
nouvelle génération pour R.

## Installation

``` r

install.packages("remotes")
remotes::install_github("aristarquepeniel40-lab/mecore")
```

## Exemple rapide

``` r

library(mecore)

meta <- me_metadata(
  project_name = "Suivi agricole", organization = "Ministere de l'Agriculture",
  country = "Benin", donor = "Banque mondiale", manager = "A. Segue",
  start_date = as.Date("2026-01-01"), end_date = as.Date("2026-12-31"),
  version = "1.0", description = "Suivi des rendements agricoles",
  objectives = "Ameliorer les rendements", sdgs = c("2.3.1")
)

d <- me_dataset(
  name = "exploitants",
  data = data.frame(age = c(20, 35, 42), rendement = c(1200, 2400, 1800)),
  metadata = meta
)

p <- me_project(name = "Suivi agricole", metadata = meta,
                 datasets = list(d), indicators = list(), logframe = NULL)
```

## L’écosystème MEverse

| Package | Rôle |
|----|----|
| **mecore** | Modèle de domaine (ce dépôt) |
| [medata](https://github.com/aristarquepeniel40-lab/medata) | Import (CSV/Excel), validation de schéma, rapport de qualité |
| [meindicator](https://github.com/aristarquepeniel40-lab/meindicator) | Calcul d’indicateurs, y compris désagrégés par groupe |
| [mecheck](https://github.com/aristarquepeniel40-lab/mecheck) | Contrôle de cohérence à l’échelle d’un projet complet |
| [mereport](https://github.com/aristarquepeniel40-lab/mereport) | Génération de rapports Markdown |

Voir
[`ARCHITECTURE.md`](https://aristarquepeniel40-lab.github.io/mecore/ARCHITECTURE.md)
pour la conception détaillée, l’historique des décisions, et les leçons
techniques rencontrées en construisant cet écosystème.

## Licence

MIT — voir
[`LICENSE`](https://aristarquepeniel40-lab.github.io/mecore/LICENSE).
