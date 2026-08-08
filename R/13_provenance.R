# Provenance / reproductibilite embarquee (idee innovante #4).
# Chaque rapport genere peut embarquer ses metadonnees de provenance :
# version de mecore, empreinte des datasets sources, date de calcul.
# Un peu comme renv::snapshot(), mais au niveau du document produit —
# utile pour des institutions qui exigent la tracabilite methodologique.

#' Empreinte (hash) d'un dataset, pour tracer la provenance d'un rapport
#'
#' @param dataset Un `me_dataset`.
#' @return Chaine de caracteres (hash SHA-1 tronque).
#' @export
dataset_fingerprint <- function(dataset) {
  stopifnot(S7::S7_inherits(dataset, me_dataset))
  raw <- paste(utils::capture.output(utils::str(dataset@data)), collapse = "\n")
  if (requireNamespace("digest", quietly = TRUE)) {
    digest::digest(raw, algo = "sha1")
  } else {
    # repli sans dependance externe si le package `digest` n'est pas installe
    sprintf("crc32:%s", sprintf("%08x", sum(utf8ToInt(raw)) %% (2^32 - 1)))
  }
}

#' Construire un bloc de provenance pour un rapport
#'
#' @param report Un `me_report`.
#' @return Une liste (serialisable en JSON/YAML) avec version, empreintes, date.
#' @export
build_provenance <- function(report) {
  stopifnot(S7::S7_inherits(report, me_report))
  datasets <- report@project@datasets
  list(
    mecore_version = tryCatch(
      as.character(utils::packageVersion("mecore")),
      error = function(e) "dev (non installe)"
    ),
    generated_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
    datasets = lapply(datasets, function(d) {
      list(name = d@name, fingerprint = dataset_fingerprint(d), n_rows = nrow(d@data))
    }),
    n_indicators = length(report@indicators)
  )
}
