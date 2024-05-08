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
        writer.writerow(["titre", "resume", "realisation", "duree", "genre"])
        for _ in range(n):
            titre = fake.sentence(nb_words=5)
            resume = fake.text(max_nb_chars=200)
            realisation = fake.date_this_century().isoformat()
            duree = random.randint(60, 180)
            genre = fake.word()  # Supposons que le genre correspond au nom d'un genre déjà existant
            writer.writerow([titre, resume, realisation, duree, genre])

def generate_publications(n):
    with open(os.path.join(base_path, 'publications.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["auteur", "titre", "contenu", "datePublication"])
        for _ in range(n):
            auteur = random.randint(1, 100)  # Supposons 100 utilisateurs
            titre = fake.sentence(nb_words=6)
            contenu = fake.text(max_nb_chars=500)
            datePublication = fake.date_time_this_year().isoformat()
            writer.writerow([auteur, titre, contenu, datePublication])

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
        for _ in range(n):
            userId = random.randint(1, 100)
            follower = random.randint(1, 100)
            while userId == follower:
                follower = random.randint(1, 100)
            writer.writerow([userId, follower])

# Table 'Serie'
def generate_series(n):
    with open(os.path.join(base_path, 'series.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["id", "saison", "titre", "nbreEpisodes", "dureeParEpisode", "datePremiere", "genre"])
        for _ in range(n):
            id = random.randint(1, 10)
            saison = random.randint(1, 5)
            titre = fake.sentence(nb_words=4)
            nbreEpisodes = random.randint(8, 24)
            dureeParEpisode = random.randint(20, 60)
            datePremiere = fake.date_this_decade().isoformat()
            genre = random.randint(1, 10)  # Supposons que les genres sont numérotés de 1 à 10
            writer.writerow([id, saison, titre, nbreEpisodes, dureeParEpisode, datePremiere, genre])

def generate_events(n):
    with open(os.path.join(base_path, 'events.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["dateEvent", "lieuEvent", "nomEvent", "nbPlaceDispo", "nbPlaceReserve", "idOrganisateur"])
        for _ in range(n):
            dateEvent = fake.date_between(start_date="today", end_date="+2y").isoformat()
            lieuEvent = fake.city()
            nomEvent = fake.sentence(nb_words=5)
            nbPlaceDispo = random.randint(50, 500)
            nbPlaceReserve = random.randint(0, nbPlaceDispo)  # Assurez-vous que ce nombre est inférieur ou égal à nbPlaceDispo
            idOrganisateur = random.randint(1, 100)
            writer.writerow([dateEvent, lieuEvent, nomEvent, nbPlaceDispo, nbPlaceReserve, idOrganisateur])

# Ajouter d'autres fonctions similaires pour générer des données pour 'SujetPublication', 'MotsCles', 'CategorieDiscussion', 'Discussion', 'ParticipationEvent', 'Archive', 'Commentaire', 'Reaction', 'Message', 'Notification' etc.

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
def generate_participation_event(n):
    with open(os.path.join(base_path, 'participation_event.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idUser", "idEvent"])
        for _ in range(n):
            idUser = random.randint(1, 100)  # Assuming 100 users
            idEvent = random.randint(1, 20)  # Assuming 20 events
            writer.writerow([idUser, idEvent])

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
def generate_reaction(n):
    with open(os.path.join(base_path, 'reaction.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idReaction", "idPubli", "idUser", "type"])
        types = ['Like', 'Dislike', 'Neutre', 'Fun', 'Sad', 'Angry']
        for i in range(1, n+1):
            idPubli = random.randint(1, 100)
            idUser = random.randint(1, 100)
            type = random.choice(types)
            writer.writerow([i, idPubli, idUser, type])

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
def generate_mots_cles_publication(n):
    with open(os.path.join(base_path, 'mots_cles_publication.csv'), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["idPubliMotCle", "idPublication", "idMotCle"])
        for i in range(1, n+1):
            idPublication = random.randint(1, 100)
            idMotCle = random.randint(1, 30)  # Assuming 30 mots clés
            writer.writerow([i, idPublication, idMotCle])

# activation de ses fonctions
            
generate_users(100)  # Générer 100 utilisateurs
generate_films(50)   # Générer 50 films
generate_publications(100)  # Générer 100 publications

generate_sujet_publication(10)  # Generate 10 sujet publication entries
generate_mots_cles(30)          # Generate 30 unique mots clés
generate_categorie_discussion(10)  # Generate 10 unique categories
generate_discussions(50)        # Generate 50 discussions

generate_participation_event(50)  # Generate 50 event participations
generate_archive(30)              # Generate 30 archive entries
generate_commentaire(100)         # Generate 100 comments
generate_reaction(200)            # Generate 200 reactions
generate_message(150)             # Generate 150 messages
generate_notification(80)         # Generate 80 notifications

generate_roles()
generate_amis(100)
generate_follows(100)
generate_filme_publication(100)
generate_mots_cles_publication(100)
generate_series(100)

