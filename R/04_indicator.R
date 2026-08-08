#' Indicateur MEverse
#'
#' Definition + valeur calculee d'un indicateur. `mecore` ne definit que
#' la structure ; le calcul reel appartient a `meindicator`.
#'
#' Invariant : un indicateur reference toujours au moins un `me_dataset`
#' source (interdiction de l'indicateur "orphelin", cf. ARCHITECTURE.md §2.2).
#'
#' @param label Libelle lisible (ex. "Age moyen des enquetes").
#' @param formula Formule R (objet `formula`) definissant le calcul.
#' @param datasets Liste de `me_dataset` sources (1 ou plus).
#' @param value Valeur calculee (NULL tant que non calculee).
#' @param unit Unite de mesure (ex. "annees", "%"). Peut etre vide si `value` non numerique.
#' @export
me_indicator <- S7::new_class(
  "me_indicator",
  package = "mecore",
  properties = list(
    label    = S7::class_character,
    formula  = S7::new_S3_class("formula"),
    datasets = S7::class_list,
    value    = S7::class_any,
    unit     = S7::class_character
  ),
  validator = function(self) {
    if (length(self@datasets) < 1) {
      return("un `me_indicator` doit referencer au moins un `me_dataset` (pas d'indicateur orphelin)")
    }
    if (!all(vapply(self@datasets, S7::S7_inherits, logical(1), class = me_dataset))) {
      return("`datasets` doit etre une liste de `me_dataset`")
    }
    if (is.numeric(self@value) && !nzchar(self@unit)) {
      return("`unit` doit etre renseignee quand `value` est numerique")
    }
    NULL
  }
)
