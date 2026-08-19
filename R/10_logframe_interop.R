# Interoperabilite du cadre logique (idee innovante #3).
# Plutot que d'inventer un format MEverse isole, on vise l'export/import
# vers un gabarit Excel simple, compatible avec la structure habituelle
# des cadres logiques utilises par les bailleurs (UE, USAID, AFD...) :
# une feuille avec colonnes Objectif | Resultat | Indicateur | Unite | Hypothese.
#
# NOTE : ce module s'appuie sur `openxlsx` (non installe dans cet
# environnement de test). A installer cote utilisateur :
# install.packages("openxlsx")

#' Exporter un me_logframe vers un fichier Excel
#'
#' @param logframe Un `me_logframe`.
#' @param path Chemin du fichier .xlsx a creer.
#' @export
export_logframe_xlsx <- function(logframe, path) {
  stopifnot(S7::S7_inherits(logframe, me_logframe))
  if (!requireNamespace("openxlsx", quietly = TRUE)) {
    me_dependency_error("le package 'openxlsx' est requis : install.packages('openxlsx')")
  }

  lignes <- do.call(rbind, lapply(logframe@results, function(res) {
    if (length(res@indicators) == 0) {
      return(data.frame(
        Objectif = logframe@goal, Resultat = res@label,
        Indicateur = NA_character_, Unite = NA_character_,
        stringsAsFactors = FALSE
      ))
    }
    do.call(rbind, lapply(res@indicators, function(ind) {
      data.frame(
        Objectif = logframe@goal, Resultat = res@label,
        Indicateur = ind@label, Unite = ind@unit,
        stringsAsFactors = FALSE
      )
    }))
  }))
  lignes$Hypotheses <- paste(logframe@hypotheses, collapse = "; ")

  openxlsx::write.xlsx(lignes, path, sheetName = "Cadre logique")
  invisible(path)
}

#' Importer un cadre logique depuis un gabarit Excel usuel
#'
#' Attend un fichier avec au minimum les colonnes :
#' Objectif, Resultat, Indicateur, Unite (Hypotheses optionnelle).
#'
#' IMPORTANT (correctif -- bug trouve en testant avec le vrai openxlsx) :
#' un indicateur importe depuis Excel n'a pas de `me_dataset` source, et
#' l'invariant "pas d'indicateur orphelin" de `mecore::me_indicator`
#' empeche d'en construire un valide a ce stade. La version precedente
#' de cette fonction calculait les infos d'indicateurs importes (label,
#' unite) puis les jetait silencieusement -- perte de donnees invisible,
#' seulement visible en testant un vrai cycle export/import. Corrige :
#' ces informations sont maintenant retournees a part, dans
#' `pending_indicators`, pour etre completees via `attach_indicator()`
#' une fois un vrai dataset disponible.
#'
#' @param path Chemin du fichier .xlsx.
#' @return Une liste `list(logframe, pending_indicators)` : `logframe`
#'   est un `me_logframe` (resultats sans indicateurs pour l'instant) ;
#'   `pending_indicators` est un `data.frame` (`resultat`, `indicateur`,
#'   `unite`) listant les indicateurs a completer.
#' @export
import_logframe_xlsx <- function(path) {
  if (!requireNamespace("openxlsx", quietly = TRUE)) {
    me_dependency_error("le package 'openxlsx' est requis : install.packages('openxlsx')")
  }
  df <- openxlsx::read.xlsx(path, sheet = 1)

  requis <- c("Objectif", "Resultat", "Indicateur", "Unite")
  manquantes <- setdiff(requis, names(df))
  if (length(manquantes) > 0) {
    me_validation_error(sprintf(
      "colonnes manquantes dans le fichier importe : %s",
      paste(manquantes, collapse = ", ")
    ))
  }

  results <- lapply(split(df, df$Resultat), function(sous_df) {
    me_result(label = unique(sous_df$Resultat), indicators = list())
  })

  logframe <- me_logframe(
    goal = unique(df$Objectif)[1],
    results = unname(results),
    hypotheses = if ("Hypotheses" %in% names(df)) unique(df$Hypotheses) else character(0)
  )

  pending <- data.frame(
    resultat = df$Resultat,
    indicateur = df$Indicateur,
    unite = df$Unite,
    stringsAsFactors = FALSE
  )
  pending <- pending[!is.na(pending$indicateur), , drop = FALSE]
  rownames(pending) <- NULL

  list(logframe = logframe, pending_indicators = pending)
}

#' Rattacher un indicateur calcule a un resultat existant d'un logframe
#'
#' Complement naturel de `import_logframe_xlsx()` : une fois un vrai
#' `me_indicator` calcule (avec un vrai `me_dataset` source) pour une
#' ligne de `pending_indicators`, cette fonction l'insere proprement
#' dans le `me_result` correspondant, par son libelle.
#'
#' @param logframe Un `me_logframe`.
#' @param result_label Libelle exact du `me_result` cible (voir
#'   `pending_indicators$resultat`).
#' @param indicator Un `mecore::me_indicator` deja calcule.
#' @return Le `me_logframe` mis a jour.
#' @export
attach_indicator <- function(logframe, result_label, indicator) {
  stopifnot(S7::S7_inherits(logframe, me_logframe))
  stopifnot(S7::S7_inherits(indicator, me_indicator))

  idx <- which(vapply(logframe@results, function(r) r@label, character(1)) == result_label)
  if (length(idx) == 0) {
    me_validation_error(sprintf("resultat '%s' introuvable dans le logframe", result_label))
  }

  logframe@results[[idx[1]]]@indicators <- c(logframe@results[[idx[1]]]@indicators, list(indicator))
  logframe
}
