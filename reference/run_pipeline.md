# Executer un pipeline sur un objet, avec journalisation

Executer un pipeline sur un objet, avec journalisation

## Usage

``` r
run_pipeline(pipeline, x)
```

## Arguments

- pipeline:

  Un `me_pipeline`.

- x:

  Objet de depart (ex. un `me_project`).

## Value

Une liste `list(result = ..., pipeline = ...)` ; `pipeline` contient le
journal d'execution mis a jour (horodatage, nom d'etape).
