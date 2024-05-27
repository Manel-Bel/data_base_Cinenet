# Projet_BD

Commandes:

1.  to start/end the server : sudo service postgresql start / sudo service postgresql stop
2.  run : psql
3.  execute a file  : \\i tp2.sql     (or the path)
4.  to check the tables: \\d
5.  to connect to cinenet databse: \\c cinenet;

- Correspandence des fichiers
  - a. fichier tables.sql :
    - contient les requêtes pour la création des tables et éventuellement les vues
  - b. requtes.sql :
    - contient 20+ requêtes demandées
  - c. peuplement.sql :
    - contient les instructions pour copier les données des fichiers vers les tables correspondantes
  - d. data_generator.py :
    - contient les fonctions pour filtrer et nettoyer les données des fichiers Csv
  - e. algorecommendation.sql :
    - contient l'algorithme et les étapes suivies pour la création d'un indice de recommandations
  - requete_para.sql
    - Contient les requêtes paramétrées de recherche préparées
  - script.sql :
    - Contient les requêtes pour la saisie du prompt et l'exécution de chaque requête paramétrée


-pour cree les tables : \i tables.sql
-pour peupler les tables : \i peuplement.sql
-les requetes demandées sont dans requetes.sql
-ceux avec recherche dans requete_para.sql et script.sql
-Algorithme de recommendation : \i algorecommendation.sql
-SchemaER represente le schema ER de notre base de données
-data_generator.py est un fichier python qui contient des fonctions qui cree les fichiers CSV -- peuplement des tables (puisque les fichiers sont deja remplis il est inutile d'executer ce fichier)

