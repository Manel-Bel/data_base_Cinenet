-- Algorithme de recommendation

-- 1 Calculer le Nombre de Réactions Positives par Publication
WITH PositiveReactions AS (
    SELECT R.publiId,
        COUNT(*) AS nb_positive_reaction
    FROM Reaction R
    WHERE R.type IN ('Like', 'Fun', 'Love')
    AND NOT EXISTS (
        SELECT 1
        FROM HistoriquePublication hp
        WHERE hp.publiId = R.publiId AND hp.idUser = [CurrentUserId] 
        -- a remplacer 
        )
    GROUP BY R.publiId
);

-- 2 le max de personnes ( interessé et qui participe )
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
    GROUP BY PEP.publiId
);


-- 3 Troisieme indice :

-- Étape 1 : Filtrer l'historique des publications de l'utilisateur
WITH UserHistory AS (
    SELECT hp.publiId
    FROM HistoriquePublication hp
    WHERE
        hp.userId = [CurrentUserId] -- Remplacez par l'ID de l'utilisateur actuel
),


-- Étape 2 : Filtrer les publications avec des bonnes réactions
UserLikedPublications AS (
    SELECT
        R.publiId
    FROM
        Reaction R
    WHERE
        R.userId = [CurrentUserId] -- ID de l'utilisateur actuel
        AND R.type IN ('Like', 'Fun', 'Love')
        AND EXISTS (
            SELECT 1
            FROM UserHistory UH
            WHERE UH.publiId = R.publiId
        )
),

-- Étape 3 : Trouver les films et séries associés à ces publications
UserLikedFilmsSeries AS (
    SELECT
        PF.FilmId AS ItemId, 'Film' AS ItemType
    FROM
        PublicationFilm PF
    WHERE
        PF.publiId IN (SELECT publiId FROM UserLikedPublications)
    UNION
    SELECT
        PS.SerieId AS ItemId, 'Serie' AS ItemType
    FROM
        PublicationSerie PS
    WHERE
        PS.publiId IN (SELECT publiId FROM UserLikedPublications)
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

