# Contrat de schema pour un Dataset

Definit les colonnes attendues d'un `me_dataset` (nom, type, label).
Consomme par `medata` (validation a l'import) et `mecheck` (controle
qualite), evitant que chaque package reinvente sa propre notion de
"colonnes attendues". Inspire de Frictionless Data Table Schema.

## Usage

``` r
me_schema_field(
  name = character(0),
  type = character(0),
  label = character(0),
  required = logical(0)
)
```

## Arguments

- name:

  Nom du champ, doit correspondre a une colonne du data.frame.

- type:

  Type attendu : "character", "double", "integer", "logical", "Date".

- label:

  Libelle humain (pour affichage / rapports).

- required:

  Le champ est-il obligatoire ?
