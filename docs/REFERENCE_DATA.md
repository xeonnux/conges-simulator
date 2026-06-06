# Référence de validation — Données du Google Sheet

## Paramètres du contrat de référence

```
Date de début  : 15 mars 2020
Date de fin    : 31 janvier 2023
Salaire brut   : 506,00 €
```

---

## Tableau 1 — Périodes de congés

| Période | Mois travaillés | Jours acquis | Maintien (sal/22×j) | Méthode 10% | Valeur retenue |
|---------|-----------------|-------------|---------------------|-------------|----------------|
| 15/03/2020 → 31/05/2020 | 2,55 | 6,375 | 146,625 € | 128,95 € | 146,625 € |
| 01/06/2020 → 31/05/2021 | 12,00 | 30,000 | 690,000 € | 607,20 € | 690,000 € |
| 01/06/2021 → 31/05/2022 | 12,00 | 30,000 | 690,000 € | 607,20 € | 690,000 € |
| 01/06/2022 → 31/01/2023 | 8,00 | 20,000 | 460,000 € | 404,80 € | 460,000 € |

**Total congés = 1 986,625 €**

### Formules révélées par le sheet

```
Jours acquis       = mois_travaillés × 2,5
Maintien salaire   = $B$3 / 22 × jours_acquis         (B3 = 506)
Méthode 10%        = 0,1 × SUM(salaires de la période)
Valeur retenue     = MAX(maintien, 10%)
```

### Point d'attention — Calcul des mois travaillés (période 1)

Le sheet affiche **2,55 mois** pour la période 1 (15 mars → 31 mai 2020).
Le prorata du salaire pour mars est `506 × 17/31 = 277,48 €` (confirmé par la formule `=506*17/31`).

La somme brute des proratas donnerait `17/31 + 1 + 1 = 2,5484...` mais le sheet affiche `2,55`.
Cela correspond à un **arrondi à 2 décimales** de la somme des proratas : `round(2.5484, 2) = 2.55`.

> **Décision d'implémentation :** arrondir `months_worked` à 2 décimales pour correspondre
> au sheet de référence, OU conserver la précision complète et accepter un écart < 0,01
> sur les montants finaux. La première option garantit une correspondance exacte.

---

## Tableau 2 — Rémunération mensuelle

| Mois | Salaire brut | Mode A (juin) | Mode B (1/12è) | Mode C (10% + régul) |
|------|-------------|---------------|----------------|----------------------|
| mars 2020 | 277,48 € | 0,00 € | 0,00 € | 27,75 € |
| avril 2020 | 506,00 € | 0,00 € | 0,00 € | 50,60 € |
| mai 2020 | 506,00 € | 0,00 € | 0,00 € | 50,60 € |
| juin 2020 | 506,00 € | **146,63 €** | **12,22 €** | **68,28 €** |
| juillet 2020 | 506,00 € | 0,00 € | 12,22 € | 50,60 € |
| août 2020 | 506,00 € | 0,00 € | 12,22 € | 50,60 € |
| sept 2020 | 506,00 € | 0,00 € | 12,22 € | 50,60 € |
| oct 2020 | 506,00 € | 0,00 € | 12,22 € | 50,60 € |
| nov 2020 | 506,00 € | 0,00 € | 12,22 € | 50,60 € |
| déc 2020 | 506,00 € | 0,00 € | 12,22 € | 50,60 € |
| jan 2021 | 506,00 € | 0,00 € | 12,22 € | 50,60 € |
| fév 2021 | 506,00 € | 0,00 € | 12,22 € | 50,60 € |
| mars 2021 | 506,00 € | 0,00 € | 12,22 € | 50,60 € |
| avril 2021 | 506,00 € | 0,00 € | 12,22 € | 50,60 € |
| mai 2021 | 506,00 € | 0,00 € | 12,22 € | 50,60 € |
| **juin 2021** | 506,00 € | **690,00 €** | **57,50 €** | **133,40 €** |
| juillet 2021 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| août 2021 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| sept 2021 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| oct 2021 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| nov 2021 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| déc 2021 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| jan 2022 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| fév 2022 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| mars 2022 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| avril 2022 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| mai 2022 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| **juin 2022** | 506,00 € | **690,00 €** | **57,50 €** | **133,40 €** |
| juillet 2022 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| août 2022 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| sept 2022 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| oct 2022 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| nov 2022 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| déc 2022 | 506,00 € | 0,00 € | 57,50 € | 50,60 € |
| **jan 2023** | 506,00 € | **460,00 €** | **747,50 €** | **105,80 €** |
| **TOTAL** | **17 481,48 €** | **1 986,63 €** | **1 986,63 €** | **1 986,63 €** |

---

## Analyse des formules — Logique par mode de paiement

### Mode A — Paiement intégral en juin

```
Mois de juin après clôture de période → montant = valeur_retenue de la période
Dernier mois (si pas juin)            → montant = valeur_retenue de la période en cours

Formules du sheet :
  juin 2020  (C16) : =F6                → 146,625 (P1 value)
  juin 2021  (C28) : =F7                → 690,000 (P2 value)
  juin 2022  (C40) : =F8                → 690,000 (P3 value)
  jan  2023  (C47) : =F9                → 460,000 (P4, terminal)
  Tous les autres  : 0
```

### Mode B — Paiement par 1/12ème

```
Après clôture d'une période → 1/12ème de la valeur chaque mois pendant 12 mois
Dernier mois du contrat     → solde des 1/12èmes restants + valeur période en cours

Formules du sheet :
  juin 2020 → mai 2021  (D16:D27) : =$F$6/12  → 12,21875 par mois (P1)
  juin 2021 → mai 2022  (D28:D39) : =$F$7/12  → 57,50 par mois (P2)
  juin 2022 → déc 2022  (D40:D46) : =$F$8/12  → 57,50 par mois (P3, 7 mois payés)
  jan  2023             (D47)     : =F8-SUM(D40:D46) + F9
                                   → (690-7×57.50) + 460
                                   → 287.50 + 460 = 747.50 (P3 solde + P4 complet)

Note : dans cet exemple les 1/12èmes ne se chevauchent JAMAIS car chaque période
       dure exactement 12 mois (sauf P1 et P4). Mais avec un contrat différent,
       deux flux de 1/12èmes PEUVENT se superposer.
```

### Mode C — 10% mensuel + régularisation en juin

Le sheet sépare le mode C en deux colonnes :
- **E** : part mensuelle = `0.1 × salaire_brut_du_mois` (versée CHAQUE mois)
- **F** : part régularisation (versée uniquement en juin ou au dernier mois)
- **G** : total = E + F

```
Chaque mois          : 10% du salaire brut
Mois de juin         : 10% du mois + régularisation
Régularisation       : valeur_retenue − somme des 10% versés sur la période

Formules du sheet :
  Part 10% (E)  : =0.1*B_n                          (tous les mois)
  Régul juin 2020 (F16) : =F6-SUM(E13:E15)           → 146.625 - 128.948 = 17.677
  Régul juin 2021 (F28) : =F7-SUM(E16:E27)           → 690 - 607.2 = 82.80
  Régul juin 2022 (F40) : =(F8-SUM(E28:E39))         → 690 - 607.2 = 82.80
  Régul jan 2023  (F47) : =F9-SUM(E40:E47)           → 460 - 404.8 = 55.20
  Total (G)      : =E_n + F_n
```

**Observation importante :** la régularisation en juin calcule `valeur_retenue - somme(10% des salaires de TOUTE la période)`. La période pour la régul de juin N+1 couvre les mois de juin N à mai N+1 (les mois de la période de référence), PAS les mois depuis la dernière régul.

---

## Valeurs clés pour les tests automatisés

```ruby
# spec/support/reference_data.rb

REFERENCE = {
  contract: {
    start_date: Date.new(2020, 3, 15),
    end_date: Date.new(2023, 1, 31),
    monthly_salary: 506.0
  },

  periods: [
    {
      start_date: Date.new(2020, 3, 15), end_date: Date.new(2020, 5, 31),
      months_worked: 2.55, days_acquired: 6.375,
      maintien_value: 146.625, ten_percent_value: 128.95, leave_value: 146.625
    },
    {
      start_date: Date.new(2020, 6, 1), end_date: Date.new(2021, 5, 31),
      months_worked: 12.0, days_acquired: 30.0,
      maintien_value: 690.0, ten_percent_value: 607.2, leave_value: 690.0
    },
    {
      start_date: Date.new(2021, 6, 1), end_date: Date.new(2022, 5, 31),
      months_worked: 12.0, days_acquired: 30.0,
      maintien_value: 690.0, ten_percent_value: 607.2, leave_value: 690.0
    },
    {
      start_date: Date.new(2022, 6, 1), end_date: Date.new(2023, 1, 31),
      months_worked: 8.0, days_acquired: 20.0,
      maintien_value: 460.0, ten_percent_value: 404.8, leave_value: 460.0
    }
  ],

  total_leave_value: 1986.625,
  total_salary: 17481.48,

  # Key monthly values to spot-check (not exhaustive)
  spot_checks: {
    # [year, month] => { salary:, mode_a:, mode_b:, mode_c: }
    [2020, 3]  => { salary: 277.48, mode_a: 0.0,    mode_b: 0.0,    mode_c: 27.75  },
    [2020, 6]  => { salary: 506.0,  mode_a: 146.63, mode_b: 12.22,  mode_c: 68.28  },
    [2021, 6]  => { salary: 506.0,  mode_a: 690.0,  mode_b: 57.50,  mode_c: 133.40 },
    [2022, 6]  => { salary: 506.0,  mode_a: 690.0,  mode_b: 57.50,  mode_c: 133.40 },
    [2023, 1]  => { salary: 506.0,  mode_a: 460.0,  mode_b: 747.50, mode_c: 105.80 },
  }
}
```

---

## Observations pour l'implémentation

1. **Le sheet sépare le mode C en deux sous-colonnes** (10% mensuel + régularisation).
   Notre implémentation peut stocker le total directement dans `leave_mode_c`, mais
   afficher les deux composantes séparément dans la vue serait un plus pour la lisibilité.

2. **La régularisation du mode C en juin** soustrait les 10% versés sur les mois de
   LA PÉRIODE (pas depuis le dernier juin). Par exemple, la régul de juin 2021 soustrait
   les 10% de juin 2020 à mai 2021 (les 12 mois de la période 2), pas les 10% de
   juin 2020 à mai 2021 qui inclurait les mois de P1.

   Correction : en regardant les formules plus précisément :
   - F16 (régul juin 2020) = F6 - SUM(E13:E15) → P1 value - 10% de mars-mai 2020 (mois de P1)
   - F28 (régul juin 2021) = F7 - SUM(E16:E27) → P2 value - 10% de juin 2020-mai 2021 (mois de P2)
   - F40 (régul juin 2022) = F8 - SUM(E28:E39) → P3 value - 10% de juin 2021-mai 2022 (mois de P3)
   - F47 (régul jan 2023)  = F9 - SUM(E40:E47) → P4 value - 10% de juin 2022-jan 2023 (mois de P4)

   Chaque régularisation soustrait les 10% versés UNIQUEMENT sur les mois de SA PROPRE PÉRIODE. ✓

3. **Le dernier mois du Mode B** est le plus complexe :
   `solde_1/12èmes_période_précédente + valeur_complète_période_en_cours`
   Formule : `=F8-SUM(D40:D46) + F9` = (690 - 7×57.50) + 460 = 287.50 + 460 = 747.50

4. **Pas de chevauchement de 1/12èmes dans cet exemple**, mais notre code doit le gérer
   pour des contrats où les périodes sont plus courtes que 12 mois.

5. **Les montants du mode C dans le total** : la vérification du sheet somme `E+F` séparément,
   c'est-à-dire `SUM(E13:E47) + SUM(F13:F47) = 1986.625`. Notre total de `leave_mode_c`
   doit correspondre.
