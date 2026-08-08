#' Projet MEverse
#'
#' Racine agregeante. Un `me_project` a exactement une `me_metadata`,
#' zero ou plusieurs `me_dataset`, zero ou plusieurs `me_indicator`,
#' au plus un `me_logframe`. Voir ARCHITECTURE.md §2.2.
#'
#' @param name Nom du projet.
#' @param metadata Un objet `me_metadata`.
#' @param datasets Liste de `me_dataset` (peut etre vide).
#' @param indicators Liste de `me_indicator` (peut etre vide).
#' @param logframe `me_logframe` ou `NULL`.
#' @export
me_project <- S7::new_class(
  "me_project",
  package = "mecore",
  properties = list(
    name       = S7::class_character,
    metadata   = me_metadata,
    datasets   = S7::class_list,
    indicators = S7::class_list,
    logframe   = S7::new_union(me_logframe, NULL)
  ),
  validator = function(self) {
    if (!all(vapply(self@datasets, S7::S7_inherits, logical(1), class = me_dataset))) {
      return("`datasets` doit etre une liste de `me_dataset`")
    }
    if (!all(vapply(self@indicators, S7::S7_inherits, logical(1), class = me_indicator))) {
      return("`indicators` doit etre une liste de `me_indicator`")
    }
    NULL
  }
)

#' @noRd
S7::method(me_validate, me_project) <- function(x, ...) {
  # delegue aux invariants du validator S7 (leve automatiquement si invalide)
  # + validation du logframe s'il existe
  if (!is.null(x@logframe)) me_validate(x@logframe)
  invisible(x)
}
