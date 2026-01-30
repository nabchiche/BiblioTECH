-- DDL (Data Definition Language) - Base de données BIBLIOTech
-- Ce script crée l'ensemble des tables de notre schéma relationnel :)

DROP TABLE IF EXISTS PARTICIPE;
DROP TABLE IF EXISTS EVENT;
DROP TABLE IF EXISTS SUGGERE;
DROP TABLE IF EXISTS RESERVE;
DROP TABLE IF EXISTS EMPRUNTE;
DROP TABLE IF EXISTS TRANSFERT;
DROP TABLE IF EXISTS CATALOGUE;
DROP TABLE IF EXISTS ECRIT;
DROP TABLE IF EXISTS EXEMPLAIRE;
DROP TABLE IF EXISTS OUVRAGE;
DROP TABLE IF EXISTS CATEGORIE;
DROP TABLE IF EXISTS AUTEUR;
DROP TABLE IF EXISTS ABONNE;
DROP TABLE IF EXISTS TYPE_ABONNEMENT;
DROP TABLE IF EXISTS EST_DISTANT;
DROP TABLE IF EXISTS BIBLIOTHEQUE;
DROP TABLE IF EXISTS REGION;


-- 1. GESTION DES LIEUX ET DU RÉSEAU


CREATE TABLE REGION (
    id_region INT PRIMARY KEY AUTO_INCREMENT,
    nom_region VARCHAR(255) NOT NULL
);

CREATE TABLE BIBLIOTHEQUE (
    id_biblio INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(255) NOT NULL,
    adresse VARCHAR(255) NOT NULL,
    id_region INT NOT NULL,
    CONSTRAINT fk_bibliotheque_region FOREIGN KEY (id_region) REFERENCES REGION(id_region)
);

CREATE TABLE EST_DISTANT (
    id_biblio_A INT NOT NULL,
    id_biblio_B INT NOT NULL,
    temps_transport INT NOT NULL,
    PRIMARY KEY (id_biblio_A, id_biblio_B),
    CONSTRAINT fk_est_distant_biblio_a FOREIGN KEY (id_biblio_A) REFERENCES BIBLIOTHEQUE(id_biblio),
    CONSTRAINT fk_est_distant_biblio_b FOREIGN KEY (id_biblio_B) REFERENCES BIBLIOTHEQUE(id_biblio)
);


-- 2. CATALOGUE ET OUVRAGES


CREATE TABLE CATEGORIE (
    id_cat INT PRIMARY KEY AUTO_INCREMENT,
    libelle_genre VARCHAR(100) NOT NULL
);

CREATE TABLE AUTEUR (
    id_auteur INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(255) NOT NULL
);

CREATE TABLE OUVRAGE (
    id_ouvrage INT PRIMARY KEY AUTO_INCREMENT,
    titre VARCHAR(255) NOT NULL,
    type_support VARCHAR(50) NOT NULL,
    compteur_demande_achat INT DEFAULT 0,
    id_cat INT NOT NULL,
    CONSTRAINT fk_ouvrage_categorie FOREIGN KEY (id_cat) REFERENCES CATEGORIE(id_cat)
);

CREATE TABLE ECRIT (
    id_auteur INT NOT NULL,
    id_ouvrage INT NOT NULL,
    PRIMARY KEY (id_auteur, id_ouvrage),
    CONSTRAINT fk_ecrit_auteur FOREIGN KEY (id_auteur) REFERENCES AUTEUR(id_auteur),
    CONSTRAINT fk_ecrit_ouvrage FOREIGN KEY (id_ouvrage) REFERENCES OUVRAGE(id_ouvrage)
);

CREATE TABLE CATALOGUE (
    id_ouvrage INT NOT NULL,
    id_biblio INT NOT NULL,
    PRIMARY KEY (id_ouvrage, id_biblio),
    CONSTRAINT fk_catalogue_ouvrage FOREIGN KEY (id_ouvrage) REFERENCES OUVRAGE(id_ouvrage),
    CONSTRAINT fk_catalogue_bibliotheque FOREIGN KEY (id_biblio) REFERENCES BIBLIOTHEQUE(id_biblio)
);


-- 3. GESTION DU STOCK PHYSIQUE


CREATE TABLE EXEMPLAIRE (
    code_barre VARCHAR(255) PRIMARY KEY,
    etage VARCHAR(50),
    rayon VARCHAR(50),
    etat VARCHAR(100) NOT NULL,
    id_ouvrage INT NOT NULL,
    id_biblio INT NOT NULL,
    CONSTRAINT fk_exemplaire_ouvrage FOREIGN KEY (id_ouvrage) REFERENCES OUVRAGE(id_ouvrage),
    CONSTRAINT fk_exemplaire_bibliotheque FOREIGN KEY (id_biblio) REFERENCES BIBLIOTHEQUE(id_biblio)
);

CREATE TABLE TRANSFERT (
    id_transfert INT PRIMARY KEY AUTO_INCREMENT,
    statut VARCHAR(100) NOT NULL,
    date_depart DATE NOT NULL,
    id_biblio_source INT NOT NULL,
    id_biblio_dest INT NOT NULL,
    code_barre VARCHAR(255) NOT NULL,
    CONSTRAINT fk_transfert_biblio_source FOREIGN KEY (id_biblio_source) REFERENCES BIBLIOTHEQUE(id_biblio),
    CONSTRAINT fk_transfert_biblio_dest FOREIGN KEY (id_biblio_dest) REFERENCES BIBLIOTHEQUE(id_biblio),
    CONSTRAINT fk_transfert_exemplaire FOREIGN KEY (code_barre) REFERENCES EXEMPLAIRE(code_barre)
);

-- 4. GESTION DES ABONNÉS ET ADHÉSIONS

CREATE TABLE TYPE_ABONNEMENT (
    id_type INT PRIMARY KEY AUTO_INCREMENT,
    libelle VARCHAR(100) NOT NULL,
    quota_max INT NOT NULL,
    duree_pret_max INT NOT NULL
);

CREATE TABLE ABONNE (
    id_abonne INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(255) NOT NULL,
    est_bloque BOOLEAN DEFAULT FALSE,
    fin_blocage DATE NULL,
    id_type INT NOT NULL,
    CONSTRAINT fk_abonne_type FOREIGN KEY (id_type) REFERENCES TYPE_ABONNEMENT(id_type)
);


-- 5. GESTION DES PRÊTS ET RÉSERVATIONS


CREATE TABLE EMPRUNTE (
    id_abonne INT NOT NULL,
    code_barre VARCHAR(255) NOT NULL,
    date_emprunt DATE NOT NULL,
    date_retour_prevue DATE NOT NULL,
    est_prolonge BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (id_abonne, code_barre, date_emprunt),
    CONSTRAINT fk_emprunte_abonne FOREIGN KEY (id_abonne) REFERENCES ABONNE(id_abonne),
    CONSTRAINT fk_emprunte_exemplaire FOREIGN KEY (code_barre) REFERENCES EXEMPLAIRE(code_barre)
);

CREATE TABLE RESERVE (
    id_ouvrage INT NOT NULL,
    id_abonne INT NOT NULL,
    date_demande DATETIME NOT NULL,
    id_biblio_retrait INT NOT NULL,
    PRIMARY KEY (id_ouvrage, id_abonne),
    CONSTRAINT fk_reserve_ouvrage FOREIGN KEY (id_ouvrage) REFERENCES OUVRAGE(id_ouvrage),
    CONSTRAINT fk_reserve_abonne FOREIGN KEY (id_abonne) REFERENCES ABONNE(id_abonne),
    CONSTRAINT fk_reserve_bibliotheque FOREIGN KEY (id_biblio_retrait) REFERENCES BIBLIOTHEQUE(id_biblio)
);

CREATE TABLE SUGGERE (
    id_abonne INT NOT NULL,
    id_ouvrage INT NOT NULL,
    date_suggestion DATE NOT NULL,
    PRIMARY KEY (id_abonne, id_ouvrage),
    CONSTRAINT fk_suggere_abonne FOREIGN KEY (id_abonne) REFERENCES ABONNE(id_abonne),
    CONSTRAINT fk_suggere_ouvrage FOREIGN KEY (id_ouvrage) REFERENCES OUVRAGE(id_ouvrage)
);


-- 6. GESTION DES ÉVÉNEMENTS


CREATE TABLE EVENT (
    id_event INT PRIMARY KEY AUTO_INCREMENT,
    date DATETIME NOT NULL,
    capacite INT NOT NULL,
    nb_inscrits INT DEFAULT 0,
    id_biblio INT NOT NULL,
    CONSTRAINT fk_event_bibliotheque FOREIGN KEY (id_biblio) REFERENCES BIBLIOTHEQUE(id_biblio)
);

CREATE TABLE PARTICIPE (
    id_abonne INT NOT NULL,
    id_event INT NOT NULL,
    PRIMARY KEY (id_abonne, id_event),
    CONSTRAINT fk_participe_abonne FOREIGN KEY (id_abonne) REFERENCES ABONNE(id_abonne),
    CONSTRAINT fk_participe_event FOREIGN KEY (id_event) REFERENCES EVENT(id_event)
);


-- FIN DU SCRIPT DDL

