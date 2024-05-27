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