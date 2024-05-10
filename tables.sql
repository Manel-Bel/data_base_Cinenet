-- CREATE DATABASE CineNet;
\c cinenet;

-- DROP TABLE IF EXISTS Role;
DROP TABLE IF EXISTS Amis;
DROP TABLE IF EXISTS Follower;
DROP TABLE IF EXISTS Archive;
DROP TABLE IF EXISTS Film;
DROP TABLE IF EXISTS Serie;
DROP TABLE IF EXISTS Reaction;
DROP TABLE IF EXISTS GenreCinemato;
DROP TABLE IF EXISTS MotsClesPublication;
DROP TABLE if EXISTS MotsCles;
DROP TABLE IF EXISTS ParticipationEvent;
DROP TABLE IF EXISTS InteresseEvent;
DROP TABLE IF EXISTS HistoriquePublication;
DROP TABLE IF EXISTS HistoriqueReaction;
DROP TABLE IF EXISTS EventParticulier;
DROP TABLE IF EXISTS Publication;
DROP TABLE IF EXISTS SujetPublication;
DROP TABLE IF EXISTS Discussion;
DROP TABLE IF EXISTS CategorieDiscussion;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS Users;

DROP TYPE IF EXISTS TypeRole CASCADE;
DROP TYPE IF EXISTS TypeReaction CASCADE;



--  _id INTEGER REFERENCES Role(id) ON DELETE SET NULL/enuuuum c'est comme on veut 

CREATE TYPE TypeRole as ENUM ('lamda', 'Realisateur', 'acteur', 'organisateurSalle', 'Cinema' ,'Club');

CREATE TABLE Users(
    id serial PRIMARY KEY,
    username  VARCHAR(50) NOT NULL UNIQUE,
    password  VARCHAR(128) NOT NULL,
    email  VARCHAR(75),
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

-- CREATE VIEW UtilisateursSuivis AS
-- SELECT DISTINCT u.* FROM Users u INNER JOIN Follower f ON u.id = f.folowerid;


-- One publication can be linked to one or several films.
-- CREATE TABLE Filme_Publication (
-- filmPubliId SERIAL PRIMARY KEY,
-- filmId INTEGER REFERENCES Film(id),
-- publiId INTEGER REFERENCES Publication(publiId)
-- );

-- ALTER TABLE Filme_Publication ADD CONSTRAINT film_publi_unique UNIQUE (filmId, publiId);

CREATE TABLE GenreCinemato(
    id SERIAL PRIMARY KEY,
    nom  VARCHAR(32) NOT NULL,
    parentId INTEGER REFERENCES GenreCinemato(id)
);

CREATE TABLE Film(
    id          SERIAL PRIMARY KEY,
    titre       VARCHAR(64) NOT NULL,
    resume      TEXT,
    realisation DATE,
    duree       INTEGER, -- en minutes
    genre       VARCHAR(32)
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

-- ALTER TABLE Serie ADD CONSTRAINT unique_serie UNIQUE (numero, saison);



CREATE TABLE SujetPublication(
    id INTEGER PRIMARY KEY,
    description  VARCHAR(1024) NOT NULL
);

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


CREATE TABLE Publication( --peut etre table publication sujet publication
    id INTEGER PRIMARY KEY,
    auteur INTEGER REFERENCES Users(id),
    discussionId INTEGER REFERENCES Discussion(id),
    titre VARCHAR(200) NOT NULL,
    contenu TEXT NOT NULL,
    sujetId INTEGER REFERENCES SujetPublication(id),
    --pourquoi avec cle et non pas table 

    -- motsCles INTEGER REFERENCES MotsCles(motCleId),
    --datePublication TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
    FOREIGN KEY (idPubli) REFERENCES Publication(id) ON DELETE CASCADE
);

CREATE TABLE EventParticulier( -- pourquoi auteur + organisateur 
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

CREATE TABLE ParticipationEvent(-- assurer l'exclusion avec  interesser
   userId INTEGER REFERENCES Users(id),     -- L'utilisateur s'inscrit à l'événement
   eventId INTEGER REFERENCES EventParticulier(id), -- L'événement auquel il s'inscrit
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


CREATE TABLE Archive( -- pourquoi relation vers publication et non pas evenement particulié
    idArchive SERIAL PRIMARY KEY,
    dateArchivage DATE NOT NULL,
    raison VARCHAR(255) NOT NULL,
    idEvent INTEGER REFERENCES Publication(id)  
);


-- CREATE TABLE Commentaire (
--     idCommentaire SERIAL PRIMARY KEY,
--     idPubli INTEGER REFERENCES Publication(publiId),
--     auteur INTEGER REFERENCES User(id),
--     contenu TEXT NOT NULL,
--     dateCommentaire DATE NOT NULL
-- );



-- message envoyé par un utilisateur à un autre.
CREATE TABLE Message (
    id SERIAL PRIMARY KEY,
    expéditeur INTEGER REFERENCES Users(id),
    destinataire INTEGER REFERENCES Users(id),
    contenu TEXT NOT NULL
);

-- CREATE TABLE Notification (
--     id SERIAL PRIMARY KEY,
--     notificationType NotificationType NOT NULL, -- Type de la notification : newFriendRequest, friendAccepted, friendShipRejected
--     vue BOOLEAN DEFAULT FALSE, -- False signifie que la notification n'a pas été vu par l'utilisateur
--     dateEnvoie DATE NOT NULL,
--     publication VueSurPublication INTEGER, -- Si cette colonne est null c'est qu'il s'agit d'une notification de like ou de dislike sur une public
--     expéditeur INTEGER REFERENCES User(id),
--     destinataire INTEGER REFERENCES User(id),
--     typeNotification ENUM('AjoutPublication','Suivi')
-- );


CREATE TABLE HistoriquePublication(
    idUser  INTEGER REFERENCES Users(id),
    idPubli INTEGER,
    action VARCHAR(255), --  ou ajouter ou voir ou repondre à une publication
    dateAction DATE NOT NULL,
    PRIMARY KEY (idUser, idPubli, dateAction),
    FOREIGN KEY (idUser) REFERENCES Users(id) ON UPDATE CASCADE,
    FOREIGN KEY (idPubli) REFERENCES Publication(id) ON DELETE CASCADE
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


-- Peuplement de la base de données à partir des fichiers CSV --
\copy GenreCinemato(id, nom, parentId) FROM 'CSV/genre_cinemato.csv' WITH (FORMAT csv, HEADER true);
\copy Users(username, password, email, role) FROM 'CSV/Utilisateurs.csv' WITH (FORMAT csv, HEADER true);
\copy Amis(user1, user2) FROM 'CSV/amis.csv' WITH (FORMAT csv, HEADER true);
\copy Follower(id, folower) FROM 'CSV/follow.csv' WITH (FORMAT csv, HEADER true);
\copy Film(id, titre, resume, realisation, duree, genre) FROM 'CSV/films.csv' WITH (FORMAT csv, HEADER true);
\copy Serie(id, saison, titre, nbreEpisodes, dureeParEpisode, datePremiere, genre) FROM 'CSV/series.csv' WITH (FORMAT csv, HEADER true);
\copy MotsCles(motCleId, motCle) FROM 'CSV/mots_cles.csv' WITH (FORMAT csv, HEADER true);
\copy CategorieDiscussion(id, nomCategorie) FROM 'CSV/categorie_discussion.csv' WITH (FORMAT csv, HEADER true);
\copy SujetPublication(id, description) FROM 'CSV/sujet_publication.csv' WITH (FORMAT csv, HEADER true);

\copy EventParticulier(id, auteur, nomEvent, dateEvent, lieuEvent, nbPlaceDispo, nbPlaceReserve, organisateur, liens_web) FROM 'CSV/EventParticulier.csv' WITH (FORMAT csv, HEADER true);
\copy InteresseEvent(userId, eventId) FROM 'CSV/InteresseEvent.csv' WITH (FORMAT csv, HEADER true);
\copy ParticipationEvent(userId, eventId) FROM 'CSV/participation_event.csv' WITH (FORMAT csv, HEADER true);
\copy Discussion(id, auteur, titre, description, categorie) FROM 'CSV/discussions.csv' WITH (FORMAT csv, HEADER true);
\copy Publication(id, auteur, discussionId, titre, contenu, sujetId, parentId) FROM 'CSV/publications.csv' WITH (FORMAT csv, HEADER true);
\copy MotsClesPublication(publiId, motCleId) FROM 'CSV/mots_cles_publication.csv' WITH (FORMAT csv, HEADER true);

\copy Reaction(idPubli, idUser, type) FROM 'CSV/reactions.csv' WITH (FORMAT csv, HEADER true);
\copy Archive(idArchive, dateArchivage, raison, idEvent) FROM 'CSV/archive.csv' WITH (FORMAT csv, HEADER true);
\copy Message(id, expéditeur, destinataire, contenu) FROM 'CSV/message.csv' WITH (FORMAT csv, HEADER true);
--\copy Commentaire(idCommentaire, idPubli, auteur, contenu, dateCommentaire) FROM 'CSV/commentaire.csv' WITH (FORMAT csv, HEADER true);
--\copy Notification(id, notificationType, vue, dateEnvoie, publication, expéditeur, destinataire) FROM 'CSV/notification.csv' WITH (FORMAT csv, HEADER true);
\copy HistoriquePublication(idUser, idPubli, action, dateAction) FROM 'CSV/historique_publication.csv' WITH (FORMAT csv, HEADER true);


-- Assurez-vous que les noms de fichier et les chemins correspondent à ceux de votre système de fichiers.

---------------------------------------------------------

