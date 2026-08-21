# Indicateur MEverse

Definition + valeur calculee d'un indicateur. `mecore` ne definit que la
structure ; le calcul reel appartient a `meindicator`.

## Usage

``` r
me_indicator(
  label = character(0),
  formula = (function (.data) 
 {
    
    stop(sprintf("S3 class <%s> doesn't have a constructor", class[[1]]), call. =
    FALSE)
 })(),
  datasets = list(),
  value = NULL,
  unit = character(0)
)
```

## Arguments

- label:

  Libelle lisible (ex. "Age moyen des enquetes").

- formula:

  Formule R (objet `formula`) definissant le calcul.

- datasets:

  Liste de `me_dataset` sources (1 ou plus).

- value:

  Valeur calculee (NULL tant que non calculee).

- unit:

  Unite de mesure (ex. "annees", "%"). Peut etre vide si `value` non
  numerique.

## Details

Invariant : un indicateur reference toujours au moins un `me_dataset`
source (interdiction de l'indicateur "orphelin", cf. ARCHITECTURE.md
§2.2).
