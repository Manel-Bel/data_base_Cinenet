-- Algorithme de recommendation

-- 1 Calculer le Nombre de Réactions Positives par Publication  // premier indice
WITH PositiveReactions AS ( 
    SELECT R.publiId,
        COUNT(*) AS TotalPositiveReactions
    FROM Reaction R
    WHERE R.typer IN ('Like', 'Fun', 'Love')
    AND NOT EXISTS (
        SELECT 1
        FROM HistoriquePublication hp
        WHERE hp.publiId = R.publiId AND hp.userId = 208 
        )
    GROUP BY R.publiId
),

-- 2 le max de personnes ( interessé et qui participe ) // deuxieme indice
EventInterestParticipation AS (
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
),


--  // Troisieme indice :

-- Étape 1 : Filtrer l'historique des publications de l'utilisateur
 UserHistory AS (
    SELECT hp.publiId
    FROM HistoriquePublication hp
    WHERE
        hp.userId = 208
),


-- Étape 2 : Filtrer les publications avec des bonnes réactions
UserLikedPublications AS (
    SELECT uh.publiId
    FROM UserHistory uh
    JOIN Reaction r ON uh.publiId = r.publiId
    WHERE r.userId = 208  -- Remplacez [CurrentUserId] par l'ID de l'utilisateur actuel
    AND r.typeR IN ('Like', 'Fun', 'Love')
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
    SELECT DISTINCT
        G.name AS GenreName
    FROM
        UserLikedFilmsSeries ULFS
    JOIN
        FilmGenre FG ON ULFS.ItemId = FG.filmId AND ULFS.ItemType = 'Film'
    JOIN
        GenreCinemato G ON FG.genreId = G.id
    UNION
    SELECT DISTINCT
        G.name AS GenreName
    FROM
        UserLikedFilmsSeries ULFS
    JOIN
        SerieGenre SG ON ULFS.ItemId = SG.serieId AND ULFS.ItemType = 'Serie'
    JOIN
        GenreCinemato G ON SG.genre = G.id
),

-- Étape 5 : Proposer des publications de films et séries du même genre
RecommendedPublications AS (
    SELECT
        P.id AS PublicationID,
        P.titre AS PublicationTitle,
        G.name AS GenreName
    FROM
        Publication P
    LEFT JOIN
        PublicationFilm PF ON P.id = PF.publiId
    LEFT JOIN
        Film F ON PF.FilmId = F.id
    LEFT JOIN
        FilmGenre FG ON F.id = FG.filmId
    LEFT JOIN
        PublicationSerie PS ON P.id = PS.publiId
    LEFT JOIN
        Serie S ON PS.SerieId = S.id
    LEFT JOIN
        SerieGenre SG ON S.id = SG.serieId
    LEFT JOIN
        GenreCinemato G ON G.id = FG.genreId OR G.id = SG.genre
    WHERE
        G.name IN (SELECT GenreName FROM UserLikedGenres)
        AND NOT EXISTS (
            SELECT 1
            FROM HistoriquePublication HP
            WHERE HP.publiId = P.id AND HP.userId = 208
        )
)


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
    PositiveReactions PR ON P.id = PR.publiId
LEFT JOIN
    EventInterestParticipation EIP ON P.id = EIP.publiId
ORDER BY
    RecommendationScore DESC
LIMIT 10;

