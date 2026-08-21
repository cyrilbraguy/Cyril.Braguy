# CV — Cyril Braguy

Source unique en Markdown (`resume.md`), mise en forme séparée (LaTeX pour le PDF,
CSS/HTML pour le web), sur le modèle décrit dans
[cet article](https://blog.genezini.com/p/creating-a-maintainable-resume-with-markdown-and-pandoc/).

Le rendu PDF reproduit le style du CV Word d'origine : bandeau supérieur (nom à
gauche, encart bleu marine avec coordonnées + photo à droite), sidebar grise à
gauche (Training, Education, Qualities, Strong Points, Hobbies), colonne
principale à droite avec une **colonne de dates** en face de chaque expérience.
Couleurs et bandes reprennent les couleurs exactes extraites du `.docx`
d'origine (bleu `#3E5282`, bandeau `#2C3A60`, fond sidebar `#EDEDED`).

## Structure

```
resume.md                       # tout le contenu — la seule chose à éditer au quotidien
images/photo.png                 # photo (reprise du docx d'origine)
templates/resume.latex           # template pandoc -> PDF (1 page, sidebar + dates, xelatex)
templates/resume.html.template   # template pandoc -> HTML (même mise en page, en CSS)
templates/resume.css             # style de la version HTML
templates/split-sidebar.lua      # filtre pandoc (voir plus bas)
dist/                             # fichiers générés — non versionnés
```

## Le contenu de `resume.md`

Tout est à plat, dans l'ordre naturel de lecture :

1. Le paragraphe de contact (adresse, tél, email, LinkedIn)
2. `## Profile`
3. `## Data Science & Machine Learning` puis ses `### Titre | Entreprise — Date`
4. `## Engineering Background` puis ses `### Titre | Entreprise — Date`
5. `## Training`, `## Education`, `## Qualities`, `## Strong Points`, `## Hobbies`

La convention `### Titre du poste | Entreprise — Année` (le `| Entreprise` est
optionnel, la date est toujours en dernier après un tiret cadratin `—`) est ce
qui permet au filtre de reconstruire automatiquement la colonne de dates.

## Le filtre `split-sidebar.lua`

Pour le PDF et le HTML (mise en page à 3 zones), le filtre :

1. Retire le paragraphe de contact et les sections `Training` / `Education` /
   `Qualities` / `Strong Points` / `Hobbies` du corps principal et les place
   dans des variables (`$sidebar-training$`, `$sidebar-qualities$`, etc.) que
   les templates affichent dans la colonne de gauche.
2. Repère chaque `### Titre | Entreprise — Date` restant dans le corps
   principal, en extrait la date, et enveloppe l'entrée dans une petite
   structure à deux colonnes (date à gauche, contenu à droite) — un
   environnement LaTeX (`cventry`) pour le PDF, une `<div class="entry">` pour
   le HTML.

Le DOCX est généré **sans** ce filtre : tout reste linéaire, dans l'ordre du
fichier source, dates incluses dans le texte du titre (pas de sidebar colorée
ni de colonne de dates séparée — Pandoc ne permet pas ce niveau de mise en
page custom pour le `.docx` sans repartir sur du XML manuel).

**Conséquence pratique :** un seul fichier à modifier (`resume.md`), aucune
duplication de contenu entre les formats.

## Qualities — remarque

Dans le `.docx` d'origine, chaque qualité (Rigor, Curiosity, …) est suivie
d'une barre colorée, mais en inspectant le XML, cette barre a la même largeur
pour toutes les qualités : c'est un élément décoratif, pas une jauge de niveau
variable. Le rendu ici reprend ce parti pris (un simple marqueur carré coloré
devant chaque mot) plutôt que d'inventer des niveaux de maîtrise qui n'étaient
pas dans le fichier source.

## Prérequis

- [pandoc](https://pandoc.org/installing.html)
- Une distribution LaTeX avec `xelatex` (TeX Live complet, MacTeX ou MiKTeX)

## Génération

```bash
make          # pdf + html + docx dans dist/
make pdf
make html
make docx
```

## Workflow Git pour gérer les versions envoyées en candidature

- `main` : version générique à jour.
- Une branche (ou un tag) par candidature ciblée :
  `git checkout -b candidature/entreprise-x`, on adapte le profil/les
  mots-clés, on génère le PDF, on tag (`git tag cand-entreprise-x`) pour
  retrouver exactement ce qui a été envoyé.
- Le diff Markdown reste lisible dans `git log -p` / `git diff`,
  contrairement à un `.docx`.

## Si le contenu dépasse une page après une mise à jour

Dans `templates/resume.latex` : réduire la police de base (`9pt` →
`8.5pt`), resserrer `itemsep`/`vspace` dans `cvheader`/`cventry`, ou
raccourcir les puces les plus longues dans `resume.md`.

## Idées d'évolution

- `.github/workflows/build.yml` pour générer le PDF à chaque push et le
  publier en artifact/release.
- `resume.fr.md` pour une version française (mêmes templates).

- remplace le cv principal par la version generee
- fais un markdown avec l'entete , la photo, les 2 colonnes un peu comme le pdf... et des boutons : get pdf, get .html

corrections du 21/08 : 
regarde dans le .pdf : reduis l'espace vertical entre les totres et les filigranes, mets 2 ou 3 pts, et dis moi ou se trouve le parametre

ensuite ajuste les espacements de la partie experiences pour que tout tienne sur une seule page, je vais te donner mon dernier pdf et .latex 

et modifie le .md pour enlever tous les — qui sont des caracteres trahissant l'aide de llm pour faire le document, mets un ; ou un - ou un autre caractere ; 

remplace les — avant les noms d'entreprise dans le pdf par des -

