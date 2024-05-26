**Utilisateur** (_id_utilisateur_, nom_utilisateur, mot_de_passe, id_role, email)

- Utilisateur\[id_role\] ⊆ Role\[id_role\]
- Unique email

**Role** (_id_role_, nom_role)

**Ami** (_utilisateur_id_1_, _utilisateur_id_2_)

- Ami\[utilisateur_id_1\] ⊆ Utilisateur\[id_utilisateur\]
- Ami\[utilisateur_id_2\] ⊆ Utilisateur\[id_utilisateur\]
- Contraintes :
  - _utilisateur_id_1  !=   utilisateur_id_2_
  - si le couple (a,b) --> pas de (b,a)

**Suivre** (_utilisateur_id_suiveur_, _utilisateur_id_suivi_)

- Suivre\[utilisateur_id_suiveur\] ⊆ Utilisateur\[id_utilisateur\]
- Suivre\[utilisateur_id_suivi\] ⊆ Utilisateur\[id_utilisateur\]
- Contraintes :
  - _utilisateur_id_suiveur  !=  utilisateur_id_suivi_

**Discussion** (_id_discussion_, id_cd)

- Discussion\[id_cd\] ⊆ CategorieDiscussion\[id_cd\]

**CategorieDiscussion** (_id_cd_, nom_cd)

- Unique nom_cd

**Publication** (_id_publication_, description, utilisateur_id, discussion_id)

- Publication\[utilisateur_id\] ⊆ Utilisateur\[id_utilisateur\]
- Publication\[discussion_id\] ⊆ Discussion\[id_discussion\]

**Reaction** (_utilisateur_id_, _publication_id_)

- Reaction\[utilisateur_id\] ⊆ Utilisateur\[id_utilisateur\]
- Reaction\[publication_id\] ⊆ Publication\[id_publication\]

**MotCle** (_id_mot_cle_, nom_mot_cle)

- Unique nom_mot_cle

**EvenementParticulier** (_id_evenement_, date, prix, lieu)

- Unique (titre, date, lieu)

**Participer** (_utilisateur_id_, _evenement_id_, participation_type)

- Participer\[utilisateur_id\] ⊆ Utilisateur\[id_utilisateur\]
- Participer\[evenement_id\] ⊆ EvenementParticulier\[id_evenement\]

**Organiser** (_utilisateur_id_, _evenement_id_)

- Organiser\[utilisateur_id\] ⊆ Utilisateur\[id_utilisateur\]
- Organiser\[evenement_id\] ⊆ EvenementParticulier\[id_evenement\]

**Archive** (_id_archive_, evenement_id)

- Archive\[evenement_id\] ⊆ EvenementParticulier\[id_evenement\]
- Unique evenement_id

**Genre** (_id_genre_, description, id_genre_parent)

- Genre\[id_genre_parent\] ⊆ Genre\[id_genre\]
- Unique description

**Film** (_id_film_,titre, resume, durée, realisation)

**Serie** (_id_serie_,titre, resume, durée, saison )

**FilmGenre** (_film_id_, genreId)

- FilmGenre\[film_id\] ⊆ Film\[id_film\]
- FilmGenrer\[genreId\] ⊆ Genre\[id_genre\]
