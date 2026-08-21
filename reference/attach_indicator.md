# Rattacher un indicateur calcule a un resultat existant d'un logframe

Complement naturel de
[`import_logframe_xlsx()`](https://aristarquepeniel40-lab.github.io/mecore/reference/import_logframe_xlsx.md)
: une fois un vrai `me_indicator` calcule (avec un vrai `me_dataset`
source) pour une ligne de `pending_indicators`, cette fonction l'insere
proprement dans le `me_result` correspondant, par son libelle.

## Usage

``` r
attach_indicator(logframe, result_label, indicator)
```

## Arguments

- logframe:

  Un `me_logframe`.

- result_label:

  Libelle exact du `me_result` cible (voir
  `pending_indicators$resultat`).

- indicator:

  Un
  [`mecore::me_indicator`](https://aristarquepeniel40-lab.github.io/mecore/reference/me_indicator.md)
  deja calcule.

## Value

Le `me_logframe` mis a jour.
