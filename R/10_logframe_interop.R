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
#' @param path Chemin du fichier .xlsx.
#' @return Un `me_logframe`.
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
    inds <- lapply(seq_len(nrow(sous_df)), function(i) {
      # Indicateur importe sans dataset source : a completer manuellement
      # avant tout calcul (l'invariant "pas d'indicateur orphelin" du
      # modele S7 empeche de le laisser dans cet etat).
      list(label = sous_df$Indicateur[i], unit = sous_df$Unite[i])
    })
    me_result(label = unique(sous_df$Resultat), indicators = list())
  })

  me_logframe(
    goal = unique(df$Objectif)[1],
    results = unname(results),
    hypotheses = if ("Hypotheses" %in% names(df)) unique(df$Hypotheses) else character(0)
  )
}
