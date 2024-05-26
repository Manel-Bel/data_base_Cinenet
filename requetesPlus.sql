select id, nomEvent, dateEvent, organisateur from EventParticulier limit 25;

select * from ParticipationEvent;

CREATE VIEW UserFellowersView AS
    SELECT u.id as id_user, u.username as name_user, uf.id as follower_id, uf.username as follower_name
    FROM Follower f
    JOIN Users u ON f.id = u.id
    JOIN Users uf ON uf.id = f.folower
;

CREATE VIEW EventParticulierNonNull AS
    SELECT *
    FROM EventParticulier
    WHERE nbPlaceDispo IS NOT NULL
;

INSERT INTO GenreCinemato (name, parent) VALUES
('Action', NULL),
('Comedy', NULL),
('Drama', NULL),
('Thriller', 1),
('Romantic Comedy', 2),
('Horror', NULL), --6
('Slasher', 6), -- Subgenre of Horror
('Supernatural', 6), -- Subgenre of Horror
('Psychological', 6); -- Subgenre of Horror

INSERT INTO Film (titre, resume, realisation, duree) VALUES
('Inception', 'A mind-bending thriller', '2010-07-16', 148),
('The Dark Knight', 'Batman faces the Joker', '2008-07-18', 152),
('Forrest Gump', 'The story of Forrest Gump', '1994-07-06', 142),
('The Hangover', 'A bachelor party gone wrong', '2009-06-05', 100),
('Love Actually', 'Multiple romantic stories', '2003-11-14', 135),
('The Exorcist', 'When a teenage girl is possessed by a mysterious entity, her mother seeks the help of two priests to save her.', '1973-12-26', 122),
('Halloween', 'Fifteen years after murdering his sister on Halloween night 1963, Michael Myers escapes from a mental hospital and returns to the small town of Haddonfield, Illinois to kill again.', '1978-10-25', 91),
('The Shining', 'A family heads to an isolated hotel for the winter where a sinister presence influences the father into violence, while his psychic son sees horrific forebodings from both past and future.', '1980-06-13', 146),
('Psycho', 'A secretary embezzles money and runs away, only to come across a secluded motel operated by a strange young man.', '1960-09-08', 109),
('Scream', 'A year after the murder of her mother, a teenage girl is terrorized by a new killer, who targets the girl and her friends by using horror films as part of a deadly game.', '1996-12-20', 111);

INSERT INTO FilmGenre (filmId, genreId) VALUES
(1, 4),
(2, 1),
(3, 3),
(4, 2),
(5, 5),
(6, 8), -- The Exorcist (Supernatural)
(7, 7), -- Halloween (Slasher)
(8, 8), -- The Shining (Supernatural)
(9, 9), -- Psycho (Psychological)
(10, 7), -- Scream (Slasher)
(10, 9); -- Scream (Psychological)


SELECT id, titre,realisation FROM Film limit 10;
SELECT id, auteur, titre, categorie from Discussion limit 5;

SELECT id, auteur, titre, parentId FROM Publication LIMIT 5;

-- One publication can be linked to one or several films.
-- CREATE TABLE Filme_Publication (
-- filmPubliId SERIAL PRIMARY KEY,
-- filmId INTEGER REFERENCES Film(id),
-- publiId INTEGER REFERENCES Publication(publiId)
-- );



-- Utilisation d'un FULL JOIN pour afficher tous les sujets de publication et toutes les discussions, indépendamment de s'ils sont liés ou non

-- SELECT sp.description AS sujet_description, d.titre AS discussion_titre
-- FROM SujetPublication sp
-- FULL JOIN Publication p ON sp.id = p.sujetId
-- FULL JOIN Discussion d ON p.discussionId = d.id
-- ORDER BY sp.description, d.titre;

INSERT INTO Publication (id, auteur, discussionId, titre, contenu, datePublication, parentId) VALUES
(1, 1, 1, 'Introduction to Databases', 'This is an introduction to databases.', '2023-05-01 10:00:00', NULL),
(2, 2, 1, 'SQL Basics', 'Let s discuss the basics of SQL.', '2023-05-01 10:30:00', NULL),
(3, 3, 2, 'Advanced SQL Queries', 'Let s discuss advanced SQL queries.', '2023-05-02 09:00:00', NULL),
(4, 4, 2, 'Database Optimization', 'Tips for optimizing database performance.', '2023-05-02 09:30:00', NULL),
(5, 5, 3, 'NoSQL Databases', 'An overview of NoSQL databases.', '2023-05-03 08:00:00', NULL);

-- Réponses à ces publications
INSERT INTO Publication (id, auteur, discussionId, titre, contenu, datePublication, parentId) VALUES
(6, 2, 1, 'Re: Introduction to Databases', 'Thank you for the introduction.', '2023-05-01 11:00:00', 1),
(7, 3, 1, 'Re: SQL Basics', 'SQL is a powerful language.', '2023-05-01 11:15:00', 2),
(8, 4, 2, 'Re: Advanced SQL Queries', 'Here are some tips for advanced SQL queries.', '2023-05-02 10:30:00', 3),
(9, 5, 2, 'Re: Database Optimization', 'I have some more optimization tips.', '2023-05-02 11:00:00', 4),
(10, 1, 3, 'Re: NoSQL Databases', 'NoSQL databases are great for unstructured data.', '2023-05-03 09:00:00', 5);

-- Réponses de second niveau
INSERT INTO Publication (id, auteur, discussionId, titre, contenu, datePublication, parentId) VALUES
(11, 3, 1, 'Re: Introduction to Databases', 'Glad you found it useful.', '2023-05-01 12:00:00', 6),
(12, 4, 2, 'Re: Advanced SQL Queries', 'Thank you for the tips.', '2023-05-02 11:45:00', 8),
(13, 5, 3, 'Re: NoSQL Databases', 'Indeed, NoSQL is very flexible.', '2023-05-03 10:00:00', 10);

-- Réponses de troisième niveau
INSERT INTO Publication (id, auteur, discussionId, titre, contenu, datePublication, parentId) VALUES
(14, 1, 1, 'Re: Introduction to Databases', 'Let me know if you have more questions.', '2023-05-01 13:00:00', 11),
(15, 2, 2, 'Re: Advanced SQL Queries', 'Happy to help!', '2023-05-02 12:30:00', 12);



