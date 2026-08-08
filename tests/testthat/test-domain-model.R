# Petit constructeur d'aide pour les tests (evite de repeter tous les champs
# obligatoires de me_metadata a chaque test).
helper_metadata <- function() {
  me_metadata(
    project_name = "Projet test",
    organization = "Org test",
    country = "Benin",
    donor = "N/A",
    manager = "Testeur",
    start_date = Sys.Date(),
    end_date = Sys.Date() + 365,
    version = "0.1",
    description = "desc",
    objectives = "obj",
    sdgs = character(0)
  )
}

test_that("me_metadata s'instancie avec les champs attendus", {
  m <- helper_metadata()
  expect_true(S7::S7_inherits(m, me_metadata))
  expect_equal(m@organization, "Org test")
})

test_that("me_indicator refuse d'etre orphelin (0 dataset)", {
  expect_error(
    me_indicator(label = "x", formula = ~x, datasets = list(), value = 1, unit = "u"),
    regexp = "au moins un .me_dataset."
  )
})

test_that("me_indicator exige une unite quand value est numerique", {
  d <- me_dataset(name = "d", data = data.frame(x = 1), metadata = helper_metadata())
  expect_error(
    me_indicator(label = "x", formula = ~x, datasets = list(d), value = 1, unit = ""),
    regexp = "unit. doit etre renseignee"
  )
})

test_that("check_schema detecte un type incorrect", {
  s <- me_schema(fields = list(
    me_schema_field(name = "age", type = "double", label = "Age", required = TRUE)
  ))
  df_bad <- data.frame(age = "vingt")
  expect_error(check_schema(df_bad, s), class = "me_validation_error")
})

test_that("me_validate signale un resultat de logframe sans indicateur", {
  lf <- me_logframe(
    goal = "g",
    results = list(me_result(label = "R1", indicators = list())),
    hypotheses = character(0)
  )
  expect_error(me_validate(lf), class = "me_validation_error")
})

test_that("le walking skeleton produit un indicateur numerique coherent", {
  d <- me_dataset(name = "d", data = data.frame(age = c(20, 22, 25, 31)), metadata = helper_metadata())
  i <- me_indicator(label = "Age moyen", formula = ~ mean(age),
                     datasets = list(d), value = mean(d@data$age), unit = "annees")
  expect_equal(i@value, 24.5)
})
