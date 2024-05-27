-- rechercher un event à venir par lieu et  date 

PREPARE recherche_par_lieu_et_date(VARCHAR, DATE, DATE) AS
SELECT nomEvent, organisateur, dateEvent, lieuEvent
FROM EventParticulier
WHERE LOWER(lieuEvent) LIKE LOWER('%' || $1 || '%')
    OR dateEvent BETWEEN $2 AND $3
AND dateEvent >= CURRENT_DATE;


-- --------------------------------------------------------------
-- recherche de tous les events auxquels un user participe 
PREPARE recherche_participation_event_user(INTEGER) AS
SELECT nomEvent, dateEvent, lieuEvent
FROM EventParticulier e 
JOIN ParticipationEvent p ON e.id = p.eventId
WHERE p.userId = $1;


-- -----------------------------------------------------
-- recherche des event d'un organisateur spécifique
PREPARE recherche_events_organisateur(INTEGER) AS
SELECT nomEvent, dateEvent, lieuEvent
FROM EventParticulier e
WHERE organisateur = $1;


-- -------------------------------------------------------------
-- recherche publication par motClé 
PREPARE recherche_publication_motcle(INTEGER) AS
SELECT id as id_publication , auteur, datePublication, contenu 
FROM Publication p 
WHERE id IN 
(SELECT publiId 
FROM MotsClesPublication WHERE motCleId = $1);


-- --------------------------------------------------
-- rechercher les events passés 
PREPARE recherche_events_passes AS
SELECT * FROM EventParticulier
WHERE dateEvent < CURRENT_DATE;


-- -----------------------------------------------------------
-- rechercher les events à venir 
PREPARE recherche_events_avenir AS
SELECT *
FROM EventParticulier
WHERE dateEvent >= CURRENT_DATE;
-- ---> execution
EXECUTE recherche_events_avenir;

-- ------------------------------------------------------
-- recherche des events à venir où l'user est intéressé 
PREPARE recherche_events_avenir_interesse(INTEGER) AS
SELECT * FROM EventParticulier e 
WHERE e.id IN
    (SELECT eventid 
    FROM InteresseEvent ie 
    WHERE userId = $1)
    AND e.dateEvent >= CURRENT_DATE
;


-- -----------------------------------------------------
-- recherche des events auxquels participent les amis d'un user
PREPARE recherche_events_ami(INTEGER) AS
SELECT e.*
FROM EventParticulier e
WHERE e.id IN (
    SELECT eventId 
    FROM ParticipationEvent pe 
    WHERE userId IN (
        SELECT user2
        FROM Amis a
        WHERE user1 = $1
        UNION
        SELECT user1
        FROM Amis a
        WHERE user2 = $1
        )
    )
;
