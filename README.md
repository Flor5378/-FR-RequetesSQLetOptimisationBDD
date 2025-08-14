# 📊 Études et Statistiques sur la Population Française

Projet universitaire réalisé dans le cadre du module UE INFO, visant à analyser des données démographiques françaises via une base de données relationnelle et des visualisations Python.

## 🧠 Méthodologie

### 1. MCD & MLD

#### 1.1 Présentation

Le MCD (Modèle Conceptuel de Données) comporte plusieurs entités principales :  
- **Commune** (Code commune, Nom, Superficie)  
- **Département** (Code département, Nom)  
- **Région** (Code région, Nom)  
- **Population** (idPopulation, DateAnnée)  
- **Naissance** (idNaissance, nbNaissance)  
- **Décès** (idDeces, nbDécès)  
- **DateAnnée** et **DateTrancheAnnée** (Année, AnnéeDébut, AnnéeFin)

Les relations :  
- `Contenir` : Commune → Département (1,1) → (1,n)  
- `Posséder` : Département → Région (1,1) → (1,n)  
- `Avoir` : Commune → Population (1,1) → (0,1)  
- `Enregistrer` : relie les entités DateAnnée, Naissance, Décès, Population et DateTrancheAnnée

Le MLD (Modèle Logique de Données) a été dérivé du MCD avec les clés primaires/étrangères et types SQL (`INT`, `VARCHAR(50)`).

#### 1.2 Limites et Contraintes

- Problème de granularité : gestion de Naissances/Décès individuels
- Difficulté à relier les entités `Commune` et `Population` de façon cohérente
- La relation `Enregistrer` a été introduite pour regrouper les données temporelles et démographiques
- Génération semi-automatique du MLD à partir du MCD, avec validation manuelle

---

### 2. Traitement de la Base de Données

#### 2.1 Script Python

Un script Python a été développé pour :
- Lire et corriger des fichiers `.csv` multi-délimiteurs (`;` ou `,`)
- Sauvegarder des versions "corrected" des CSV
- Limiter les noms de colonnes à 64 caractères (limite MySQL)
- Charger les données dans une base MySQL via `pandas.to_sql()` et `sqlalchemy.create_engine()`
- Si vous voulez reproduire tout le processus de production des tables et corrections des CSV, vous devez changer le nom des chemins des csv appelés.


#### 2.2 Script SQL

Exemple : création de la table `Département` :
```sql
CREATE TABLE Departement (
  CodeDepart VARCHAR(50) NOT NULL PRIMARY KEY,
  NomDepart VARCHAR(255) NOT NULL,
  CodeRegion INT,
  FOREIGN KEY (CodeRegion) REFERENCES Region(CodeRegion)
);
```

## 🔧 2.3 Contraintes rencontrées

- Problèmes de compatibilité entre **Spyder** et **SQL** → bascule vers **Visual Studio Code**
- Complexité à unifier tous les CSV en un seul fichier
- Problèmes liés aux délimiteurs (`;`, `,`) dans les fichiers CSV
- Adaptation continue du **MCD** pour assurer la cohérence avec les données réelles
- Renommage des colonnes pour améliorer la lisibilité et l’usage dans SQL

---

### 3.1 Analyse SQL & Visualisation

#### 💾 Exemple de requête SQL

```sql
SELECT c.LIBMOD AS Ville,
       (p."P20_POP" - p."P68_POP") AS Evolution
FROM Commune c
JOIN Population p ON c.CODGEO = p.CODGEO
ORDER BY Evolution DESC
LIMIT 10;

```
![Image](https://github.com/user-attachments/assets/1bcb6ee8-4cd9-40b3-8b80-fc73a6afcdf8)

### 3.2 🔍 Limites et Contraintes

- Les fichiers CSV initiaux étaient **peu standardisés** : noms de colonnes différents, formats incohérents
- La **cohérence des tables SQL** était essentielle pour des requêtes fiables
- Problèmes spécifiques liés aux **DROM-COM** : code postal sur 5 chiffres nécessitant un traitement particulier
- La **structuration de la base SQL** devait être rigoureuse : toute erreur imposait une reprise partielle
- La **préparation des données** était complexe pour garantir une exploitation correcte et efficace

---

### 🧩 Auteurs

- **Florian GROLLEAU**, **William SMITH**, **Romain JAFFUEL** – Double diplôme **Sciences Po** & **CY Tech**
