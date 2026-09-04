# Professionaliser le golemverse — diagnostic & plan d'action

> Audit réalisé le 2026-06-16 — 14 repos sondés via l'API GitHub + analyse transverse,
> recoupée avec les fichiers du site (`index.qmd`, `packages/`, `roadmap/`, `news/`).

## Le diagnostic en une phrase

Le golemverse a un **noyau réellement production-grade** (golem, dockerfiler, fakir, shinipsum)
entouré d'une **longue traîne de 9 packages dormants depuis 2023** présentés sous la même
bannière « production-grade » — et un **site vitrine qui se contredit lui-même**. Ce n'est pas
tant que les packages sont « en coin de table » : la plupart sont *bien faits mais abandonnés*,
et c'est l'**emballage collectif** qui fait amateur.

## Les signaux « coin de table » les plus visibles (factuels)

- **9 des 14 packages ont leur dernier commit (branche par défaut) au 2023-03-27** — une date de
  commit de masse unique, puis plus rien.
- **8 packages affichent un badge R-CMD-check vert… alors que le workflow CI n'a JAMAIS tourné**
  (`total_count = 0` runs) : gargoyle, gemstones, elvis, brochure, ghooks, skeleton, shinidraw,
  minifyr. Le badge est purement décoratif.
- **elvis** : les 9 fichiers de test sont des stubs identiques `expect_equal(2 * 2, 4)`, et le
  README dit littéralement *« [EXPERIMENTAL, DO NOT USE] »*.
- **w3css** : 28 fichiers `R/todo_*.R` vides, 27 issues auto-générées « Implement - », 0 % de
  couverture réelle, bannière *« [WORK IN PROGRESS] »*.
- **Les 14 repos affichent `NOASSERTION` comme licence** côté GitHub (alors que tous déclarent
  MIT) — pas un seul ne montre « MIT License » dans sa sidebar.
- **gargoyle** est marqué *stable* + sur CRAN… mais hébergé sur le compte **perso** `colinfay`,
  dormant depuis 22 mois, CI jamais lancée.
- **Le meta-package `{golemverse}` n'existe pas** : `install.packages("golemverse")` est en
  commentaire dans `index.qmd`, et il n'y a ni package CRAN, ni repo, ni org `golemverse`.
- **Le site se contredit** : la table de stats a **13 lignes (minifyr manquant)** alors que la
  home en liste 14 ; elle affiche des badges CRAN/téléchargements pour 10 packages **qui ne sont
  pas sur CRAN** ; et `golem.lint` existe déjà mais la roadmap le liste comme « à créer ».

## Tableau de bord (score de professionnalisme / 100)

| Package | Score | Dernier commit | CRAN | Lifecycle affiché → réel | Reco |
|---|---|---|---|---|---|
| **golem** | 94 | mai 2026 | ✅ 0.5.1 | stable → stable ✅ | **Cœur** — sortir 0.6.0 sur CRAN |
| **dockerfiler** | 90 | mai 2026 | ✅ 1.0.0 | stable → stable ✅ | **Cœur** |
| **fakir** | 86 | avr 2026 | ✅ 1.0.0 | stable → stable ✅ | **Cœur** — re-knit + CRAN 1.1.0 |
| **shinipsum** | 78 | mai 2026 | ✅ 0.1.1 | stable → stable ✅ | **Cœur** — repo figé à 0.0.0.9000 à débloquer |
| gargoyle | 62 | août 2024 | ✅ 0.0.1 | stable → **dormant** ⚠️ | Relabel + **régler la propriété** |
| skeleton | 58 | avr 2023 | ❌ | experimental → dormant ⚠️ | Archiver ou relabel |
| brochure | 52 | mars 2023 | ❌ | experimental → dormant | Finir (109★, prometteur) **ou** experimental assumé |
| bank | 52 | mars 2023 | ❌ | experimental → dormant | Relabel ou archiver |
| gemstones | 52 | mars 2023 | ❌ | experimental → dormant | Relabel ou archiver |
| ghooks | 48 | mars 2023 | ❌ | experimental → dormant | Finir (merger `dev`) ou archiver |
| shinidraw | 42 | juin 2023 | ❌ | experimental → dormant ⚠️ | Relabel ; lien vers compte perso à corriger |
| minifyr | 42 | juin 2023 | ❌ | experimental → dormant | Relabel/sécuriser (PR dependabot en attente) |
| **w3css** | 38 | mars 2023 | ❌ | experimental → dormant ⚠️ | **Archiver ou dé-lister** (28 stubs vides) |
| **elvis** | 38 | mars 2023 | ❌ | experimental → **abandoned** ⚠️ | **Archiver ou dé-lister** (tests bidon) |

---

## Le plan d'action, par vagues (du meilleur ROI au plus lourd)

### Vague 0 — Quick wins transverses (≈ 1 journée, ROI crédibilité énorme)

Aucune décision stratégique requise, gros effet visuel :

1. **Faire détecter la licence MIT sur les 14 repos.** Cause unique partout : le couple `LICENSE`
   + `LICENSE.md` au format stub R que `licensee` ne classe pas. Un `usethis::use_mit_license()`
   propre par repo → « MIT License » s'affiche enfin. *C'est le meilleur ratio effort/crédibilité
   du rapport.*
2. **Réparer le site (ce repo) :**
   - Ajouter la ligne **minifyr** manquante — ou mieux, **générer la table depuis
     `packages.yaml`** (le `how-to.R` fait déjà ça à moitié) pour qu'elle ne puisse plus diverger.
   - **N'afficher les badges CRAN/téléchargements que pour les packages réellement sur CRAN**
     (`onCran`) — sinon 10 badges « unknown ».
   - Corriger les **labels lifecycle** (gargoyle n'est pas « stable », les dormants ne sont pas
     « experimental »).
3. **Nettoyer le blog :** 3 posts finis (`extending-golem`, `streamlining-…`,
   `about-prototyping-…`) sont coincés en `draft: true`, et `news/golem-shinylive/` traîne
   non-commité dans l'arbre de travail. Publier ou supprimer. Un blog figé à « golem 0.5.1, août
   2024 » est pire que pas de blog.
4. **Normaliser la casse** `ThinkR-open` / `colinfay` partout (DESCRIPTION, badges,
   `packages.yaml`).

### Vague 1 — La décision structurante : définir le périmètre

C'est **la** décision qui débarrasse du « coin de table ». Sans bar d'entrée, on expose elvis à
côté d'un flagship 941★.

5. **Publier une politique de lifecycle** (4 tiers : *Core* = CRAN + tests + pkgdown + actif ;
   *Experimental* = en cours, vrais tests ; *Dormant/Superseded* = archivé read-only).
6. **Trancher la traîne** : archiver (GitHub read-only) **elvis** et **w3css** (les deux plus gros
   boulets) sauf engagement à les finir ; relabel honnête en *dormant* pour bank, gemstones,
   ghooks, skeleton, minifyr, shinidraw. **brochure** (109★, substantiel) mérite soit d'être fini,
   soit un *experimental* assumé sans la bannière « DO NOT USE ».
7. **Le meta-package** : soit construire un vrai `{golemverse}` léger (Imports des membres *Core*,
   message d'attache, `golemverse_packages()`) et dé-commenter l'install, soit **retirer la
   promesse tidyverse** et le bloc commenté. Ne pas livrer du code d'install en commentaire.
8. **Ne pas absorber** les 8 candidats de la roadmap (darkmode, handydandy, nessy…) tant que la
   traîne n'est pas nettoyée — ce serait multiplier tous les problèmes ci-dessus.

### Vague 2 — Régler la propriété org vs perso

9. **Transférer gargoyle, brochure, skeleton, minifyr vers `thinkr-open`** (GitHub redirige les
   vieilles URLs), ou documenter explicitement qu'ils sont perso. **Priorité absolue : gargoyle**
   — *stable + CRAN + compte perso* est la pire combinaison pour une marque qui vend la rigueur
   prod (risque bus-factor, pas de triage org, pas de secrets CI partagés).

### Vague 3 — Remettre le noyau au carré (les 4 qui portent la marque)

10. **golem** : sortir **0.6.0 sur CRAN** (CRAN-SUBMISSION déjà prêt — CRAN traîne de ~2 ans
    derrière le dev) ; repointer le badge codecov (branche figée `fix/create-if-needed` →
    `master`) ; resynchroniser la bannière de version ; ajouter un **vrai hex
    `man/figures/logo.png`** (aujourd'hui c'est le PNG du template RStudio).
11. **shinipsum** : le repo public est **figé à 0.0.0.9000 (2023)** alors que CRAN est à 0.1.1 →
    resynchroniser DESCRIPTION/README/pkgdown, corriger l'install README contradictoire, remplir
    NEWS, merger/fermer les 4 PR en attente (dont une de 2020).
12. **fakir** : re-knit du README (figé 2023, affiche « 1.0.0 »), corriger la casse de l'URL,
    pousser 1.1.0 sur CRAN, section NEWS 1.1.0.
13. **dockerfiler** : hex logo, CONTRIBUTING, badges CRAN/lifecycle.

### Vague 4 — Standards « verse » (cohérence + gouvernance)

14. **Relancer les CI qui n'ont jamais tourné** sur tous les packages conservés (commit trivial /
    `workflow_dispatch`) pour que les badges disent la vérité, et bumper les actions datées
    (`checkout@v3`).
15. **Famille de hex stickers** + un **thème pkgdown partagé** (aligné sur l'objectif roadmap
    « bslib5 »), déployé sur chaque package conservé (10/14 n'ont aucun site pkgdown ni `homepage`
    aujourd'hui).
16. **CONTRIBUTING + CoC uniformes** partout (golem est le seul complet).
17. **Discoverability** : ajouter le topic `golemverse` à shinidraw et minifyr (ils n'en ont
    aucun) ; pointer le lien « GitHub » du site vers une source contrôlée plutôt que
    `github.com/topics/golemverse` (qui remonte déjà des repos tiers squattant le topic) ;
    réconcilier roadmap ↔ site ↔ topic (golem.lint existe déjà).

---

## Annexe — détail par package

### Noyau (à garder)

- **golem** (94) — Flagship : 941★, CRAN, 8 workflows CI verts, 54 fichiers de test (~88 % cov),
  8 vignettes, pkgdown, NEWS/CONTRIBUTING/CoC/MIT. *Gaps :* CRAN (0.5.1) traîne derrière le dev
  (0.6.0.9000) ; badge codecov pinné sur une branche figée ; bannière de version désynchronisée ;
  pas de vrai hex logo ; licence vue NOASSERTION.
- **dockerfiler** (90) — Production-ready : CRAN 1.0.0 (sync GitHub), CI verte, suite de tests
  profonde, pkgdown, NEWS, MIT. *Gaps cosmétiques :* pas de hex logo, pas de CONTRIBUTING, pas de
  badge CRAN/lifecycle dans le README.
- **fakir** (86) — Maintenu, qualité prod : CRAN, CI verte, pkgdown, tests, NEWS, hex logo, bonne
  org. *Gaps :* README figé 2023 (affiche « 1.0.0 » alors que DESCRIPTION = 1.1.0), casse URL
  `Thinkr-open`, CRAN en retard sur 1.1.0, NEWS sans section 1.1.0, pas de CONTRIBUTING.
- **shinipsum** (78) — Soigné, CRAN 0.1.1, bonne couverture, CI verte, pkgdown, hex logo. *Gaps
  majeurs :* DESCRIPTION/README/pkgdown **figés à 0.0.0.9000 (2023)** → semble négligé ; install
  README contradictoire (prose « dev version » mais code `install.packages`) ; NEWS = boilerplate
  vide ; 4 PR ouvertes non mergées (dont #8 de 2020).

### Traîne (à trancher)

- **gargoyle** (62) — Utile, CRAN, README/vignette/tests réels, **mais dormant (22 mois), CI
  jamais lancée, NEWS stub, pas de pkgdown, 2 PR + bugs en attente, sur compte perso.** Le badge
  « stable » surévalue la réalité.
- **skeleton** (58) — Bien construit mais dormant ~38 mois, compte perso, CI jamais lancée, pas de
  NEWS/pkgdown/CRAN. Exemple golem-hook erroné dans le README (arguments inversés).
- **brochure** (52) — Substantiel (109★, excellent README) mais branche par défaut dormante depuis
  mars 2023, CI jamais lancée, réécriture du routing bloquée sur des branches, couverture 42 %
  (cœur du moteur à 0 %), bannière « DO NOT USE ».
- **bank** (52) — Backends de cache utiles et bien documentés, mais dormant, CI **skip tous les
  tests fonctionnels** (`skip_on_ci`, nécessite Docker), pas de CRAN/pkgdown/vignette, DESCRIPTION
  minimaliste.
- **gemstones** (52) — Add-on golem propre mais dormant ~39 mois, CI jamais lancée, moitié de la
  surface non testée (use_notifyjs à 0 %), pas de pkgdown, fautes d'anglais dans le README.
- **ghooks** (48) — Helper réel avec vrais tests, mais inachevé : DESCRIPTION = placeholder
  « What the package does », CI jamais lancée, travail fini coincé sur `dev`, main figé ~38 mois.
- **shinidraw** (42) — Wrapper utile et raisonnablement testé, abandonné après 2023 : CI jamais
  lancée, pas de CRAN/pkgdown, URL/BugReports pointent vers le compte perso, About vide, **pas de
  topic golemverse**, 8 bugs non triés.
- **minifyr** (42) — Wrapper soigné, bons tests, mais dormant, CI jamais lancée, **tests skippés
  entièrement sans Node en CI**, NEWS périmé, PR dependabot de sécurité en attente depuis 2023,
  compte perso, **pas de topic golemverse**.
- **w3css** (38) — Structure propre, CI passe, bons exemples README, **mais branche par défaut
  ~39 mois figée, 0 % de couverture réelle, 28 composants en stubs vides, [WIP]**, seul travail
  récent dans une PR non mergée.
- **elvis** (38) — Idée sympa (try_* plus sûrs) jamais aboutie : **9 fichiers de test tous
  identiques `2*2==4`**, CI jamais lancée, pas de release, aucun commit sur main depuis mars 2023,
  README « [EXPERIMENTAL, DO NOT USE] ». **Effectivement abandonné.**

---

## En résumé

Le golemverse a un noyau solide — **golem (94), dockerfiler (90), fakir (86), shinipsum (78)** —
mais il est présenté dans un cadre qui érode sa crédibilité : une promesse meta-package fictive,
9 packages dormants mal étiquetés (dont 2 quasi non-fonctionnels et toujours mis en avant), une
propriété éclatée entre l'org et un compte perso, un site vitrine qui se contredit, et zéro
licence détectable sur les 14 repos.

**Wins crédibilité les moins chers, dans l'ordre :** (1) fix licence MIT sur les 14 repos ;
(2) corriger la table du site (minifyr + badges CRAN conditionnels + labels lifecycle) ;
(3) construire un vrai `{golemverse}` ou supprimer la promesse d'install ; (4) archiver/relabel
honnêtement elvis, w3css et le reste de la traîne ; (5) régler la propriété org/perso (gargoyle
en premier).
