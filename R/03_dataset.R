#' Jeu de donnees MEverse
#'
#' Conteneur pour des donnees brutes ou nettoyees. `mecore` ne definit
#' que la structure ; la logique de nettoyage/import appartient a `medata`.
#'
#' @param name Nom court du dataset (ex. "baseline_2026").
#' @param data Un `data.frame`.
#' @param metadata Un objet `me_metadata`.
#' @export
me_dataset <- S7::new_class(
  "me_dataset",
  package = "mecore",
  properties = list(
    name     = S7::class_character,
    data     = S7::class_data.frame,
    metadata = me_metadata
  ),
  validator = function(self) {
    if (nrow(self@data) == 0) {
      return("`data` ne peut pas etre vide")
    }
    NULL
  }
)
