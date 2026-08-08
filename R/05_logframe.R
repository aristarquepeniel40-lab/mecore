#' Resultat d'un cadre logique
#'
#' @param label Libelle du resultat (ex. "R1 : acces ameliore aux services").
#' @param indicators Liste de `me_indicator` associes (peut etre vide en construction).
#' @export
me_result <- S7::new_class(
  "me_result",
  package = "mecore",
  properties = list(
    label      = S7::class_character,
    indicators = S7::class_list
  )
)

#' Cadre logique MEverse
#'
#' Un `me_project` a au plus UN `me_logframe` actif (cardinalite 0..1).
#'
#' @param goal Objectif general.
#' @param results Liste de `me_result`.
#' @param hypotheses Liste de chaines de caracteres (hypotheses/risques).
#' @export
me_logframe <- S7::new_class(
  "me_logframe",
  package = "mecore",
  properties = list(
    goal       = S7::class_character,
    results    = S7::class_list,
    hypotheses = S7::class_character
  )
)

#' Validation "finale" d'un cadre logique
#'
#' Contrairement au validator de classe (verifie a chaque instanciation),
#' cette validation ne s'applique que quand on considere le logframe
#' termine : chaque `me_result` doit alors avoir au moins un indicateur.
#' Voir ARCHITECTURE.md §2.3.
#'
#' Note : seul le generique `me_validate` (voir 00_generics.R) est exporte.
#' Cette methode n'a pas besoin de sa propre page de documentation.
#' @noRd
S7::method(me_validate, me_logframe) <- function(x, ...) {
  incomplets <- Filter(function(r) length(r@indicators) == 0, x@results)
  if (length(incomplets) > 0) {
    labels <- vapply(incomplets, function(r) r@label, character(1))
    me_validation_error(sprintf(
      "resultat(s) sans indicateur associe : %s",
      paste(labels, collapse = ", ")
    ))
  }
  x
}
