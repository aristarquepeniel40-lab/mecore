#' Tableau de bord MEverse
#'
#' Ne stocke jamais de donnees : reference des `me_indicator` deja
#' calcules (principe de non-duplication d'etat, ARCHITECTURE.md §2.2).
#'
#' @param title Titre du tableau de bord.
#' @param indicators Liste de `me_indicator` a afficher (1 ou plus).
#' @export
me_dashboard <- S7::new_class(
  "me_dashboard",
  package = "mecore",
  properties = list(
    title      = S7::class_character,
    indicators = S7::class_list
  ),
  validator = function(self) {
    if (length(self@indicators) < 1) {
      return("un `me_dashboard` doit referencer au moins un `me_indicator`")
    }
    NULL
  }
)

#' Rapport MEverse
#'
#' Assemble narratif + indicateurs + (optionnellement) un dashboard.
#' Ne stocke pas de donnees, uniquement des references.
#'
#' @param project Le `me_project` d'origine.
#' @param indicators Liste de `me_indicator` inclus dans le rapport.
#' @param dashboard `me_dashboard` optionnel.
#' @param narrative Texte narratif (peut etre vide au moment de la creation).
#' @export
me_report <- S7::new_class(
  "me_report",
  package = "mecore",
  properties = list(
    project    = me_project,
    indicators = S7::class_list,
    dashboard  = S7::new_union(me_dashboard, NULL),
    narrative  = S7::class_character
  )
)
