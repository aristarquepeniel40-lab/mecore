# Rapport MEverse

Assemble narratif + indicateurs + (optionnellement) un dashboard. Ne
stocke pas de donnees, uniquement des references.

## Usage

``` r
me_report(
  project = me_project(),
  indicators = list(),
  dashboard = me_dashboard(),
  narrative = character(0)
)
```

## Arguments

- project:

  Le `me_project` d'origine.

- indicators:

  Liste de `me_indicator` inclus dans le rapport.

- dashboard:

  `me_dashboard` optionnel.

- narrative:

  Texte narratif (peut etre vide au moment de la creation).
