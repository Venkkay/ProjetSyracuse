# ProjetSyracuse
Projet de seconde d'année sur les suite de syracuse


La conjecture de Syracuse			 Velay Lucas   Gautier Jordan   
11/02/2022

Informations générales :

Ce programme permet d'utiliser la suite de Syracuse afin de créer plusieurs graphes contenant les informations recherchés.

Tout d'abord il y a un programme syracuse.c qui effectue la suite de Syracuse pour toutes les valeurs rentrées en paramètre et les renvoies avec des données complémentaires qui 
sont l'altitude maximum, la durée du vol et la durée à l'altitude maximum.
Ensuite il y a un script syracuse.bash qui prend en paramètre deux nombres, exécute le .c pour toutes les valeurs comprises entre ces deux nombres et enfin créer des graphes 
pour les valeurs obtenues ainsi que pour les données complémentaires.

Démarrage :

Afin d'exécuter le programme Syracuse, il faut aller sur un invite de commandes, puis faire le chemin jusqu'au dossier contenant tous les fichiers fournis.

Ensuite il faut effectuer la commande suivante avec nombre1 et nombre2 les deux valeurs définissant l’intervalle sur lequel on souhaite exécuter le programme :

./syracuse.bash [U0Min] [U0Max] OU ./syracuse.bash [OPTION]
U0Min : Borne inferieur de l'interval et U0Max : Borne superieur de l'interval

Options :
	-c, --clear   Nettoie, supprime le dossier de sesultat avec les graps et les syntheses"
	-h, --help    Affiche l'aide du script"


Exemple :
./syracuse.bash 50 1050 
