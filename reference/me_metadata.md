# Metadonnees d'un projet MEverse

Decrit un projet AVANT toute donnee, indicateur ou rapport : nom,
organisation porteuse, pays, bailleur, responsable, dates, version,
description, objectifs.

## Usage

``` r
me_metadata(
  project_name = character(0),
  organization = character(0),
  country = character(0),
  donor = character(0),
  manager = character(0),
  start_date = (function (.data = double()) 
 {
     .Date(.data)
 })(),
  end_date = (function (.data = double()) 
 {
     .Date(.data)
 })(),
  version = character(0),
  description = character(0),
  objectives = character(0),
  sdgs = character(0)
)
```

## Arguments

- project_name:

  Nom du projet.

- organization:

  Organisation porteuse (ex. "Ministere de la Sante").

- country:

  Pays de mise en oeuvre.

- donor:

  Bailleur (ex. "Banque mondiale").

- manager:

  Responsable du projet.

- start_date:

  Date de debut (classe R `Date`).

- end_date:

  Date de fin (classe R `Date`).

- version:

  Version du projet/document (ex. "1.0").

- description:

  Description libre du projet.

- objectives:

  Objectifs du projet (vecteur de caracteres).

- sdgs:

  Codes ODD associes (ex. c("1.1.1", "4.1.1")).

## Details

Principe de conception (choix explicite) : ce fichier decrit UNIQUEMENT
la structure d'un `me_metadata`. Il ne contient aucune logique metier,
aucun calcul, aucune lecture de fichier, aucune validation au-dela du
typage natif de S7 (`properties`). Toute coherence a verifier entre
champs (ex. `end_date` \>= `start_date`) est volontairement laissee a
une fonction separee, hors de la classe (voir ARCHITECTURE.md §2.4).
