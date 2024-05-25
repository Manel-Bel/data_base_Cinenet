-- une requête qui porte sur au moins trois tables
-- quels sont tous les amis du realisateur "Cedric" qui suivent le STUDIO MAPPA
SELECT u.id, u.username
FROM Users u 
WHERE u.id IN (
    SELECT a.user2
    FROM Amis a
    WHERE a.user2 = 
        (SELECT DISTINCT id FROM Users WHERE username = 'Cedric' AND role = 'Realisateur')
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


-- une sous-requête dans le WHERE ; 
-- quels sont les films de genre 'Horror' et leurs sous genre ?
-- à CHANGER 
SELECT f.id, f.titre, f.resume, g.genre
FROM Films f JOIN GenreCinemato g 
ON f.genre = g.id
WHERE g.nom = 'Horror' OR 
g.parentId = (
    SELECT id FROM GenreCinemato WHERE nom = 'Horror'
    )
ORDER BY f.titre ;
-- probleme de genre 



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





-- Une requête récursive;
-- profondeur de chaque publication sur le forum
WITH RECURSIVE publicationDepth AS 
    (SELECT id as id_publication , auteur, titre, parentId,
        0 AS profondeur 
    FROM  Publication
    WHERE parentId IS NULL

    UNION ALL
    -- Recursive case: 
    SELECT  p.id AS id_publication, p.auteur, p.titre, p.parentId,
        pd.profondeur + 1 AS profondeur
    FROM Publication p
    JOIN publicationDepth pd 
    ON p.parentId = pd.id_publication
)

SELECT id_publication, auteur, titre, parentId, profondeur
FROM  publicationDepth
ORDER BY  profondeur, id_publication;

-- Ajout du deuxieme profondeur ou le truc d'amies


