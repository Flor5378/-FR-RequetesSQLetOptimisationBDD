CREATE DATABASE Population;

-- Créer table Region
USE Population;
CREATE TABLE Population.Region (
    codeRegion INT, -- Changez le type de données si nécessaire
    nomRegion VARCHAR(255), -- Changez la taille selon vos besoins
    PRIMARY KEY (codeRegion) -- Facultatif si une clé primaire est nécessaire
);

USE Population;
INSERT INTO Region (codeRegion, nomRegion)
SELECT DISTINCT codeRegion, nomRegion
FROM populationdepartementsfrance;

USE Population;
SELECT * FROM Region LIMIT 0, 1000;



-- Créer table Departement
CREATE TABLE Departement (
    CodeDepart  VARCHAR(50) NOT NULL,
    NomDepart VARCHAR(255) NOT NULL,
    CodeRegion INT NOT NULL,
    PRIMARY KEY (CodeDepart),
    FOREIGN KEY (CodeRegion) REFERENCES Region(CodeRegion)
);

-- Insertion des données dans Departement
INSERT INTO Departement (CodeDepart, NomDepart, CodeRegion)
SELECT DISTINCT CodeDepart, NomDepart, CodeRegion
FROM populationdepartementsfrance;

-- Vérification des données dans Departement et leurs régions associées
SELECT d.CodeDepart, d.NomDepart, r.NomRegion
FROM Departement d
JOIN Region r ON d.CodeRegion = r.CodeRegion;






-- Créer table Commune
USE POPULATION;
CREATE TABLE Commune AS
SELECT LIB_MOD, COD_MOD
FROM populationmetadataseriehistorique2020
WHERE LIB_MOD IS NOT NULL AND COD_MOD IS NOT NULL;

USE Population;
-- Ajouter une colonne CodeDepart à la table Commune
ALTER TABLE Commune ADD COLUMN CodeDepart VARCHAR(3);

-- Mettre à jour CodeDepart pour les COD_MOD de 4 chiffres (avec un zéro si nécessaire)
UPDATE Commune
SET CodeDepart = LPAD(SUBSTRING(COD_MOD, 1, 1), 2, '0')
WHERE LENGTH(COD_MOD) = 4;

-- Étape 3 : Mettre à jour CodeDepart pour les COD_MOD de 5 chiffres (déjà au bon format)
UPDATE Commune
SET CodeDepart = SUBSTRING(COD_MOD, 1, 2)
WHERE LENGTH(COD_MOD) = 5;

SELECT LIB_MOD, COD_MOD, CodeDepart
FROM Commune
LIMIT 10;

-- Vérification des données dans Commune
SELECT LIB_MOD, COD_MOD, CodeDepart
FROM Commune
LIMIT 10;

USE Population;
ALTER TABLE Commune RENAME COLUMN COD_MOD TO CODGEO;

-- Correction affiché les villes et départements d'outre-mer
USE Population;
SELECT c.LIB_MOD AS Commune, c.CODGEO AS CodeCommune, d.NomDepart AS Departement,d.CodeDepart AS CodeDepartement
FROM Commune c
JOIN Departement d 
    ON d.CodeDepart = LEFT(c.CODGEO, 3)
WHERE LENGTH(c.CODGEO) = 5
ORDER BY d.CodeDepart, c.LIB_MOD;




--  Créer table Population
USE Population;
CREATE TABLE Population AS
SELECT CODGEO, P20_POP, P14_POP, P09_POP, D99_POP, D90_POP, D82_POP, D75_POP, D68_POP
FROM populationseriehistorique2020;

-- Créer table Naissance
USE Population;
CREATE TABLE Naissance AS
SELECT CODGEO, NAIS1420, NAIS0914, NAIS9909, NAIS9099, NAIS8290, NAIS7582, NAIS6875
FROM populationseriehistorique2020;


-- Créer table DECES
USE Population;
CREATE TABLE Deces AS
SELECT CODGEO, DECE1420, DECE0914, DECE9909, DECE9099, DECE8290, DECE7582, DECE6875
FROM populationseriehistorique2020;





-- Question 1 : Liste des populations en 2020 avec le nom de ville, département, région
USE Population ;
SELECT c.LIB_MOD AS Ville, 
       d.NomDepart AS Departement, 
       r.NomRegion AS Region, 
       p.P20_POP AS Population_2020
FROM Commune c
JOIN Departement d ON c.CodeDepart = d.CodeDepart
JOIN Region r ON d.CodeRegion = r.CodeRegion
JOIN Population p ON c.CODGEO = p.CODGEO
WHERE p.P20_POP IS NOT NULL;

-- Question 2 : Évolution de la population française de 1968 à 2020
USE Population;
SELECT SUM(D68_POP)/1000000 AS Population_1968_en_million, 
       SUM(P20_POP)/1000000 AS Population_2020_en_million, 
       (SUM(P20_POP) - SUM(D68_POP))/1000000 AS Evolution_en_million
FROM Population;

-- Question 3a : Liste des populations en 2020 par département
USE Population;
SELECT 
    d.NomDepart AS Departement, 
    SUM(p.P20_POP) AS Population_2020
FROM Departement d
LEFT JOIN Commune c ON d.CodeDepart = c.CodeDepart
LEFT JOIN Population p ON c.CODGEO = p.CODGEO
GROUP BY d.NomDepart;

-- Question 3b : Liste des populations en 2020 par région
USE Population;
SELECT 
    r.NomRegion AS Region, 
    SUM(p.P20_POP) AS Population_2020
FROM Region r
JOIN Departement d ON r.CodeRegion = d.CodeRegion
JOIN Commune c ON d.CodeDepart = c.CodeDepart
JOIN Population p ON c.CODGEO = p.CODGEO
GROUP BY r.NomRegion;



-- Question 4 : Population de Paris au total et par arrondissement
USE Population;
SELECT SUM(p.P20_POP) AS Population_totale_Paris
FROM Commune c
JOIN Population p ON c.CODGEO = p.CODGEO
WHERE c.LIB_MOD LIKE 'Paris%' AND c.LIB_MOD != 'Paris';

SELECT c.LIB_MOD AS Arrondissement, 
       p.P20_POP AS Population
FROM Commune c
JOIN Population p ON c.CODGEO = p.CODGEO
WHERE c.LIB_MOD LIKE 'Paris%' 
      AND c.LIB_MOD != 'Paris';

-- Correction Population des arrondissements de Paris
SELECT c.LIB_MOD AS Arrondissement, 
       p.P20_POP AS Population
FROM Commune c
JOIN Population p ON c.CODGEO = p.CODGEO
WHERE c.LIB_MOD LIKE 'Paris%' 
      AND c.LIB_MOD != 'Paris'
      AND c.LIB_MOD LIKE '%Arrondissement';


-- Question 5a : 10 villes ayant cru le plus de 1968 à 2020
SELECT 
    c.LIB_MOD AS Ville, 
    (p.P20_POP - p.D68_POP) AS Evolution
FROM Commune c
JOIN Population p ON c.CODGEO = p.CODGEO
ORDER BY Evolution DESC
LIMIT 10;

-- Question 5b : 10 départements ayant cru le plus de 1968 à 2020
SELECT 
    d.NomDepart AS Departement, 
    (SUM(p.P20_POP) - SUM(p.D68_POP)) AS Evolution
FROM Departement d
JOIN Commune c ON d.CodeDepart = c.CodeDepart
JOIN Population p ON c.CODGEO = p.CODGEO
GROUP BY d.NomDepart
ORDER BY Evolution DESC
LIMIT 10;

-- Question 5c : 10 régions ayant cru le plus de 1968 à 2020
SELECT r.NomRegion AS Region, 
		(SUM(p.P20_POP) - SUM(p.D68_POP)) AS Evolution
FROM Region r
JOIN Departement d ON r.CodeRegion = d.CodeRegion
JOIN Commune c ON d.CodeDepart = c.CodeDepart
JOIN Population p ON c.CODGEO = p.CODGEO
GROUP BY r.NomRegion
ORDER BY Evolution DESC
LIMIT 10;

-- Question 6 : Liste des 10 villes / départements où on naît / meurt le plus
-- Naissances par ville
SELECT 
    c.LIB_MOD AS Ville, 
    SUM(n.NAIS1420) AS Naissances
FROM Commune c
JOIN Naissance n ON c.CODGEO = n.CODGEO
GROUP BY c.LIB_MOD
ORDER BY Naissances DESC
LIMIT 10;

-- Décès par ville
SELECT 
    c.LIB_MOD AS Ville, 
    SUM(d.DECE1420) AS Deces
FROM Commune c
JOIN Deces d ON c.CODGEO = d.CODGEO
GROUP BY c.LIB_MOD
ORDER BY Deces DESC
LIMIT 10;

-- Naissances par département
SELECT 
    d.NomDepart AS Departement, 
    SUM(n.NAIS1420) AS Naissances
FROM Departement d
JOIN Commune c ON d.CodeDepart = c.CodeDepart
JOIN Naissance n ON c.CODGEO = n.CODGEO
GROUP BY d.NomDepart
ORDER BY Naissances DESC
LIMIT 10;

-- Décès par département
SELECT 
    d.NomDepart AS Departement, 
    SUM(de.DECE1420) AS Deces
FROM Departement d
JOIN Commune c ON d.CodeDepart = c.CodeDepart
JOIN Deces de ON c.CODGEO = de.CODGEO
GROUP BY d.NomDepart
ORDER BY Deces DESC
LIMIT 10;

-- Question 7 : Liste des 10 villes / départements avec la plus grande/petite densité
-- Densité des villes
SELECT 
    c.LIB_MOD AS Ville, 
    ROUND((p.P20_POP / c.Superficie), 2) AS Densite
FROM Commune c
JOIN Population p ON c.CODGEO = p.CODGEO
WHERE c.Superficie > 0
ORDER BY Densite DESC
LIMIT 10;

-- Densité des départements
SELECT d.NomDepart AS Departement, 
		ROUND((SUM(p.P20_POP) / SUM(c.Superficie)), 2) AS Densite
FROM Departement d
JOIN Commune c ON d.CodeDepart = c.CodeDepart
JOIN Population p ON c.CODGEO = p.CODGEO
GROUP BY d.NomDepart
ORDER BY Densite DESC
LIMIT 10;



-- Question 8 : Comparaison des naissances / décès / mouvements par département
SELECT 
    d.NomDepart AS Departement, 
    SUM(n.NAIS1420) AS Naissances, 
    SUM(de.DECE1420) AS Deces, 
    (SUM(p.P20_POP) - SUM(p.D68_POP)) - (SUM(n.NAIS1420) - SUM(de.DECE1420)) AS Mouvements
FROM Departement d
JOIN Commune c ON d.CodeDepart = c.CodeDepart
JOIN Population p ON c.CODGEO = p.CODGEO
JOIN Naissance n ON c.CODGEO = n.CODGEO
JOIN Deces de ON c.CODGEO = de.CODGEO
GROUP BY d.NomDepart;

SELECT r.nomRegion AS Region, SUM(n.NAIS1420) AS Naissances, SUM(de.DECE1420) AS Deces, (SUM(p.P20_POP) - SUM(p.D68_POP)) - (SUM(n.NAIS1420) - SUM(de.DECE1420)) AS Mouvements
FROM Region r
JOIN Departement d ON r.CodeRegion = d.CodeRegion
JOIN Commune c ON d.CodeDepart = c.CodeDepart
JOIN Population p ON c.CODGEO = p.CODGEO
JOIN Naissance n ON c.CODGEO = n.CODGEO
JOIN Deces de ON c.CODGEO = de.CODGEO
GROUP BY r.nomRegion;

-- Question 9 : Comparaison par recensement des naissances / décès / mouvements en France
SELECT SUM(n.NAIS1420) AS Naissances, SUM(de.DECE1420) AS Deces, ((SUM(p.P20_POP) - SUM(p.D68_POP)) - (SUM(n.NAIS1420) - SUM(de.DECE1420)))/1000000 AS Mouvements_en_million
FROM Population p
JOIN Naissance n ON p.CODGEO = n.CODGEO
JOIN Deces de ON p.CODGEO = de.CODGEO;



-- Requête 1 : Croissance de la population par Region
SELECT 
    r.nomRegion AS Region,
    SUM(p.P20_POP) AS Population2020,
    SUM(p.D68_POP) AS Population1968,
    ((SUM(p.P20_POP) - SUM(p.D68_POP)) / SUM(p.D68_POP) * 100) AS CroissancePourcentage
FROM Region r
JOIN Departement d ON r.CodeRegion = d.CodeRegion
JOIN Population p ON d.CodeDepart = LEFT(p.CODGEO, 2)
GROUP BY r.nomRegion
ORDER BY CroissancePourcentage DESC;

-- Requête 2 : Solde Naturel 
SELECT 
    r.nomRegion AS Region,
    SUM(p.NAIS1420 + p.NAIS0914 + p.NAIS9909 + p.NAIS9099 + p.NAIS8290 + p.NAIS7582 + p.NAIS6875) AS TotalNaissances,
    SUM(p.DECE1420 + p.DECE0914 + p.DECE9909 + p.DECE9099 + p.DECE8290 + p.DECE7582 + p.DECE6875) AS TotalDeces,
    (SUM(p.NAIS1420 + p.NAIS0914 + p.NAIS9909 + p.NAIS9099 + p.NAIS8290 + p.NAIS7582 + p.NAIS6875) - 
     SUM(p.DECE1420 + p.DECE0914 + p.DECE9909 + p.DECE9099 + p.DECE8290 + p.DECE7582 + p.DECE6875)) AS SoldeNaturel
FROM Region r
JOIN Departement d ON r.CodeRegion = d.CodeRegion
JOIN PopulationSerieHistorique2020 p ON d.CodeDepart = LEFT(p.CODGEO, 2)
GROUP BY r.nomRegion
ORDER BY SoldeNaturel DESC;

-- Requête 3 : Évolution des mouvements de population (1968-2020) par département
SELECT 
    d.NomDepart AS Departement,
    SUM(p.D68_POP) AS Population1968,
    SUM(p.P20_POP) AS Population2020,
    SUM(p.NAIS1420 + p.NAIS0914 + p.NAIS9909 + p.NAIS9099 + p.NAIS8290 + p.NAIS7582 + p.NAIS6875) AS TotalNaissances,
    SUM(p.DECE1420 + p.DECE0914 + p.DECE9909 + p.DECE9099 + p.DECE8290 + p.DECE7582 + p.DECE6875) AS TotalDeces,
    (SUM(p.NAIS1420 + p.NAIS0914 + p.NAIS9909 + p.NAIS9099 + p.NAIS8290 + p.NAIS7582 + p.NAIS6875) - 
     SUM(p.DECE1420 + p.DECE0914 + p.DECE9909 + p.DECE9099 + p.DECE8290 + p.DECE7582 + p.DECE6875)) AS SoldeNaturel,
    (SUM(p.P20_POP) - SUM(p.D68_POP)) AS VariationPopulation
FROM Departement d
JOIN PopulationSerieHistorique2020 p ON d.CodeDepart = LEFT(p.CODGEO, 2)
GROUP BY d.NomDepart
ORDER BY VariationPopulation DESC;

-- Requête 4 : Taux de natalité et mortalité par région en 2020
SELECT 
    r.nomRegion AS Region,
    SUM(p.NAIS1420) AS TotalNaissances2020,
    SUM(p.DECE1420) AS TotalDeces2020,
    SUM(p.P20_POP) AS PopulationTotale2020,
    (SUM(p.NAIS1420) / SUM(p.P20_POP)) * 100 AS TauxNatalite,
    (SUM(p.DECE1420) / SUM(p.P20_POP)) * 100 AS TauxMortalite
FROM Region r
JOIN Departement d ON r.CodeRegion = d.CodeRegion
JOIN PopulationSerieHistorique2020 p ON d.CodeDepart = LEFT(p.CODGEO, 2)
GROUP BY r.nomRegion
ORDER BY TauxNatalite DESC;

-- Requete 5 Perte Population departement
SELECT 
    d.NomDepart AS Departement,
    SUM(p.D68_POP) AS Population1968,
    SUM(p.P20_POP) AS Population2020,
    (SUM(p.P20_POP) - SUM(p.D68_POP)) AS PertePopulation
FROM Departement d
JOIN Population p ON d.CodeDepart = LEFT(p.CODGEO, 2)
GROUP BY d.NomDepart
HAVING PertePopulation < 0
ORDER BY PertePopulation ASC;







-- Probleme avec superficie
USE Population;   
SET GLOBAL wait_timeout = 1800;
SET GLOBAL interactive_timeout = 1800;
SET GLOBAL net_read_timeout = 1800;
SET GLOBAL net_write_timeout = 1800;
SET GLOBAL max_allowed_packet = 256 * 1024 * 1024;
 
UPDATE Commune c
JOIN populationseriehistorique2020 p ON c.CODGEO = p.CODGEO
SET c.SUPERF = p.SUPERF
WHERE p.SUPERF IS NOT NULL AND p.SUPERF > 0
LIMIT 1000;  -- Mettez à jour 1000 lignes à la fois



-- Densité 10 villes les plus denses
USE Population;
SELECT c.LIB_MOD, 
       (SUM(p.P20_POP) / SUM(p.SUPERF)) AS densite_population
FROM Commune c
JOIN populationseriehistorique2020 p ON c.CODGEO = p.CODGEO
WHERE p.P20_POP IS NOT NULL AND p.SUPERF > 0
GROUP BY c.LIB_MOD
ORDER BY densite_population DESC
LIMIT 10;



-- Densité 10 villes les moins dense
USE Population;
SELECT c.LIB_MOD, 
       (SUM(p.P20_POP) / SUM(p.SUPERF)) AS densite_population
FROM Commune c
JOIN populationseriehistorique2020 p ON c.CODGEO = p.CODGEO
WHERE p.P20_POP IS NOT NULL AND p.SUPERF > 0
GROUP BY c.LIB_MOD
ORDER BY densite_population ASC
LIMIT 10;