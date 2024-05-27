import csv
import random
import os
from faker import Faker
fake = Faker()

# Chemin de base pour tous les fichiers CSV
base_path = os.path.dirname(os.path.abspath(__file__))

def generate_users2(n):
    try:
        with open(os.path.join(base_path, 'Utilisateurs.csv'), mode='w', newline='') as file:

            writer = csv.writer(file)
            writer.writerow(["username", "password", "email", "role"])
            existing_emails = set()  # Pour garantir l'unicité des noms d'utilisateur    
            roles = ['lamda', 'Realisateur', 'acteur', 'organisateurSalle', 'Cinema' ,'Club', 'Studio', 'organisateurEvent']  # Correspond à l'ENUM TypeRole
            while len(existing_emails) < n:
                email = fake.user_email()
                if email in existing_emails:
                    continue
                username = fake.user_name()
                password = fake.password(length=12)
                email = fake.email()
                role = random.choice(roles)
                writer.writerow([username, password, email, role])
                existing_emails.add(email)
    except Exception as e:
        print(f"An error occurred while writing Utilisateurs.csv: {e}")

def generate_users(n):
    path = os.path.join(os.getcwd(), 'Utilisateurs.csv')  # Utilise le répertoire de travail courant
    try:
        with open(path, mode='w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(["username", "password", "email", "role"])
            existing_emails = set()
            existing_usernames = set()  # Pour assurer l'unicité des noms d'utilisateur
            roles = ['lamda', 'Realisateur', 'acteur', 'organisateurSalle', 'Cinema', 'Club', 'Studio', 'organisateurEvent']
            
            while len(existing_emails) < n:
                email = fake.email()
                if email not in existing_emails:
                    username = fake.user_name()
                    # Assurer que le nom d'utilisateur est unique
                    while username in existing_usernames:
                        username = fake.user_name()
                    
                    password = fake.password(length=12)
                    role = random.choice(roles)
                    writer.writerow([username, password, email, role])
                    existing_emails.add(email)
                    existing_usernames.add(username)  # Ajouter le nom d'utilisateur à l'ensemble
    except Exception as e:
        print(f"An error occurred while writing Utilisateurs.csv: {e}")
        
def generate_films(n):
    with open(os.path.join(base_path, 'films.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["id", "titre", "resume", "realisation", "duree"])
        for i in range(1, n+1):  # Utiliser i pour générer un ID unique pour chaque film
            titre = fake.sentence(nb_words=5)
            resume = fake.text(max_nb_chars=200)
            realisation = fake.date_this_century().isoformat()
            duree = random.randint(60, 180)
            writer.writerow([i, titre, resume, realisation, duree])


def generate_publications(n):
    path = os.path.join(base_path, 'publications.csv')
    with open(path, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["id", "auteur", "discussionId", "titre", "contenu", "datePublication", "parentId"])
        
        # Les parentId valides commencent à 1 et vont jusqu'à n, mais on utilise une publication comme parent pour les suivantes
        for i in range(1, n+1):
            auteur = random.randint(1, 100)  # Supposer que nous avons 100 utilisateurs max
            discussionId = random.randint(1, 50)  # Supposer que nous avons 50 discussions max
            titre = fake.sentence()
            contenu = fake.text()
            datePublication = fake.date_time_between(start_date="-1y", end_date="now").isoformat()
            
            # Chaque publication a un parentId, qui est un ID existant d'une publication précédente, sauf la première
            if i == 1:
                parentId = 2  # La première publication pourrait être de premier niveau si nécessaire
            else:
                parentId = random.randint(1, i-1)  # Assurer que le parentId est toujours un ID existant
                
            writer.writerow([i, auteur, discussionId, titre, contenu, datePublication, parentId])



# Table 'Role'
def generate_roles():
    roles = ['lamda', 'Realisateur', 'acteur', 'organisateurSalle', 'Cinema' ,'Club', 'Studio', 'organisateurEvent']
    with open(os.path.join(base_path, 'roles.csv'), mode='w', newline='') as file:

        writer = csv.writer(file)
        writer.writerow(["name"])
        for role in roles:
            writer.writerow([role])


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
def generate_series2(n, max_genre_id):
    with open(os.path.join(base_path, 'series.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["id", "saison", "titre", "nbreEpisodes", "dureeParEpisode", "datePremiere"])
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
            writer.writerow([id, saison, titre, nbreEpisodes, dureeParEpisode, datePremiere])
            used_ids.add(id)  # Ajouter l'ID à l'ensemble des ID utilisés

def generate_series(n, max_genre_id):
    path = os.path.join(base_path, 'series.csv')  # Conserve le chemin original basé sur base_path
    with open(path, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["id", "saison", "titre", "nbreEpisodes", "dureeParEpisode", "datePremiere"])
        
        for i in range(1, n + 1):  # Génération séquentielle des IDs de 1 à n
            saison = random.randint(1, 5)
            titre = fake.sentence(nb_words=4)
            nbreEpisodes = random.randint(8, 24)
            dureeParEpisode = random.randint(20, 60)
            datePremiere = fake.date_this_decade().isoformat()
            writer.writerow([i, saison, titre, nbreEpisodes, dureeParEpisode, datePremiere])

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
        writer.writerow(["idCategorie", "categorie"])
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
        writer.writerow(["id", "auteur", "titre", "description", "categorieId"])
        for i in range(1, n+1):
            idCreateur = random.randint(1, 100)  # Assuming 100 users
            titreDiscussion = fake.sentence(nb_words=5)
            description = fake.paragraph(nb_sentences=3)
            idCategorie = random.randint(1, 10)  # Assuming 10 categories
            writer.writerow([i, idCreateur, titreDiscussion, description, idCategorie])


# Table 'ParticipationEvent'
def generate_participation_event2(n, max_event_id):
    with open(os.path.join(base_path, 'participation_event.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idUser", "idEvent"])
        
        unique_pairs = set()
        
        while len(unique_pairs) < n:
            idUser = random.randint(1, 300)  # Assuming 100 users
            idEvent = random.randint(1, max_event_id)  # Utiliser max_event_id pour définir le nombre max d'événements
            
            # Créer une paire tuple de idUser et idEvent
            pair = (idUser, idEvent)
            
            # Vérifier si la paire est déjà dans l'ensemble
            if pair not in unique_pairs:
                writer.writerow([idUser, idEvent])
                unique_pairs.add(pair)  # Ajouter la paire à l'ensemble pour suivre l'unicité

def generate_participation_event(n, max_event_id):
    base_path = os.getcwd()  # Utilise le répertoire de travail courant
    with open(os.path.join(base_path, 'participation_event.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idUser", "idEvent"])
        
        unique_pairs = set()

        while len(unique_pairs) < n:
            idUser = random.randint(151, 300)  # Utiliser des ID utilisateurs de 151 à 300
            idEvent = random.randint(1, max_event_id)  # Utiliser max_event_id pour définir le nombre max d'événements
            
            if (idUser, idEvent) not in unique_pairs:
                writer.writerow([idUser, idEvent])
                unique_pairs.add((idUser, idEvent))


# Table 'Archive'
def generate_archive(n):
    with open(os.path.join(base_path, 'archive.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idArchive", "dateArchivage", "raison", "eventId"])
        for i in range(1, n+1):
            dateArchivage = fake.date_this_year().isoformat()
            raison = fake.sentence(nb_words=5)
            eventId = random.randint(1, 100)  # Assuming 100 publications
            writer.writerow([i, dateArchivage, raison, eventId])

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


def generate_reactions2(n, max_pub_id):
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

# def generate_reactions(n, max_pub_id):
#     path = os.path.join(base_path, 'reactions.csv')
#     with open(path, mode='w', newline='') as file:
#         writer = csv.writer(file)
#         writer.writerow(["id", "publiId", "userId", "typeR"])  # Ajout de la colonne 'id'
#         types = ['Like', 'Dislike', 'Neutre', 'Fun', 'Sad', 'Angry', 'Love']  # Assurez-vous que cela inclut tous les types possibles
#         valid_pub_ids = set(range(1, max_pub_id + 1))  # Assurez-vous que max_pub_id est le maximum réel dans 'publication'
#         used_pairs = set()
#         id_counter = 1  # Compteur pour les ID, commence à 1

#         while len(used_pairs) < n:
#             publiId = random.choice(list(valid_pub_ids))
#             userId = random.randint(1, 100)  # Supposer 100 utilisateurs max
#             pair = (publiId, userId)

#             if pair not in used_pairs:
#                 reaction_type = random.choice(types)
#                 writer.writerow([id_counter, publiId, userId, reaction_type])  # Ajout de l'ID à la ligne
#                 used_pairs.add(pair)
#                 id_counter += 1  # Incrémenter l'ID pour chaque nouvelle entrée




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
        writer.writerow(["id", "nom", "parent"])
        
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
            auteur = random.randint(1, 300)  # Assuming there are 100 users
            nomEvent = fake.sentence(nb_words=5)
            dateEvent = fake.date_between(start_date="today", end_date="+2y").isoformat()
            lieuEvent = fake.city()
            nbPlaceDispo = random.randint(50, 500)
            nbPlaceReserve = random.randint(0, nbPlaceDispo)  # Ensure this number is less than or equal to nbPlaceDispo
            organisateur = random.randint(1, 300) if random.choice([True, False]) else None
            
            # Generating between 1 and 5 random web links and formatting them as a PostgreSQL array
            liens_web = '{' + ', '.join([fake.url() for _ in range(random.randint(1, 5))]) + '}'

            writer.writerow([id, auteur, nomEvent, dateEvent, lieuEvent, nbPlaceDispo, nbPlaceReserve, organisateur, liens_web])

def generate_interesse_event2(n, max_user_id, max_event_id):
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

def generate_interesse_event(n, max_event_id):
    base_path = os.getcwd()  # Utilise le répertoire de travail courant
    with open(os.path.join(base_path, 'InteresseEvent.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["userId", "eventId"])
        
        unique_pairs = set()

        while len(unique_pairs) < n:
            userId = random.randint(1, 150)  # Utiliser des ID utilisateurs de 1 à 150
            eventId = random.randint(1, max_event_id)  # Utiliser max_event_id pour définir le nombre max d'événements
            
            if (userId, eventId) not in unique_pairs:
                writer.writerow([userId, eventId])
                unique_pairs.add((userId, eventId))

def generate_historique_publication2(n, max_user_id, max_publi_id):
    with open(os.path.join(base_path, 'historique_publication.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["userId", "publiId", "action", "dateAction"])
        
        actions = ["ajouter", "voir", "repondre à une publication"]  # Définir les types d'actions possibles

        for _ in range(n):
            idUser = random.randint(1, max_user_id)  # Choix d'un idUser existant
            idPubli = random.randint(1, max_publi_id)  # Choix d'un idPubli existant
            action = random.choice(actions)  # Sélection aléatoire d'une action
            dateAction = fake.date_between(start_date="-2y", end_date="today")  # Génération d'une date d'action

            writer.writerow([idUser, idPubli, action, dateAction])

# def generate_historique_publication(n, max_user_id, max_publi_id, max_reaction_id):
#     path = os.path.join(base_path, 'historique_publication.csv')
#     with open(path, mode='w', newline='') as file:
#         writer = csv.writer(file)
#         writer.writerow(["userId", "publiId", "action", "dateAction", "idReaction"])
        
#         actions = ["ajouter", "voir", "repondre à une publication"]  # Définir les types d'actions possibles

#         for _ in range(n):
#             userId = random.randint(1, max_user_id)  # Choix d'un userId existant
#             publiId = random.randint(1, max_publi_id)  # Choix d'un publiId existant
#             action = random.choice(actions)  # Sélection aléatoire d'une action
#             dateAction = fake.date_between(start_date="-2y", end_date="today").isoformat()  # Génération d'une date d'action
#             idReaction = random.randint(1, max_reaction_id) if action != "ajouter" else None  # Assumer une réaction si l'action n'est pas "ajouter"

#             # Vérifier si l'id de réaction est requis pour toutes les actions; si non, ajuster la condition ci-dessus
#             writer.writerow([userId, publiId, action, dateAction, idReaction])
            
def generate_historique_and_reactions2(histo_count, reaction_count, max_user_id, max_publi_id):
    historique_path = 'historique_publication.csv'
    reaction_path = 'reactions.csv'
    
    with open(historique_path, mode='w', newline='') as histo_file, \
         open(reaction_path, mode='w', newline='') as reaction_file:
        
        histo_writer = csv.writer(histo_file)
        reaction_writer = csv.writer(reaction_file)
        
        histo_writer.writerow(["userId", "publiId", "action", "dateAction", "idReaction"])
        reaction_writer.writerow(["id", "publiId", "userId", "typeR"])  # Ajout de la colonne 'id'
        
        actions = ["ajouter", "voir", "repondre à une publication"]  # Définir les types d'actions possibles
        types = ['Like', 'Dislike', 'Neutre', 'Fun', 'Sad', 'Angry', 'Love']  # Types de réactions
        used_pairs = set()
        id_counter = 1  # Compteur pour les ID des réactions
        
        # Générer les entrées de l'historique
        historique_entries = []
        for _ in range(histo_count):
            userId = random.randint(1, max_user_id)
            publiId = random.randint(1, max_publi_id)
            action = random.choice(actions)
            dateAction = fake.date_between(start_date="-2y", end_date="today").isoformat()
            idReaction = None  # Initialiser l'idReaction à None pour "ajouter" et autres
            
            if action != "ajouter":
                idReaction = id_counter
                reaction_type = random.choice(types)
                reaction_writer.writerow([id_counter, publiId, userId, reaction_type])
                id_counter += 1
            
            historique_entries.append((userId, publiId, action, dateAction, idReaction))
            histo_writer.writerow([userId, publiId, action, dateAction, idReaction])
            used_pairs.add((userId, publiId))
        
        # Générer les réactions additionnelles si nécessaire
        while len(used_pairs) < reaction_count:
            userId = random.randint(1, max_user_id)
            publiId = random.randint(1, max_publi_id)
            if (userId, publiId) in used_pairs:
                continue
            
            reaction_type = random.choice(types)
            reaction_writer.writerow([id_counter, publiId, userId, reaction_type])
            id_counter += 1
            used_pairs.add((userId, publiId))

def generate_historique_and_reactions(histo_count, reaction_count, max_user_id, max_publi_id):
    historique_path = 'historique_publication.csv'
    reaction_path = 'reactions.csv'
    
    with open(historique_path, mode='w', newline='') as histo_file, \
         open(reaction_path, mode='w', newline='') as reaction_file:
        
        histo_writer = csv.writer(histo_file)
        reaction_writer = csv.writer(reaction_file)
        
        histo_writer.writerow(["userId", "publiId", "action", "dateAction", "idReaction"])
        reaction_writer.writerow(["id", "publiId", "userId", "typeR"])  # Ajout de la colonne 'id'
        
        actions = ["ajouter", "voir", "repondre à une publication"]  # Définir les types d'actions possibles
        types = ['Like', 'Dislike', 'Neutre', 'Fun', 'Sad', 'Angry', 'Love']  # Types de réactions
        used_pairs = set()
        id_counter = 1  # Compteur pour les ID des réactions
        
        # Générer les entrées de l'historique
        historique_entries = []
        reaction_entries = []
        
        for _ in range(histo_count):
            userId = random.randint(1, max_user_id)
            publiId = random.randint(1, max_publi_id)
            action = random.choice(actions)
            dateAction = fake.date_between(start_date="-2y", end_date="today").isoformat()
            idReaction = None  # Initialiser l'idReaction à None pour "ajouter" et autres
            
            if action != "ajouter":
                if (publiId, userId) not in used_pairs:
                    idReaction = id_counter
                    reaction_type = random.choice(types)
                    reaction_entries.append([id_counter, publiId, userId, reaction_type])
                    used_pairs.add((publiId, userId))
                    id_counter += 1
            
            historique_entries.append([userId, publiId, action, dateAction, idReaction])
            used_pairs.add((publiId, userId))

        # Écrire les entrées de l'historique dans le fichier CSV
        for entry in historique_entries:
            histo_writer.writerow(entry)

        # Écrire les entrées de réaction dans le fichier CSV
        for entry in reaction_entries:
            reaction_writer.writerow(entry)

        # Générer les réactions additionnelles si nécessaire
        while len(reaction_entries) < reaction_count:
            publiId = random.randint(1, max_publi_id)
            userId = random.randint(1, max_user_id)
            if (publiId, userId) in used_pairs:
                continue
            
            reaction_type = random.choice(types)
            reaction_writer.writerow([id_counter, publiId, userId, reaction_type])
            reaction_entries.append([id_counter, publiId, userId, reaction_type])
            id_counter += 1
            used_pairs.add((publiId, userId))

def generate_film_genre(n, max_film_id, max_genre_id):
    path = os.path.join(base_path, 'film_genre.csv')
    with open(path, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["filmId", "genreId"])
        unique_pairs = set()  # Pour éviter les doublons

        while len(unique_pairs) < n:
            filmId = random.randint(1, max_film_id)
            genreId = random.randint(1, max_genre_id)

            if (filmId, genreId) not in unique_pairs:
                writer.writerow([filmId, genreId])
                unique_pairs.add((filmId, genreId))

def generate_serie_genre(n, max_serie_id, max_genre_id):
    path = os.path.join(base_path, 'serie_genre.csv')
    with open(path, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["serieId", "genre"])
        unique_pairs = set()  # Pour garantir l'unicité des associations

        while len(unique_pairs) < n:
            serieId = random.randint(1, max_serie_id)
            genreId = random.randint(1, max_genre_id)

            if (serieId, genreId) not in unique_pairs:
                writer.writerow([serieId, genreId])
                unique_pairs.add((serieId, genreId))

def generate_publication_event_part(n):
    with open('publication_event_part.csv', mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["publiId", "eventId"])
        publi_ids = range(1, 100)  # Assumer 100 publications existantes
        event_ids = range(1, 201)  # Assumer 200 événements existants
        pairs = set()

        while len(pairs) < n:
            pair = (random.choice(publi_ids), random.choice(event_ids))
            if pair not in pairs:
                writer.writerow(pair)
                pairs.add(pair)

def generate_publication_film(n):
    with open('publication_film.csv', mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["publiId", "FilmId"])
        publi_ids = range(1, 100)  # Assumer 100 publications existantes
        film_ids = range(1, 101)   # Assumer 100 films existants
        pairs = set()

        while len(pairs) < n:
            pair = (random.choice(publi_ids), random.choice(film_ids))
            if pair not in pairs:
                writer.writerow(pair)
                pairs.add(pair)

def generate_publication_serie(n):
    with open('publication_serie.csv', mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["publiId", "SerieId"])
        publi_ids = range(1, 100)  # Assumer 100 publications existantes
        serie_ids = range(1, 101)  # Assumer 100 séries existantes
        pairs = set()

        while len(pairs) < n:
            pair = (random.choice(publi_ids), random.choice(serie_ids))
            if pair not in pairs:
                writer.writerow(pair)
                pairs.add(pair)

# activation de ses fonctions
generate_genre_cinemato(24)  # Générer des genres cinématographiques, en assurant qu'il y en a assez pour les références

generate_users(300) 
generate_films(100)  
generate_series(100, 24)  # Générer 100 séries en s'assurant que les genres existent
generate_publications(100)  
generate_sujet_publication(10) 
generate_mots_cles(30)         
generate_categorie_discussion(10)  # Générer 10 catégories de discussion uniques
generate_discussions(50)    

generate_film_genre(100, 50, 24)  # Supposons que vous voulez 75 associations film-genre
generate_serie_genre(100, 100, 24)  # 100 associations série-genre

generate_archive(30)        
generate_commentaire(100)

# generate_reactions(600, 100)  # Générer 200 réactions pour 100 publications
generate_historique_and_reactions(1800,1900,300,100)
generate_message(50)             
# generate_notification(80) 

generate_roles()
generate_amis(100)
generate_follows(100)
generate_filme_publication(100)
generate_mots_cles_publication(100, 100, 30)  # Supposons que vous ayez 100 publications et 30 mots clés

generate_event_particulier(200)  # Generate 50 particular events
generate_interesse_event(700,200)  # Generate 200 entries with up to 100 users and 50 events
generate_participation_event(700,200)  # Générer 50 participations à des événements, avec un maximum de 20 événements différents

# generate_historique_publication(1800, 300,100,600)

generate_publication_event_part(100)
generate_publication_film(100)
generate_publication_serie(100)


