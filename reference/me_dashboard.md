# Tableau de bord MEverse

Ne stocke jamais de donnees : reference des `me_indicator` deja calcules
(principe de non-duplication d'etat, ARCHITECTURE.md §2.2).

## Usage

``` r
me_dashboard(title = character(0), indicators = list())
```

## Arguments

- title:

  Titre du tableau de bord.

- indicators:

  Liste de `me_indicator` a afficher (1 ou plus).
