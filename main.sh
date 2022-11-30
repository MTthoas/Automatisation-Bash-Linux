#!/bin/bash

if [ $(id -u) -ne 0 ]; then
    echo "Vous n'etes pas l'administrateur"
else

echo "Entrez "1" pour ajouter un utilisateur";
echo "Entrez "2" Modifier un utilisateur";
echo "Entrez "3" Supprimer un utilisateur";
echo "Entrez "4" Sortir du script"; 
echo "";

echo "Le code est-il interactif ? (O/N)"
read interactif

choix=0;

if [ $interactif = "O" ]; then
    read -p "Entrez votre choix: " choix;
else
    echo "Le code n'est pas interactif"
    iteration=0;
    File="interact.txt"
    if grep -q "create" "$File" ; then
        if grep -q "modify" "$File" ; then
            if grep -q "delete" "$File" ; then
                iteration=$((iteration+1))
            fi
            iteration=$((iteration+1))
        fi
        iteration=$((iteration+1))
    fi
fi

    if(($choix == 1)); then

        echo "Entrez le nombre d'utilisateurs à créer : "
        read nb
        for ((i=1; i<=$nb; i++))
        do

            while true;
            do
                echo "Entrez le nom de l'utilisateur $i : "
                read nom
                if getent passwd $nom > /dev/null 2>&1; then
                    echo "L'utilisateur $nom existe déjà"
                    continue
                fi
                break

            done;

            while true
            do

                echo "Entrez le chemin du répertoire de l'utilisateur $nom : "
                read chemin

                    if [ -d $chemin ]; then
                        echo "Le répertoire existe déjà"
                        continue
                    fi

                    if [ -z $chemin ]; then

                    echo "Le chemin est vide" 
                    continue

                    fi

                    if [ ! ${chemin:0:1} = '/' ]; then
                        echo "Le chemin doit commencer par '/'"
                        continue
                    fi

                    break
    
                done

                while true
                do

                    echo "Entrez la date d'expiration de l'utilisateur sous ce format ( 2001-01-24 ) : "
                    read dateVar

                    if [ -z $dateVar ]; then

                        echo "La date est vide" 
                        continue

                    fi

                    while [[ ! $dateVar =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; do
                        echo "Mauvais format de date"
                        echo "Entrez la date d'expiration de l'utilisateur sous ce format ( 2001-01-24 ) : "
                        read dateVar
                    done

                    echo "Date : $dateVar"
                         
                    if [ $dateVar \< $(date +%Y-%m-%d) ];
                        then
                            echo "La date d'expiration doit être supérieure à la date du jour"
                        else
                            break
                    fi
                        
                done

                    while true;
                    do

                        echo "Entrez le mot de passe de l'utilisateur $nom : "
                        read -s mdp

                        if [ -z $mdp ]; then

                            echo "Le mot de passe est vide" 
                            continue

                        fi

                        echo "Entrez à nouveau le mot de passe de l'utilisateur $nom : "
                        read -s pass2

                        if [ -z $pass2 ]; then

                            echo "Le mot de passe est vide" 
                            continue

                        fi 

                        if [ $mdp != $pass2 ]; then
                            echo "Les mots de passe ne correspondent pas"
                            continue
                        fi

                        break

                    done;


                    while true; do

                        echo "Entrez l'ID de l'utilisateur $nom : "
                        read id

                        if [ -z $id ]; then

                            echo "L'id est vide" 
                            continue

                        fi

                        if grep -q $id /etc/passwd
                        then
                            echo "L'id $id existe déjà"
                        else
                            echo "L'id $id n'existe pas, il sera donc créé"
                            break  
                        fi

                    done

                    echo "Entrez le shell de l'utilisateur $nom : "
                    read shell

                    while true; do

                        if [ -z $shell ]; then
                            echo "Le shell est vide"
                            echo "Entrez le shell de l'utilisateur $nom : "
                            read shell
                            continue
                        fi

                        if grep -q $shell /etc/shells
                        then
                            echo "Le shell existe, pas besoin d'installation"
                        else
                            echo "Le shell n'existe pas, installation en cours"
                            ln -s dash  $shell    
                        fi

                        break

                    done

                    echo "Le shell $shell a été ajouté avec succès"

                    useradd -m -p $mdp -d $chemin -u $id -e $dateVar $nom --shell $shell      

                    # echo "Ajout du SHELL dans le chemin $chemin"
                    # cp main.sh $chemin

                    echo "L'utilisateur $nom a été ajouté avec succès"
                    
            done
    fi

    if(($choix == 2)); then

        while true; do

            echo "Entrez un nom d'utilisateur à modifier : "
            read nameModif

            if [ -z $nameModif ]; then

                echo "Le nom est vide" 
                continue

            fi
        
            if grep -q $nameModif /etc/passwd
            then
                break
            else
                echo "L'user n'existe pas" 
            fi

        done

        while true
        do

        if [ $(id -u) -eq 0 ]; then
            echo ""
            echo "Entrez "1" pour : Modifier le nom de l'utilisateur"
            echo "Entrez "2" pour : Modifier le chemin du répertoire de l'utilisateur"
            echo "Entrez "3" pour : Modifier la date d'expiration de l'utilisateur"
            echo "Entrez "4" pour : Modifier le mot de passe de l'utilisateur"
            echo "Entrez "5" pour : Modifier le shell de l'utilisateur"
            echo "Entrez "6" pour : Modifier l'ID de l'utilisateur"
            echo "Entrez "7" pour : Quittez le programme"
            echo ""
            read -p "Entrez votre choix : " choix; echo ""
            
                case $choix in

                    1)

                    while true; do

                        read -p "1 ) Entrez le nouveau nom d'utilisateur de $nameModif : " nomModifed

                        if [ -z $nomModifed ]; then

                            echo "Le nom est vide" 
                            continue

                        fi

                       if getent passwd $nomModifed > /dev/null 2>&1; then
                            echo "Le nom d'utilisateur $nomModifed existe déjà"
                            continue
                        else
                            break  
                        fi

                    done

                    usermod -l $nomModifed $nameModif
                    echo "Le nom de l'utilisateur $nameModif a été modifié avec succès"
                    ;;

                    2) 

                    while true
                    do
                        read -p "2 ) Le nouveau chemin du dossier utilisateur de $nameModif : " PathModified

                        if [ -d $PathModified ]; then
                            echo "Le répertoire existe déjà"
                            continue
                        fi

                        if [ -z $PathModified ]; then

                        echo "Le chemin est vide" 
                        continue

                        fi

                        if [ ! ${PathModified:0:1} = '/' ]; then
                            echo "Le chemin doit commencer par '/'" 
                            continue
                        fi

                        break
        
                    done

                    usermod -d $PathModified $nameModif
                    mv $PathModified $PathModified/$nameModif
                    echo "Le chemin du dossier utilisateur de $nameModif a été modifié avec succès"
                    ;;
                    
                    3) 

                    while true
                    do

                        read -p "3 ) Entrez la nouvel date date d’expiration de $nameModif : " DateModified

                        if [ -z $DateModified ]; then

                            echo "La date est vide" 
                            continue

                        fi

                        while [[ ! $DateModified =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; do
                            echo "Mauvais format de date"
                            echo "Entrez la date d'expiration de l'utilisateur sous ce format ( 2001-01-24 ) : "
                            read DateModified
                        done
                            
                        if [ $DateModified \< $(date +%Y-%m-%d) ];
                            then
                                echo "La date d'expiration doit être supérieure à la date du jour"
                            else
                                break
                        fi
                        
                    done

                    usermod -e $DateModified $nameModif
                    echo "La date d’expiration de $nameModif a été modifié avec succès"
                    ;;
                    4) 
                    while true; do

                        read -p "4 ) Entrez le nouveau mot de passe de $nameModif : " PassModified


                        if [ -z $PassModified ]; then

                            echo "Le mot de passe est vide" 
                            continue

                        fi

                        break

                    done

                    usermod -p $PassModified $nameModif
                    ;;
                    5) 

                    while true; do

                        read -p "5 ) Entrez le nouveau SHELL de $nameModif : " ShellModified

                        if [ -z $ShellModified ]; then
                            echo "Le shell est vide"
                            continue
                        fi

                        if grep -q $ShellModified /etc/shells
                        then
                            continue
                        else
                            echo "Le shell n'existe pas, installation en cours"
                            ln -s dash $shell    
                        fi

                        break

                    done

                    usermod -s $ShellModified $nameModif
                    ;;


                    6) 
                    
                    while true; do

                        read -p "6 ) Entrez le nouvel ID de $nameModif : " IdModified

                        if [ -z $IdModified ]; then

                            echo "L'ID est vide" 
                            continue

                        fi

                        if grep -q $IdModified /etc/passwd
                        then
                            echo "L'id $IdModified existe déjà"
                        else
                            break  
                        fi

                    done

                    usermod -u $IdModified $nameModif
                    echo "L'ID de $nameModif a été modifié avec succès"
                    
                    ;;
                    7) echo "Vous etes sorti du script"; exit;
                    ;;
                    *) echo "Choix invalide"
                    ;;
                esac

        else
            echo "Vous n'êtes pas root"
        fi

        done

    fi

    if(($choix == 3)); then

        errorVar=0

        while true; do

            echo "Entrez un nom d'utilisateur à supprimer : "; read nameDelete
        
            if ! grep -q $nameDelete /etc/passwd
            then
                errorVar=1
                break
            fi

            echo "Voulez-vous supprimer le dossier utilisateur ? (O/N)"; read rep  

            if [ $rep = "O" ]; then
                echo "Voulez-vous supprimer l'utilisateur même si il est connecté ? (O/N)"; read repForce

                if [ $repForce = "O" ]; then
                    {
                    deluser --remove-home -f $nameDelete
                    } || { 
                        errorVar=2
                        break
                    }
                else
                    {
                    userdel -r $nameDelete
                    } || { 
                    echo "Erreur lors de la suppression de l'utilisateur $nameDelete"
                        errorVar=3
                        break
                    }
                fi


            elif [ $rep = "N" ]; then

                 echo "Voulez-vous supprimer l'utilisateur même si il est connecté ? (O/N)"; read repForce

                    if [ $repForce = "O" ]; then
                    {
                    userdel -f $nameDelete
                    } || { 
                        errorVar=4
                        break
                    }

                    else

                    {
                    userdel $nameDelete
                    } || { 
                        errorVar=5
                        break
                    }
                    fi

            else

                error=6;
                break

            fi

            done
                
                case $errorVar in
                    0) echo "L'utilisateur $nameDelete a été supprimé avec succès"
                    ;;
                    1) echo "L'utilisateur $nameDelete n'existe pas"
                    ;;
                    2) echo "Erreur lors de la suppression de l'utilisateur $nameDelete"
                    ;;
                    3) echo "Erreur lors de la suppression de l'utilisateur $nameDelete"
                    ;;
                    4) echo "Erreur lors de la suppression de l'utilisateur $nameDelete"
                    ;;
                    5) echo "Erreur lors de la suppression de l'utilisateur $nameDelete"
                    ;;
                    6) echo "Erreur du problème"
                    ;;
                esac     

    fi


fi