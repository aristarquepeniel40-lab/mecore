#' Valider un objet MEverse
#'
#' Retourne l'objet inchange si valide (pour permettre le chainage avec
#' le pipe natif `|>`) ; leve une condition `me_validation_error` sinon.
#'
#' @param x Un objet MEverse (Project, Dataset, Indicator, ...).
#' @param ... Arguments additionnels passes aux methodes.
#' @export
me_validate <- S7::new_generic("me_validate", "x")

#' Calculer les indicateurs d'un objet
#'
#' @param x Un objet MEverse portant des indicateurs (ex. Project).
#' @param ... Arguments additionnels passes aux methodes.
#' @export
compute_indicators <- S7::new_generic("compute_indicators", "x")

#' Generer un rapport a partir d'un objet
#'
#' @param x Un objet MEverse a partir duquel generer un rapport (ex. Project).
#' @param ... Arguments additionnels passes aux methodes.
#' @export
generate_report <- S7::new_generic("generate_report", "x")

#' Decrire un objet MEverse en texte structure (voir idee IA-ready)
#'
#' @param x Un objet MEverse (Indicator, Dataset, Project, ...).
#' @param ... Arguments additionnels passes aux methodes.
#' @export
me_describe <- S7::new_generic("me_describe", "x")
