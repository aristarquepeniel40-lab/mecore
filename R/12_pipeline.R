#' Pipeline MEverse — objet de premiere classe pour la tracabilite
#'
#' Capture explicitement l'enchainement d'operations plutot que de le
#' laisser implicite dans un simple `|>`. Permet de serialiser, rejouer
#' et journaliser un pipeline complet — important en M&E, ou
#' l'auditabilite du calcul compte autant que le resultat (idee #6).
#'
#' @param steps Liste de fonctions nommees, appliquees dans l'ordre.
#' @param log Liste des etapes deja executees (horodatage + nom).
#' @export
me_pipeline <- S7::new_class(
  "me_pipeline",
  package = "mecore",
  properties = list(
    steps = S7::class_list,
    log   = S7::class_list
  )
)

#' Executer un pipeline sur un objet, avec journalisation
#'
#' @param pipeline Un `me_pipeline`.
#' @param x Objet de depart (ex. un `me_project`).
#' @return Une liste `list(result = ..., pipeline = ...)` ; `pipeline`
#'   contient le journal d'execution mis a jour (horodatage, nom d'etape).
#' @export
run_pipeline <- function(pipeline, x) {
  stopifnot(S7::S7_inherits(pipeline, me_pipeline))
  log <- pipeline@log
  for (nom in names(pipeline@steps)) {
    fn <- pipeline@steps[[nom]]
    x <- fn(x)
    log <- c(log, list(list(step = nom, timestamp = Sys.time())))
  }
  pipeline@log <- log
  list(result = x, pipeline = pipeline)
}
