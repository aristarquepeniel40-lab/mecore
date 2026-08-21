# Changelog

## mecore 1.0.0

Première version stable des fondations de l’écosystème MEverse.

### Modèle de domaine

- Classes S7 : `me_metadata`, `me_dataset`, `me_indicator`,
  `me_logframe` (+ `me_result`), `me_project`, `me_dashboard`,
  `me_report`.
- `me_metadata` est une classe de structure pure (aucune validation
  au-delà du typage natif de S7) — décision architecturale documentée
  dans `ARCHITECTURE.md` §2.4.

### Conventions d’API

- Génériques
  [`me_validate()`](https://aristarquepeniel40-lab.github.io/mecore/reference/me_validate.md),
  [`compute_indicators()`](https://aristarquepeniel40-lab.github.io/mecore/reference/compute_indicators.md),
  [`generate_report()`](https://aristarquepeniel40-lab.github.io/mecore/reference/generate_report.md),
  [`me_describe()`](https://aristarquepeniel40-lab.github.io/mecore/reference/me_describe.md)
  — préfixés `me_` pour éviter toute collision avec d’autres packages
  (voir ci-dessous).
- Toute méthode S7 cross-package doit inclure un hook `.onLoad` avec
  [`S7::methods_register()`](https://rconsortium.github.io/S7/reference/methods_register.html),
  sans quoi le générique ne “voit” pas la méthode au moment du dispatch.

### Fonctionnalités additionnelles

- `me_schema`/[`check_schema()`](https://aristarquepeniel40-lab.github.io/mecore/reference/check_schema.md)
  — contrat de schéma pour valider un dataset.
- Registre minimal d’indicateurs ODD (4 indicateurs) — voir le package
  `mesdg` pour un registre étendu (190 indicateurs officiels).
- `me_pipeline`/[`run_pipeline()`](https://aristarquepeniel40-lab.github.io/mecore/reference/run_pipeline.md)
  — traçabilité d’un enchaînement d’opérations.
- [`build_provenance()`](https://aristarquepeniel40-lab.github.io/mecore/reference/build_provenance.md)/[`dataset_fingerprint()`](https://aristarquepeniel40-lab.github.io/mecore/reference/dataset_fingerprint.md)
  — empreinte de provenance d’un rapport.
- [`export_logframe_xlsx()`](https://aristarquepeniel40-lab.github.io/mecore/reference/export_logframe_xlsx.md)/[`import_logframe_xlsx()`](https://aristarquepeniel40-lab.github.io/mecore/reference/import_logframe_xlsx.md)/[`attach_indicator()`](https://aristarquepeniel40-lab.github.io/mecore/reference/attach_indicator.md)
  — interopérabilité du cadre logique avec les gabarits Excel usuels des
  bailleurs.

### Corrections notables

- [`import_logframe_xlsx()`](https://aristarquepeniel40-lab.github.io/mecore/reference/import_logframe_xlsx.md)
  perdait silencieusement les informations d’indicateurs importés
  (label, unité) lors d’un cycle export/import. Corrigé : retourne
  désormais `list(logframe, pending_indicators)`.
- `describe()` renommé
  [`me_describe()`](https://aristarquepeniel40-lab.github.io/mecore/reference/me_describe.md)
  : collision avec
  [`testthat::describe()`](https://testthat.r-lib.org/reference/describe.html),
  quasi systématiquement chargé en session de développement R.
