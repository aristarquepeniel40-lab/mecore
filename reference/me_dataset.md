# Jeu de donnees MEverse

Conteneur pour des donnees brutes ou nettoyees. `mecore` ne definit que
la structure ; la logique de nettoyage/import appartient a `medata`.

## Usage

``` r
me_dataset(
  name = character(0),
  data = (function (.data = list(), row.names = NULL) 
 {
     if (is.null(row.names)) {

            list2DF(.data)
     }
     else {
         out <- list2DF(.data,
    length(row.names))
attr(out, "row.names") <- row.names
         out
     }

    })(),
  metadata = me_metadata()
)
```

## Arguments

- name:

  Nom court du dataset (ex. "baseline_2026").

- data:

  Un `data.frame`.

- metadata:

  Un objet `me_metadata`.
