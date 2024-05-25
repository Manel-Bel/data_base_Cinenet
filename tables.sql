-- CREATE DATABASE CineNet;
\c cinenet;

-- DROP TABLE IF EXISTS Role;
DROP TABLE IF EXISTS Amis;
DROP TABLE IF EXISTS Follower;
DROP TABLE IF EXISTS Archive;
DROP TABLE IF EXISTS Film;
DROP TABLE IF EXISTS Serie;
DROP TABLE IF EXISTS Reaction;
DROP TABLE IF EXISTS GenreCinemato CASCADE;
DROP TABLE IF EXISTS MotsClesPublication;
DROP TABLE if EXISTS MotsCles;
DROP TABLE IF EXISTS ParticipationEvent;
DROP TABLE IF EXISTS InteresseEvent;
DROP TABLE IF EXISTS HistoriquePublication;
DROP TABLE IF EXISTS HistoriqueReaction;
DROP TABLE IF EXISTS EventParticulier;
DROP TABLE IF EXISTS Publication CASCADE;
DROP TABLE IF EXISTS SujetPublication;
DROP TABLE IF EXISTS Discussion;
DROP TABLE IF EXISTS CategorieDiscussion;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS Users;

DROP TYPE IF EXISTS TypeRole CASCADE;
DROP TYPE IF EXISTS TypeReaction CASCADE;

-- CHANGEMENT
CREATE TYPE TypeRole as ENUM ('lamda', 'Realisateur', 'acteur', 'organisateurSalle', 'Cinema' ,'Club', 'Studio', 'organisateurEvent');

-- CHANGEMENT USERNAME NOT UNIQUE BUT EMAIL MUST BE UNIQUE
CREATE TABLE Users(
    id serial PRIMARY KEY,
    username  VARCHAR(50) NOT NULL,
    password  VARCHAR(128) NOT NULL,
    email  VARCHAR(75) UNIQUE,
    role TypeRole
);


-- symétrique
CREATE TABLE Amis(
    user1 INTEGER REFERENCES Users(id),
    user2 INTEGER REFERENCES Users(id),
    PRIMARY KEY (user1, user2),
    CONSTRAINT amis_self  CHECK (user1 != user2)
);

CREATE TABLE Follower(
    id INTEGER REFERENCES Users(id),
    folower  INTEGER REFERENCES Users(id),
    PRIMARY KEY (id, folower),
    CONSTRAINT follow_self CHECK (id != folower)
);

-- CHANGEMENT : id n'est plus un integer c'est le nom
-- et parent n'est plus integer
-- nom --> name
CREATE TABLE GenreCinemato(
    id SERIAL INTEGER PRIMARY KEY,
    name    VARCHAR(32) PRIMARY KEY,
    parent INTEGER REFERENCES GenreCinemato(id)
);

-- CHANGEMENT : genre
CREATE TABLE Film(
    id          SERIAL PRIMARY KEY,
    titre       VARCHAR(64) NOT NULL,
    resume      TEXT,
    realisation DATE,
    duree       INTEGER, -- en minutes
);

-- CHANGEMENt NV TABLE
CREATE TABLE FilmGenre(
    idFilm      INTEGER REFERENCES Film(id),
    genre       INTEGER REFERENCES GenreCinemato(id),
    PRIMARY KEY (idFilm, genre)
);


CREATE TABLE Serie(
    id          SERIAL PRIMARY KEY,
    saison      SMALLINT,
    titre       VARCHAR(64) NOT NULL,
    nbreEpisodes SMALLINT,
    dureeParEpisode INTEGER, -- en minutes
    datePremiere DATE,
    genre        INTEGER REFERENCES GenreCinemato(id)
);

CREATE TABLE SerieGenre(
    idSerie      INTEGER REFERENCES Serie(id),
    genre       INTEGER REFERENCES GenreCinemato(id),
    PRIMARY KEY (idSerie, genre)
);

-- ALTER TABLE Serie ADD CONSTRAINT unique_serie UNIQUE (numero, saison);


-- 
-- CREATE TABLE SujetPublication(
--     id INTEGER PRIMARY KEY,
--     description  VARCHAR(1024) NOT NULL
-- );

CREATE TABLE MotsCles(
    motCleId SERIAL PRIMARY KEY,
    motCle VARCHAR(32) UNIQUE
);

CREATE TABLE CategorieDiscussion(
    id SERIAL PRIMARY KEY,
    nomCategorie   VARCHAR(32) NOT NULL
);

CREATE TABLE Discussion(
    id SERIAL PRIMARY KEY,
    auteur INTEGER,
    titre VARCHAR(255) NOT NULL,
    description TEXT,
    categorie INTEGER,
    FOREIGN KEY (categorie) REFERENCES CategorieDiscussion(id) ON DELETE CASCADE,
    FOREIGN KEY (auteur) REFERENCES Users(id) ON DELETE CASCADE
);

--  ADDED DATE
CREATE TABLE Publication( 
    id INTEGER PRIMARY KEY,
    auteur INTEGER REFERENCES Users(id),
    discussionId INTEGER REFERENCES Discussion(id),
    titre VARCHAR(200) NOT NULL,
    contenu TEXT NOT NULL,
    -- sujetId INTEGER REFERENCES SujetPublication(id),
    datePublication TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    parentId  INTEGER REFERENCES Publication(id), --NULL si publication premier niveau
    FOREIGN KEY (auteur) REFERENCES Users(id) ON DELETE CASCADE
);


CREATE TABLE MotsClesPublication( --dayen
    publiId INTEGER,
    motCleId INTEGER,
    PRIMARY KEY (publiId, motCleId),
    FOREIGN KEY (motCleId) REFERENCES MotsCles(motCleId) ON DELETE CASCADE,
    FOREIGN KEY (publiId) REFERENCES Publication(id) ON DELETE CASCADE
);

CREATE TYPE TypeReaction as ENUM ('Like', 'Dislike', 'Neutre', 'Fun', 'Sad' ,'Angry');

CREATE TABLE Reaction(
    idPubli INTEGER REFERENCES Publication(id),
    idUser INTEGER,
    type TypeReaction,
    PRIMARY KEY (idPubli, idUser),
    FOREIGN KEY (idUser) REFERENCES Users(id),
    FOREIGN KEY (idPubli) REFERENCES Publication(id) ON DELETE CASCADE?
);


-- ORGANISATEUR N'EST PAS UNE CLE ETARNGERE 
CREATE TABLE EventParticulier( 
   id SERIAL PRIMARY KEY,
   auteur INTEGER,
   nomEvent VARCHAR(255) NOT NULL,
   dateEvent DATE NOT NULL,                   
   lieuEvent VARCHAR(255) NOT NULL,              
   nbPlaceDispo INTEGER NOT NULL,     
   nbPlaceReserve INTEGER NOT NULL DEFAULT 0,
   organisateur INTEGER ,
   liens_web TEXT[],
   FOREIGN KEY (auteur) REFERENCES Users(id) ON DELETE CASCADE,
   FOREIGN KEY (organisateur) REFERENCES Users(id) ON DELETE CASCADE
);

CREATE TABLE ParticipationEvent (
   userId INTEGER REFERENCES Users(id),     
   eventId INTEGER REFERENCES EventParticulier(id), 
   PRIMARY KEY(userId, eventId)
);

CREATE TABLE InteresseEvent(
    userId INTEGER REFERENCES Users(id),
    eventId INTEGER REFERENCES EventParticulier(id),
    PRIMARY KEY(userId, eventId)
);



-- La vue "ParticipationEvent" affiche tous les inscrits à un événement donné.
-- CREATE VIEW ParticipationEvents AS 
-- SELECT P.* FROM Participant P INNER JOIN EventParticulier E on P.idEvent=E.idEvent;

-- ALTER TABLE ParticipationEvents ADD CONSTRAINT check_nbplace CHECK (nbPlaceDispo - nbPlaceReserve >=  0);



-- changement fait pour id event 
CREATE TABLE Archive( -- pourquoi relation vers publication et non pas evenement particulié
    idArchive SERIAL PRIMARY KEY,
    dateArchivage DATE NOT NULL,
    raison VARCHAR(255) NOT NULL,
    idEvent INTEGER REFERENCES EventParticulier(id)  
);




-- message envoyé par un utilisateur à un autre.
CREATE TABLE Message (
    id SERIAL PRIMARY KEY,
    expéditeur INTEGER REFERENCES Users(id),
    destinataire INTEGER REFERENCES Users(id),
    contenu TEXT NOT NULL
);



CREATE TABLE HistoriquePublication(
    idUser  INTEGER REFERENCES Users(id),
    idPubli INTEGER,
    action VARCHAR(255), --  ou ajouter ou voir ou repondre à une publication
    dateAction DATE NOT NULL,
    idReaction INTEGER REFERENCES Reaction(id),
    PRIMARY KEY (idUser, idPubli, dateAction),
    FOREIGN KEY (idUser) REFERENCES Users(id) ON UPDATE CASCADE,
    FOREIGN KEY (idPubli) REFERENCES Publication(id) ON DELETE CASCADE
);

