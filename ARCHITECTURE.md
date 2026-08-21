# ARCHITECTURE.md — Écosystème MEverse

> Document de référence du projet MEverse (Monitoring & Evaluation
> Universe). Statut : **v1.0 — VALIDÉ**. Walking Skeleton fonctionnel,
> tests `FAIL 0 | PASS 7`, `devtools::check()` :
> `0 errors | 1 warning (accepté, voir §9) | 0 notes`. Toute nouvelle
> classe/fonction dans `mecore` doit d’abord être ajoutée à ce document.
> Dernière mise à jour : Août 2026.

------------------------------------------------------------------------

## 0. Objet de ce document

Ce document fixe, avant l’écriture du code : - le **modèle de domaine**
(objets métier, responsabilités, relations, cardinalités) ; - les
**conventions d’API** communes à tous les packages ; - la **stratégie de
dépendances** entre packages ; - le **cycle de développement**
obligatoire pour chaque fonctionnalité ; - les **critères de sortie**
(definition of done) de chaque étape.

**Règle d’or** : aucune classe S7 n’est codée dans `mecore` avant que
l’objet correspondant existe dans la section 2 de ce document, avec ses
propriétés, ses invariants et ses relations.

**Critère de clôture de ce draft** : ce document est considéré “validé
v1.0” quand on peut, à la main, instancier un `Project` contenant un
`Dataset` et une `Metadata`, calculer un `Indicator` dessus, et produire
un objet `Report` minimal — sans écrire une seule ligne de code
additionnelle non prévue ici. Voir §7 (Walking Skeleton).

------------------------------------------------------------------------

## 1. Portée de `mecore`

`mecore` fournit uniquement : - les classes des objets métier ci-dessous
(S7) ; - leurs validateurs ; - les fonctions utilitaires transverses
(dates, chemins, logging, messages d’erreur standardisés) ; - les
constantes et métadonnées de convention (codes pays, unités, etc.) ; -
les conventions d’API (voir §5).

`mecore` **ne contient jamais** : calcul d’indicateurs, génération de
rapports/tableaux de bord, connecteurs de collecte (KoboToolbox, ODK…).
Ces responsabilités appartiennent aux packages consommateurs.

------------------------------------------------------------------------

## 2. Modèle de domaine

### 2.1 Objets métier et responsabilités

| Objet | Responsabilité | Contient des données ? | Package propriétaire |
|----|----|----|----|
| `Project` | Racine agrégeante ; identité et cycle de vie d’un projet M&E | Non (référence les autres) | `mecore` |
| `Metadata` | Décrit un projet ou un dataset (dates, auteurs, source, licence) | Oui (descriptif) | `mecore` |
| `Dataset` | Conteneur de données brutes/nettoyées + schéma | Oui | `mecore` (structure) / `medata` (logique) |
| `Indicator` | Définition + valeur calculée d’un indicateur (formule, unité, désagrégations) | Oui (définition + résultat) | `mecore` (structure) / `meindicator` (calcul) |
| `Logframe` | Cadre logique : objectifs, résultats, indicateurs associés, hypothèses | Oui | `mecore` (structure) / `melogframe` (logique) |
| `Dashboard` | Assemblage de visualisations à partir d’indicateurs | Non (référence) | `medashboard` |
| `Report` | Document généré (narratif + visualisations + indicateurs) | Non (référence + rendu) | `mereport` |

**Principe appliqué** : `mecore` définit la **structure** (la classe S7,
ses propriétés, ses invariants). Le package spécialisé définit le
**comportement** (comment on calcule, valide, rend). C’est la même
séparation que celle déjà actée en section 3 du rapport d’avancement,
appliquée maintenant objet par objet.

### 2.2 Relations et cardinalités

    Project (1)
      ├── Metadata (1)                — un projet a exactement une fiche de métadonnées
      ├── Dataset (0..n)               — un projet peut avoir zéro, un ou plusieurs jeux de données
      ├── Indicator (0..n)             — calculés à partir d'un ou plusieurs Dataset
      ├── Logframe (0..1)              — un projet a au plus un cadre logique actif
      ├── Report (0..n)                — plusieurs rapports peuvent être générés dans le temps
      └── Dashboard (0..n)

    Indicator (n) ──requires──> Dataset (1..n)
    Indicator (n) ──may reference──> Logframe.Result (0..1)   — un indicateur peut être lié à un résultat du cadre logique
    Report (1) ──assembles──> Indicator (0..n) + Dashboard (0..1) + narrative text
    Dashboard (1) ──displays──> Indicator (1..n)

**Décisions explicites à figer (actuellement absentes du rapport
initial)** : 1. Un `Project` peut avoir **plusieurs** `Dataset` (ex. :
baseline + endline) — pas une relation 1:1. 2. Un `Indicator` référence
toujours au moins un `Dataset` source ; on interdit un indicateur
“orphelin”. 3. Un `Logframe` est optionnel au niveau `Project` (tous les
projets n’en ont pas un dès la V1). 4. `Dashboard` et `Report` ne
stockent jamais de données : ils référencent des `Indicator` déjà
calculés (principe : pas de duplication d’état).

### 2.3 Invariants à valider (S7 `validator`)

> ⚠️ **Correction (décision confirmée avec l’auteur du projet)** :
> `me_metadata` est une **classe de structure pure** — aucun
> `validator`, même pour une cohérence simple comme l’ordre des dates.
> Voir §2.4 pour le principe complet. La ligne `Metadata` ci-dessous est
> donc retirée de ce tableau et déplacée en tant qu’exception
> documentée.

| Objet | Invariant | Où le vérifier |
|----|----|----|
| `Dataset` | le schéma déclaré correspond aux colonnes réelles | validator + fonction [`check_schema()`](https://aristarquepeniel40-lab.github.io/mecore/reference/check_schema.md) (voir `me_schema`, idée innovante \#1) |
| `Indicator` | l’unité est renseignée si `value` est numérique | validator (attention : tester avec [`nzchar()`](https://rdrr.io/r/base/nchar.html), pas `length()==0` — une chaîne vide a `length() == 1`, bug trouvé en testant) |
| `Logframe` | chaque `Result` a au moins un `Indicator` associé au moment de la validation finale | fonction [`me_validate()`](https://aristarquepeniel40-lab.github.io/mecore/reference/me_validate.md) de haut niveau, pas dans le validator de classe (car un Logframe en construction n’a pas encore tous ses indicateurs) |

### 2.4 Principe : classes de structure pures (choix explicite)

Certaines classes de `mecore` — à commencer par `me_metadata` — ne
contiennent **aucune logique**, y compris de validation au-delà du
typage natif de S7. Elles décrivent une structure, point final : pas de
calcul, pas de lecture de fichier, pas d’effet de bord, pas de
vérification de cohérence inter-champs.

Toute cohérence à vérifier entre plusieurs champs (ex.
`end_date >= start_date`) est volontairement déplacée hors de la classe,
dans une fonction séparée (à venir, potentiellement dans `mecheck`),
plutôt que dans un `validator` S7. C’est un choix délibéré : même si un
`validator` S7 n’est pas à proprement parler du “calcul métier” (il
ressemble plus à une contrainte `CHECK` de base de données), le projet
préfère garder une frontière stricte et prévisible — une classe ne fait
jamais autre chose que décrire.

`me_metadata` reflète les informations qu’un projet possède avant même
d’avoir des données, indicateurs ou rapports :

| Propriété      | Type        | Description                        |
|----------------|-------------|------------------------------------|
| `project_name` | `character` | Nom du projet                      |
| `organization` | `character` | Organisation porteuse              |
| `country`      | `character` | Pays de mise en œuvre              |
| `donor`        | `character` | Bailleur                           |
| `manager`      | `character` | Responsable du projet              |
| `start_date`   | `Date`      | Date de début                      |
| `end_date`     | `Date`      | Date de fin                        |
| `version`      | `character` | Version du projet/document         |
| `description`  | `character` | Description libre                  |
| `objectives`   | `character` | Objectifs du projet                |
| `sdgs`         | `character` | Codes ODD associés (ex. `"4.1.1"`) |

------------------------------------------------------------------------

## 3. Correctif technique — erreur S7 rencontrée

**Cause réelle** : `S7::class_date` n’existe pas ; le nom exporté est
[`S7::class_Date`](https://rconsortium.github.io/S7/reference/base_s3_classes.html)
(D majuscule), l’un des wrappers de `base_s3_classes`.

``` r

# ❌ Échoue : 'class_date' is not an exported object from 'namespace:S7'
me_metadata <- new_class("me_metadata", properties = list(
  created_at = S7::class_date
))

# ✅ Fonctionne
me_metadata <- new_class("me_metadata", package = "mecore", properties = list(
  created_at = S7::class_Date,
  modified_at = S7::class_Date
))
```

**Action** : vérifier systématiquement les noms exportés avant d’assumer
qu’une classe de base n’existe pas — `ls("package:S7")` ou la vignette
`base_s3_classes` fait gagner du temps. Documenter cette liste dans
`ARCHITECTURE.md` (voir tableau ci-dessous) pour que l’équipe ne perde
plus de temps sur ce point.

| Type R natif                    | Wrapper S7                    |
|---------------------------------|-------------------------------|
| `character`                     | `class_character`             |
| `numeric` / `double`            | `class_double`                |
| `integer`                       | `class_integer`               |
| `logical`                       | `class_logical`               |
| `Date`                          | `class_Date`                  |
| `POSIXct`/`POSIXt`              | `class_POSIXt`                |
| `factor`                        | `new_S3_class("factor")`      |
| classe S3 quelconque non listée | `new_S3_class("NomDeClasse")` |

------------------------------------------------------------------------

## 4. Dépendances entre packages

### 4.1 Règles

1.  Tout package du namespace `me*` dépend de `mecore` et **seulement**
    de `mecore` pour ses types de base (jamais de dépendance circulaire,
    jamais de dépendance directe entre deux packages spécialisés au même
    niveau — ex. `meindicator` ne dépend pas de `mereport`).

2.  `mecore` ne dépend **d’aucun** package `me*`.

3.  Contrainte de version dans `DESCRIPTION` de chaque package
    spécialisé :

        Imports:
            mecore (>= 0.1.0)

4.  Tant que `mecore` est en version `0.0.x` (pré-stable), chaque
    breaking change de `mecore` doit être accompagné d’un ticket listant
    les packages consommateurs à mettre à jour.

### 4.2 Intégration continue

- CI de `mecore` : tests unitaires uniquement (ne connaît pas les autres
  packages).
- CI de chaque package spécialisé : matrice testant contre (a) la
  dernière version CRAN/release de `mecore`, (b) la branche `main` de
  `mecore` (pour détecter une régression avant qu’elle ne sorte).
- Dès que 2 packages spécialisés existent (probablement `meindicator` et
  `medata`), ajouter un test d’intégration croisé minimal (ex. :
  `meindicator` calcule un indicateur sur un `Dataset` produit par
  `medata`).

------------------------------------------------------------------------

## 5. Conventions d’API communes

- Toutes les fonctions exposées suivent le style pipe :
  `objet |> verbe()`.

- **[`me_validate()`](https://aristarquepeniel40-lab.github.io/mecore/reference/me_validate.md)**
  (et non `validate()`) retourne toujours l’objet (inchangé si valide)
  pour permettre le chaînage ; en cas d’invalidité, elle **lève une
  condition** de classe `me_validation_error` (pas un simple
  [`stop()`](https://rdrr.io/r/base/stop.html) générique), afin que
  l’appelant puisse la capturer avec
  `tryCatch(..., me_validation_error = ...)`. \> ⚠️ **Correction
  (testée)** : `S7` exporte déjà une fonction `validate()` (validation
  d’un objet contre sa définition de classe). Nommer notre générique
  `validate()` le masque silencieusement sans erreur visible — piège
  classique de collision de noms. D’où le préfixe `me_` sur tous les
  génériques haut niveau de l’écosystème (`me_validate`, à distinguer de
  `compute_indicators`/`generate_report`/`describe` qui ne sont pas déjà
  pris par S7, vérifié).

- Toute erreur métier utilise des conditions S3 nommées
  `me_<type>_error` héritant de
  [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html), pour
  rester interceptables et cohérentes dans tout l’écosystème.

- Nommage : verbes à l’infinitif pour les actions
  ([`compute_indicators()`](https://aristarquepeniel40-lab.github.io/mecore/reference/compute_indicators.md),
  [`generate_report()`](https://aristarquepeniel40-lab.github.io/mecore/reference/generate_report.md)),
  noms pour les constructeurs
  ([`me_project()`](https://aristarquepeniel40-lab.github.io/mecore/reference/me_project.md),
  [`me_dataset()`](https://aristarquepeniel40-lab.github.io/mecore/reference/me_dataset.md)).

- Tout objet exporté par un package doit déclarer
  `package = "<nom_du_package>"` dans `new_class()` pour éviter les
  collisions de noms entre packages `me*`.

- **Méthodes cross-package (règle testée)** : tout package `me*` qui
  enregistre une méthode S7 sur un générique **défini dans un autre
  package** de l’écosystème (ex. `meindicator` enregistrant une méthode
  sur
  [`mecore::compute_indicators`](https://aristarquepeniel40-lab.github.io/mecore/reference/compute_indicators.md))
  doit inclure un `R/zzz.R` avec :

  ``` r

  .onLoad <- function(libname, pkgname) {
    S7::methods_register()
  }
  ```

  Sans ce hook, la méthode est bien enregistrée en mémoire mais le
  générique ne la “voit” pas au moment du dispatch
  (`Error: Can't find method for ...`), une erreur silencieuse et non
  intuitive découverte en testant `meindicator`. Ne pas oublier ce
  fichier pour `medata`, `mereport`, `medashboard`, etc.

- **Méthodes S7 : jamais de `@export` sur une méthode elle-même** — seul
  le générique est exporté (`@export` sur `S7::new_generic(...)`).
  Marquer chaque `S7::method(...) <- function(x, ...) {...}` avec
  `@noRd` : exporter la méthode séparément crée un alias en double et un
  conflit de documentation (trouvé en corrigeant `mecore`).

------------------------------------------------------------------------

## 6. Cycle de développement (rappel, inchangé du rapport)

    Conception → Architecture → Implémentation → Tests → Documentation → Validation → Publication

Ajout d’un critère de sortie par étape pour éviter le flou :

| Étape | Definition of done |
|----|----|
| Conception | Objet(s) et relations ajoutés à ce document, relus par au moins Dr. Agbo ou un pair |
| Architecture | Signature de fonctions/classe rédigée (même sans corps) |
| Implémentation | Code compile, `devtools::check()` sans erreur |
| Tests | Couverture ≥ 80 % sur le module concerné (`covr::package_coverage()`) |
| Documentation | `roxygen2::roxygenise()` sans warning, exemple `@examples` exécutable |
| Validation | Revue par un pair (ou soi-même à froid, 24h après) |
| Publication | Tag de version + entrée dans `NEWS.md` |

------------------------------------------------------------------------

## 7. Walking Skeleton — premier cas d’usage bout-en-bout

Avant de développer `meindicator`, `medata`, `mecheck`, `mereport` en
parallèle (risque identifié : dette de cohérence croisée), il est
recommandé de dérouler un **squelette minimal** entièrement dans
`mecore`, sans optimisation ni exhaustivité :

``` r

p <- me_project(name = "Pilote")
d <- me_dataset(p, data = data.frame(age = c(20, 22, 25)))
i <- me_indicator(d, formula = ~ mean(age), label = "Âge moyen")
r <- me_report(p, indicators = list(i))
```

**Objectif** : valider que le modèle du §2 “tient” en pratique sur un
cas trivial avant de le généraliser à 12 packages. Si ce pipeline
minimal révèle un problème de cardinalité ou de responsabilité, il est
infiniment moins coûteux de le corriger ici que dans 4 packages
développés en parallèle.

**Critère de passage au développement parallèle (§ moyen terme du
rapport)** : ce pipeline s’exécute sans erreur, est testé, et a été relu
— alors seulement `meindicator`, `medata`, `mecheck`, `mereport` peuvent
démarrer en parallèle.

------------------------------------------------------------------------

## 8. Jalons mesurables

| Jalon | Critère quantifiable |
|----|----|
| `mecore` — architecture validée | Ce document passé en v1.0 + walking skeleton (§7) fonctionnel |
| `mecore` — stabilisé | Couverture de tests ≥ 80 %, API publique inchangée depuis 2 releases mineures consécutives, 0 erreur `R CMD check` |
| Première version utilisable de MEverse | `mecore` + `meindicator` + `medata` + `mereport` publiés, pipeline complet testé sur un jeu de données réel (pas seulement jouet) |
| Publication CRAN de `mecore` | `R CMD check --as-cran` propre, vignette d’introduction rédigée |

------------------------------------------------------------------------

## 9. Historique des décisions (à tenir à jour)

| Date | Décision | Raison |
|----|----|----|
| Août 2026 | Système objet : S7 | Moderne, typé, recommandé pour nouveaux projets R |
| Août 2026 | Réorientation architecture-first | Échec `class_date` a révélé l’absence de modèle métier préalable |
| Août 2026 | Correctif : `class_Date` (pas `class_date`) | Faute de casse dans le nom exporté, sans lien avec l’absence de modèle |
| Août 2026 | Générique renommé `validate()` → [`me_validate()`](https://aristarquepeniel40-lab.github.io/mecore/reference/me_validate.md) | Collision silencieuse avec [`S7::validate()`](https://rconsortium.github.io/S7/reference/validate.html), déjà exporté par le package S7 |
| Août 2026 | Modèle de domaine (§2) implémenté et testé (`me_metadata`, `me_dataset`, `me_indicator`, `me_logframe`, `me_project`, `me_dashboard`, `me_report`) | Walking Skeleton (§7) exécuté avec succès de bout en bout |
| Août 2026 | Ajout de `me_schema` (contrat de schéma), registre d’indicateurs ODD, `me_pipeline`, `describe()`, provenance/empreinte de dataset | Prototypage des 6 idées innovantes proposées, toutes fonctionnelles en l’état |
| Août 2026 | `me_metadata` réécrit sans validator, champs enrichis (`organization`, `donor`, `manager`, `sdgs`…) | Décision explicite : classe de structure pure, aucune logique même triviale (voir §2.4) |
| Août 2026 | `devtools::check()` : 0 erreur, 1 warning cosmétique accepté comme dette technique connue | “Codoc mismatches” causés par la génération automatique des valeurs par défaut de propriétés S7 (`class_data.frame`, `class_Date`, `new_S3_class("formula")`) — comportement interne de S7, reproduit ensuite sur `meindicator` (`me_indicator_recipe`), sans impact fonctionnel dans les deux cas |
| Août 2026 | `ARCHITECTURE.md` passé en v1.0 | Critère de clôture du §0 rempli : Walking Skeleton + tests + `check()` tous verts |
| Août 2026 | Démarrage de `meindicator` (premier package spécialisé, seul autorisé pour l’instant — voir §7) | `mecore` stabilisé (au sens du §8) |
| Août 2026 | `meindicator` validé : `0 errors | 1 warning (cosmétique, accepté) | 0 notes`. Règle `.onLoad`/[`S7::methods_register()`](https://rconsortium.github.io/S7/reference/methods_register.html) reconfirmée sans régression | Deuxième package du même niveau de rigueur que `mecore` |
| Août 2026 | Démarrage de `medata` (import CSV, validation de schéma, rapport de qualité, nettoyage minimal) | Comble l’angle mort identifié : rien n’empêchait `meindicator::compute_indicator()` de calculer sur des données mal typées avant l’existence de `medata` |
| Août 2026 | Bug trouvé : [`nrow()`](https://rdrr.io/r/base/nrow.html)/[`ncol()`](https://rdrr.io/r/base/nrow.html) retournent `integer`, incompatible avec une propriété S7 `class_double` (pas de coercion implicite) | Corrigé avec `as.double(...)` — à garder en tête pour toute future propriété `class_double` alimentée par `nrow`/`ncol`/`length` |
| Août 2026 | `medata` validé : `0 errors | 1 warning (cosmétique, même artefact`class_data.frame`, accepté) | 0 notes`. Intégration bout-en-bout confirmée avec `meindicator` (indicateur calculé sur données importées + nettoyées) | Troisième package du même niveau de rigueur |
| Août 2026 | Trois dépôts Git initialisés (`mecore`, `meindicator`, `medata`), un par package | Convention standard R, cohérente avec le versionnement indépendant du §4 |
| Août 2026 | Démarrage de `mereport` (assemblage + rendu Markdown de rapports) | Rendre visible un résultat concret de la chaîne `medata` → `meindicator` → `mereport` |
| Août 2026 | `mereport` validé, aucun bug trouvé en testant (première fois) — chaîne complète `import_csv` → `compute_indicators` → `generate_report` fonctionnelle du premier coup | Confirme que les conventions du §5 (alias locaux pour génériques cross-package, `zzz.R`/`methods_register()`) sont maintenant bien ancrées |
| Août 2026 | `mereport` : `0 errors \| 0 warnings \| 0 notes` — premier package à ce niveau (pas de propriété `class_data.frame`/`class_Date`, donc pas d’artefact codoc) | Meilleur résultat des 4 packages ; confirme que le warning cosmétique des autres est bien spécifique à ce type de propriété S7, pas une regression generale |
| Août 2026 | Pipeline complet confirmé installé et fonctionnel : `mecore` → `medata` → `meindicator` → `mereport` | Les 4 packages sont réellement installés (`devtools::install()`), pas seulement chargés en mémoire (`load_all()`) |
| Août 2026 | Démarrage de `mecheck` (5e package) : contrôle de cohérence à l’échelle d’un projet complet, pas d’un dataset isolé | Complémentaire à `medata` (qui vérifie un dataset seul) |
| Août 2026 | La règle `dates_coherentes` de `mecheck` implémente la vérification `end_date >= start_date` explicitement exclue du validator de `me_metadata` au §2.4 | Referme la boucle ouverte lors de la décision “classe de structure pure” — la cohérence différée trouve enfin sa place |
| Août 2026 | `mecheck` : aucun bug trouvé en testant, 4 règles validées sur des cas volontairement problématiques (dates inversées, labels dupliqués, dataset référencé absent) | Deuxième package consécutif sans bug détecté (après `mereport`) |
| Août 2026 | `mecheck` validé : `0 errors \| 1 warning (cosmétique, même artefact`class_data.frame`, accepté) \| 0 notes` | Cinquième package au même standard de rigueur |
| Août 2026 | Pipeline testé sur données réelles (enquête agricole, 200 exploitants) via un script autonome, sans modifier aucun package | `medata::import_csv()` ne gérant pas l’Excel, le `me_dataset` a été construit directement depuis un data.frame `readxl` — solution légitime et non invasive |
| Août 2026 | Ajout de `medata::import_xlsx()`, même contrat que `import_csv()` (fichier introuvable, dépendance `readxl` manquante, schéma bloquant) | Rendre l’import Excel natif au package plutôt que contourné à la main |
| Août 2026 | Ajout de `meindicator::compute_indicator_by_group()` + champ optionnel `group_by` sur `me_indicator_recipe` | Indicateurs désagrégés (région, sexe…) plutôt que seulement des moyennes globales ; rétrocompatibilité vérifiée sur les recettes existantes |
| Août 2026 | Bug trouvé (via `mecheck`, sur données réelles) : `compute_indicator_by_group()` créait des sous-datasets dérivés jamais enregistrés dans `project@datasets`, déclenchant à raison la règle `indicateurs_datasets_presents` | Corrigé : chaque indicateur désagrégé référence désormais le dataset **original**, le filtrage par modalité restant un détail de calcul interne. Premier cas concret où `mecheck` détecte un vrai défaut de conception d’un autre package plutôt qu’un jeu de test synthétique |
| Août 2026 | `medata` (avec `import_xlsx`) validé : `0 errors \| 1 warning (cosmétique, accepté) \| 0 notes` après correction du `Collate:` et `Suggests: readxl` manquants dans `DESCRIPTION` | Import Excel réel confirmé fonctionnel côté utilisateur (pas seulement via le faux `readxl` de test) |
| Août 2026 | `meindicator` (avec désagrégation) **fonctionnellement validé** : walking skeleton complet, `devtools::test()` → `FAIL 0`, mais `devtools::check()` non complété — bloqué par une dérive de l’horloge système Windows de l’utilisateur (`checking for future file timestamps`), sans lien avec le code | À reprendre : relancer `devtools::check()` une fois l’horloge système corrigée (`w32tm /resync`), pour confirmer l’absence de warnings/notes comme sur le reste de l’écosystème |
| Août 2026 | `meindicator` (avec désagrégation) validé définitivement : `0 errors \| 1 warning (cosmétique, même artefact`new_S3_class(“formula”)`, accepté) \| 0 notes` | L’écart d’horloge (~24 min) a persisté même après `w32tm /resync` (probablement horloge matérielle/RTC) ; contourné pour ce check via `Sys.setenv(`*R_CHECK_SYSTEM_CLOCK*`= "FALSE")`, sans rapport avec la qualité du code |
| Août 2026 | Intégration `mereport` ↔︎ `mecheck` implémentée : `generate_report(project, ..., check = FALSE, block_on_failure = FALSE)` | Comble le dernier point volontairement laissé de côté depuis la création de `mecheck` (§6 de `GUIDE_MECHECK.md`) |
| Août 2026 | `mecheck` ajouté en `Suggests` de `mereport` (même logique que `readxl` dans `medata`) — dégradation propre (avertissement) si absent | Cohérence avec la convention déjà établie pour les dépendances optionnelles inter-packages |
| Août 2026 | Testé sur 5 cas (non-régression, section ajoutée, avertissement non bloquant, blocage effectif, dégradation sans `mecheck`) + confirmé sur données réelles (rapport agricole avec 4/4 règles respectées) | Aucun bug trouvé cette fois-ci |
| Août 2026 | Bug trouvé par `devtools::check()` chez l’utilisateur : caractères non-ASCII (emoji ⚠️, tiret cadratin —, symbole §) dans `mereport`, rejetés pour la portabilité (`checking code files for non-ASCII characters`) | Corrigés (emoji retiré, tirets cadratins → `--`, § → “section”). Note : les 4 packages précédents contiennent aussi des tirets cadratins dans leurs commentaires sans avoir déclenché ce warning chez l’utilisateur — cause exacte non élucidée, non retouchés puisque déjà validés à 0 erreur ; à garder en tête (préférer l’ASCII pur) pour tout futur fichier `.R` |
| Août 2026 | Note trouvée : dossiers `40DE90FA`/`shared` (cache OneDrive, projet situé dans un dossier synchronisé) signalés par `checking top-level files` | Ajoutés au `.Rbuildignore` (`^[0-9A-F]{8}$`, `^shared$`) |
| Août 2026 | `mereport` (avec intégration `mecheck`) validé définitivement : `0 errors \| 0 warnings \| 0 notes` | Intégration `mereport` ↔︎ `mecheck` officiellement close |
| Août 2026 | Les 5 packages publiés sur GitHub (`github.com/aristarquepeniel40-lab/<package>`), publics, avec `Remotes:` inter-packages dans chaque `DESCRIPTION` | Installation possible partout via `remotes::install_github()`, plus besoin d’une copie locale manuelle |
| Août 2026 | Publication vérifiée de bout en bout : copies locales désinstallées, les 5 packages retéléchargés uniquement depuis GitHub, réinstallés dans l’ordre des dépendances, pipeline complet (import → indicateurs → contrôle qualité → rapport) retesté avec succès | Preuve que la publication est fonctionnelle pour un tiers, pas seulement en local chez l’auteur |
| Août 2026 | Limite de test assumée sur `import_xlsx()` : `readxl` non installable dans l’environnement de test (dépendances `tibble`/`vctrs`/`pillar` trop lourdes sans CRAN) — contrôle de flux testé via un faux package `readxl` minimal, la lecture réelle du xlsx reste à confirmer côté utilisateur | Transparence sur la portée exacte des tests effectués |
