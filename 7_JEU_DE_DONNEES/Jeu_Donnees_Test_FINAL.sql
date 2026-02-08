-- ============================================================
-- JEU DE DONNÉES DE TEST - BIBLIOTech
-- ============================================================
-- Ce script insère des données de test pour vérifier le bon
-- fonctionnement de la base de données et des requêtes. 
-- Nous avons mis en forme le document de la même manière que pour les requêtes pour une meilleure lisibilité.
-- (Disclaimer: Les idées de données, (comme le choix des livres) ont été prises au hasard)
-- ============================================================

-- ============================================================
-- 1. RÉGIONS
-- ============================================================
INSERT INTO REGION (nom_region) VALUES ('Île-de-France');
INSERT INTO REGION (nom_region) VALUES ('Provence-Alpes-Côte d''Azur');
INSERT INTO REGION (nom_region) VALUES ('Auvergne-Rhône-Alpes');

-- ============================================================
-- 2. BIBLIOTHÈQUES
-- ============================================================
INSERT INTO BIBLIOTHEQUE (nom, adresse, id_region) VALUES ('Bibliothèque Centrale Paris', '10 Rue de Rivoli, 75001 Paris', 1);
INSERT INTO BIBLIOTHEQUE (nom, adresse, id_region) VALUES ('Médiathèque Montmartre', '25 Rue Lepic, 75018 Paris', 1);
INSERT INTO BIBLIOTHEQUE (nom, adresse, id_region) VALUES ('Bibliothèque Marseille Vieux-Port', '5 Quai du Port, 13002 Marseille', 2);
INSERT INTO BIBLIOTHEQUE (nom, adresse, id_region) VALUES ('Médiathèque Lyon Part-Dieu', '30 Boulevard Vivier Merle, 69003 Lyon', 3);

-- ============================================================
-- 3. DISTANCES ENTRE BIBLIOTHÈQUES (même région)
-- ============================================================
INSERT INTO EST_DISTANT (id_biblio_A, id_biblio_B, temps_transport) VALUES (1, 2, 30);

-- ============================================================
-- 4. CATÉGORIES
-- ============================================================
INSERT INTO CATEGORIE (libelle_genre) VALUES ('Roman');
INSERT INTO CATEGORIE (libelle_genre) VALUES ('Science-Fiction');
INSERT INTO CATEGORIE (libelle_genre) VALUES ('Histoire');
INSERT INTO CATEGORIE (libelle_genre) VALUES ('Informatique');
INSERT INTO CATEGORIE (libelle_genre) VALUES ('Jeunesse');

-- ============================================================
-- 5. AUTEURS
-- ============================================================
INSERT INTO AUTEUR (nom) VALUES ('Victor Hugo');
INSERT INTO AUTEUR (nom) VALUES ('Albert Camus');
INSERT INTO AUTEUR (nom) VALUES ('Isaac Asimov');
INSERT INTO AUTEUR (nom) VALUES ('J.K. Rowling');
INSERT INTO AUTEUR (nom) VALUES ('Yuval Noah Harari');

-- ============================================================
-- 6. OUVRAGES
-- ============================================================
INSERT INTO OUVRAGE (titre, type_support, compteur_demande_achat, id_cat) VALUES ('Les Misérables', 'Livre', 0, 1);
INSERT INTO OUVRAGE (titre, type_support, compteur_demande_achat, id_cat) VALUES ('L''Étranger', 'Livre', 2, 1);
INSERT INTO OUVRAGE (titre, type_support, compteur_demande_achat, id_cat) VALUES ('Fondation', 'Livre', 5, 2);
INSERT INTO OUVRAGE (titre, type_support, compteur_demande_achat, id_cat) VALUES ('Harry Potter à l''école des sorciers', 'Livre', 3, 5);
INSERT INTO OUVRAGE (titre, type_support, compteur_demande_achat, id_cat) VALUES ('Sapiens', 'Livre', 1, 3);
INSERT INTO OUVRAGE (titre, type_support, compteur_demande_achat, id_cat) VALUES ('Le Seigneur des Anneaux - Audiobook', 'CD', 0, 2);

-- ============================================================
-- 7. ÉCRIT (relation auteur-ouvrage)
-- ============================================================
INSERT INTO ECRIT (id_auteur, id_ouvrage) VALUES (1, 1);
INSERT INTO ECRIT (id_auteur, id_ouvrage) VALUES (2, 2);
INSERT INTO ECRIT (id_auteur, id_ouvrage) VALUES (3, 3);
INSERT INTO ECRIT (id_auteur, id_ouvrage) VALUES (4, 4);
INSERT INTO ECRIT (id_auteur, id_ouvrage) VALUES (5, 5);

-- ============================================================
-- 8. CATALOGUE (ouvrages référencés par bibliothèque)
-- ============================================================
INSERT INTO CATALOGUE (id_ouvrage, id_biblio) VALUES (1, 1);
INSERT INTO CATALOGUE (id_ouvrage, id_biblio) VALUES (1, 2);
INSERT INTO CATALOGUE (id_ouvrage, id_biblio) VALUES (2, 1);
INSERT INTO CATALOGUE (id_ouvrage, id_biblio) VALUES (3, 1);
INSERT INTO CATALOGUE (id_ouvrage, id_biblio) VALUES (3, 3);
INSERT INTO CATALOGUE (id_ouvrage, id_biblio) VALUES (4, 1);
INSERT INTO CATALOGUE (id_ouvrage, id_biblio) VALUES (4, 2);
INSERT INTO CATALOGUE (id_ouvrage, id_biblio) VALUES (4, 3);
INSERT INTO CATALOGUE (id_ouvrage, id_biblio) VALUES (5, 4);

-- ============================================================
-- 9. EXEMPLAIRES
-- ============================================================
INSERT INTO EXEMPLAIRE (code_barre, etage, rayon, etat, id_ouvrage, id_biblio) VALUES ('ISBN-001-A', '1er', 'A1', 'Bon', 1, 1);
INSERT INTO EXEMPLAIRE (code_barre, etage, rayon, etat, id_ouvrage, id_biblio) VALUES ('ISBN-001-B', '2ème', 'B3', 'Neuf', 1, 2);
INSERT INTO EXEMPLAIRE (code_barre, etage, rayon, etat, id_ouvrage, id_biblio) VALUES ('ISBN-002-A', '1er', 'A2', 'Bon', 2, 1);
INSERT INTO EXEMPLAIRE (code_barre, etage, rayon, etat, id_ouvrage, id_biblio) VALUES ('ISBN-003-A', 'RDC', 'C1', 'Usé', 3, 1);
INSERT INTO EXEMPLAIRE (code_barre, etage, rayon, etat, id_ouvrage, id_biblio) VALUES ('ISBN-003-B', '1er', 'C2', 'Neuf', 3, 3);
INSERT INTO EXEMPLAIRE (code_barre, etage, rayon, etat, id_ouvrage, id_biblio) VALUES ('ISBN-004-A', '2ème', 'D1', 'Bon', 4, 1);
INSERT INTO EXEMPLAIRE (code_barre, etage, rayon, etat, id_ouvrage, id_biblio) VALUES ('ISBN-004-B', '1er', 'D2', 'Bon', 4, 2);
INSERT INTO EXEMPLAIRE (code_barre, etage, rayon, etat, id_ouvrage, id_biblio) VALUES ('ISBN-005-A', 'RDC', 'E1', 'Neuf', 5, 4);

-- ============================================================
-- 10. TYPES D'ABONNEMENT
-- ============================================================
INSERT INTO TYPE_ABONNEMENT (libelle, quota_max, duree_pret_max) VALUES ('Étudiant', 3, 21);
INSERT INTO TYPE_ABONNEMENT (libelle, quota_max, duree_pret_max) VALUES ('Professeur', 5, 30);
INSERT INTO TYPE_ABONNEMENT (libelle, quota_max, duree_pret_max) VALUES ('Lambda', 2, 14);

-- ============================================================
-- 11. ABONNÉS
-- ============================================================
INSERT INTO ABONNE (nom, est_bloque, fin_blocage, id_type) VALUES ('Jean Dupont', FALSE, NULL, 1);
INSERT INTO ABONNE (nom, est_bloque, fin_blocage, id_type) VALUES ('Marie Martin', FALSE, NULL, 2);
INSERT INTO ABONNE (nom, est_bloque, fin_blocage, id_type) VALUES ('Pierre Durand', TRUE, '2026-02-10', 3);
INSERT INTO ABONNE (nom, est_bloque, fin_blocage, id_type) VALUES ('Sophie Bernard', FALSE, NULL, 1);

-- ============================================================
-- 12. EMPRUNTS
-- ============================================================
INSERT INTO EMPRUNTE (id_abonne, code_barre, date_emprunt, date_retour_prevue, est_prolonge) VALUES (1, 'ISBN-001-A', '2026-01-15', '2026-02-05', FALSE);
INSERT INTO EMPRUNTE (id_abonne, code_barre, date_emprunt, date_retour_prevue, est_prolonge) VALUES (1, 'ISBN-003-A', '2026-01-20', '2026-02-10', FALSE);
INSERT INTO EMPRUNTE (id_abonne, code_barre, date_emprunt, date_retour_prevue, est_prolonge) VALUES (2, 'ISBN-004-A', '2026-01-10', '2026-02-09', TRUE);
INSERT INTO EMPRUNTE (id_abonne, code_barre, date_emprunt, date_retour_prevue, est_prolonge) VALUES (4, 'ISBN-002-A', '2026-01-25', '2026-02-15', FALSE);

-- ============================================================
-- 13. RÉSERVATIONS
-- ============================================================
INSERT INTO RESERVE (id_ouvrage, id_abonne, date_demande, id_biblio_retrait) VALUES (1, 4, '2026-01-28 10:30:00', 1);
INSERT INTO RESERVE (id_ouvrage, id_abonne, date_demande, id_biblio_retrait) VALUES (3, 1, '2026-01-29 14:00:00', 2);

-- ============================================================
-- 14. SUGGESTIONS D'ACHAT
-- ============================================================
INSERT INTO SUGGERE (id_abonne, id_ouvrage, date_suggestion) VALUES (1, 3, '2026-01-20');
INSERT INTO SUGGERE (id_abonne, id_ouvrage, date_suggestion) VALUES (2, 3, '2026-01-22');

-- ============================================================
-- 15. ÉVÉNEMENTS
-- ============================================================
INSERT INTO EVENT (date, capacite, nb_inscrits, id_biblio) VALUES ('2026-03-15 14:00:00', 50, 5, 1);
INSERT INTO EVENT (date, capacite, nb_inscrits, id_biblio) VALUES ('2026-04-01 18:00:00', 30, 2, 2);

-- ============================================================
-- 16. PARTICIPATIONS AUX ÉVÉNEMENTS
-- ============================================================
INSERT INTO PARTICIPE (id_abonne, id_event) VALUES (1, 1);
INSERT INTO PARTICIPE (id_abonne, id_event) VALUES (2, 1);
INSERT INTO PARTICIPE (id_abonne, id_event) VALUES (4, 1);

-- ============================================================
-- 17. TRANSFERTS
-- ============================================================
INSERT INTO TRANSFERT (statut, date_depart, id_biblio_source, id_biblio_dest, code_barre) VALUES ('En transit', '2026-02-01', 1, 2, 'ISBN-004-A');


