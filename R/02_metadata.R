#' Metadonnees d'un projet MEverse
#'
#' Decrit un projet AVANT toute donnee, indicateur ou rapport : nom,
#' organisation porteuse, pays, bailleur, responsable, dates, version,
#' description, objectifs.
#'
#' Principe de conception (choix explicite) : ce fichier decrit UNIQUEMENT
#' la structure d'un `me_metadata`. Il ne contient aucune logique metier,
#' aucun calcul, aucune lecture de fichier, aucune validation au-dela du
#' typage natif de S7 (`properties`). Toute coherence a verifier entre
#' champs (ex. `end_date` >= `start_date`) est volontairement laissee a
#' une fonction separee, hors de la classe (voir ARCHITECTURE.md §2.4).
#'
#' @param project_name Nom du projet.
#' @param organization Organisation porteuse (ex. "Ministere de la Sante").
#' @param country Pays de mise en oeuvre.
#' @param donor Bailleur (ex. "Banque mondiale").
#' @param manager Responsable du projet.
#' @param start_date Date de debut (classe R `Date`).
#' @param end_date Date de fin (classe R `Date`).
#' @param version Version du projet/document (ex. "1.0").
#' @param description Description libre du projet.
#' @param objectives Objectifs du projet (vecteur de caracteres).
#' @param sdgs Codes ODD associes (ex. c("1.1.1", "4.1.1")).
#' @export
me_metadata <- S7::new_class(
  "me_metadata",
  package = "mecore",
  properties = list(
    project_name = S7::class_character,
    organization = S7::class_character,
    country      = S7::class_character,
    donor        = S7::class_character,
    manager      = S7::class_character,
    # Correctif : S7::class_date n'existe pas -> S7::class_Date (D majuscule)
    start_date   = S7::class_Date,
    end_date     = S7::class_Date,
    version      = S7::class_character,
    description  = S7::class_character,
    objectives   = S7::class_character,
    sdgs         = S7::class_character
  )
)
