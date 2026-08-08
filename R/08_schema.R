#' Contrat de schema pour un Dataset
#'
#' Definit les colonnes attendues d'un `me_dataset` (nom, type, label).
#' Consomme par `medata` (validation a l'import) et `mecheck` (controle
#' qualite), evitant que chaque package reinvente sa propre notion de
#' "colonnes attendues". Inspire de Frictionless Data Table Schema.
#'
#' @param name Nom du champ, doit correspondre a une colonne du data.frame.
#' @param type Type attendu : "character", "double", "integer", "logical", "Date".
#' @param label Libelle humain (pour affichage / rapports).
#' @param required Le champ est-il obligatoire ?
#' @export
me_schema_field <- S7::new_class(
  "me_schema_field",
  package = "mecore",
  properties = list(
    name     = S7::class_character,
    type     = S7::class_character,
    label    = S7::class_character,
    required = S7::class_logical
  ),
  validator = function(self) {
    types_valides <- c("character", "double", "integer", "logical", "Date", "factor")
    if (!self@type %in% types_valides) {
      return(sprintf("`type` doit etre l'un de : %s", paste(types_valides, collapse = ", ")))
    }
    NULL
  }
)

#' Contrat de schema (ensemble de champs attendus)
#'
#' Regroupe plusieurs `me_schema_field` pour decrire l'ensemble des
#' colonnes attendues d'un dataset. Voir `check_schema()` pour la
#' verification effective.
#'
#' @param fields Liste de `me_schema_field`.
#' @export
me_schema <- S7::new_class(
  "me_schema",
  package = "mecore",
  properties = list(fields = S7::class_list)
)

#' Verifie qu'un data.frame respecte un me_schema
#'
#' @param data Un data.frame.
#' @param schema Un `me_schema`.
#' @return `TRUE` invisible si conforme ; leve `me_validation_error` sinon.
#' @export
check_schema <- function(data, schema) {
  stopifnot(is.data.frame(data), S7::S7_inherits(schema, me_schema))

  problemes <- character(0)
  for (f in schema@fields) {
    if (!(f@name %in% names(data))) {
      if (isTRUE(f@required)) {
        problemes <- c(problemes, sprintf("colonne manquante : '%s'", f@name))
      }
      next
    }
    type_reel <- class(data[[f@name]])[1]
    type_attendu <- switch(f@type,
      "double"  = "numeric",
      "integer" = "integer",
      f@type
    )
    if (!identical(type_reel, type_attendu) &&
        !(f@type == "double" && type_reel == "integer")) {
      problemes <- c(problemes, sprintf(
        "colonne '%s' : type attendu '%s', type reel '%s'",
        f@name, f@type, type_reel
      ))
    }
  }

  if (length(problemes) > 0) {
    me_validation_error(paste(
      "schema non respecte :\n-", paste(problemes, collapse = "\n- ")
    ))
  }
  invisible(TRUE)
}
