# Planning Agile — Simulateur de Congés Payés Assistante Maternelle

## 1. Objectif Métier (Business Goal)

**Problème :** Un particulier employeur d'une assistante maternelle en contrat "année incomplète" doit calculer et planifier le paiement des congés payés selon les règles de la Convention Collective Nationale (CCN 2004). Ces règles sont complexes et diffèrent totalement du régime classique des salariés.

**Résultat attendu :** L'utilisateur saisit les paramètres de son contrat et obtient une simulation détaillée comprenant :
- Le découpage en périodes de congés (1er juin → 31 mai)
- Le nombre de jours acquis par période et leur valorisation monétaire
- Un échéancier mensuel du salaire brut et des congés payés selon 3 modes de paiement au choix
- La gestion automatique du solde de tout compte en cas de fin de contrat anticipée

**Contrainte invariante :** Quel que soit le mode de paiement choisi, le total des sommes versées au salarié au titre des congés payés doit être identique.

---

## 2. Personas

**Persona principal — L'employeur particulier**
Parent employant une assistante maternelle à son domicile. N'est pas un professionnel RH/paie. A besoin d'un outil simple pour comprendre et anticiper les montants dus au titre des congés payés sur toute la durée du contrat.

---

## 3. User Stories

### Epic 1 : Saisie et validation du contrat

> **Story 1.1 — Saisir les paramètres du contrat**
>
> *En tant qu'employeur, je veux saisir les informations de base de mon contrat (dates, salaire) afin que le simulateur puisse effectuer les calculs.*
>
> **Inputs :**
> - Date de début de contrat (format date valide, obligatoire)
> - Date de fin de contrat (format date valide, obligatoire)
> - Salaire brut mensuel (montant en euros)
>
> **Critères d'acceptation :**
> - [ ] Les dates sont au format valide (ex: YYYY-MM-DD ou JJ/MM/AAAA)
> - [ ] Les deux dates sont obligatoires et présentes
> - [ ] La date de fin est strictement postérieure à la date de début
> - [ ] Le salaire brut mensuel est compris entre 200 € et 1 200 €
> - [ ] En cas de saisie invalide, un message d'erreur explicite est affiché
> - [ ] Aucun calcul ne se lance tant que les validations ne passent pas

---

### Epic 2 : Découpage en périodes de congés

> **Story 2.1 — Calculer les périodes de référence**
>
> *En tant qu'employeur, je veux voir le découpage de mon contrat en périodes de congés (1er juin → 31 mai) afin de comprendre sur quelles fenêtres les droits sont calculés.*
>
> **Règles métier :**
> - Une période de référence court du 1er juin au 31 mai
> - La première période commence à la date de début du contrat et se termine au 31 mai suivant
> - Les périodes intermédiaires couvrent un cycle complet du 1er juin au 31 mai
> - La dernière période commence au 1er juin et se termine à la date de fin du contrat
> - Si le contrat commence et se termine au sein d'une même période, il n'y a qu'une seule période
>
> **Critères d'acceptation :**
> - [ ] Un contrat du 11/09/2023 au 25/07/2025 produit 3 périodes :
>   - 11/09/2023 → 31/05/2024
>   - 01/06/2024 → 31/05/2025
>   - 01/06/2025 → 25/07/2025
> - [ ] Un contrat du 01/06/2024 au 31/05/2025 produit 1 période complète
> - [ ] Un contrat du 15/01/2025 au 20/03/2025 produit 1 seule période partielle
> - [ ] La liste des périodes est affichée dans le tableau récapitulatif

---

> **Story 2.2 — Calculer les mois couverts et leurs proratas**
>
> *En tant qu'employeur, je veux voir la liste de tous les mois couverts par le contrat avec le prorata applicable à chacun, afin de comprendre comment les montants mensuels sont calculés.*
>
> **Règles métier :**
> - Un mois entièrement couvert par le contrat a un prorata de 1.0
> - Un mois partiellement couvert (début ou fin de contrat en cours de mois) a un prorata = nombre de jours couverts / nombre de jours dans le mois
> - Formule confirmée par le spreadsheet : `first_day = max(start_date, 1er du mois)`, `last_day = min(end_date, dernier du mois)`, `days_covered = last_day - first_day + 1`, `prorata = days_covered / days_in_month`
> - Exemple début : contrat commençant le 15 mars → days_covered = 31 - 15 + 1 = 17, prorata = 17/31
> - Exemple fin : contrat finissant le 25 juillet → days_covered = 25, prorata = 25/31
> - Le prorata s'applique au salaire brut. Le spreadsheet confirme : salaire mars = `506 × 17/31 = 277,48 €`
>
> **Critères d'acceptation :**
> - [ ] Le premier mois d'un contrat commençant le 11/09/2023 a un prorata de 20/30
> - [ ] Le dernier mois d'un contrat finissant le 25/07/2025 a un prorata de 25/31
> - [ ] Tous les mois intermédiaires ont un prorata de 1.0
> - [ ] Le salaire brut du mois = salaire mensuel × prorata

---

### Epic 3 : Acquisition des congés

> **Story 3.1 — Calculer les jours acquis par période**
>
> *En tant qu'employeur, je veux connaître le nombre de jours de congés acquis sur chaque période de référence, afin de savoir combien de jours mon assistante maternelle a accumulés.*
>
> **Règles métier :**
> - 2,5 jours ouvrables acquis par mois entièrement travaillé
> - Pour un mois incomplet : 2,5 × prorata calendaire du mois
> - Le total est calculé par période (somme des acquisitions mensuelles)
> - Le nombre de mois d'acquisition par période est affiché (somme des proratas)
>
> **Critères d'acceptation :**
> - [ ] Un mois complet = 2,5 jours acquis
> - [ ] Un mois avec prorata 20/30 = 2,5 × 20/30 ≈ 1,67 jours
> - [ ] Le total des jours acquis sur une période complète (12 mois entiers) = 30 jours
> - [ ] Le nombre de jours acquis par période est affiché dans le tableau des périodes

---

### Epic 4 : Valorisation des congés

> **Story 4.1 — Calculer la valeur par la méthode "maintien de salaire"**
>
> *En tant qu'employeur, je veux calculer la valeur des congés par la méthode du maintien de salaire, afin de la comparer avec la méthode des 10%.*
>
> **Règles métier :**
> - Formule : (salaire mensuel brut / 22) × nombre de jours acquis sur la période
> - Le diviseur 22 représente le nombre de jours ouvrables standard par mois (fixe)
> - Le salaire mensuel utilisé est le salaire brut contractuel (pas le proratisé)
>
> **Critères d'acceptation :**
> - [ ] Pour un salaire de 500 € et 30 jours acquis : (500 / 22) × 30 = 681,82 €
> - [ ] La valeur est calculée pour chaque période
> - [ ] La valeur est affichée dans le tableau des périodes

---

> **Story 4.2 — Calculer la valeur par la méthode des 10%**
>
> *En tant qu'employeur, je veux calculer la valeur des congés par la méthode des 10%, afin de la comparer avec la méthode du maintien de salaire.*
>
> **Règles métier :**
> - Formule : 10% de la somme des salaires bruts versés sur la période de référence
> - La base inclut uniquement les salaires bruts (hors indemnités entretien/nourriture)
> - La base exclut les montants versés au titre des congés payés eux-mêmes
>
> **Critères d'acceptation :**
> - [ ] Pour 12 mois à 500 € : 10% × 6 000 € = 600 €
> - [ ] Pour une période incomplète (ex: 8,67 mois) la base est la somme des salaires proratisés
> - [ ] La valeur est affichée dans le tableau des périodes

---

> **Story 4.3 — Retenir la méthode la plus avantageuse**
>
> *En tant qu'employeur, je veux que le simulateur retienne automatiquement la méthode la plus favorable au salarié, conformément à la CCN.*
>
> **Règles métier :**
> - La valeur retenue = max(maintien de salaire, méthode 10%)
> - Ce montant est celui utilisé pour le paiement, quel que soit le mode choisi
>
> **Critères d'acceptation :**
> - [ ] Si maintien = 681,82 € et 10% = 600 €, la valeur retenue est 681,82 €
> - [ ] La valeur retenue est affichée dans le tableau des périodes dans une colonne dédiée
> - [ ] Les deux méthodes restent visibles pour comparaison

---

### Epic 5 : Paiement des congés — Mode A (Intégral en juin)

> **Story 5.1 — Payer l'intégralité des congés en juin**
>
> *En tant qu'employeur, je veux voir le montant total des congés versé en une seule fois au mois de juin suivant la clôture de la période, afin de planifier ma trésorerie.*
>
> **Règles métier :**
> - Les congés acquis du 1er juin N au 31 mai N+1 sont valorisés au 31 mai N+1
> - Le montant total est versé en juin N+1
> - Sur le tableau mensuel, seul le mois de juin comporte un montant en colonne "congés"
> - Les autres mois affichent 0 € en congés
>
> **Critères d'acceptation :**
> - [ ] Le mois de juin affiche le montant total des congés de la période précédente
> - [ ] Tous les autres mois affichent 0,00 € en congés pour ce mode
> - [ ] Le total des congés versés sur l'ensemble du contrat = somme des valeurs retenues de toutes les périodes

---

> **Story 5.2 — Solder les congés en cas de fin de contrat (Mode A)**
>
> *En tant qu'employeur, je veux que le dernier mois du contrat inclue le solde de tous les congés restant dus, afin de respecter l'obligation légale.*
>
> **Règles métier :**
> - Si le contrat se termine avant le 31 mai : les congés de la période en cours (N) sont valorisés et versés sur la dernière fiche de paie
> - Si des congés de la période précédente (N-1) n'ont pas encore été versés (ex: fin avant juin), ils sont également ajoutés à la dernière fiche de paie
>
> **Critères d'acceptation :**
> - [ ] Contrat finissant en mars 2025 : le mois de mars inclut les congés N (juin 2024 → mars 2025) + les congés N-1 non versés (si le contrat n'a pas atteint le mois de juin précédent)
> - [ ] Contrat finissant en juillet 2025 : juin 2025 a déjà versé la période N-1, juillet verse les congés N en cours (juin → juillet)

---

### Epic 6 : Paiement des congés — Mode B (Par 1/12ème)

> **Story 6.1 — Verser les congés par 1/12ème mensuel**
>
> *En tant qu'employeur, je veux étaler le paiement des congés sur 12 mois après la clôture de la période, afin de lisser ma charge financière.*
>
> **Règles métier :**
> - Les congés acquis sur la période (1er juin N → 31 mai N+1) sont valorisés au 31 mai N+1
> - Le montant est divisé par 12 et versé mensuellement de juin N+1 à mai N+2
> - Si deux flux de 1/12ème se superposent (période N-1 et N-2 en cours de versement), les montants se cumulent sur le mois
>
> **Critères d'acceptation :**
> - [ ] Pour des congés valant 600 €, chaque mois reçoit 50 € pendant 12 mois
> - [ ] Aucun versement de congés n'apparaît avant le premier mois de juin suivant la première clôture de période
> - [ ] Si deux périodes ont des 1/12ème en cours simultanément, le montant mensuel est la somme des deux
> - [ ] Le total versé sur l'ensemble du contrat = somme des valeurs retenues

---

> **Story 6.2 — Solder les congés en cas de fin de contrat (Mode B)**
>
> *En tant qu'employeur, je veux que le dernier mois du contrat inclue le solde de tous les 1/12èmes restants + la valorisation de la période en cours.*
>
> **Règles métier :**
> - Si le contrat se termine alors que des 1/12èmes de la période N-1 sont encore en cours de versement : les mensualités restantes sont soldées sur la dernière fiche de paie
> - Les congés de la période en cours (N) sont valorisés et intégralement versés sur la dernière fiche de paie
>
> **Critères d'acceptation :**
> - [ ] Contrat finissant en octobre 2025 alors que les 1/12èmes de la période N-1 (juin 2025 → mai 2026) sont en cours : les 7 mensualités restantes (nov → mai) sont ajoutées au mois d'octobre
> - [ ] Les congés de la période en cours (juin 2025 → octobre 2025) sont valorisés et ajoutés au mois d'octobre
> - [ ] Le total de tous les versements = somme des valeurs retenues de toutes les périodes

---

### Epic 7 : Paiement des congés — Mode C (10% mensuel + régularisation)

> **Story 7.1 — Verser 10% du salaire brut chaque mois**
>
> *En tant qu'employeur, je veux verser chaque mois 10% du salaire brut en provision de congés payés, avec une régularisation en juin, afin de simplifier le suivi.*
>
> **Règles métier :**
> - Chaque mois, un montant de 10% du salaire brut du mois est versé au titre des congés
> - En juin (à la clôture de la période), on calcule la valeur réelle des congés (max des 2 méthodes)
> - La régularisation = valeur réelle − somme des 10% déjà versés **sur les mois de cette même période uniquement**
> - ⚠️ Important : la régularisation de juin N+1 soustrait les 10% versés de juin N à mai N+1 (mois de la période de référence), pas ceux versés depuis le dernier juin. Confirmé par les formules du Google Sheet.
> - La régularisation est toujours ≥ 0 (pas de régularisation négative, car la méthode la plus avantageuse est retenue)
> - Le mois de juin comporte donc : le 10% du mois de juin + le montant de régularisation
>
> **Critères d'acceptation :**
> - [ ] Chaque mois affiche 10% du salaire brut proratisé du mois
> - [ ] Le mois de juin affiche la somme du 10% mensuel + la régularisation
> - [ ] La régularisation n'est jamais négative
> - [ ] Le total versé sur l'ensemble du contrat = somme des valeurs retenues de toutes les périodes
> - [ ] Référence : pour le contrat 15/03/2020 → 31/01/2023 à 506 €, juin 2020 = 68,28 € (50,60 € de 10% + 17,68 € de régul)

---

> **Story 7.2 — Solder les congés en cas de fin de contrat (Mode C)**
>
> *En tant qu'employeur, je veux que le dernier mois du contrat inclue la régularisation des congés, en tenant compte des 10% déjà versés.*
>
> **Règles métier :**
> - Congés de la période en cours (N) : valeur réelle − somme des 10% déjà versés sur N
> - Congés de la période précédente (N-1) éventuellement non régularisés : solde restant dû
> - Tout est versé sur la dernière fiche de paie
>
> **Critères d'acceptation :**
> - [ ] Le dernier mois affiche le 10% du mois + la régularisation de la période en cours + le solde éventuel de la période N-1
> - [ ] Le total cumulé de tous les versements = somme des valeurs retenues

---

### Epic 8 : Affichage des résultats

> **Story 8.1 — Afficher le tableau des périodes de congés**
>
> *En tant qu'employeur, je veux voir un récapitulatif par période avec les jours acquis et leur valorisation, afin de comprendre les calculs.*
>
> **Colonnes attendues :**
> - Période (date début → date fin)
> - Nombre de mois d'acquisition (somme des proratas)
> - Nombre de jours acquis
> - Valeur méthode "maintien de salaire" (salaire / 22 × jours acquis)
> - Valeur méthode "10%" (10% des salaires versés sur la période)
> - Valeur retenue (max des deux)
>
> **Critères d'acceptation :**
> - [ ] Le tableau contient une ligne par période
> - [ ] Les montants sont arrondis à 2 décimales
> - [ ] La colonne "valeur retenue" est bien le max des deux méthodes

---

> **Story 8.2 — Afficher le tableau de rémunération mensuelle**
>
> *En tant qu'employeur, je veux voir mois par mois le détail du salaire brut et des congés payés pour chacun des 3 modes, afin de comparer et choisir le mode de paiement.*
>
> **Colonnes attendues :**
> - Mois (ex: "Septembre 2023")
> - Salaire brut dû
> - Congés — Mode A (intégral en juin)
> - Congés — Mode B (par 1/12ème)
> - Congés — Mode C (10% + régularisation)
>
> **Critères d'acceptation :**
> - [ ] Le tableau contient une ligne par mois couvert par le contrat
> - [ ] Les montants sont arrondis à 2 décimales
> - [ ] Une ligne de total en fin de tableau vérifie que les 3 colonnes de congés sont identiques
> - [ ] Le total des congés de chaque mode = somme des valeurs retenues de toutes les périodes

---

### Epic 9 : Vérification de cohérence

> **Story 9.1 — Vérifier l'invariant de cohérence inter-modes**
>
> *En tant qu'employeur, je veux être assuré que le total des congés versés est identique quel que soit le mode de paiement choisi.*
>
> **Règles métier :**
> - Somme(congés Mode A) = Somme(congés Mode B) = Somme(congés Mode C)
> - Ce total = somme des valeurs retenues de toutes les périodes
>
> **Critères d'acceptation :**
> - [ ] Le simulateur calcule et affiche les 3 totaux
> - [ ] Si les totaux divergent (au-delà d'un epsilon d'arrondi de 0,01 €), un avertissement est affiché
> - [ ] Les tests automatisés vérifient systématiquement cet invariant

---

## 4. Backlog priorisé (Sprints)

### Sprint 1 — Fondations (~1h)
| # | Story | Priorité |
|---|-------|----------|
| 1 | Story 1.1 — Saisie et validation du contrat | Must |
| 2 | Story 2.1 — Calcul des périodes de référence | Must |
| 3 | Story 2.2 — Calcul des mois et proratas | Must |

**Livrable :** Un contrat validé produit une liste de périodes et de mois avec leurs proratas. Tests verts.

### Sprint 2 — Moteur de calcul (~1h)
| # | Story | Priorité |
|---|-------|----------|
| 4 | Story 3.1 — Acquisition des jours | Must |
| 5 | Story 4.1 — Valorisation maintien de salaire | Must |
| 6 | Story 4.2 — Valorisation 10% | Must |
| 7 | Story 4.3 — Sélection méthode la plus avantageuse | Must |

**Livrable :** Pour un contrat donné, chaque période a ses jours acquis et sa valeur monétaire. Tests verts. Validation croisée avec le Google Sheet d'exemple.

### Sprint 3 — Modes de paiement + rupture de contrat (~2h)
| # | Story | Priorité |
|---|-------|----------|
| 8 | Story 5.1 — Mode A : paiement intégral en juin | Must |
| 9 | Story 5.2 — Solde fin de contrat (Mode A) | Must |
| 10 | Story 6.1 — Mode B : paiement par 1/12ème | Must |
| 11 | Story 6.2 — Solde fin de contrat (Mode B) | Must |
| 12 | Story 7.1 — Mode C : 10% mensuel + régularisation | Must |
| 13 | Story 7.2 — Solde fin de contrat (Mode C) | Must |

**Livrable :** Les 3 modes produisent un échéancier mensuel, y compris en cas de fin de contrat anticipée. L'invariant de cohérence (totaux identiques) est vérifié sur chaque mode. Tests verts.

> **Note :** Les stories de rupture (5.2, 6.2, 7.2) sont testées comme des contextes additionnels dans les mêmes fichiers de spec que les stories principales (5.1, 6.1, 7.1). Cela permet de vérifier que l'invariant est maintenu dans tous les cas sans séparer le code en deux sprints.

### Sprint 4 — Orchestrateur + persistance (~45min)
| # | Story | Priorité |
|---|-------|----------|
| 14 | Story 9.1 — Vérification de cohérence (invariant inter-modes) | Must |
| - | SimulatorService — orchestration complète + persistance DB | Must |
| - | Golden reference test — validation contre le Google Sheet | Must |

**Livrable :** Le `SimulatorService` enchaîne tous les calculateurs, calcule les 3 modes de paiement, et persiste les résultats en base de données (LeavePeriod + MonthEntry). L'invariant inter-modes est testé sur 6 scénarios différents. Le test golden reference valide les résultats contre le spreadsheet de l'examinateur (contrat 15/03/2020 → 31/01/2023, salaire 506 €). Tests verts.

> **Note :** C'est le seul sprint qui touche à ActiveRecord. Les sprints 1–3 utilisent des `OpenStruct` et `Hash`, sans base de données.

### Sprint 5 — Contrôleur + routes (~45min)
| # | Story | Priorité |
|---|-------|----------|
| 15 | Story 8.1 — Tableau des périodes (via controller show) | Must |
| 16 | Story 8.2 — Tableau de rémunération mensuelle (via controller show) | Must |
| - | SimulationsController (new, create, show) + routes | Must |

**Livrable :** Les routes `simulations#new`, `simulations#create`, `simulations#show` fonctionnent. Le formulaire crée une simulation, le show affiche les résultats. Request specs verts.

### Sprint 6 — Vues, Stimulus/Turbo et livraison (~45min)
| # | Story | Priorité |
|---|-------|----------|
| - | Vues ERB (formulaire, tableaux des périodes et des mois) | Must |
| - | Stimulus controller (validation client-side) | Should |
| - | Localisation FR (dates, messages d'erreur) | Should |
| - | README finalisé + push GitHub | Must |

**Livrable :** Application Rails fonctionnelle, formulaire avec validation côté client, résultats affichés dans deux tableaux avec ligne de total. README complet. Code commenté. Push final sur GitHub.

---

## 5. Definition of Done (DoD)

Chaque story est considérée terminée quand :
- [ ] Le test a été écrit AVANT le code (TDD)
- [ ] Le code est écrit et fonctionnel
- [ ] Les tests unitaires couvrent les cas nominaux et les cas limites
- [ ] Les classes métier principales sont commentées
- [ ] L'invariant de cohérence inter-modes reste vérifié
- [ ] `bundle exec rspec` passe entièrement (suite complète verte)
- [ ] Le code est commité avec un message descriptif

**Définition de Done finale (Sprint 4+) :**
- [ ] Le test golden reference (`golden_reference_spec.rb`) passe — les valeurs correspondent au Google Sheet de l'examinateur

---

## 6. Cas limites identifiés (pour les tests)

| Cas | Description |
|-----|-------------|
| **Contrat de référence** | **15/03/2020 → 31/01/2023, 506 € — valeurs à valider contre le Google Sheet** |
| Contrat court | Début et fin dans la même période (ex: 15/01/2025 → 20/03/2025) |
| Contrat démarrant le 1er juin | La première période est complète |
| Contrat finissant le 31 mai | La dernière période est complète, pas de solde anticipé |
| Contrat d'un seul mois | Un seul mois, une seule période |
| Fin de contrat avant le premier juin | Jamais de paiement en juin, tout est soldé sur le dernier mois |
| Mois de février | Prorata sur 28 ou 29 jours (année bissextile) |
| Chevauchement de 1/12èmes | Ne se produit PAS : les flux de 1/12ème sont toujours séquentiels (Jun→May). Le cumul n'intervient que sur le dernier mois (solde terminal). |
| Solde Mode B terminal | Reliquat des 1/12èmes non versés + valeur période en cours (ex: jan 2023 = 747,50 €) |
| Salaire min/max | Vérifier avec 200 € et 1 200 € |
| Contrat long (4+ ans) | Multiples périodes, cumuls de paiements |

### Points de vigilance découverts

**Arrondi de `months_worked` :** Le Google Sheet de référence affiche 2,55 mois pour la période 1 (15/03 → 31/05/2020), alors que la somme exacte des proratas donne 17/31 + 1 + 1 = 2,5484. Le sheet arrondit à 2 décimales. Ce choix se propage sur `days_acquired` (6,375 au lieu de 6,371) et impacte le montant final (~0,10 € d'écart). Le golden test utilise une tolérance de 0,01 €.

**Régularisation Mode C :** Les formules du sheet confirment que chaque régularisation en juin soustrait les 10% versés uniquement sur les mois de SA PROPRE PÉRIODE (pas depuis le dernier juin). Exemple : régul juin 2021 = P2 value − SUM(10% de juin 2020 à mai 2021).

---

## 7. Stack technique

| Composant | Choix |
|-----------|-------|
| Framework | Rails 8.1.1 |
| Langage | Ruby >= 3.2 |
| Base de données | MariaDB (mysql2) |
| Frontend | Hotwire (Turbo + Stimulus) |
| CSS | Tailwind CSS |
| Tests | RSpec + FactoryBot + Shoulda Matchers |
| Méthodologie | TDD (Red → Green → Refactor) |
| Livraison | GitHub (accès lecture : charly.hay@top-webgroup.com) |
| Documentation | README.md + docs/ |

---

## 8. Décisions d'architecture

### Couche de calcul pure (sans base de données)

Tous les calculateurs et services de paiement opèrent sur des `OpenStruct` (périodes) et `Hash` (mois) — jamais d'ActiveRecord. Seul le `SimulatorService` (orchestrateur) fait le pont entre la couche de calcul et la base de données.

```
Calculators (pure Ruby)  →  SimulatorService (bridge)  →  ActiveRecord (DB)
  OpenStruct + Hash             seul point de                Simulation
  pas de DB                     persistance                  LeavePeriod
                                                             MonthEntry
```

### Module partagé : PeriodMonthFilter

La logique "quels mois appartiennent à quelle période" est extraite dans un module `PeriodMonthFilter` réutilisé par `AccrualCalculator`, `SimulatorService` et les helpers de test.

---

## 9. Validation de référence — Google Sheet

Le simulateur doit reproduire les résultats du spreadsheet fourni par l'examinateur.

**Contrat de référence :**
- Début : 15 mars 2020
- Fin : 31 janvier 2023
- Salaire : 506,00 €

**Résultats attendus :**

| Période | Mois | Jours | Valeur retenue |
|---------|------|-------|----------------|
| 15/03/2020 → 31/05/2020 | 2,55 | 6,375 | 146,63 € |
| 01/06/2020 → 31/05/2021 | 12,00 | 30,000 | 690,00 € |
| 01/06/2021 → 31/05/2022 | 12,00 | 30,000 | 690,00 € |
| 01/06/2022 → 31/01/2023 | 8,00 | 20,000 | 460,00 € |

**Total congés = 1 986,63 € (identique pour les 3 modes)**

**Points de vérification mensuels clés :**

| Mois | Salaire | Mode A | Mode B | Mode C |
|------|---------|--------|--------|--------|
| mars 2020 | 277,48 € | 0,00 € | 0,00 € | 27,75 € |
| juin 2020 | 506,00 € | 146,63 € | 12,22 € | 68,28 € |
| juin 2021 | 506,00 € | 690,00 € | 57,50 € | 133,40 € |
| juin 2022 | 506,00 € | 690,00 € | 57,50 € | 133,40 € |
| jan 2023 | 506,00 € | 460,00 € | 747,50 € | 105,80 € |

Un test "golden reference" (`spec/services/golden_reference_spec.rb`) valide automatiquement ces valeurs.

Détails complets dans `docs/REFERENCE_DATA.md`.

---

## 10. Documents liés

| Document | Contenu |
|----------|---------|
| `README.md` | Vue d'ensemble du projet, prérequis, installation, feuille de route |
| `docs/PLANNING_AGILE.md` | Ce document — user stories, critères d'acceptation, backlog |
| `docs/REFERENCE_DATA.md` | Données de référence extraites du Google Sheet + analyse des formules |
