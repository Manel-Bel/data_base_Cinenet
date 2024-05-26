-- une requête qui porte sur au moins trois tables
-- quels sont tous les amis du realisateur "paul06" qui suivent le STUDIO MAPPA
SELECT u.id, u.username
FROM Users u 
WHERE u.id IN (
    SELECT a.user2
    FROM Amis a
    WHERE a.user2 = 
        (SELECT DISTINCT id FROM Users WHERE username = 'paul06' AND role = 'Realisateur')
    )
    AND u.id IN (
        SELECT folower 
        FROM Follower
        WHERE id = 
            ( SELECT id 
            FROM Users
            WHERE username = 'Mappa' AND role = 'Studio')
            )
;


-- auto jointure pour recuperer les sous genre du genre action dont l'id est 1 :)))
select G2.id, G2.nom from GenreCinemato G1 inner join GenreCinemato G2 on G1.id = G2.parentId where G1.id = 1 ;


-- — une sous-requête corrélée
-- la liste des utilisateurs ayant participé à tous les evemements organisé par 'japan expo'
SELECT u.id, u.username
FROM Users u
WHERE NOT EXISTS
    ( SELECT * 
    FROM EventParticulier e 
    WHERE e.organisateur = 
        ( SELECT id 
        FROM Users
        WHERE username = 'Japan Expo')
        AND NOT EXISTS 
        ( SELECT *
        FROM ParticipationEvent pe 
        WHERE pe.eventId = e.id 
        AND pe.userId = u.id
        )
    )
;


-- sous requete dans le from 
SELECT u.username, p.titre
FROM (
    SELECT id, username
    FROM Users
    WHERE username LIKE 'j%'
) AS u
INNER JOIN Publication p ON p.auteur = u.id;


-- une sous-requête dans le WHERE ; 
-- quels sont les films de genre 'Horror' et leurs sous genre ?
-- à CHANGER 
SELECT f.id, f.titre
FROM Film f JOIN FilmGenre fg  ON f.id = fg.filmId
JOIN GenreCinemato g ON fg.genreId = g.id
WHERE g.name = 'Horror' OR 
    g.parent = (
        SELECT id FROM GenreCinemato WHERE name = 'Horror'
        )
GROUP BY f.id
ORDER BY f.titre ;




--Compter le nombre de publications par utilisateur, mais seulement pour ceux ayant plus de 5 publications
SELECT auteur, COUNT(*) AS nombre_publications
FROM Publication
GROUP BY auteur
HAVING COUNT(*) > 5;


-- Calculer le nombre moyen d'épisodes par série pour chaque genre, en incluant seulement les genres avec plus de 2 séries
SELECT g.nom, AVG(s.nbreEpisodes) AS moyenne_episodes
FROM Serie s
JOIN GenreCinemato g ON s.genre = g.id
GROUP BY g.nom
HAVING COUNT(s.id) > 2;


--Compter le nombre de réactions de chaque type pour les publications ayant reçu plus de 10 réactions en total

SELECT idPubli, type, COUNT(*) AS nombre_reactions
FROM Reaction
GROUP BY idPubli, type
HAVING COUNT(*) > 10;


-- Identifier les événements avec un nombre de places disponibles inférieur à 10% du total initial
SELECT id, nomEvent, (nbPlaceDispo - nbPlaceReserve) AS places_restantes
FROM EventParticulier
GROUP BY id
HAVING (nbPlaceDispo - nbPlaceReserve) < (0.1 * nbPlaceDispo);


--  une requête impliquant le calcul de deux agrégats
-- quel est la moyenne du nombre maximun de participant à un evenement pour chaque année
SELECT year, ROUND(AVG(max_participants), 2) as moyenne_max_participants
FROM(
    SELECT EXTRACT(MONTH FROM e.dateEvent) as mois, EXTRACT(YEAR FROM e.dateEvent) as year, max(pa.userId) as max_participants
    FROM EventParticulier e JOIN ParticipationEvent pa
    ON e.id = pa.eventId
    GROUP BY mois, year
    )
AS max_participants_par_mois_year
GROUP BY year
ORDER BY year DESC
;



--Utilisation d'un RIGHT JOIN pour trouver tous les films et leur genre, même ceux sans genre spécifié
SELECT f.titre, g.nom
FROM GenreCinemato g
RIGHT JOIN Film f ON f.genre = g.nom
ORDER BY f.titre;


--Utilisation d'un FULL JOIN pour afficher tous les utilisateurs et tous les événements, montrant les correspondances et les non-correspondances
SELECT u.username, e.nomEvent
FROM Users u
FULL JOIN ParticipationEvent pe ON u.id = pe.userId
FULL JOIN EventParticulier e ON pe.eventId = e.id
ORDER BY u.username, e.nomEvent;


--Utilisation d'un LEFT JOIN pour lister tous les événements et leur nombre de participants, y compris ceux sans participants

SELECT e.nomEvent, COUNT(pe.userId) AS nombre_participants
FROM EventParticulier e
LEFT JOIN ParticipationEvent pe ON e.id = pe.eventId
GROUP BY e.nomEvent
ORDER BY nombre_participants;


-- — deux requêtes équivalentes exprimant une condition de totalité, l’une avec des sous requêtes corrélées et l’autre avec de l’agrégation

-- Quels sont les utilisateurs ayant participé UNIQUEMENT à tous les événements organisés par un studio HBO et ne pas avoir participé au évènement de studio adverse NETFLIX ?
SELECT u.id, u.username
FROM Users u
WHERE NOT EXISTS (
    SELECT *
    FROM ParticipationEvent pe_hbo
    JOIN EventParticulier e_hbo ON pe_hbo.eventId = e_hbo.id
    WHERE pe_hbo.userId = u.id
    AND e_hbo.organisateur = 'HBO'
)
AND NOT EXISTS (
    SELECT *
    FROM EventParticulier e_netflix
    WHERE e_netflix.organisateur = 'Netflix'
    AND NOT EXISTS (
        SELECT *
        FROM ParticipationEvent pe_netflix
        WHERE pe_netflix.id = u.id
        AND pe_netflix.eventId = e_netflix.id
    )
);


SELECT u.id, u.username
FROM Users u
JOIN ParticipationEvent pe_netflix ON u.id = pe_netflix.id
JOIN EventParticulier e_netflix ON pe_netflix.eventId = e_netflix.eventId
WHERE e_netflix.organisateur = 'Netflix'
GROUP BY u.id, u.username
HAVING COUNT(pe_netflix.eventId) = (
    SELECT COUNT(e_netflix_inner.eventId)
    FROM EventParticulier e_netflix_inner
    WHERE e_netflix_inner.nom = 'Netflix'
)
AND u.id NOT IN (
    SELECT pe_hbo.id
    FROM ParticipationEvent pe_hbo
    JOIN EventParticulier e_hbo ON pe_hbo.id_evenement = e_hbo.id_evenement
    WHERE s_hbo.organisateur = 'HBO'
);




--requete equivantes mais qui retourne de resultat deffirents a cause de valeur null :

-- Q1: Recherche d'événements avec le plus grand nombre de places disponibles sans aucun autre événement ayant plus de places, triés par nom d'événement.
SELECT nomEvent
FROM EventParticulier AS E1
WHERE NOT EXISTS (
    SELECT 1
    FROM EventParticulier AS E2
    WHERE E2.nbPlaceDispo > E1.nbPlaceDispo
)
ORDER BY nomEvent DESC;

-- Q2: Recherche directe des événements avec le nombre maximum de places disponibles, triés par nom d'événement.
SELECT nomEvent
FROM EventParticulier
WHERE nbPlaceDispo = (
    SELECT MAX(nbPlaceDispo)
    FROM EventParticulier
)
ORDER BY nomEvent DESC;

--sur des donnee sans null 

SELECT nomEvent
FROM EventParticulierNonNull AS E1
WHERE NOT EXISTS (
    SELECT 1
    FROM EventParticulier AS E2
    WHERE E2.nbPlaceDispo > E1.nbPlaceDispo
)
ORDER BY nomEvent DESC;

SELECT nomEvent
FROM EventParticulierNonNull
WHERE nbPlaceDispo = (
    SELECT MAX(nbPlaceDispo)
    FROM EventParticulier
)
ORDER BY nomEvent DESC;

--correction de ses requetes avec utilisations de COALESCE

SELECT nomEvent
FROM EventParticulier AS E1
WHERE NOT EXISTS (
    SELECT 1
    FROM EventParticulier AS E2
    WHERE COALESCE(E2.nbPlaceDispo, 0) > COALESCE(E1.nbPlaceDispo, 0)
)
ORDER BY nomEvent DESC;

SELECT nomEvent
FROM EventParticulier
WHERE COALESCE(nbPlaceDispo, 0) = (
    SELECT COALESCE(MAX(nbPlaceDispo), 0)
    FROM EventParticulier
)
ORDER BY nomEvent DESC;




-- Une requête récursive;
-- niveau de chaque publication sur le forum
WITH RECURSIVE publicationNiveau AS 
    (SELECT id as id_publication , auteur, titre, parentId,
        0 AS niveau 
    FROM  Publication
    WHERE parentId IS NULL

    UNION ALL
    -- Recursive case: 
    SELECT  p.id AS id_publication, p.auteur, p.titre, p.parentId,
        pn.niveau + 1 AS niveau
    FROM Publication p
    JOIN publicationNiveau pn 
    ON p.parentId = pn.id_publication
)

SELECT id_publication, auteur, titre, parentId, niveau
FROM  publicationNiveau
ORDER BY  niveau, id_publication;

-- calcule de la profondeur d'un publication  (exemple publication 1)
WITH RECURSIVE publicationDepth AS(   
    SELECT id as id_publication,parentId, 0 AS profondeur
    FROM  Publication
    WHERE id = 1
    UNION ALL

    SELECT p.id AS id_publication, p.parentId, d.profondeur + 1 as profondeur
    FROM Publication p
    JOIN publicationDepth d ON p.parentId = d.id_publication 
)
, MaxProfondeur AS (
    SELECT id_publication, MAX(profondeur) AS hauteur
    FROM publicationDepth
    GROUP BY id_publication
)
SELECT p.id AS id_publication, p.auteur, p.titre, p.parentId, COALESCE(mp.hauteur, 0)
FROM publication p 
JOIN MaxProfondeur mp ON p.id = mp.id_publication
WHERE p.id= 1
;

-- chaine d'amitié de user 1 à revoir 
WITH RECURSIVE chaineAmitie AS(
    SELECT user1 as id_user, user2 as ami, 1 AS niveau
    FROM Amis
    WHERE user1 = 1
    UNION
    SELECT a.user1 as id_user, a.user2 as ami, ca.niveau + 1 as niveau
    FROM Amis a 
    JOIN chaineAmitie as ca 
    ON a.user1 = ca.ami 
    )
SELECT DISTINCT
ca.ami,
u.username,
ca.niveau
FROM  ChaineAmitie ca
JOIN  Users u ON ca.ami = u.id
ORDER BY ca.niveau, ca.ami;





--Requete avec fenetrage 
--La requête vise à identifier les 10 événements les plus populaires, organisés par des utilisateurs ayant le rôle 'acteur'
--, pour chaque mois de l'année 2025. La popularité est déterminée par le nombre de participants à chaque événement.

WITH MonthlyEventOrganizers AS (
    SELECT
        E.id AS EventID,
        E.organisateur AS OrganizerID,
        U.username AS OrganizerName,
        EXTRACT(MONTH FROM E.dateEvent) AS EventMonth,
        EXTRACT(YEAR FROM E.dateEvent) AS EventYear,
        COUNT(P.userId) AS TotalParticipants,
        RANK() OVER (PARTITION BY EXTRACT(MONTH FROM E.dateEvent) ORDER BY COUNT(P.userId) DESC) AS Rank

    FROM EventParticulier E

    INNER JOIN Users U ON E.organisateur = U.id

    INNER JOIN ParticipationEvent P ON E.id = P.eventId
    WHERE U.role = 'acteur' AND EXTRACT(YEAR FROM E.dateEvent) = 2025
    GROUP BY
        E.id, E.organisateur, U.username, EXTRACT(MONTH FROM E.dateEvent), EXTRACT(YEAR FROM E.dateEvent)
)
SELECT
    EventID,
    OrganizerID,
    OrganizerName,
    EventMonth,
    EventYear,
    TotalParticipants,
    Rank

FROM MonthlyEventOrganizers
WHERE Rank <= 10
ORDER BY EventMonth, Rank;

