# Importer un cadre logique depuis un gabarit Excel usuel

Attend un fichier avec au minimum les colonnes : Objectif, Resultat,
Indicateur, Unite (Hypotheses optionnelle).

## Usage

``` r
import_logframe_xlsx(path)
```

## Arguments

- path:

  Chemin du fichier .xlsx.

## Value

Une liste `list(logframe, pending_indicators)` : `logframe` est un
`me_logframe` (resultats sans indicateurs pour l'instant) ;
`pending_indicators` est un `data.frame` (`resultat`, `indicateur`,
`unite`) listant les indicateurs a completer.

## Details

IMPORTANT (correctif – bug trouve en testant avec le vrai openxlsx) : un
indicateur importe depuis Excel n'a pas de `me_dataset` source, et
l'invariant "pas d'indicateur orphelin" de
[`mecore::me_indicator`](https://aristarquepeniel40-lab.github.io/mecore/reference/me_indicator.md)
empeche d'en construire un valide a ce stade. La version precedente de
cette fonction calculait les infos d'indicateurs importes (label, unite)
puis les jetait silencieusement – perte de donnees invisible, seulement
visible en testant un vrai cycle export/import. Corrige : ces
informations sont maintenant retournees a part, dans
`pending_indicators`, pour etre completees via
[`attach_indicator()`](https://aristarquepeniel40-lab.github.io/mecore/reference/attach_indicator.md)
une fois un vrai dataset disponible.
