# Script de nettoyage — a executer UNE FOIS dans RStudio, depuis la racine
# du projet mecore (le dossier contenant DESCRIPTION).
#
# Contexte : une copie precedente a duplique les fichiers R/ sans supprimer
# les anciens (sans prefixe numerique). Ce script :
#   1. Verifie que chaque ancien fichier est identique a son equivalent prefixe
#      (securite : n'efface RIEN qui serait different).
#   2. Supprime uniquement les doublons confirmes identiques.
#   3. Laisse `me_metadata-class.R` intact — il est remplace par le nouveau
#      02_metadata.R (deja fusionne avec votre modele), donc a supprimer
#      seulement apres verification manuelle par vos soins.

anciens_vers_nouveaux <- list(
  "conditions.R"         = "01_conditions.R",
  "dashboard_report.R"   = "07_dashboard_report.R",
  "dataset.R"             = "03_dataset.R",
  "describe_methods.R"   = "11_describe_methods.R",
  "generics.R"            = "00_generics.R",
  "indicator.R"           = "04_indicator.R",
  "indicator_registry.R" = "09_indicator_registry.R",
  "logframe.R"            = "05_logframe.R",
  "logframe_interop.R"   = "10_logframe_interop.R",
  "metadata.R"            = "02_metadata.R",
  "pipeline.R"            = "12_pipeline.R",
  "project.R"             = "06_project.R",
  "provenance.R"          = "13_provenance.R",
  "schema.R"              = "08_schema.R"
)

for (ancien in names(anciens_vers_nouveaux)) {
  nouveau <- anciens_vers_nouveaux[[ancien]]
  chemin_ancien  <- file.path("R", ancien)
  chemin_nouveau <- file.path("R", nouveau)

  if (!file.exists(chemin_ancien)) next  # deja nettoye

  if (!file.exists(chemin_nouveau)) {
    warning(sprintf("'%s' n'a pas d'equivalent prefixe : NON supprime, a verifier manuellement.", ancien))
    next
  }

  identiques <- identical(readLines(chemin_ancien), readLines(chemin_nouveau))
  if (identiques) {
    file.remove(chemin_ancien)
    message(sprintf("Supprime (doublon confirme identique) : %s", ancien))
  } else {
    warning(sprintf("'%s' est DIFFERENT de '%s' : NON supprime, a comparer manuellement !", ancien, nouveau))
  }
}

# me_metadata-class.R : deja fusionne avec vos champs dans 02_metadata.R.
# Decommentez la ligne suivante seulement apres avoir confirme que
# 02_metadata.R contient bien tout ce dont vous avez besoin :
# file.remove("R/me_metadata-class.R")

message("\nNettoyage termine. Fichiers restants dans R/ :")
print(sort(list.files("R")))
