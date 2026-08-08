# Walking Skeleton MEverse — a executer dans RStudio pour valider le modele
# Voir ARCHITECTURE.md §7. Ne pas etendre tant que ce script n'est pas propre.
#
# NOTE : les fichiers R/ portent desormais un prefixe numerique
# (00_generics.R, 01_conditions.R, ...) qui force l'ordre de chargement
# correct, y compris pour devtools::load_all() qui source par ordre
# alphabetique. Le champ Collate: du DESCRIPTION fait double securite.

library(S7)

meta <- me_metadata(
  project_name = "Enquete pilote",
  organization = "Universite de Parakou",
  country      = "Benin",
  donor        = "N/A",
  manager      = "Aristarque Peniel Segue",
  start_date   = as.Date("2026-01-01"),
  end_date     = as.Date("2026-12-31"),
  version      = "0.1",
  description  = "Projet pilote pour valider le modele de domaine MEverse",
  objectives   = "Valider le walking skeleton",
  sdgs         = character(0)
)

p <- me_project(
  name       = "Pilote",
  metadata   = meta,
  datasets   = list(),
  indicators = list(),
  logframe   = NULL
)

d <- me_dataset(
  name     = "enquete_pilote",
  data     = data.frame(age = c(20, 22, 25, 31)),
  metadata = meta
)

# on ajoute le dataset au projet (immutabilite S7 : on reassigne la propriete)
p@datasets <- list(d)

i <- me_indicator(
  label    = "Age moyen",
  formula  = ~ mean(age),
  datasets = list(d),
  value    = mean(d@data$age),
  unit     = "annees"
)

p@indicators <- list(i)

r <- me_report(
  project    = p,
  indicators = list(i),
  dashboard  = NULL,
  narrative  = sprintf("L'age moyen des enquetes est de %.1f ans.", i@value)
)

# --- Verifications ---
stopifnot(S7_inherits(p, me_project))
stopifnot(length(p@datasets) == 1)
stopifnot(length(p@indicators) == 1)
stopifnot(is.numeric(i@value))

cat(r@narrative, "\n")
cat("Walking skeleton OK : le modele de domaine fonctionne de bout en bout.\n")
