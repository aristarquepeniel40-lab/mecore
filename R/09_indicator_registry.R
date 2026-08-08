# Registre d'indicateurs standards (idee innovante #2).
# Catalogue minimal embarque dans mecore pour donner une valeur
# perceptible des la V1, sans attendre un futur package "mesdg".
# A terme : generer ce data.frame depuis les donnees officielles ODD
# (ex. API globale des indicateurs SDG) plutot que de le maintenir a la main.

.me_indicator_registry <- data.frame(
  code  = c("1.1.1", "3.1.1", "4.1.1", "5.5.1"),
  odd   = c(1, 3, 4, 5),
  label = c(
    "Proportion de la population vivant sous le seuil de pauvrete international",
    "Taux de mortalite maternelle",
    "Proportion d'enfants/jeunes maitrisant un niveau minimal en lecture/mathematiques",
    "Proportion de sieges occupes par des femmes (parlements/gouvernements locaux)"
  ),
  unit = c("%", "pour 100 000 naissances vivantes", "%", "%"),
  stringsAsFactors = FALSE
)

#' Rechercher un indicateur standard ODD par code ou mot-cle
#'
#' @param query Code ODD (ex. "4.1.1") ou mot-cle du libelle.
#' @return Un data.frame filtre (0 a n lignes).
#' @export
search_sdg_indicator <- function(query) {
  hit_code <- .me_indicator_registry$code == query
  hit_label <- grepl(query, .me_indicator_registry$label, ignore.case = TRUE)
  .me_indicator_registry[hit_code | hit_label, ]
}

#' Instancier un me_indicator a partir d'un code ODD standard
#'
#' @param code Code de l'indicateur standard (ex. "4.1.1").
#' @param datasets Liste de `me_dataset` sources.
#' @param formula Formule de calcul specifique au contexte du projet.
#' @param value Valeur calculee (optionnelle a la creation).
#' @export
me_indicator_from_sdg <- function(code, datasets, formula, value = NULL) {
  ref <- .me_indicator_registry[.me_indicator_registry$code == code, ]
  if (nrow(ref) == 0) {
    me_validation_error(sprintf("code ODD inconnu dans le registre : '%s'", code))
  }
  me_indicator(
    label    = sprintf("[ODD %s] %s", ref$code, ref$label),
    formula  = formula,
    datasets = datasets,
    value    = if (is.null(value)) NA_real_ else value,
    unit     = ref$unit
  )
}
