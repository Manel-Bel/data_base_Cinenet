-- Peuplement de la base de données à partir des fichiers CSV --
\copy GenreCinemato(id,name, parent) FROM 'CSV/genre_cinemato.csv' WITH (FORMAT csv, HEADER true);
\copy Users(username, password, email, role) FROM 'CSV/Utilisateurs.csv' WITH (FORMAT csv, HEADER true);

\copy Amis(user1, user2) FROM 'CSV/amis.csv' WITH (FORMAT csv, HEADER true);

\copy Follower(id, folower) FROM 'CSV/follow.csv' WITH (FORMAT csv, HEADER true);

 \copy Film(id,titre, resume, realisation, duree) FROM 'CSV/films.csv' WITH (FORMAT csv, HEADER true);


 \copy FilmGenre(filmId, genreId) FROM 'CSV/film_genre.csv' WITH (FORMAT csv, HEADER true);


 \copy Serie(id,saison, titre, nbreEpisodes, dureeParEpisode, datePremiere) FROM 'CSV/series.csv' WITH (FORMAT csv, HEADER true);

 \copy serieGenre(serieId, genre) FROM 'CSV/serie_genre.csv' WITH (FORMAT csv, HEADER true);


 \copy MotsCles(motCleId, motCle) FROM 'CSV/mots_cles.csv' WITH (FORMAT csv, HEADER true);

\copy CategorieDiscussion(id, categorie) FROM 'CSV/categorie_discussion.csv' WITH (FORMAT csv, HEADER true);

 \copy EventParticulier(id, auteur, nomEvent, dateEvent, lieuEvent, nbPlaceDispo, nbPlaceReserve, organisateur, liens_web) FROM 'CSV/EventParticulier.csv' WITH (FORMAT csv, HEADER true);

\copy InteresseEvent(userId, eventId) FROM 'CSV/InteresseEvent.csv' WITH (FORMAT csv, HEADER true);

 \copy ParticipationEvent(userId, eventId) FROM 'CSV/participation_event.csv' WITH (FORMAT csv, HEADER true);

 \copy Discussion(id, auteur, titre, description, categorieId) FROM 'CSV/discussions.csv' WITH (FORMAT csv, HEADER true);

\copy Publication(id, auteur, discussionId, titre, contenu, datePublication, parentId) FROM 'CSV/publications.csv' WITH (FORMAT csv, HEADER true);

\copy MotsClesPublication(publiId, motCleId) FROM 'CSV/mots_cles_publication.csv' WITH (FORMAT csv, HEADER true);

 \copy Reaction(id,publiId,userId,typeR) FROM 'CSV/reactions.csv' WITH (FORMAT csv, HEADER true);

 \copy Archive(idArchive, dateArchivage, raison, eventId) FROM 'CSV/archive.csv' WITH (FORMAT csv, HEADER true);

 \copy Message(id, expéditeur, destinataire, contenu) FROM 'CSV/message.csv' WITH (FORMAT csv, HEADER true);

\copy HistoriquePublication(userId, publiID, action, dateAction,idReaction) FROM 'CSV/historique_publication.csv' WITH (FORMAT csv, HEADER true);

\copy PublicationEventPart(publiId, eventId) FROM 'CSV/publication_event_part.csv' WITH (FORMAT csv, HEADER true);

\copy PublicationFilm(publiId, FilmId) FROM 'CSV/publication_film.csv' WITH (FORMAT csv, HEADER true);

\copy PublicationSerie(publiId, SerieId) FROM 'CSV/publication_serie.csv' WITH (FORMAT csv, HEADER true);



-- ---------------------------------------------------------