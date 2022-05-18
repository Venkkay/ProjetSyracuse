#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>


// Fonction générant la suite de syracuse

int calculSuite(long U0, char nomFichier[]){
    //Initialisations
    FILE* fichier;
    long Un = U0;
    int index = 0;
    long altiMax = U0;
    int dureeAltitude = 1;
    int comptDureeAltitude = 1;
    float resultat = 0;
    fichier = fopen(nomFichier, "w");
    if(fichier == NULL){
        return 3;           // Retour d'un code d'erreur si le fichier de donnée n'a pas pu être ouvert
    }

    fprintf(fichier, "n Un\n");
    fprintf(fichier, "0 %ld\n", U0);

    // Boucle tant que Un est different de 1
    while (Un != 1){
        if(Un%2 == 0){              // Cas Un est pair
            resultat = Un/2;
            Un = (long)resultat;
        }
        else{                       // Cas Un est impair
            resultat = Un*3 +1;
            Un = (long)resultat;
        }
        if(altiMax < Un){           // Recherche de la valeur max de Un, correspondante à l'altitude max
            altiMax = Un;
        }
        if(Un >= U0){               // Recherche de la durée max de des valeurs superieurs ou égales à U0, correspondate à la durée en altitude
            comptDureeAltitude++;
        }
        else if(dureeAltitude < comptDureeAltitude){
            dureeAltitude = comptDureeAltitude;
            comptDureeAltitude = 0;
        }
        else{
            comptDureeAltitude = 0;
        }
        index++;
        fprintf(fichier, "%d %ld\n", index, Un);    // Ajout de chaque valeur de la suite dans un fichier
    }
    // Ajout des donnée supplémentaire : altitude max, durée de vol et durée en altitude
    fprintf(fichier,"\n\naltimax=%ld\ndureevol=%d\ndureealtitude=%d", altiMax, index, dureeAltitude);   // Ajout des donnée supplémentaire : altitude 
    fclose(fichier);
    return 0;
}

int main(int argc, char **argv){

    // Test du nombre de parametre et retour d'un code d'erreur en cas de problème
    if(argc != 3){
        return 1;
    }
    
    // Test si le 2eme parametre est bien un nombre entier positif differents de 0 et retourn un code d'erreur en cas de problème
    char* endPtr;
    long value = strtol(argv[1], &endPtr, 10);
    if(strcmp(endPtr, "") != 0 || value == 0 || value != labs(value)){
        printf("pb\n");
        return 2;
    }

    // Génère la suite de syracuse et récupère un code selon la situation : 0, tout va bien et 3, il y a un problème à l'ouverture du fichier
    int retour = calculSuite(value, argv[2]);

    // Renvoi le code de retour de la fonction calculSuite()
    return retour;
}
