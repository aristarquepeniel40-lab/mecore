# Valider un objet MEverse

Retourne l'objet inchange si valide (pour permettre le chainage avec le
pipe natif `|>`) ; leve une condition `me_validation_error` sinon.

## Usage

``` r
me_validate(x, ...)
```

## Arguments

- x:

  Un objet MEverse (Project, Dataset, Indicator, ...).

- ...:

  Arguments additionnels passes aux methodes.
