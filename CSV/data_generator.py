import csv
import random
import os
from faker import Faker
fake = Faker()

# Chemin de base pour tous les fichiers CSV
base_path = os.path.dirname(os.path.abspath(__file__))

def generate_users(n):
    try:
        with open(os.path.join(base_path, 'Utilisateurs.csv'), mode='w', newline='') as file:

            writer = csv.writer(file)
            writer.writerow(["username", "password", "email", "role"])
            existing_users = set()  # Pour garantir l'unicité des noms d'utilisateur    
            roles = ['lamda', 'Realisateur', 'acteur', 'organisateurSalle', 'Cinema' ,'Club']  # Correspond à l'ENUM TypeRole
            while len(existing_users) < n:
                username = fake.user_name()
                if username in existing_users:
                    continue
                password = fake.password(length=12)
                email = fake.email()
                role = random.choice(roles)
                writer.writerow([username, password, email, role])
                existing_users.add(username)
    except Exception as e:
        print(f"An error occurred while writing Utilisateurs.csv: {e}")

def generate_films(n):
    with open(os.path.join(base_path, 'films.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["id", "titre", "resume", "realisation", "duree", "genre"])
        for i in range(1, n+1):  # Utiliser i pour générer un ID unique pour chaque film
            titre = fake.sentence(nb_words=5)
            resume = fake.text(max_nb_chars=200)
            realisation = fake.date_this_century().isoformat()
            duree = random.randint(60, 180)
            genre = fake.word()  # Supposons que le genre correspond au nom d'un genre déjà existant
            writer.writerow([i, titre, resume, realisation, duree, genre])


def generate_publications(n):
    path = os.path.join(base_path, 'publications.csv')
    with open(path, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["id", "auteur", "discussionId", "titre", "contenu", "sujetId", "parentId"])
        
        # Les parentId valides commencent à 1 et vont jusqu'à n, mais on utilise une publication comme parent pour les suivantes
        for i in range(1, n+1):
            auteur = random.randint(1, 100)  # Supposer que nous avons 100 utilisateurs max
            discussionId = random.randint(1, 50)  # Supposer que nous avons 50 discussions max
            titre = fake.sentence()
            contenu = fake.text()
            sujetId = random.randint(1, 10)  # Supposer que nous avons 10 sujets max
           # datePublication = fake.date_time_between(start_date="-1y", end_date="now").isoformat()
            
            # Chaque publication a un parentId, qui est un ID existant d'une publication précédente, sauf la première
            if i == 1:
                parentId = 2  # La première publication pourrait être de premier niveau si nécessaire
            else:
                parentId = random.randint(1, i-1)  # Assurer que le parentId est toujours un ID existant
                
            writer.writerow([i, auteur, discussionId, titre, contenu, sujetId, parentId])






# Table 'Role'
def generate_roles():
    roles = ['Admin', 'Moderateur', 'Membre', 'Visiteur', 'VIP']
    with open(os.path.join(base_path, 'roles.csv'), mode='w', newline='') as file:

        writer = csv.writer(file)
        writer.writerow(["name"])
        for role in roles:
            writer.writerow([role])

# Table 'Amis'
def generate_friends(n):
    with open(os.path.join(base_path, 'amis.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["user1", "user2"])
        for _ in range(n):
            user1 = random.randint(1, 100)
            user2 = random.randint(1, 100)
            while user1 == user2:
                user2 = random.randint(1, 100)
            writer.writerow([user1, user2])

# Table 'Follow'
def generate_follows(n):
    with open(os.path.join(base_path, 'follow.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["userId", "follower"])
        
        unique_pairs = set()  # Set to keep track of unique (userId, follower) pairs
        
        while len(unique_pairs) < n:
            userId = random.randint(1, 100)  # Assuming 100 users
            follower = random.randint(1, 100)
            
            # Ensure the follower is not the same as the userId
            while userId == follower:
                follower = random.randint(1, 100)
            
            # Create a tuple for the pair
            pair = (userId, follower)
            
            # Only write to file if the pair is unique
            if pair not in unique_pairs:
                writer.writerow([userId, follower])
                unique_pairs.add(pair)  # Add the new pair to the set to ensure uniqueness


# Table 'Serie'
def generate_series(n, max_genre_id):
    with open(os.path.join(base_path, 'series.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["id", "saison", "titre", "nbreEpisodes", "dureeParEpisode", "datePremiere", "genre"])
        used_ids = set()  # Ensemble pour suivre les ID utilisés
        while len(used_ids) < n:
            id = random.randint(1, 200)  # Élargir la plage pour réduire les collisions
            if id in used_ids:
                continue  # Sauter cet ID s'il a déjà été utilisé
            saison = random.randint(1, 5)
            titre = fake.sentence(nb_words=4)
            nbreEpisodes = random.randint(8, 24)
            dureeParEpisode = random.randint(20, 60)
            datePremiere = fake.date_this_decade().isoformat()
            genre = random.randint(1, max_genre_id)
            writer.writerow([id, saison, titre, nbreEpisodes, dureeParEpisode, datePremiere, genre])
            used_ids.add(id)  # Ajouter l'ID à l'ensemble des ID utilisés




def generate_events(n):
    with open(os.path.join(base_path, 'events.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["dateEvent", "lieuEvent", "nomEvent", "nbPlaceDispo", "nbPlaceReserve", "idOrganisateur"])
        for _ in range(n):
            dateEvent = fake.date_between(start_date="today", end_date="+2y").isoformat()
            lieuEvent = fake.city()
            nomEvent = fake.sentence(nb_words=5)
            nbPlaceDispo = random.randint(50, 500)
            nbPlaceReserve = random.randint(0, nbPlaceDispo) 
            idOrganisateur = random.randint(1, 100)
            writer.writerow([dateEvent, lieuEvent, nomEvent, nbPlaceDispo, nbPlaceReserve, idOrganisateur])


# Table 'SujetPublication'
def generate_sujet_publication(n):
    with open(os.path.join(base_path, 'sujet_publication.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idSujet", "description"])
        for i in range(1, n+1):
            description = fake.sentence(nb_words=6)
            writer.writerow([i, description])

# Table 'MotsCles'
def generate_mots_cles(n):
    with open(os.path.join(base_path, 'mots_cles.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idMotCle", "motCle"])
        mots_cles = set()  # Use a set to avoid duplicate words
        while len(mots_cles) < n:
            mot_cle = fake.word()
            mots_cles.add(mot_cle)
        for i, mot_cle in enumerate(mots_cles, 1):
            writer.writerow([i, mot_cle])

# Table 'CategorieDiscussion'
def generate_categorie_discussion(n):
    with open(os.path.join(base_path, 'categorie_discussion.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idCategorie", "nomCategorie"])
        categories = set()  # Use a set to avoid duplicate categories
        while len(categories) < n:
            categorie = fake.word()
            categories.add(categorie)
        for i, categorie in enumerate(categories, 1):
            writer.writerow([i, categorie])

# Table 'Discussion'
def generate_discussions(n):
    with open(os.path.join(base_path, 'discussions.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idDiscussion", "idCreateur", "titreDiscussion", "description", "idCategorie"])
        for i in range(1, n+1):
            idCreateur = random.randint(1, 100)  # Assuming 100 users
            titreDiscussion = fake.sentence(nb_words=5)
            description = fake.paragraph(nb_sentences=3)
            idCategorie = random.randint(1, 10)  # Assuming 10 categories
            writer.writerow([i, idCreateur, titreDiscussion, description, idCategorie])


# Table 'ParticipationEvent'
def generate_participation_event(n, max_event_id):
    with open(os.path.join(base_path, 'participation_event.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idUser", "idEvent"])
        
        unique_pairs = set()
        
        while len(unique_pairs) < n:
            idUser = random.randint(1, 100)  # Assuming 100 users
            idEvent = random.randint(1, max_event_id)  # Utiliser max_event_id pour définir le nombre max d'événements
            
            # Créer une paire tuple de idUser et idEvent
            pair = (idUser, idEvent)
            
            # Vérifier si la paire est déjà dans l'ensemble
            if pair not in unique_pairs:
                writer.writerow([idUser, idEvent])
                unique_pairs.add(pair)  # Ajouter la paire à l'ensemble pour suivre l'unicité



# Table 'Archive'
def generate_archive(n):
    with open(os.path.join(base_path, 'archive.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idArchive", "dateArchivage", "raison", "publication"])
        for i in range(1, n+1):
            dateArchivage = fake.date_this_year().isoformat()
            raison = fake.sentence(nb_words=5)
            publication = random.randint(1, 100)  # Assuming 100 publications
            writer.writerow([i, dateArchivage, raison, publication])

# Table 'Commentaire'
def generate_commentaire(n):
    with open(os.path.join(base_path, 'commentaire.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idCommentaire", "idPubli", "auteur", "contenu", "dateCommentaire"])
        for i in range(1, n+1):
            idPubli = random.randint(1, 100)
            auteur = random.randint(1, 100)
            contenu = fake.sentence(nb_words=12)
            dateCommentaire = fake.date_this_year().isoformat()
            writer.writerow([i, idPubli, auteur, contenu, dateCommentaire])

# Table 'Reaction'


def generate_reactions(n, max_pub_id):
    path = os.path.join(base_path, 'reactions.csv')
    with open(path, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idPubli", "idUser", "type"])
        types = ['Like', 'Dislike', 'Neutre', 'Fun', 'Sad', 'Angry']
        valid_pub_ids = set(range(1, max_pub_id + 1))  # Assurez-vous que max_pub_id est le maximum réel dans 'publication'
        used_pairs = set()

        while len(used_pairs) < n:
            idPubli = random.choice(list(valid_pub_ids))
            idUser = random.randint(1, 100)  # Supposer 100 utilisateurs max
            pair = (idPubli, idUser)

            if pair not in used_pairs:
                type = random.choice(types)
                writer.writerow([idPubli, idUser, type])
                used_pairs.add(pair)









# Table 'Message'
def generate_message(n):
    with open(os.path.join(base_path, 'message.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["id", "expéditeur", "destinataire", "contenu"])
        for i in range(1, n+1):
            expediteur = random.randint(1, 100)
            destinataire = random.randint(1, 100)
            while expediteur == destinataire:
                destinataire = random.randint(1, 100)
            contenu = fake.paragraph(nb_sentences=1)
            writer.writerow([i, expediteur, destinataire, contenu])

# Table 'Notification'
def generate_notification(n):
    with open(os.path.join(base_path, 'notification.csv'), mode='w', newline='') as file:

        writer = csv.writer(file)
        writer.writerow(["id", "notificationType", "vue", "dateEnvoie", "publication", "expéditeur", "destinataire"])
        types = ['AjoutPublication', 'Suivi']
        for i in range(1, n+1):
            notificationType = random.choice(types)
            vue = random.choice([True, False])
            dateEnvoie = fake.date_this_year().isoformat()
            publication = random.randint(1, 100) if notificationType == 'AjoutPublication' else None
            expediteur = random.randint(1, 100)
            destinataire = random.randint(1, 100)
            writer.writerow([i, notificationType, vue, dateEnvoie, publication, expediteur, destinataire])




# Table 'Amis'
def generate_amis(n):
    try:
        with open(os.path.join(base_path, 'amis.csv'), mode='w', newline='') as file:

            writer = csv.writer(file)
            writer.writerow(["user1", "user2"])
            amis_set = set()
            while len(amis_set) < n:
                user1, user2 = random.randint(1, 100), random.randint(1, 100)
                if user1 != user2 and (user1, user2) not in amis_set and (user2, user1) not in amis_set:
                    writer.writerow([user1, user2])
                    amis_set.add((user1, user2))
    except Exception as e:
        print(f"An error occurred while writing amis.csv: {e}")



# Table 'Filme_Publication'
def generate_filme_publication(n):
    with open(os.path.join(base_path, 'filme_publication.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["filmPubliId", "filmId", "publiId"])
        for i in range(1, n+1):
            filmId = random.randint(1, 50)  # Assuming 50 films
            publiId = random.randint(1, 100)  # Assuming 100 publications
            writer.writerow([i, filmId, publiId])

# Table 'MotsClesPublication'
def generate_mots_cles_publication(n, max_publi_id, max_mot_cle_id):
    base_path = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(base_path, 'mots_cles_publication.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["publiId", "motCleId"])

        unique_pairs = set()  # Pour éviter les doublons de paires (publiId, motCleId)

        while len(unique_pairs) < n:
            publiId = random.randint(1, max_publi_id)  # Générer un publiId existant
            motCleId = random.randint(1, max_mot_cle_id)  # Générer un motCleId existant

            if (publiId, motCleId) not in unique_pairs:
                writer.writerow([publiId, motCleId])
                unique_pairs.add((publiId, motCleId))


def generate_genre_cinemato(n):
    with open(os.path.join(base_path, 'genre_cinemato.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["id", "nom", "parentId"])
        
        # Example genres for illustration
        base_genres = ['Action', 'Comedy', 'Drama', 'Fantasy', 'Horror', 'Science Fiction']
        sub_genres = {
            'Action': ['Adventure', 'War', 'Spy'],
            'Comedy': ['Satire', 'Romantic', 'Slapstick'],
            'Drama': ['Crime', 'Mystery', 'Historical'],
            'Fantasy': ['Epic', 'Dark Fantasy', 'Urban Fantasy'],
            'Horror': ['Gothic', 'Occult', 'Survival'],
            'Science Fiction': ['Cyberpunk', 'Space Opera', 'Time Travel']
        }
        
        # Generating base genres first
        genres = {name: i+1 for i, name in enumerate(base_genres)}  # Mapping genre names to IDs
        for genre, id in genres.items():
            writer.writerow([id, genre, None])  # Top-level genres have no parent
        
        # Generating sub-genres
        current_id = len(base_genres) + 1
        for genre, sub_list in sub_genres.items():
            parent_id = genres[genre]
            for sub in sub_list:
                writer.writerow([current_id, sub, parent_id])
                current_id += 1
def generate_event_particulier(n):
    with open(os.path.join(base_path, 'EventParticulier.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["id", "auteur", "nomEvent", "dateEvent", "lieuEvent", "nbPlaceDispo", "nbPlaceReserve", "organisateur", "liens_web"])
        
        for i in range(1, n+1):
            id = i
            auteur = random.randint(1, 100)  # Assuming there are 100 users
            nomEvent = fake.sentence(nb_words=5)
            dateEvent = fake.date_between(start_date="today", end_date="+2y").isoformat()
            lieuEvent = fake.city()
            nbPlaceDispo = random.randint(50, 500)
            nbPlaceReserve = random.randint(0, nbPlaceDispo)  # Ensure this number is less than or equal to nbPlaceDispo
            organisateur = random.randint(1, 100) if random.choice([True, False]) else None
            
            # Generating between 1 and 5 random web links and formatting them as a PostgreSQL array
            liens_web = '{' + ', '.join([fake.url() for _ in range(random.randint(1, 5))]) + '}'

            writer.writerow([id, auteur, nomEvent, dateEvent, lieuEvent, nbPlaceDispo, nbPlaceReserve, organisateur, liens_web])

def generate_interesse_event(n, max_user_id, max_event_id):
    with open(os.path.join(base_path, 'InteresseEvent.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["userId", "eventId"])
        
        unique_pairs = set()  # To avoid duplicate (userId, eventId) pairs

        while len(unique_pairs) < n:
            userId = random.randint(1, max_user_id)  # Assuming max_user_id is the maximum number of users
            eventId = random.randint(1, max_event_id)  # Assuming max_event_id is the maximum number of events

            # Ensure the pair is unique before writing
            if (userId, eventId) not in unique_pairs:
                writer.writerow([userId, eventId])
                unique_pairs.add((userId, eventId))

def generate_historique_publication(n, max_user_id, max_publi_id):
    with open(os.path.join(base_path, 'historique_publication.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idUser", "idPubli", "action", "dateAction"])
        
        actions = ["ajouter", "voir", "repondre à une publication"]  # Définir les types d'actions possibles

        for _ in range(n):
            idUser = random.randint(1, max_user_id)  # Choix d'un idUser existant
            idPubli = random.randint(1, max_publi_id)  # Choix d'un idPubli existant
            action = random.choice(actions)  # Sélection aléatoire d'une action
            dateAction = fake.date_between(start_date="-2y", end_date="today")  # Génération d'une date d'action

            writer.writerow([idUser, idPubli, action, dateAction])

# activation de ses fonctions
generate_genre_cinemato(24)  # Générer des genres cinématographiques, en assurant qu'il y en a assez pour les références

generate_users(100)  # Générer 100 utilisateurs
generate_films(50)   # Générer 50 films
generate_publications(100)  # Générer 100 publications

generate_sujet_publication(10)  # Générer 10 entrées de sujet de publication
generate_mots_cles(30)          # Générer 30 mots clés uniques
generate_categorie_discussion(10)  # Générer 10 catégories de discussion uniques
generate_discussions(50)        # Générer 50 discussions

generate_participation_event(50, 20)  # Générer 50 participations à des événements, avec un maximum de 20 événements différents
generate_archive(30)              # Générer 30 entrées d'archive
generate_commentaire(100)         # Générer 100 commentaires
# Exemple de correction de l'appel de la fonction
generate_reactions(200, 100)  # Générer 200 réactions pour 100 publications

generate_message(150)             # Générer 150 messages
generate_notification(80)         # Générer 80 notifications

generate_roles()
generate_amis(100)
generate_follows(100)
generate_filme_publication(100)
generate_mots_cles_publication(100, 100, 30)  # Supposons que vous ayez 100 publications et 30 mots clés

generate_series(100, 24)  # Générer 100 séries en s'assurant que les genres existent
generate_event_particulier(100)  # Generate 50 particular events
generate_interesse_event(200, 100, 50)  # Generate 200 entries with up to 100 users and 50 events
generate_historique_publication(100, 100, 50)  # Générer 100 entrées historiques avec jusqu'à 100 utilisateurs et 50 publications



