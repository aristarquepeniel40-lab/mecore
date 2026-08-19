helper_metadata <- function() {
  me_metadata(
    project_name = "p", organization = "o", country = "c", donor = "d", manager = "m",
    start_date = Sys.Date(), end_date = Sys.Date() + 1,
    version = "0.1", description = "d", objectives = "o", sdgs = character(0)
  )
}

test_that("export_logframe_xlsx puis import_logframe_xlsx ne perd pas l'information indicateur", {
  meta <- helper_metadata()
  d <- me_dataset(name = "d1", data = data.frame(x = 1:3), metadata = meta)
  ind <- me_indicator(label = "Taux acces", formula = ~ mean(x), datasets = list(d), value = 65, unit = "%")
  r1 <- me_result(label = "R1", indicators = list(ind))
  lf <- me_logframe(goal = "G", results = list(r1), hypotheses = "H")

  chemin <- tempfile(fileext = ".xlsx")
  export_logframe_xlsx(lf, chemin)
  res <- import_logframe_xlsx(chemin)

  expect_equal(nrow(res$pending_indicators), 1)
  expect_equal(res$pending_indicators$indicateur, "Taux acces")
  expect_equal(res$pending_indicators$unite, "%")
})

test_that("import_logframe_xlsx gere plusieurs resultats et des indicateurs manquants", {
  gabarit <- data.frame(
    Resultat = c("R1", "R1", "R2"),
    Objectif = c("Obj", "Obj", "Obj"),
    Indicateur = c("A", "B", NA),
    Unite = c("%", "count", NA),
    stringsAsFactors = FALSE
  )
  chemin <- tempfile(fileext = ".xlsx")
  openxlsx::write.xlsx(gabarit, chemin)

  res <- import_logframe_xlsx(chemin)
  expect_equal(length(res$logframe@results), 2)
  expect_equal(nrow(res$pending_indicators), 2)
})

test_that("import_logframe_xlsx signale les colonnes manquantes", {
  gabarit <- data.frame(Resultat = "R1", stringsAsFactors = FALSE)
  chemin <- tempfile(fileext = ".xlsx")
  openxlsx::write.xlsx(gabarit, chemin)
  expect_error(import_logframe_xlsx(chemin), regexp = "colonnes manquantes")
})

test_that("attach_indicator rattache correctement un indicateur calcule", {
  meta <- helper_metadata()
  r1 <- me_result(label = "R1", indicators = list())
  lf <- me_logframe(goal = "G", results = list(r1), hypotheses = character(0))

  d <- me_dataset(name = "d1", data = data.frame(x = 1:3), metadata = meta)
  ind <- me_indicator(label = "X", formula = ~ mean(x), datasets = list(d), value = 1, unit = "u")

  lf2 <- attach_indicator(lf, "R1", ind)
  expect_equal(length(lf2@results[[1]]@indicators), 1)
})

test_that("attach_indicator signale un resultat introuvable", {
  meta <- helper_metadata()
  r1 <- me_result(label = "R1", indicators = list())
  lf <- me_logframe(goal = "G", results = list(r1), hypotheses = character(0))
  d <- me_dataset(name = "d1", data = data.frame(x = 1:3), metadata = meta)
  ind <- me_indicator(label = "X", formula = ~ mean(x), datasets = list(d), value = 1, unit = "u")

  expect_error(attach_indicator(lf, "Inexistant", ind), regexp = "introuvable")
})
