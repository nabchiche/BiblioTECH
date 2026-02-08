-- ============================================================
-- NOS REQUÊTES SQL - Projet BIBLIOTech
-- ============================================================
-- Nous avons chacun à notre tour écrit nos requêtes sur ce document avec
-- ce que l'on pense être la difficulté adéquate associée. 
-- Nous avons mis en forme nos commentaires chacun de la même manière, et 
-- nous avons aussi ajouté une rapide description pour chaque requête.
-- ============================================================


-- ############################################################
-- LUC : MODULE "CATALOGUE ET STATISTIQUES" (7 requêtes)
-- ############################################################


-- L1. Recherche d'ouvrages par titre (Moyenne)
-- LOGIQUE : Cette requête permet de rechercher un ouvrage par son titre.
-- On utilise LIKE avec des % pour permettre une recherche partielle.
-- On joint les tables OUVRAGE, ECRIT, AUTEUR et CATEGORIE.

SELECT o.id_ouvrage, o.titre, o.type_support, c.libelle_genre AS categorie, a.nom AS auteur
FROM OUVRAGE o
JOIN CATEGORIE c ON o.id_cat = c.id_cat
JOIN ECRIT e ON o.id_ouvrage = e.id_ouvrage
JOIN AUTEUR a ON e.id_auteur = a.id_auteur
WHERE o.titre LIKE '%mot_recherche%'
ORDER BY o.titre;


-- L2. Recherche d'ouvrages par auteur (Moyenne)
-- LOGIQUE : On filtre sur le nom de l'auteur via la table ECRIT.

SELECT o.id_ouvrage, o.titre, o.type_support, c.libelle_genre AS categorie, a.nom AS auteur
FROM OUVRAGE o
JOIN CATEGORIE c ON o.id_cat = c.id_cat
JOIN ECRIT e ON o.id_ouvrage = e.id_ouvrage
JOIN AUTEUR a ON e.id_auteur = a.id_auteur
WHERE a.nom LIKE '%nom_auteur%'
ORDER BY o.titre;


-- L3. Recherche d'ouvrages par catégorie (Moyenne)
-- LOGIQUE : On filtre les ouvrages selon leur catégorie (genre).

SELECT o.id_ouvrage, o.titre, o.type_support, c.libelle_genre AS categorie
FROM OUVRAGE o
JOIN CATEGORIE c ON o.id_cat = c.id_cat
WHERE c.libelle_genre = 'Roman'
ORDER BY o.titre;


-- L4. Affichage de la fiche ouvrage avec ses exemplaires (Simple)
-- LOGIQUE : Pour un ouvrage donné, on récupère tous ses exemplaires
-- physiques avec leur localisation et leur état.

SELECT o.titre, o.type_support, c.libelle_genre AS categorie,
       ex.code_barre, ex.etat, ex.etage, ex.rayon,
       b.nom AS bibliotheque
FROM OUVRAGE o
JOIN CATEGORIE c ON o.id_cat = c.id_cat
JOIN EXEMPLAIRE ex ON o.id_ouvrage = ex.id_ouvrage
JOIN BIBLIOTHEQUE b ON ex.id_biblio = b.id_biblio
WHERE o.id_ouvrage = 1;


-- L5. Gestion des suggestions d'achat - Enregistrer une suggestion (Moyenne)
-- LOGIQUE : On insère une suggestion et on incrémente le compteur.

INSERT INTO SUGGERE (id_abonne, id_ouvrage, date_suggestion)
VALUES (1, 5, CURRENT_DATE);

UPDATE OUVRAGE
SET compteur_demande_achat = compteur_demande_achat + 1
WHERE id_ouvrage = 5;


-- L6. Alerter quand le seuil de suggestions est atteint (Moyenne)
-- LOGIQUE : Identifie les ouvrages dont le compteur >= seuil.

SELECT id_ouvrage, titre, compteur_demande_achat
FROM OUVRAGE
WHERE compteur_demande_achat >= 5
ORDER BY compteur_demande_achat DESC;


-- L7. TÂCHE DIFFICILE : Rapport des ouvrages les plus populaires par région (Difficile)
-- LOGIQUE : Requête complexe avec CTE et ROW_NUMBER().
-- La 1ère CTE agrège les emprunts par région et ouvrage.
-- La 2ème CTE attribue un rang par région avec ROW_NUMBER() OVER(PARTITION BY ...).
-- Le SELECT final ne garde que le Top 10 par région.

WITH EmpruntsParRegion AS (
    SELECT r.id_region, r.nom_region, o.id_ouvrage, o.titre,
           COUNT(*) AS nb_emprunts
    FROM EMPRUNTE em
    JOIN EXEMPLAIRE ex ON em.code_barre = ex.code_barre
    JOIN OUVRAGE o ON ex.id_ouvrage = o.id_ouvrage
    JOIN BIBLIOTHEQUE b ON ex.id_biblio = b.id_biblio
    JOIN REGION r ON b.id_region = r.id_region
    WHERE em.date_emprunt >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY r.id_region, r.nom_region, o.id_ouvrage, o.titre
),
ClassementParRegion AS (
    SELECT id_region, nom_region, id_ouvrage, titre, nb_emprunts,
           ROW_NUMBER() OVER(PARTITION BY id_region ORDER BY nb_emprunts DESC) AS rang
    FROM EmpruntsParRegion
)
SELECT nom_region, rang, titre, nb_emprunts
FROM ClassementParRegion
WHERE rang <= 10
ORDER BY nom_region, rang;


-- ############################################################
-- MARIE : MODULE "RÉSERVATIONS ET ÉVÉNEMENTS" (8 requêtes)
-- ############################################################


-- M1. Créer une réservation (Moyenne)
-- LOGIQUE : On insère une réservation avec NOW() pour l'horodatage précis,
-- essentiel pour la gestion FIFO de la file d'attente.

INSERT INTO RESERVE (id_ouvrage, id_abonne, date_demande, id_biblio_retrait)
VALUES (3, 2, NOW(), 1);


-- M2. Consulter les réservations actives d'un abonné (Moyenne)
-- LOGIQUE : On joint RESERVE, OUVRAGE et BIBLIOTHEQUE pour afficher
-- les réservations en cours d'un abonné donné.

SELECT r.date_demande, o.titre, b.nom AS bibliotheque_retrait
FROM RESERVE r
JOIN OUVRAGE o ON r.id_ouvrage = o.id_ouvrage
JOIN BIBLIOTHEQUE b ON r.id_biblio_retrait = b.id_biblio
WHERE r.id_abonne = 2
ORDER BY r.date_demande;


-- M3. Gestion de la file d'attente - Voir la position (Moyenne)
-- LOGIQUE : ROW_NUMBER() attribue dynamiquement la position dans la file
-- en triant par date de demande (FIFO).

SELECT a.nom AS abonne, r.date_demande,
       ROW_NUMBER() OVER(ORDER BY r.date_demande ASC) AS position_file
FROM RESERVE r
JOIN ABONNE a ON r.id_abonne = a.id_abonne
WHERE r.id_ouvrage = 3
ORDER BY r.date_demande;


-- M4. Notification de mise à disposition (Simple)
-- LOGIQUE : On sélectionne le premier de la file (LIMIT 1 + ORDER BY date_demande)
-- pour identifier l'abonné à notifier.

SELECT a.id_abonne, a.nom, r.id_biblio_retrait, b.nom AS bibliotheque
FROM RESERVE r
JOIN ABONNE a ON r.id_abonne = a.id_abonne
JOIN BIBLIOTHEQUE b ON r.id_biblio_retrait = b.id_biblio
WHERE r.id_ouvrage = 3
ORDER BY r.date_demande ASC
LIMIT 1;


-- M5. TÂCHE DIFFICILE : Détermination de l'action post-retour (Difficile)
-- LOGIQUE : Requête décisionnelle avec CTE + CASE WHEN.
-- La CTE identifie le premier en attente via ROW_NUMBER().
-- Le CASE WHEN décide : si la bibliothèque de retour = celle souhaitée → mise de côté,
-- sinon → déclenchement d'un transfert.

WITH PremierEnAttente AS (
    SELECT r.id_ouvrage, r.id_abonne, r.id_biblio_retrait,
           ROW_NUMBER() OVER(PARTITION BY r.id_ouvrage ORDER BY r.date_demande ASC) AS rang
    FROM RESERVE r
)
SELECT p.id_abonne, a.nom AS abonne, o.titre,
       b_retrait.nom AS bibliotheque_souhaitee,
       b_retour.nom AS bibliotheque_retour,
       CASE 
           WHEN p.id_biblio_retrait = 2 THEN 'Mettre de côté pour le lecteur'
           ELSE 'Déclencher un transfert vers ' || b_retrait.nom
       END AS action_requise
FROM PremierEnAttente p
JOIN ABONNE a ON p.id_abonne = a.id_abonne
JOIN OUVRAGE o ON p.id_ouvrage = o.id_ouvrage
JOIN BIBLIOTHEQUE b_retrait ON p.id_biblio_retrait = b_retrait.id_biblio
JOIN BIBLIOTHEQUE b_retour ON b_retour.id_biblio = 2
WHERE p.rang = 1
AND p.id_ouvrage = 3;


-- M6. Créer un événement (Moyenne)
-- LOGIQUE : Insertion simple d'un événement avec capacité et compteur à 0.

INSERT INTO EVENT (date, capacite, nb_inscrits, id_biblio)
VALUES ('2026-03-15 14:00:00', 50, 0, 1);


-- M7. Inscrire un abonné à un événement (Moyenne)
-- LOGIQUE : Inscription nominative d'un abonné via la table PARTICIPE.

INSERT INTO PARTICIPE (id_abonne, id_event)
VALUES (1, 1);


-- M8. Inscrire un non-abonné à un événement (Moyenne)
-- LOGIQUE : On incrémente le compteur nb_inscrits car les non-abonnés
-- ne sont pas identifiés nominativement.

UPDATE EVENT
SET nb_inscrits = nb_inscrits + 1
WHERE id_event = 1;


-- ############################################################
-- THOMAS : MODULE "ABONNÉS, PRÊTS ET SANCTIONS" (9 requêtes)
-- ############################################################


-- T1. Lister tous les abonnés avec leur type (Simple)
-- LOGIQUE : Jointure simple entre ABONNE et TYPE_ABONNEMENT.

SELECT a.id_abonne, a.nom, t.libelle AS type_abonnement,
       a.est_bloque, a.fin_blocage
FROM ABONNE a
JOIN TYPE_ABONNEMENT t ON a.id_type = t.id_type
ORDER BY a.nom;


-- T2. Consulter la fiche d'un abonné avec ses droits (Simple)
-- LOGIQUE : Affiche la fiche détaillée d'un abonné avec ses droits (quota, durée).

SELECT a.id_abonne, a.nom, a.est_bloque, a.fin_blocage,
       t.libelle AS type_abonnement, t.quota_max, t.duree_pret_max
FROM ABONNE a
JOIN TYPE_ABONNEMENT t ON a.id_type = t.id_type
WHERE a.id_abonne = 1;


-- T3. Lister les types d'abonnement (Simple)
-- LOGIQUE : Requête simple pour afficher les types et leurs paramètres.

SELECT id_type, libelle, quota_max, duree_pret_max
FROM TYPE_ABONNEMENT
ORDER BY libelle;


-- T4. Vérification préalable à l'emprunt (Moyenne)
-- LOGIQUE : Vérifie si l'abonné peut emprunter (pas bloqué, quota non atteint).
-- Utilise des sous-requêtes corrélées pour compter les emprunts en cours.

SELECT a.id_abonne, a.nom, a.est_bloque,
       t.quota_max,
       (SELECT COUNT(*) FROM EMPRUNTE e 
        WHERE e.id_abonne = a.id_abonne 
        AND e.date_retour_prevue >= CURRENT_DATE) AS emprunts_en_cours,
       CASE 
           WHEN a.est_bloque = TRUE THEN 'BLOQUÉ - Emprunt impossible'
           WHEN (SELECT COUNT(*) FROM EMPRUNTE e 
                 WHERE e.id_abonne = a.id_abonne 
                 AND e.date_retour_prevue >= CURRENT_DATE) >= t.quota_max 
           THEN 'QUOTA ATTEINT - Emprunt impossible'
           ELSE 'OK - Emprunt autorisé'
       END AS statut_emprunt
FROM ABONNE a
JOIN TYPE_ABONNEMENT t ON a.id_type = t.id_type
WHERE a.id_abonne = 1;


-- T5. Enregistrer un nouveau prêt (Moyenne)
-- LOGIQUE : INSERT ... SELECT pour calculer automatiquement la date de retour
-- en fonction du type d'abonnement de l'abonné.

INSERT INTO EMPRUNTE (id_abonne, code_barre, date_emprunt, date_retour_prevue, est_prolonge)
SELECT 1, 'ISBN-005-A', CURRENT_DATE, 
       CURRENT_DATE + (t.duree_pret_max || ' days')::INTERVAL,
       FALSE
FROM TYPE_ABONNEMENT t
JOIN ABONNE a ON a.id_type = t.id_type
WHERE a.id_abonne = 1;


-- T6. Enregistrer un retour (Moyenne)
-- LOGIQUE : Suppression de l'emprunt via la clé primaire composite.

DELETE FROM EMPRUNTE
WHERE code_barre = 'ISBN-001-A'
AND id_abonne = 1
AND date_emprunt = '2026-01-15';


-- T7. Consulter l'historique des prêts d'un abonné (Moyenne)
-- LOGIQUE : Jointures multiples pour afficher le titre et la bibliothèque.

SELECT o.titre, em.date_emprunt, em.date_retour_prevue, em.est_prolonge,
       b.nom AS bibliotheque
FROM EMPRUNTE em
JOIN EXEMPLAIRE ex ON em.code_barre = ex.code_barre
JOIN OUVRAGE o ON ex.id_ouvrage = o.id_ouvrage
JOIN BIBLIOTHEQUE b ON ex.id_biblio = b.id_biblio
WHERE em.id_abonne = 1
ORDER BY em.date_emprunt DESC;


-- T8. Lister les prêts en cours d'un abonné (Moyenne)
-- LOGIQUE : Comme T7 mais avec un filtre sur la date de retour.

SELECT o.titre, em.date_emprunt, em.date_retour_prevue, em.est_prolonge
FROM EMPRUNTE em
JOIN EXEMPLAIRE ex ON em.code_barre = ex.code_barre
JOIN OUVRAGE o ON ex.id_ouvrage = o.id_ouvrage
WHERE em.id_abonne = 1
AND em.date_retour_prevue >= CURRENT_DATE
ORDER BY em.date_retour_prevue;


-- T9. TÂCHE DIFFICILE : Automatisation des sanctions (Difficile)
-- LOGIQUE : Fonction PL/pgSQL qui vérifie si un retour est en retard
-- et applique automatiquement un blocage proportionnel au retard.
-- (C'est très très probablement la requête la plus compliquée que nous ayons faites)

-- Création de la fonction
CREATE OR REPLACE FUNCTION appliquer_sanction(
    p_id_abonne INT, 
    p_code_barre VARCHAR(255), 
    p_date_emprunt DATE
) RETURNS VOID AS $$
DECLARE
    v_date_retour_prevue DATE;
    v_jours_retard INT;
BEGIN
    -- Récupérer la date de retour prévue
    SELECT date_retour_prevue INTO v_date_retour_prevue
    FROM EMPRUNTE
    WHERE id_abonne = p_id_abonne 
    AND code_barre = p_code_barre 
    AND date_emprunt = p_date_emprunt;
    
    -- Calculer le retard (en jours)
    v_jours_retard := CURRENT_DATE - v_date_retour_prevue;
    
    -- Si retard, appliquer le blocage
    IF v_jours_retard > 0 THEN
        UPDATE ABONNE
        SET est_bloque = TRUE,
            fin_blocage = CURRENT_DATE + (v_jours_retard || ' days')::INTERVAL
        WHERE id_abonne = p_id_abonne;
    END IF;
    
    -- Supprimer l'emprunt (le livre est rendu)
    DELETE FROM EMPRUNTE
    WHERE id_abonne = p_id_abonne 
    AND code_barre = p_code_barre 
    AND date_emprunt = p_date_emprunt;
END;
$$ LANGUAGE plpgsql;

-- Étape 1 : Identifier les retards et calculer les jours
SELECT em.id_abonne, a.nom, em.date_retour_prevue,
       CURRENT_DATE - em.date_retour_prevue AS jours_retard
FROM EMPRUNTE em
JOIN ABONNE a ON em.id_abonne = a.id_abonne
WHERE em.date_retour_prevue < CURRENT_DATE;

-- Étape 2 : Appliquer le blocage pour un emprunt spécifique
UPDATE ABONNE
SET est_bloque = TRUE,
    fin_blocage = CURRENT_DATE + ((CURRENT_DATE - (
        SELECT date_retour_prevue FROM EMPRUNTE 
        WHERE code_barre = 'ISBN-001-A' AND id_abonne = 1
    )) || ' days')::INTERVAL
WHERE id_abonne = 1
AND EXISTS (
    SELECT 1 FROM EMPRUNTE 
    WHERE id_abonne = 1 AND code_barre = 'ISBN-001-A' 
    AND date_retour_prevue < CURRENT_DATE
);


-- ############################################################
-- MARINE : MODULE "RÉSEAU ET LOGISTIQUE" (8 requêtes)
-- ############################################################


-- MA1. Lister toutes les bibliothèques avec leur région (Simple)
-- LOGIQUE : Jointure simple entre BIBLIOTHEQUE et REGION.

SELECT b.id_biblio, b.nom, b.adresse, r.nom_region AS region
FROM BIBLIOTHEQUE b
JOIN REGION r ON b.id_region = r.id_region
ORDER BY r.nom_region, b.nom;


-- MA2. Lister toutes les régions (Simple)
-- LOGIQUE : Requête simple sur la table REGION.

SELECT id_region, nom_region
FROM REGION
ORDER BY nom_region;


-- MA3. Lister les événements à venir avec places restantes (Moyenne)
-- LOGIQUE : Sous-requêtes dans le SELECT pour compter les abonnés inscrits
-- et calculer dynamiquement les places restantes.

SELECT e.id_event, e.date, e.capacite, 
       (SELECT COUNT(*) FROM PARTICIPE p WHERE p.id_event = e.id_event) AS abonnes_inscrits,
       e.nb_inscrits AS non_abonnes_inscrits,
       e.capacite - (SELECT COUNT(*) FROM PARTICIPE p WHERE p.id_event = e.id_event) - e.nb_inscrits AS places_restantes,
       b.nom AS bibliotheque
FROM EVENT e
JOIN BIBLIOTHEQUE b ON e.id_biblio = b.id_biblio
WHERE e.date > NOW()
ORDER BY e.date;


-- MA4. Lister les participants d'un événement (Moyenne)
-- LOGIQUE : UNION ALL pour combiner les abonnés nominatifs et un résumé
-- des non-abonnés dans un seul résultat.

SELECT a.nom AS participant, 'Abonné' AS type_participant
FROM PARTICIPE p
JOIN ABONNE a ON p.id_abonne = a.id_abonne
WHERE p.id_event = 1
UNION ALL
SELECT e.nb_inscrits || ' non-abonné(s)' AS participant, 'Non-abonné' AS type_participant
FROM EVENT e
WHERE e.id_event = 1 AND e.nb_inscrits > 0;


-- MA5. Créer une demande de transfert (Simple)
-- LOGIQUE : Insertion simple d'un transfert avec statut initial "En transit".

INSERT INTO TRANSFERT (statut, date_depart, id_biblio_source, id_biblio_dest, code_barre)
VALUES ('En transit', CURRENT_DATE, 1, 2, 'ISBN-001-A');


-- MA6. TÂCHE DIFFICILE : Suivi des transferts inter-bibliothèques (Difficile)
-- LOGIQUE : Jointure réflexive sur EST_DISTANT.
-- BIBLIOTHEQUE est jointe 2 fois (source et destination).
-- La condition OR gère les deux sens possibles (A→B ou B→A).
-- LEFT JOIN car certains transferts n'ont pas de distance enregistrée.

SELECT t.id_transfert, 
       o.titre AS ouvrage,
       t.code_barre,
       b_source.nom AS bibliotheque_source,
       b_dest.nom AS bibliotheque_destination,
       t.statut,
       t.date_depart,
       ed.temps_transport AS temps_estime_minutes
FROM TRANSFERT t
JOIN EXEMPLAIRE ex ON t.code_barre = ex.code_barre
JOIN OUVRAGE o ON ex.id_ouvrage = o.id_ouvrage
JOIN BIBLIOTHEQUE b_source ON t.id_biblio_source = b_source.id_biblio
JOIN BIBLIOTHEQUE b_dest ON t.id_biblio_dest = b_dest.id_biblio
LEFT JOIN EST_DISTANT ed ON 
    (ed.id_biblio_A = t.id_biblio_source AND ed.id_biblio_B = t.id_biblio_dest)
    OR (ed.id_biblio_A = t.id_biblio_dest AND ed.id_biblio_B = t.id_biblio_source)
WHERE t.statut = 'En transit'
ORDER BY t.date_depart;


-- MA7. Lister les transferts par bibliothèque source (Simple)
-- LOGIQUE : Filtre les transferts partant d'une bibliothèque spécifique.

SELECT t.id_transfert, o.titre, t.statut, t.date_depart, b_dest.nom AS destination
FROM TRANSFERT t
JOIN EXEMPLAIRE ex ON t.code_barre = ex.code_barre
JOIN OUVRAGE o ON ex.id_ouvrage = o.id_ouvrage
JOIN BIBLIOTHEQUE b_dest ON t.id_biblio_dest = b_dest.id_biblio
WHERE t.id_biblio_source = 1
ORDER BY t.date_depart DESC;


-- MA8. Lister les transferts par bibliothèque destination (Simple)
-- LOGIQUE : Filtre les transferts arrivant à une bibliothèque spécifique.

SELECT t.id_transfert, o.titre, t.statut, t.date_depart, b_source.nom AS source
FROM TRANSFERT t
JOIN EXEMPLAIRE ex ON t.code_barre = ex.code_barre
JOIN OUVRAGE o ON ex.id_ouvrage = o.id_ouvrage
JOIN BIBLIOTHEQUE b_source ON t.id_biblio_source = b_source.id_biblio
WHERE t.id_biblio_dest = 2
ORDER BY t.date_depart DESC;
