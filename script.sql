-- rechercher un event à venir par lieu et  date 
-- ---> la saisie dans le prompt 
\prompt 'Tapez le lieu de l\'événement -> ' lieu_event
\prompt 'Tapez la date de début (YYYY-MM-DD) -> ' date_debut
\prompt 'Tapez la date de fin (YYYY-MM-DD) -> ' date_fin
-- ---> execution 
EXECUTE recherche_par_lieu_et_date(:lieu_event, :date_debut, :date_fin);

-- --------------------------------------------------------------
-- recherche de tous les events auxquels un user participe 
-- ---> la saisie dans le prompt
\prompt 'Tapez l\'id de l\'utilisateur -> ' user_id
-- ---> execution
EXECUTE recherche_participation_event_user(:user_id);


-- -----------------------------------------------------
-- recherche des event d'un organisateur spécifique
-- ---> la saisie dans le prompt
\prompt 'Tapez l\'id de l\'organisateur -> ' organisateur_id
-- ---> execution
EXECUTE recherche_events_organisateur(:organisateur_id);

-- -------------------------------------------------------------
-- recherche publication par motClé 
-- ---> la saisie dans le prompt
\prompt 'Tapez l\'id du motClé -> ' motcle_id
-- ---> execution
EXECUTE recherche_publication_motcle(:motcle_id);


-- --------------------------------------------------
-- rechercher les events passés 
-- ---> execution
EXECUTE recherche_events_passes;

-- -----------------------------------------------------------
-- rechercher les events à venir 
-- ---> execution
EXECUTE recherche_events_avenir;

-- ------------------------------------------------------
-- recherche des events à venir où l'user est intéressé 
-- ---> la saisie dans le prompt
\prompt 'Tapez l\'id de l\'user -> ' user_id
-- ---> execution
EXECUTE recherche_events_avenir_interesse(:user_id);

-- -----------------------------------------------------
-- recherche des events auxquels participent les amis d'un user
-- ---> la saisie dans le prompt
\prompt 'Tapez l\'id de l\'user -> ' user_id
-- ---> execution
EXECUTE recherche_events_ami(:user_id);

-- ------------------------------------------------------------
-- créer une nouvelle discussion dans une catégorie spécifique
-- ---> la saisie dans le prompt
\prompt 'Tapez l\'ID de l\'auteur -> ' auteurId
\prompt 'Tapez le titre de la discussion -> ' titreDiscussion
\prompt 'Tapez la description de la discussion -> ' descriptionDiscussion
\prompt 'Tapez l\'ID de la catégorie -> ' categorieId
-- ---> execution
EXECUTE creer_discussion (:auteurId, :titreDiscussion, :descriptionDiscussion, :categorieId);


-- -------------------------------------------
-- Publier une Publication
-- ---> la saisie dans le prompt
\prompt 'Tapez l\'ID de l\'auteur -> ' auteurId
\prompt 'Tapez l\'ID de la discussion -> ' discussionId
\prompt 'Tapez le titre de la publication -> ' titrePublication
\prompt 'Tapez le contenu de la publication -> ' contenuPublication
\prompt 'Tapez l\'ID de la publication parente (0 si aucune) -> ' parentId

-- ---> execution
EXECUTE creer_publication (:auteurId, :discussionId, :titrePublication, :contenuPublication, :parentId);


-- ----------------------------
-- creation d'un Événement
\prompt 'Tapez l\'ID de l\'auteur -> ' auteurId
\prompt 'Tapez le nom de l\'événement -> ' nomEvent
\prompt 'Tapez la date de l\'événement (YYYY-MM-DD) -> ' dateEvent
\prompt 'Tapez le lieu de l\'événement -> ' lieuEvent
\prompt 'Tapez le nombre de places disponibles -> ' nbPlaceDispo
\prompt 'Tapez l\'ID de l\'organisateur -> ' organisateurId
\prompt 'Tapez les liens web (séparés par des virgules) -> ' liensWeb

-- ---> execution
EXECUTE creer_evenement (:auteurId, :nomEvent, :dateEvent, :lieuEvent, :nbPlaceDispo, :organisateurId, string_to_array(:liensWeb, ','));

