CREATE OR REPLACE FUNCTION check_insert_participation()
RETURNS TRIGGER AS $$
BEGIN
    -- Vérifiez s'il y a déjà un enregistrement dans InteresseEvent pour le même utilisateur et événement
    IF EXISTS (
        SELECT 1
        FROM InteresseEvent
        WHERE userId = NEW.userId AND eventId = NEW.eventId
    ) THEN
        RAISE EXCEPTION 'Il n est pas possible pour un utilisateur de participer et d être intéressé en même temps. ';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_insert_interesse()
RETURNS TRIGGER AS $$
BEGIN
    -- Vérifiez s'il y a déjà un enregistrement dans ParticipationEvent pour le même utilisateur et événement
    IF EXISTS (
        SELECT 1
        FROM ParticipationEvent
        WHERE userId = NEW.userId AND eventId = NEW.eventId )
    THEN RAISE EXCEPTION 'Il n est pas possible pour un utilisateur de participer et d être intéressé en même temps. ';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER trigger_check_participation
BEFORE INSERT ON ParticipationEvent
FOR EACH ROW
EXECUTE FUNCTION check_insert_participation();

CREATE TRIGGER trigger_check_interesse
BEFORE INSERT ON InteresseEvent
FOR EACH ROW
EXECUTE FUNCTION check_insert_interesse();

--  Procédure pour archiver manuellement les events 
CREATE OR REPLACE PROCEDURE archive_past_events_procedure()
LANGUAGE plpgsql
AS $$
BEGIN
    FOR event_record IN
        SELECT id, dateEvent
        FROM EventParticulier
        WHERE dateEvent < CURRENT_DATE
    LOOP
        INSERT INTO Archive (dateArchivage, raison, eventId)
        VALUES (CURRENT_DATE, 'Event passed', event_record.id);
        DELETE FROM EventParticulier WHERE id = event_record.id;
    END LOOP;
END;
$$;


-- 2) appler la fonction 
CALL archive_past_events_procedure();


CREATE OR REPLACE FUNCTION check_and_increment_nbPlaces()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT nbPlaceReserve FROM EventParticulier WHERE id = NEW.eventId) < 
       (SELECT nbPlaceDispo FROM EventParticulier WHERE id = NEW.eventId) THEN
        UPDATE EventParticulier
        SET nbPlaceReserve = nbPlaceReserve + 1
        WHERE id = NEW.eventId;
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Nombre de places disponibles dépassé pour cet événement';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_participation
BEFORE INSERT ON ParticipationEvent
FOR EACH ROW
EXECUTE FUNCTION check_and_increment_nbPlaces();
