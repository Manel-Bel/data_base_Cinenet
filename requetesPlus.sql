select id, nomEvent, dateEvent, organisateur from EventParticulier limit 25;

select * from ParticipationEvent;

CREATE VIEW UserFellowersView AS
    SELECT u.id as id_user, u.username as name_user, uf.id as follower_id, uf.username as follower_name
    FROM Follower f
    JOIN Users u ON f.id = u.id
    JOIN Users uf ON uf.id = f.folower
;


INSERT INTO GenreCinemato (name, parent) VALUES
('Action', NULL),
('Comedy', NULL),
('Drama', NULL),
('Thriller', 'Action'),
('Romantic Comedy', 'Comedy');

INSERT INTO Film (titre, resume, realisation, duree) VALUES
('Inception', 'A mind-bending thriller', '2010-07-16', 148),
('The Dark Knight', 'Batman faces the Joker', '2008-07-18', 152),
('Forrest Gump', 'The story of Forrest Gump', '1994-07-06', 142),
('The Hangover', 'A bachelor party gone wrong', '2009-06-05', 100),
('Love Actually', 'Multiple romantic stories', '2003-11-14', 135);

INSERT INTO FilmGenre (idFilm, genre) VALUES
(1, 'Thriller'),
(2, 'Action'),
(3, 'Drama'),
(4, 'Comedy'),
(5, 'Romantic Comedy');

INSERT INTO Publication (id, auteur, discussionId, titre, contenu, datePublication, parentId) VALUES
(1, 1, 1, 'Introduction to Databases', 'This is an introduction to databases.', '2023-05-01 10:00:00', NULL),
(2, 2, 1, 'Re: Introduction to Databases', 'Thank you for the introduction.', '2023-05-01 11:00:00', 1),
(3, 1, 2, 'Advanced SQL Queries', 'Let s discuss advanced SQL queries.', '2023-05-02 09:00:00', NULL),
(4, 3, 2, 'Re: Advanced SQL Queries', 'Here are some tips for advanced SQL queries.', '2023-05-02 10:30:00', 3);


SELECT id, auteur, titre, categorie from Discussion limit 5;

SELECT id, auteur, titre, parentId FROM Publication LIMIT 5;

-- One publication can be linked to one or several films.
-- CREATE TABLE Filme_Publication (
-- filmPubliId SERIAL PRIMARY KEY,
-- filmId INTEGER REFERENCES Film(id),
-- publiId INTEGER REFERENCES Publication(publiId)
-- );


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



