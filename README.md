Simulateur de Congés Payés — Assistante Maternelle

Simulateur de paiement des congés payés pour un contrat de type année incomplète, conforme à la Convention Collective Nationale des assistants maternels du particulier employeur (CCN 2004).

Contexte

Le calcul des congés payés pour une assistante maternelle en année incomplète diffère totalement du régime classique des salariés. Ce simulateur permet à un particulier employeur de saisir les paramètres de son contrat et d'obtenir :

Le découpage en périodes de référence (1er juin → 31 mai)
Le nombre de jours de congés acquis par période et leur valorisation monétaire (max de deux méthodes)
Un échéancier mensuel du salaire brut et des congés payés selon 3 modes de paiement
La gestion automatique du solde de tout compte en cas de fin de contrat anticipée

Invariant : quel que soit le mode de paiement choisi, le total des sommes versées au salarié au titre des congés payés est identique.

***
Prérequis

Ruby >= 3.2
Rails 8.1.1
MariaDB
Node.js (pour le pipeline assets Tailwind / Stimulus)
Bundler

Installation
```bash
git clone git@github.com:xeonnux/conges_simulator.git
cd conges_simulator
```

# Installer les dépendances

```bash
bundle install
```

# Configurer la base de données
# → Éditer config/database.yml avec vos identifiants MariaDB
```bash
rails db:create
rails db:migrate
```

# Lancer les tests

```bash
bundle exec rspec
```
# Lancer le serveur
```bash
rails server
```
 ou (pour le pipeline Tailwind + Stimulus)
 
```bash
bin/dev
``` 
L'application est accessible à http://localhost:3000.

***
Stack technique

| Composant | Choix |
| --- | --- |
| Framework | Rails 8.1.1 |
| Langage | Ruby >= 3.2 |
| Base de données | MariaDB (mysql2) |
| Frontend | Hotwire (Turbo + Stimulus) |
| CSS | Tailwind CSS |
| Tests | RSpec + FactoryBot + Shoulda Matchers |

***
Architecture

```
app/
├── models/                        # Persistence + validations (thin)
│   ├── simulation.rb              # ActiveRecord — paramètres du contrat
│   ├── leave_period.rb            # ActiveRecord — périodes calculées
│   └── month_entry.rb             # ActiveRecord — échéancier mensuel
│
├── services/                      # Business logic (pure Ruby, DB-free)
│   ├── calculators/
│   │   ├── period_calculator.rb
│   │   ├── month_calculator.rb
│   │   ├── accrual_calculator.rb
│   │   └── valuation_calculator.rb
│   ├── payment/
│   │   ├── lump_sum.rb            # Mode A — Intégral en juin
│   │   ├── twelfth_spread.rb      # Mode B — Par 1/12ème
│   │   └── monthly_tenth.rb       # Mode C — 10% + régularisation
│   ├── concerns/
│   │   └── period_month_filter.rb
│   └── simulator_service.rb       # Orchestrateur (seul point de persistance)
│
├── controllers/
│   └── simulations_controller.rb  # new, create, show
│
├── javascript/controllers/
│   └── form_validation_controller.js  # Validation client (Stimulus)
│
└── views/simulations/
    ├── new.html.erb + _form.html.erb
    └── show.html.erb + _periods_table.html.erb + _months_table.html.erb
```

Principe clé : tous les calculateurs et services de paiement opèrent sur des OpenStruct et Hash — jamais d'ActiveRecord. Seul SimulatorService fait le pont entre la couche de calcul et la base de données.

***
Règles métier

Périodes de référence
Les congés sont calculés par périodes de 12 mois, du 1er juin au 31 mai. La première période commence à la date de début du contrat. La dernière se termine à la date de fin du contrat.

Acquisition
2,5 jours ouvrables acquis par mois entier travaillé. Pour un mois incomplet, un prorata calendaire est appliqué : jours_couverts / jours_dans_le_mois.

Valorisation (deux méthodes, la plus favorable au salarié est retenue)
Maintien de salaire : salaire_mensuel / 22 × jours_acquis
Méthode 10% : 10% × somme des salaires bruts versés sur la période

Paramètres acceptés
Salaire brut mensuel entre 200 € et 1 200 € (validé côté serveur et côté client).
Date de fin strictement postérieure à la date de début.

Modes de paiement
Mode A — Paiement intégral au mois de juin suivant la clôture de la période
Mode B — Paiement par 1/12ème sur les 12 mois suivants (juin N+1 → mai N+2)
Mode C — 10% du salaire brut chaque mois + régularisation en juin (hors CCN)

Fin de contrat anticipée
Le dernier mois du contrat inclut le solde de tous les congés restant dus : période en cours (N) + éventuel reliquat de la période précédente (N-1).

Hypothèses simplificatrices
La nounou ne prend jamais de vacances et travaille en permanence
Les proratas (salaire et acquisition) sont calendaires : jours_couverts / jours_dans_le_mois

***
Feuille de route — Développement

Méthodologie : TDD (Red → Green → Refactor) en 6 sprints.

Les détails complets des tests et implémentations sont dans docs/TDD_GUIDE_RAILS.md.

Sprint 1 — Fondations
Modèle Simulation (ActiveRecord) avec validations de présence, plage de salaire et cohérence des dates
Service Calculators::PeriodCalculator — découpage du contrat en périodes
Service Calculators::MonthCalculator — liste des mois avec proratas et salaires

Sprint 2 — Moteur de calcul
Service Calculators::AccrualCalculator — jours acquis par période
Service Calculators::ValuationCalculator — deux méthodes de valorisation + sélection du max

Sprint 3 — Modes de paiement + rupture
Service Payment::LumpSum — Mode A (intégral en juin)
Service Payment::TwelfthSpread — Mode B (par 1/12ème)
Service Payment::MonthlyTenth — Mode C (10% mensuel + régularisation)
Cas de fin de contrat anticipée pour les 3 modes

Sprint 4 — Orchestrateur + persistance
Modèles ActiveRecord LeavePeriod et MonthEntry (associations belongs_to / has_many)
SimulatorService — enchaîne tous les calculs et persiste en base dans une transaction
PeriodMonthFilter — module partagé pour filtrer les mois par période
Test de l'invariant inter-modes (spec/services/golden_reference_spec.rb) sur plusieurs scénarios

Sprint 5 — Contrôleur + routes
SimulationsController (new, create, show)
Routes RESTful
Request specs

Sprint 6 — Vues + Stimulus/Turbo + livraison
Formulaire de saisie avec validation côté client (Stimulus)
Tableau des périodes de congés
Tableau de rémunération mensuelle (3 modes)
Ligne de total + vérification de cohérence inter-modes
Localisation FR
README finalisé

***
Lancer les tests

# Suite complète
`bundle exec rspec`

# Par sprint / couche
```bash
bundle exec rspec spec/models/
bundle exec rspec spec/services/calculators/
bundle exec rspec spec/services/payment/
bundle exec rspec spec/services/simulator_service_spec.rb
bundle exec rspec spec/services/golden_reference_spec.rb  # invariant inter-modes
bundle exec rspec spec/requests/
```

# Avec output détaillé
```bash
bundle exec rspec --format documentation
```

***
Documentation complémentaire

| Document | Description |
| --- | --- |
| `docs/PLANNING_AGILE.md` | User stories, critères d'acceptation, backlog priorisé |
| `docs/REFERENCE_DATA.md` | Données de référence extraites du Google Sheet + analyse des formules |

***
Licence

Projet réalisé dans le cadre d'un exercice technique.