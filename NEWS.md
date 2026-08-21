# mecore 1.0.0

Première version stable des fondations de l'écosystème MEverse.

## Modèle de domaine

* Classes S7 : `me_metadata`, `me_dataset`, `me_indicator`, `me_logframe`
  (+ `me_result`), `me_project`, `me_dashboard`, `me_report`.
* `me_metadata` est une classe de structure pure (aucune validation
  au-delà du typage natif de S7) — décision architecturale documentée
  dans `ARCHITECTURE.md` §2.4.

## Conventions d'API

* Génériques `me_validate()`, `compute_indicators()`, `generate_report()`,
  `me_describe()` — préfixés `me_` pour éviter toute collision avec
  d'autres packages (voir ci-dessous).
* Toute méthode S7 cross-package doit inclure un hook `.onLoad` avec
  `S7::methods_register()`, sans quoi le générique ne "voit" pas la
  méthode au moment du dispatch.

## Fonctionnalités additionnelles

* `me_schema`/`check_schema()` — contrat de schéma pour valider un
  dataset.
* Registre minimal d'indicateurs ODD (4 indicateurs) — voir le package
  `mesdg` pour un registre étendu (190 indicateurs officiels).
* `me_pipeline`/`run_pipeline()` — traçabilité d'un enchaînement
  d'opérations.
* `build_provenance()`/`dataset_fingerprint()` — empreinte de
  provenance d'un rapport.
* `export_logframe_xlsx()`/`import_logframe_xlsx()`/`attach_indicator()`
  — interopérabilité du cadre logique avec les gabarits Excel usuels
  des bailleurs.

## Corrections notables

* `import_logframe_xlsx()` perdait silencieusement les informations
  d'indicateurs importés (label, unité) lors d'un cycle export/import.
  Corrigé : retourne désormais `list(logframe, pending_indicators)`.
* `describe()` renommé `me_describe()` : collision avec
  `testthat::describe()`, quasi systématiquement chargé en session de
  développement R.
