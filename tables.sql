CREATE DATABASE CineNet;
\c cineNet;

DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Role;
DROP TABLE IF EXISTS Publication;
DROP TABLE IF EXISTS Archive;
DROP TABLE IF EXISTS Film;
DROP TABLE IF EXISTS Serie;
DROP TABLE IF EXISTS EventParticulier;
--  Il sera possible à un utilisateur de suivre ou bien d’être ami avec une autre entité du réseau. Notez que la relation d’amitié est symétrique, mais qu’il est possible que A suive B sans que B suive A (sur le modèle du follows de Instagram)
DROP TABLE IF EXISTS Follow;
DROP TABLE IF EXISTS Friendship;
DROP TABLE IF EXISTS Sujet_publication;
DROP TABLE IF EXISTS Reaction;
DROP TABLE IF EXISTS Discussion;

CREATE TABLE User (
id serial PRIMARY KEY,
username  VARCHAR(50) NOT NULL UNIQUE,
password  VARCHAR(128) NOT NULL,
email     VARCHAR(75),
firstname VARCHAR(30),
lastname  VARCHAR(30)
);

CREATE TABLE Role (
roleId SERIAL PRIMARY KEY,
roleName VARCHAR(30) NOT NULL
);

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
genre       VARCHAR(32),
FOREIGN KEY (realisation) REFERENCES Realisation(annee)
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

CREATE TABLE Realisation (
annee INTEGER PRIMARY KEY
);


-- d’être ami avec une autre entité du réseau. Notez que la relation d’amitié est symétrique
CREATE TABLE Friendship  (
user1 INTEGER REFERENCES User(id),
user2 INTEGER REFERENCES User(id),
constraint pk_friendship primary key (user1, user2)
);


CREATE TABLE Follow (
userId INTEGER REFERENCES User(id),
folowerid  INTEGER REFERENCES User(id),
PRIMARY KEY (userId, folowerid),
CONSTRAINT follow_self CHECK (userId != folowerid)
);

CREATE  VIEW UtilisateursSuivis AS
SELECT DISTINCT u.* FROM User u INNER JOIN Follow f ON u.Id = f.folowerid WHERE f.userId = ?;


CREATE TABLE SujetPublication (
idSujet INTEGER PRIMARY KEY REFERENCES Subject(id),
description  VARCHAR(1024) NOT NULL
);

CREATE TABLE Tag (
idTag SERIAL PRIMARY KEY,
nom VARCHAR(32) UNIQUE
);


CREATE TABLE Discussion (
    id DISCUSSION SERIAL PRIMARY KEY,
    créateur INTEGER REFERENCES User(id),
    nom VARCHAR(255) NOT NULL,
    description TEXT
);


CREATE TABLE Publication (
    idPublication SERIAL PRIMARY KEY,
    discussion INTEGER REFERENCES Discussion(id),
    auteur INTEGER REFERENCES User(id),
    titre VARCHAR(100) NOT NULL,
    contenu TEXT NOT NULL,
    dSujet INTEGER REFERENCES Subject(id),
    idTag INTEGER REFERENCES Tag(id),
    datePublication IMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    visibilite INTEGER NOT NULL CHECK (visibilite BETWEEN  0 AND 2),
    FOREIGN KEY (auteur) REFERENCES User(id) ON DELETE CASCADE
);


CREATE TABLE EventParticulier(
   idEvent SERIAL PRIMARY KEY,
   eventDate DATE NOT NULL,                   
   eventlieu VARCHAR(255) NOT NULL,              
   eventNom VARCHAR(255) NOT NULL,
   nbPlaceDispo INTEGER NOT NULL,     
   nbPlaceReserve INTEGER NOT NULL DEFAULT 0,
   nbPlaceRestante INTEGER NOT NULL DEFAULT nbPlaceDispo,
   idOrganisateur INTEGER REFERENCES User(id)
   idAuteur INTEGER REFERENCES User(id)
);

CREATE  VIEW EvenementPublic AS
SELECT * FROM EventParticulier WHERE idAuteur IS NOT NULL;
ALTER TABLE EventParticulier ADD CONSTRAINT chk_eventpublic CHECK (nbPlaceDispo >= nbPlaceReserve);

-- Trigger pour mettre à jour la place restante lors de l'insertion ou modification d'un événement particulier
CREATE TABLE Inscription AS
SELECT * FROM EvenementPublic;
ALTER TABLE Inscription RENAME TO Participant;
ADD COLUMN idUser INTEGER REFERENCES User(id);

-- On ajoute une clé étrangère pour que l'on puisse associer un utilisateur à plusieurs événements.
ALTER TABLE Participant ADD COLUMN idEvent INTEGER REFERENCES EventParticulier(idEvent);

-- On crée la vue "MesEvents" qui affiche uniquement les événements organisés par l'utilisateur connecté.
CREATE OR REPLACE VIEW MesEvents AS SELECT * FROM Participant WHERE idEventAuteur = current_user;

-- La vue "Inscriptions" affiche tous les inscrits à un événement donné.
CREATE VIEW Inscriptions AS 
SELECT P.* FROM Participant P INNER JOIN EventParticulier E on P.idEvent=E.idEvent;



ALTER TABLE Inscription ADD CONSTRAINT check_nbplace CHECK (nbPlaceDispo - nbPlaceReserve >=  0);

SELECT * FROM EventParticulier e INNER JOIN Inscription i ON e.id = i.idEvent WHERE i.idUser=?;


CREATE TABLE Archive (
idArchive SERIAL PRIMARY KEY,
dateArchivage DATE NOT NULL,
raison VARCHAR(255) NOT NULL,
publication INTEGER REFERENCES Publication(id)
);


CREATE TABLE Commentaire (
    idCommentaire SERIAL PRIMARY KEY,
    publicationid INTEGER REFERENCES Publication(publiId),
    auteur INTEGER REFERENCES User(id),
    contenu TEXT NOT NULL,
    dateCommentaire DATE NOT NULL
);

CREATE TABLE Reaction(
idReaction SERIAL PRIMARY KEY,
publication INTEGER REFERENCES Publication(id),
utilisateur INTEGER REFERENCES User(id),
type CHAR(1) CHECK (type in ('J', 'D')), -- J pour J'aime / D pour J'dislike
FOREIGN KEY (utilisateur, publication) REFERENCES User(id, idPublication)
);

-- typeReacti  is an ENUM of ('Like', 'Dislike');

-- La table Message correspond à un message envoyé par un utilisateur à un autre utilisateur.
CREATE TABLE Message (
    id SERIAL PRIMARY KEY,
    expéditeur INTEGER REFERENCES User(id),
    destinataire INTEGER REFERENCES User(id),
    contenu TEXT NOT NULL
);

CREATE TABLE  Notification (
    id SERIAL PRIMARY KEY,
    notificationType NotificationType NOT NULL, -- Type de la notification : newFriendRequest, friendAccepted, friendShipRejected
    vue BOOLEAN DEFAULT FALSE, -- False signifie que la notification n'a pas été vu par l'utilisateur
                                -- True signifie que la notification a déjà été vue par l'utilisateur
    dateEnvoie DATE NOT NULL,
    publication VueSurPublication INTEGER, -- Si cette colonne est null c'est qu'il s'agit d'une notification de like ou de dislike sur une public
    expéditeur INTEGER REFERENCES User(id),
    destinataire INTEGER REFERENCES User(id),
    typeNotification ENUM('AjoutPublication','Suivi')
);


CREATE TABLE  LikeShare (
idlIKESHARING SERIAL PRIMARY KEY,
user_id INTEGER REFERENCES User(id),
date DATETIME NOT NULL,
typeReacti typeReacti NOT NULL,
publication_id INTEGER REFERENCES Publication(id)
);



---------------------------------------------------------



-- status ENUM('pending', 'accepted','refused')
--     -- pending: the user1 has sent a request to user2 and is waiting for an answer.
--     -- accepted : user1 has asked user2 and user2 has answered by accepting.
--     -- refused : user1 has asked user2 and user2 has answered by refusing.
-- );
