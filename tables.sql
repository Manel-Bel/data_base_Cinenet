CREATE DATABASE CineNet;
\c cineNet;

DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Role;
DROP TABLE IF EXISTS Amis;
DROP TABLE IF EXISTS Follow;
DROP TABLE IF EXISTS Publication;
DROP TABLE IF EXISTS Archive;
DROP TABLE IF EXISTS Film;
DROP TABLE IF EXISTS Serie;
DROP TABLE IF EXISTS EventParticulier;
DROP TABLE IF EXISTS Sujet_publication;
DROP TABLE IF EXISTS Reaction;
DROP TABLE IF EXISTS Discussion;
DROP TABLE if EXISTS MotsCles;

CREATE TABLE User (
id serial PRIMARY KEY,
username  VARCHAR(50) NOT NULL UNIQUE,
password  VARCHAR(128) NOT NULL,
email  VARCHAR(75),
role _id INTEGER REFERENCES Role(id) ON DELETE SET NULL
);

CREATE TABLE Role (
    id serial PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE
);

-- symétrique
CREATE TABLE Amis(
    user1 INTEGER REFERENCES User(id),
    user2 INTEGER REFERENCES User(id),
    constraint pk_Amis primary key (user1, user2)
);

CREATE TABLE Follow (
    userId INTEGER REFERENCES User(id),
    folowerid  INTEGER REFERENCES User(id),
    PRIMARY KEY (userId, folowerid),
    CONSTRAINT follow_self CHECK (userId != folowerid)
);

CREATE VIEW UtilisateursSuivis AS
SELECT DISTINCT u.* FROM User u INNER JOIN Follow f ON u.Id = f.folowerid;


-- One publication can be linked to one or several films.
CREATE TABLE Filme_Publication (
filmPubliId SERIAL PRIMARY KEY,
filmId INTEGER REFERENCES Film(id),
publiId INTEGER REFERENCES Publication(publiId)
);

ALTER TABLE Filme_Publication ADD CONSTRAINT film_publi_unique UNIQUE (filmId, publiId);

CREATE TABLE Film (
    id          SERIAL PRIMARY KEY,
    titre       VARCHAR(64) NOT NULL,
    resume      TEXT,
    realisation DATE,
    duree       INTEGER, -- en minutes
    genre       VARCHAR(32)
);


CREATE TABLE Serie (
    id          SERIAL PRIMARY KEY,
    numero      SMALLINT CHECK (numero > 0),
    saison      SMALLINT,
    titre       VARCHAR(64) NOT NULL,
    nbreEpisodes SMALLINT,
    dureeParEpisode INTEGER, -- en minutes
    datePremiere DATE,
    genre        VARCHAR(32)
);

ALTER TABLE Serie ADD CONSTRAINT unique_serie UNIQUE (numero, saison);

CREATE TABLE GenreCinemato (
    idGenre SERIAL PRIMARY KEY,
    nom   VARCHAR(32) NOT NULL
);

CREATE TABLE SousGenreCinemato (
idSousGenre SERIAL PRIMARY KEY,
idGenre       INTEGER REFERENCES GenreCinemato(idGenre),
nom         VARCHAR(32) NOT NULL
);


CREATE TABLE SujetPublication (
idSujet INTEGER PRIMARY KEY REFERENCES Subject(id),
description  VARCHAR(1024) NOT NULL
);

CREATE TABLE MotsCles (
idMotCle SERIAL PRIMARY KEY,
motCle VARCHAR(32) UNIQUE
);

CREATE TABLE CategorieDiscussion (
    idCategorie SERIAL PRIMARY KEY,
    nomCategorie   VARCHAR(32) NOT NULL
);

CREATE TABLE Discussion (
    idDiscussion SERIAL PRIMARY KEY,
    idCreateur INTEGER REFERENCES User(id),
    titreDiscussion VARCHAR(255) NOT NULL,
    description TEXT,
    idCategorie FOREIGN KEY REFERENCES CategorieDiscussion(idCategorie),
);


CREATE TABLE Publication (
    idPublication SERIAL PRIMARY KEY,
    auteur INTEGER REFERENCES User(id),
    -- discussion INTEGER REFERENCES Discussion(id),
    titre VARCHAR(100) NOT NULL,
    contenu TEXT NOT NULL,
    idSujet INTEGER REFERENCES Subject(id),
    -- idMotsCles INTEGER REFERENCES MotsCles(idMotCle),
    datePublication TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idPublicationParent  INTEGER REFERENCES Publication(idPublication) --NULL si publication premier niveau
    FOREIGN KEY (auteur) REFERENCES User(id) ON DELETE CASCADE
);

CREATE TABLE MotsClesPublication (
    idPubliMotCle SERIAL PRIMARY KEY,
    idPublication INTEGER REFERENCES Publication(idPublication),
    idMotCle INTEGER REFERENCES MotsCles(idMotCle),
);

CREATE TABLE EventParticulier(
   idEvent SERIAL PRIMARY KEY,
   dateEvent DATE NOT NULL,                   
   lieuEvent VARCHAR(255) NOT NULL,              
   nomEvent VARCHAR(255) NOT NULL,
   nbPlaceDispo INTEGER NOT NULL,     
   nbPlaceReserve INTEGER NOT NULL DEFAULT 0,
   idOrganisateur INTEGER REFERENCES User(id)
   idAuteur INTEGER REFERENCES User(id),
   liens_web TEXT[]
);

CREATE TABLE ParticipationEvent(
   idUser INTEGER REFERENCES User(id),     -- L'utilisateur s'inscrit à l'événement
   idEvent INTEGER REFERENCES EventParticulier(id), -- L'événement auquel il s'inscrit
   PRIMARY KEY(idUser, idEvent)
);


-- La vue "ParticipationEvent" affiche tous les inscrits à un événement donné.
CREATE VIEW ParticipationEvents AS 
SELECT P.* FROM Participant P INNER JOIN EventParticulier E on P.idEvent=E.idEvent;

ALTER TABLE ParticipationEvents ADD CONSTRAINT check_nbplace CHECK (nbPlaceDispo - nbPlaceReserve >=  0);

SELECT * FROM EventParticulier e INNER JOIN ParticipationEvents i ON e.id = i.idEvent WHERE i.idUser=?;


CREATE TABLE Archive (
    idArchive SERIAL PRIMARY KEY,
    dateArchivage DATE NOT NULL,
    raison VARCHAR(255) NOT NULL,
    publication INTEGER REFERENCES Publication(id)
);


CREATE TABLE Commentaire (
    idCommentaire SERIAL PRIMARY KEY,
    idPubli INTEGER REFERENCES Publication(publiId),
    auteur INTEGER REFERENCES User(id),
    contenu TEXT NOT NULL,
    dateCommentaire DATE NOT NULL
);

CREATE TYPE TypeReaction  as ENUM ('Like', 'Dislike', 'Neutre', 'Fun', 'Sad' ,'Angry');

CREATE TABLE Reaction(
    idReaction SERIAL PRIMARY KEY,
    idPubli INTEGER REFERENCES Publication(id),
    idUser INTEGER REFERENCES User(id),
    type TypeReaction,
    FOREIGN KEY (idUser, idPubli)  Publication(auteur, idPublication) ON DELETE CASCADE
);


-- message envoyé par un utilisateur à un autre.
CREATE TABLE Message (
    id SERIAL PRIMARY KEY,
    expéditeur INTEGER REFERENCES User(id),
    destinataire INTEGER REFERENCES User(id),
    contenu TEXT NOT NULL
);

CREATE TABLE Notification (
    id SERIAL PRIMARY KEY,
    notificationType NotificationType NOT NULL, -- Type de la notification : newFriendRequest, friendAccepted, friendShipRejected
    vue BOOLEAN DEFAULT FALSE, -- False signifie que la notification n'a pas été vu par l'utilisateur
    dateEnvoie DATE NOT NULL,
    publication VueSurPublication INTEGER, -- Si cette colonne est null c'est qu'il s'agit d'une notification de like ou de dislike sur une public
    expéditeur INTEGER REFERENCES User(id),
    destinataire INTEGER REFERENCES User(id),
    typeNotification ENUM('AjoutPublication','Suivi')
);

---------------------------------------------------------

