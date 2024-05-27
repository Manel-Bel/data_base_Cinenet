-- CREATE DATABASE CineNet;
\c cinenet;

DROP TABLE IF EXISTS Role;
DROP TABLE IF EXISTS Amis;
DROP TABLE IF EXISTS Follower;
DROP TABLE IF EXISTS Archive;
DROP TABLE IF EXISTS Film CASCADE;
DROP TABLE IF EXISTS FilmGenre;
DROP TABLE IF EXISTS Serie;
DROP TABLE IF EXISTS SerieGenre;
DROP TABLE IF EXISTS Reaction;
DROP TABLE IF EXISTS GenreCinemato CASCADE;
DROP TABLE IF EXISTS MotsClesPublication;
DROP TABLE if EXISTS MotsCles;
DROP TABLE IF EXISTS ParticipationEvent;
DROP TABLE IF EXISTS InteresseEvent;
DROP TABLE IF EXISTS HistoriquePublication;
DROP TABLE IF EXISTS HistoriqueReaction;
DROP TABLE IF EXISTS EventParticulier CASCADE;
DROP TABLE IF EXISTS Publication CASCADE;
DROP TABLE IF EXISTS SujetPublication;
DROP TABLE IF EXISTS Discussion;
DROP TABLE IF EXISTS CategorieDiscussion;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS Users CASCADE;

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

-- CHANGEMENT : 
-- nom --> name
CREATE TABLE GenreCinemato(
    id SERIAL PRIMARY KEY,
    name    VARCHAR(32) UNIQUE,
    parent INTEGER REFERENCES GenreCinemato(id)
);

    -- CHANGEMENT : genre
    CREATE TABLE Film(
        id          SERIAL PRIMARY KEY,
        titre       VARCHAR(64) NOT NULL,
        resume      TEXT,
        realisation DATE,
        duree       INTEGER -- en minutes
    );

    -- CHANGEMENt NV TABLE
    CREATE TABLE FilmGenre(
        filmId      INTEGER REFERENCES Film(id),
        genreId       INTEGER REFERENCES GenreCinemato(id),
        PRIMARY KEY (filmId, genreId)
    );


    CREATE TABLE Serie(
        id          SERIAL PRIMARY KEY,
        saison      SMALLINT,
        titre       VARCHAR(64) NOT NULL,
        nbreEpisodes SMALLINT,
        dureeParEpisode INTEGER, -- en minutes
        datePremiere DATE
        -- genre        INTEGER REFERENCES GenreCinemato(id)
    );

    CREATE TABLE SerieGenre(
        serieId      INTEGER REFERENCES Serie(id),
        genre       INTEGER REFERENCES GenreCinemato(id),
        PRIMARY KEY (serieId, genre)
    );


CREATE TABLE MotsCles(
    motCleId SERIAL PRIMARY KEY,
    motCle VARCHAR(32) UNIQUE
);
-- CHANGEMET nomCategorie -> categorie and Uniue categorie
CREATE TABLE CategorieDiscussion(
    id SERIAL PRIMARY KEY,
    categorie   VARCHAR(32) NOT NULL UNIQUE
);
-- Changement categorie -> categorieId
CREATE TABLE Discussion(
    id SERIAL PRIMARY KEY,
    auteur INTEGER,
    titre VARCHAR(255) NOT NULL,
    description TEXT,
    categorieId INTEGER,
    FOREIGN KEY (categorieId) REFERENCES CategorieDiscussion(id) ON DELETE CASCADE,
    FOREIGN KEY (auteur) REFERENCES Users(id) ON DELETE CASCADE
);

--  ADDED DATE
CREATE TABLE Publication( 
    id INTEGER PRIMARY KEY,
    auteur INTEGER REFERENCES Users(id),
    discussionId INTEGER REFERENCES Discussion(id),
    titre VARCHAR(200) NOT NULL,
    contenu TEXT NOT NULL,
    datePublication TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    parentId  INTEGER REFERENCES Publication(id), --NULL si publication premier niveau
    FOREIGN KEY (auteur) REFERENCES Users(id) ON DELETE CASCADE
);


CREATE TABLE MotsClesPublication( 
    publiId INTEGER,
    motCleId INTEGER,
    PRIMARY KEY (publiId, motCleId),
    FOREIGN KEY (motCleId) REFERENCES MotsCles(motCleId) ON DELETE CASCADE,
    FOREIGN KEY (publiId) REFERENCES Publication(id) ON DELETE CASCADE
);

CREATE TYPE TypeReaction as ENUM ('Like', 'Dislike', 'Neutre', 'Fun', 'Sad' ,'Angry', 'Love');

-- CHANGEMENT idPubli --> publiId , idUser --> userId
CREATE TABLE Reaction(
    id SERIAL PRIMARY KEY,
    publiId INTEGER REFERENCES Publication(id),
    userId INTEGER,
    typeR TypeReaction,
    UNIQUE (publiId, userId),
    FOREIGN KEY (userId) REFERENCES Users(id),
    FOREIGN KEY (publiId) REFERENCES Publication(id) ON DELETE CASCADE
);


-- CHANGEMENT Constraint
CREATE TABLE EventParticulier( 
   id SERIAL PRIMARY KEY,
   auteur INTEGER,
   nomEvent VARCHAR(255) NOT NULL,
   dateEvent DATE NOT NULL,                   
   lieuEvent VARCHAR(255) NOT NULL,              
   nbPlaceDispo INTEGER, --plus de not null     
   nbPlaceReserve INTEGER NOT NULL DEFAULT 0,
   organisateur INTEGER ,
   liens_web TEXT[],
   FOREIGN KEY (auteur) REFERENCES Users(id) ON DELETE CASCADE,
   FOREIGN KEY (organisateur) REFERENCES Users(id) ON DELETE CASCADE,
   CONSTRAINT check_places_dispo CHECK (nbPlaceReserve <= nbPlaceDispo)
);



CREATE TABLE ParticipationEvent(-- assurer l'exclusion avec  interesser
   userId INTEGER REFERENCES Users(id),
   eventId INTEGER REFERENCES EventParticulier(id), 
   PRIMARY KEY(userId, eventId)
);

CREATE TABLE InteresseEvent(
    userId INTEGER REFERENCES Users(id),
    eventId INTEGER REFERENCES EventParticulier(id),
    PRIMARY KEY(userId, eventId)
);

-- publication qui concerne un event
CREATE TABLE PublicationEventPart( --concerner
    publiId INTEGER,
    eventId INTEGER,
    PRIMARY KEY (publiId, eventId),
    FOREIGN KEY (eventId) REFERENCES EventParticulier(id) ON DELETE CASCADE,
    FOREIGN KEY (publiId) REFERENCES Publication(id) ON DELETE CASCADE
);

CREATE TABLE PublicationFilm( --relation concerner
    publiId INTEGER,
    FilmId INTEGER,
    PRIMARY KEY (publiId, FilmId),
    FOREIGN KEY (FilmId) REFERENCES Film(id) ON DELETE CASCADE,
    FOREIGN KEY (publiId) REFERENCES Publication(id) ON DELETE CASCADE
);

CREATE TABLE PublicationSerie( --concerner
    publiId INTEGER,
    SerieId INTEGER,
    PRIMARY KEY (publiId, SerieId),
    FOREIGN KEY (SerieId) REFERENCES Serie(id) ON DELETE CASCADE,
    FOREIGN KEY (publiId) REFERENCES Publication(id) ON DELETE CASCADE
);



-- CHANGEMENT  idevent -->eventId, 
CREATE TABLE Archive( 
    idArchive SERIAL PRIMARY KEY,
    dateArchivage DATE NOT NULL,
    raison VARCHAR(255) NOT NULL,
    eventId INTEGER REFERENCES EventParticulier(id)  
);


-- message envoyé par un utilisateur à un autre.
CREATE TABLE Message (
    id SERIAL PRIMARY KEY,
    expéditeur INTEGER REFERENCES Users(id),
    destinataire INTEGER REFERENCES Users(id),
    contenu TEXT NOT NULL
);


-- CHNAGEMENT IdPubli--> publiId and userID
CREATE TABLE HistoriquePublication(
    userId  INTEGER REFERENCES Users(id),
    publiId INTEGER,
    action VARCHAR(255), --  ou ajouter ou voir ou repondre à une publication
    dateAction DATE NOT NULL,
    idReaction INTEGER REFERENCES Reaction(id),
    PRIMARY KEY (userId, publiId, dateAction),
    FOREIGN KEY (userId) REFERENCES Users(id) ON UPDATE CASCADE,
    FOREIGN KEY (publiId) REFERENCES Publication(id) ON DELETE CASCADE
);

-- CREATE TABLE HistoriqueReaction(
--     idUser INTEGER,
--     idPubli INTEGER,
--     idReaction INTEGER REFERENCES Reaction(id),
--     dateAction DATE NOT NULL,
--     PRIMARY KEY(idUser, idPubli, idReaction, dateAction),
--         -- On ne peut pas avoir deux fois la même réaction sur la même publication d'un même utilisateur dans le temps
--     FOREIGN KEY(idUser) REFERENCES Users(id) ON UPDATE CASCADE,
--     FOREIGN KEY(idPubli) REFERENCES Publication(id) ON UPDATE CASCADE,
--     FOREIGN KEY(idReaction) REFERENCES Reaction(id)
-- );


