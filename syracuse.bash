#!/bin/bash

debut=$(date +%s)
ernbe='^[1-9]([0-9]+)?$'
repertoireData="dir-data"
repertoireGraph="dir-result"

# Test les parametres du script

if !(([[ $# -eq 1 ]] && [[ $1 = "-h" || $1 = "--help" || $1 = "-c" || $1 = "--clear" ]]) || ([[ $# -eq 2 ]] && [[ $1 =~ $ernbe && $2 =~ $ernbe ]] && [[ $1 -lt $2 ]] && [[ $1 -ne 0 ]]))
then 

	# Ici il y a une erreur dans les parametres et ils sont retester pour pouvoir afficher un message differents selon la situation et l'erreur
	
	if [[ $# -eq 1 ]] && !([[ $1 = "-h" || $1 = "--help" || $1 = "-c" || $1 = "--clear" ]])
	then
		echo "Erreur : option invalide -- '$1'"
	elif [[ $# -eq 2 ]] && !([[ $1 =~ $ernbe && $2 =~ $ernbe ]])
	then
		echo "Erreur : valeur entree invalide, les parametres doivent être des nombres entiers positifs -- '$1' et '$2'"
	elif [[ $# -eq 2 ]] && !([[ $1 -lt $2 ]])
	then
		echo "Erreur : valeur entree invalide, le premier parametre doit être inferieur au second -- '$1' et '$2'"
	elif [[ $# -eq 2 ]] && !([[ $1 -ne 0 ]])
	then
		echo "Erreur : valeur entree invalide, le premier paarmetre ne peut valoir 0 -- '$1' et '$2'"
	else
		echo "Erreur : nombre d'argument"
	fi
	echo "Utilisez l'option -h pour acceder l'aide"
	exit 1

elif [[ $# -eq 1 ]] && [[ $1 = "-h" || $1 = "--help" ]]
then

	# Ici l'utilisateur à demandé l'aide

	echo "Génère les graphs de la suite de syracuse sur un interval"
	echo "Syntaxe : ./syracuse.bash [U0Min] [U0Max] OU ./syracuse.bash [OPTION]"
	echo "U0Min : Borne inferieur de l'interval et U0Max : Borne superieur de l'interval"
	echo ""
	echo "  -c, --clear   Nettoie, supprime le dossier de sesultat avec les graps et les syntheses"
	echo "  -h, --help    Affiche l'aide du script"
	exit 1
elif [[ $# -eq 1 ]] && [[ $1 = "-c" || $1 = "--clear" ]]
then

	# Ici l'utilisateur à demandé de clear le fichier de résultat avec les graphs et les syntheses
	
	if [ -d $repertoireGraph ]
	then
		rm -rf $repertoireGraph/*
	fi
	exit 1
fi


# Ici le programme commence car les parametres ont été bien entrées


U0Min=$1
U0Max=$2

# On verifie si le repertoire de donnée existe et si oui on le supprime pour eviter tout problème/conflit

if [ -d $repertoireData ] && [ ! -L $repertoireData ] 
then
	rm -r $repertoireData
fi

# On peut maintent le recréer vide et y ajouter les fichiers d'altitude max, de durée de vol et de durée de vol en altitude

if [ ! -d $repertoireData ]
then
	mkdir $repertoireData
	touch $repertoireData/altitude.dat
	touch $repertoireData/dureevol.dat
	touch $repertoireData/dureealtitude.dat
else
	echo "Problème à la suppression du dossier de donnee"
	exit 1
fi

# On verifie que le dossier de resultat existe et on le crée le cas échéant

if [ ! -d $repertoireGraph ]
then
	mkdir $repertoireGraph
fi

repertoireSynthese="$repertoireGraph/Syntheses" 

# On verifie que dans le dossier de résultat il y a le dossier des synthèses et on le crée le cas échéant

if [ ! -d $repertoireSynthese ]
then
	mkdir $repertoireSynthese
fi

repertoireGraph="$repertoireGraph/graphs-$U0Min-$U0Max"

# On verifie que dans le dossier de résultat il y a le dossier des graphs pour les valeurs de U0Min et U0Max demandé et on le crée le cas échéant

if [ ! -d $repertoireGraph ]
then
	mkdir $repertoireGraph
fi

# C'est la boucle permettant de créer les fichiers de la suite de Syracuse pour chaque U0 
# puis on ajoute l'altitude max, la durée de vol et la durée de vol en altitude à leur fichier respectif

for ((i=$U0Min;i<=$U0Max;i++))
do
	nomFileData="$repertoireData/f$i.dat"
	./syracuse $i $nomFileData
	erreur=$?
	# Selon la valeur de retour de l'executable générant les suite, differents message d'erreur peuvent être afficher
	if !([[ $erreur =~ [0-3] ]]);then
		echo "Erreur retourné par l'executable syracuse non reconnu"
		exit 1
	elif [[ $erreur -eq 1 ]];then
		echo "Erreur du nombre d'argument de l'executable generant la suite de syracuse"
		exit 1
	elif [[ $erreur -eq 2 ]];then
		echo "Erreur du nombre passe en parametre de l'executable generant la suite de syracuse"
		exit 1
	elif [[ $erreur -eq 3 ]];then
		echo "Erreur lors de l'ouverture du fichier de donnee par l'executable generant la suite de syracuse "
		exit 1
	fi
	
	echo "$i "`tail -3 $nomFileData | head -1 | cut -d'=' -f2` >> $repertoireData/altitude.dat
	echo "$i "`tail -2 $nomFileData | head -1 | cut -d'=' -f2` >> $repertoireData/dureevol.dat
	echo "$i "`tail -1 $nomFileData | cut -d'=' -f2` >> $repertoireData/dureealtitude.dat
done


# Calcul des min max et moy des fichiers d'altitude max, de durée de vol et de durée de vol en altitude et ajout à un fichier de synthese

cut -d' ' -f2 $repertoireData/altitude.dat | awk 'NR == 1 { max=$1; min=$1; sum=0 } { if ($1>max) max=$1; if ($1<min) min=$1; sum+=$1;} 
	END {printf "altitudeMin=%d\naltitudeMax=%d\naltitudeMoy=%.2f\n\n", min, max, sum/NR}' > $repertoireSynthese/synthese-$U0Min-$U0Max.txt
cut -d' ' -f2 $repertoireData/dureevol.dat | awk 'NR == 1 { max=$1; min=$1; sum=0 } { if ($1>max) max=$1; if ($1<min) min=$1; sum+=$1;} 
	END {printf "dureevolMin=%d\ndureevolMax=%d\ndureevolMoy=%.2f\n\n", min, max, sum/NR}' >> $repertoireSynthese/synthese-$U0Min-$U0Max.txt
cut -d' ' -f2 $repertoireData/dureealtitude.dat | awk 'NR == 1 { max=$1; min=$1; sum=0 } { if ($1>max) max=$1; if ($1<min) min=$1; sum+=$1;} 
	END {printf "dureealtitudeMin=%d\ndureealtitudeMax=%d\ndureealtitudeMoy=%.2f\n", min, max, sum/NR}' >> $repertoireSynthese/synthese-$U0Min-$U0Max.txt


# Creation d'un fichier script gnuplot auquel on ajoute toute les instructions permettant de créer les 4 graphs

echo 'set terminal jpeg size 1920,1200' > gnu-script
echo 'set offset 0,0,1,0' >> gnu-script
echo 'set output "'$repertoireGraph'/syracuse-'$U0Min'-'$U0Max'-vols.jpg"' >> gnu-script
echo 'set title "Les vols"' >> gnu-script
echo 'set xrange [0:*]' >> gnu-script
echo 'set yrange [0:*]' >> gnu-script
echo 'set xlabel "n"' >> gnu-script
echo 'set ylabel "Un"' >> gnu-script
echo 'plot for [i='$U0Min':'$U0Max'] "'$repertoireData'/f".i.".dat" index 0 every ::1 using 1:2 title "" linecolor "blue" with lines' >> gnu-script
echo 'set output "'$repertoireGraph'/syracuse-'$U0Min'-'$U0Max'-altimax.jpg"' >> gnu-script
echo 'set title "Courbe des altitudes maximum"' >> gnu-script
echo 'set xrange ['$U0Min':'$U0Max']' >> gnu-script
echo 'set xlabel "U0"' >> gnu-script
echo 'set ylabel "Altitude maximum atteite"' >> gnu-script
echo 'plot "'$repertoireData'/altitude.dat" using 1:2 title "" linecolor "blue" with lines' >> gnu-script
echo 'set output "'$repertoireGraph'/syracuse-'$U0Min'-'$U0Max'-dureevol.jpg"' >> gnu-script
echo 'set title "Courbe des durée de vol"' >> gnu-script
echo 'set ylabel "Duree de vol"' >> gnu-script
echo 'plot "'$repertoireData'/dureevol.dat" using 1:2 title "" linecolor "blue" with lines' >> gnu-script
echo 'set output "'$repertoireGraph'/syracuse-'$U0Min'-'$U0Max'-dureealtitude.jpg"' >> gnu-script
echo 'set title "Courbe des durées en altitude ( >= U0 )' >> gnu-script
echo 'set ylabel "Duree de vol en altitude ( >= U0 )"' >> gnu-script
echo 'plot "'$repertoireData'/dureealtitude.dat" using 1:2 title "" linecolor "blue" with lines' >> gnu-script
echo 'unset offset' >> gnu-script


gnuplot gnu-script  	# Execution du script gnuplot permettant de créer les graphs
rm -f gnu-script		# Suppression du script gnuplot et du repertoire de donnée
rm -rf $repertoireData

# Affichage du temps d'execution du script

tmp=$(( $(date +%s ) - $debut ))
if [[ $tmp -lt 1 ]]
then [[ $tmp -lt 1 ]]
	echo "Le temps d'execution du script est < 1 sec"
elif [[ $tmp -lt 60 ]]
then
	echo "Le temps d'execution du script est de $tmp sec"
else
	min=$(($tmp/60))
	sec=$(($tmp-$min*60))
	echo "Le temps d'execution du script est de $min min $sec sec"
fi
