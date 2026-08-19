# Methodes me_describe() — fondation "IA-ready" (idee innovante #5).
# Chaque objet metier sait se decrire en texte structure. Cout marginal
# quasi nul aujourd'hui ; devient la fondation naturelle d'une future
# fonctionnalite d'interpretation automatique (ex. resume par un LLM),
# sans refonte du modele de domaine.

#' @noRd
S7::method(me_describe, me_indicator) <- function(x, ...) {
  valeur_txt <- if (is.null(x@value)) "non calculee" else format(x@value)
  sprintf(
    "Indicateur '%s' : %s%s, base sur %d dataset(s) (formule : %s).",
    x@label,
    valeur_txt,
    if (nzchar(x@unit)) paste0(" ", x@unit) else "",
    length(x@datasets),
    deparse(x@formula)
  )
}

#' @noRd
S7::method(me_describe, me_dataset) <- function(x, ...) {
  sprintf(
    "Dataset '%s' : %d lignes, %d colonnes (%s). Projet gere par %s.",
    x@name, nrow(x@data), ncol(x@data),
    paste(names(x@data), collapse = ", "),
    x@metadata@manager
  )
}

#' @noRd
S7::method(me_describe, me_project) <- function(x, ...) {
  sprintf(
    "Projet '%s' : %d dataset(s), %d indicateur(s)%s.",
    x@name, length(x@datasets), length(x@indicators),
    if (is.null(x@logframe)) "" else ", avec cadre logique"
  )
}
