#' Conditions d'erreur standardisees MEverse
#'
#' Toutes les erreurs metier de l'ecosysteme MEverse heritent de
#' `me_error`, ce qui permet de les intercepter globalement avec
#' `tryCatch(..., me_error = function(e) ...)`, ou individuellement
#' via leur sous-classe (ex. `me_validation_error`).
#'
#' @param message Message d'erreur affiche a l'utilisateur.
#' @param class Sous-classe specifique (ex. "me_validation_error").
#' @param call Environnement d'appel (pour rlang::abort si disponible).
#' @param ... Donnees additionnelles attachees a la condition.
#' @noRd
me_abort <- function(message, class, ...) {
  if (requireNamespace("rlang", quietly = TRUE)) {
    rlang::abort(message, class = c(class, "me_error"), ..., call = rlang::caller_env())
  } else {
    cond <- structure(
      class = c(class, "me_error", "error", "condition"),
      list(message = message, call = sys.call(-1), ...)
    )
    stop(cond)
  }
}

#' Lever une erreur de validation metier MEverse
#'
#' @param message Message d'erreur affiche a l'utilisateur.
#' @param ... Donnees additionnelles attachees a la condition.
#' @export
me_validation_error <- function(message, ...) {
  me_abort(message, class = "me_validation_error", ...)
}

#' Lever une erreur de dependance manquante (ex. package Suggests absent)
#'
#' @param message Message d'erreur affiche a l'utilisateur.
#' @param ... Donnees additionnelles attachees a la condition.
#' @export
me_dependency_error <- function(message, ...) {
  me_abort(message, class = "me_dependency_error", ...)
}
