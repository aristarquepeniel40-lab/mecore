# Verifie qu'un data.frame respecte un me_schema

Verifie qu'un data.frame respecte un me_schema

## Usage

``` r
check_schema(data, schema)
```

## Arguments

- data:

  Un data.frame.

- schema:

  Un `me_schema`.

## Value

`TRUE` invisible si conforme ; leve `me_validation_error` sinon.
