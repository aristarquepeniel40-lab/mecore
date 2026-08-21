# Projet MEverse

Racine agregeante. Un `me_project` a exactement une `me_metadata`, zero
ou plusieurs `me_dataset`, zero ou plusieurs `me_indicator`, au plus un
`me_logframe`. Voir ARCHITECTURE.md §2.2.

## Usage

``` r
me_project(
  name = character(0),
  metadata = me_metadata(),
  datasets = list(),
  indicators = list(),
  logframe = me_logframe()
)
```

## Arguments

- name:

  Nom du projet.

- metadata:

  Un objet `me_metadata`.

- datasets:

  Liste de `me_dataset` (peut etre vide).

- indicators:

  Liste de `me_indicator` (peut etre vide).

- logframe:

  `me_logframe` ou `NULL`.
