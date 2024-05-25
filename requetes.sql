-- auto jointure pour recuperrer les sous genre du genre action dont l'id est 1 :)))
select G2.id, G2.nom from GenreCinemato G1 inner join GenreCinemato G2 on G1.id = G2.parentId where G1.id = 1 ;

-- sous requete dans le from 
SELECT u.username, p.titre
FROM (
    SELECT id, username
    FROM Users
    WHERE username LIKE 'j%'
) AS u
INNER JOIN Publication p ON p.auteur = u.id;

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


-- Utilisation d'un FULL JOIN pour afficher tous les sujets de publication et toutes les discussions, indépendamment de s'ils sont liés ou non

-- SELECT sp.description AS sujet_description, d.titre AS discussion_titre
-- FROM SujetPublication sp
-- FULL JOIN Publication p ON sp.id = p.sujetId
-- FULL JOIN Discussion d ON p.discussionId = d.id
-- ORDER BY sp.description, d.titre;


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
    FROM
        EventParticulier E
    INNER JOIN
        Users U ON E.organisateur = U.id
    INNER JOIN
        ParticipationEvent P ON E.id = P.eventId
    WHERE
        U.role = 'acteur' AND EXTRACT(YEAR FROM E.dateEvent) = 2025
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
FROM
    MonthlyEventOrganizers
WHERE
    Rank <= 10
ORDER BY
    EventMonth, Rank;

-- Algorithme de recommendation

-- 1 Calculer le Nombre de Réactions Positives par Publication
WITH PositiveReactions AS (
    SELECT
        R.idPubli,
        COUNT(*) AS TotalPositiveReactions
    FROM
        Reaction R
    WHERE
        R.type IN ('Like', 'Fun', 'Love') -- Réactions considérées comme positives
        AND NOT EXISTS (
            SELECT 1
            FROM HistoriquePublication HP
            WHERE HP.idPubli = R.idPubli AND HP.idUser = [CurrentUserId] -- Remplacez par l'ID de l'utilisateur actuel
        )
    GROUP BY
        R.idPubli
)

-- 2 publication qui a le nbplacereservé le plus haut ( interessé et participer )
WITH EventInterestParticipation AS (
    SELECT
        PEP.publiId,
        COALESCE(COUNT(DISTINCT IE.userId), 0) + COALESCE(COUNT(DISTINCT PE.userId), 0) AS TotalInterestParticipation
    FROM
        PublicationEventPart PEP
    LEFT JOIN
        EventParticulier E ON PEP.eventId = E.id
    LEFT JOIN
        InteresseEvent IE ON E.id = IE.eventId
    LEFT JOIN
        ParticipationEvent PE ON E.id = PE.eventId
    GROUP BY
        PEP.publiId
)



-- 3 Troisieme indice :

-- Étape 1 : Filtrer l'historique des publications de l'utilisateur
WITH UserHistory AS (
    SELECT
        HP.idPubli
    FROM
        HistoriquePublication HP
    WHERE
        HP.idUser = [CurrentUserId] -- Remplacez par l'ID de l'utilisateur actuel
),

-- Étape 2 : Filtrer les publications avec des bonnes réactions
UserLikedPublications AS (
    SELECT
        R.idPubli
    FROM
        Reaction R
    WHERE
        R.idUser = [CurrentUserId] -- ID de l'utilisateur actuel
        AND R.type IN ('Like', 'Fun')
        AND EXISTS (
            SELECT 1
            FROM UserHistory UH
            WHERE UH.idPubli = R.idPubli
        )
),

-- Étape 3 : Trouver les films et séries associés à ces publications
UserLikedFilmsSeries AS (
    SELECT
        PF.FilmId AS ItemId, 'Film' AS ItemType
    FROM
        PublicationFilm PF
    WHERE
        PF.publiId IN (SELECT idPubli FROM UserLikedPublications)
    UNION
    SELECT
        PS.SerieId AS ItemId, 'Serie' AS ItemType
    FROM
        PublicationSerie PS
    WHERE
        PS.publiId IN (SELECT idPubli FROM UserLikedPublications)
),

-- Étape 4 : Identifier les genres des films et séries
UserLikedGenres AS (
    SELECT
        G.nom AS GenreName
    FROM
        UserLikedFilmsSeries ULFS
    JOIN
        Film F ON ULFS.ItemId = F.id AND ULFS.ItemType = 'Film'
    JOIN
        GenreCinemato G ON F.genre = G.id
    UNION
    SELECT
        G.nom AS GenreName
    FROM
        UserLikedFilmsSeries ULFS
    JOIN
        Serie S ON ULFS.ItemId = S.id AND ULFS.ItemType = 'Serie'
    JOIN
        GenreCinemato G ON S.genre = G.id
),

-- Étape 5 : Proposer des publications de films et séries du même genre
RecommendedPublications AS (
    SELECT
        P.id AS PublicationID,
        P.titre AS PublicationTitle,
        G.nom AS GenreName
    FROM
        Publication P
    LEFT JOIN
        PublicationFilm PF ON P.id = PF.publiId
    LEFT JOIN
        Film F ON PF.FilmId = F.id
    LEFT JOIN
        PublicationSerie PS ON P.id = PS.publiId
    LEFT JOIN
        Serie S ON PS.SerieId = S.id
    LEFT JOIN
        GenreCinemato G ON (F.genre = G.id OR S.genre = G.id)
    WHERE
        G.nom IN (SELECT GenreName FROM UserLikedGenres)
        AND NOT EXISTS (
            SELECT 1
            FROM HistoriquePublication HP
            WHERE HP.idPubli = P.id AND HP.idUser = [CurrentUserId]
        )
)
--juste un plus pour ce troisieme indice 
SELECT
    PublicationID,
    PublicationTitle,
    GenreName
FROM
    RecommendedPublications
ORDER BY
    GenreName, PublicationTitle
LIMIT 10;


-- Combinaison des indices
SELECT
    P.id AS PublicationID,
    P.titre AS PublicationTitle,
    COALESCE(PR.TotalPositiveReactions, 0) AS PositiveReactions,
    COALESCE(EIP.TotalInterestParticipation, 0) AS InterestParticipation,
    COALESCE(
        (SELECT COUNT(*) FROM RecommendedPublications RP WHERE RP.PublicationID = P.id),
        0
    ) AS GenreRecommendation,
    (COALESCE(PR.TotalPositiveReactions, 0) * 0.4 + COALESCE(EIP.TotalInterestParticipation, 0) * 0.3 + COALESCE(
        (SELECT COUNT(*) FROM RecommendedPublications RP WHERE RP.PublicationID = P.id),
        0
    ) * 0.3) AS RecommendationScore
FROM
    Publication P
LEFT JOIN
    PositiveReactions PR ON P.id = PR.idPubli
LEFT JOIN
    EventInterestParticipation EIP ON P.id = EIP.publiId
ORDER BY
    RecommendationScore DESC
LIMIT 10;

