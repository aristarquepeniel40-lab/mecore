# Pipeline MEverse — objet de premiere classe pour la tracabilite

Capture explicitement l'enchainement d'operations plutot que de le
laisser implicite dans un simple `|>`. Permet de serialiser, rejouer et
journaliser un pipeline complet — important en M&E, ou l'auditabilite du
calcul compte autant que le resultat (idee \#6).

## Usage

``` r
me_pipeline(steps = list(), log = list())
```

## Arguments

- steps:

  Liste de fonctions nommees, appliquees dans l'ordre.

- log:

  Liste des etapes deja executees (horodatage + nom).
