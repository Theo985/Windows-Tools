@echo off
setlocal EnableDelayedExpansion

:: Version actuelle du script
set "LOCAL_VERSION=v1.0.0"

:: URL vers la dernière version et la dernière version.txt sur GitHub
set "REMOTE_SCRIPT_URL=https://github.com/Theo985/Windows-Tools/blob/main/batsh%20tools.bat"
set "REMOTE_VERSION_URL=https://github.com/Theo985/Windows-Tools/blob/main/version.txt"

:: Dossier temporaire
set "TMP_FILE=%TEMP%\script_update.tmp"
set "TMP_VER=%TEMP%\version_check.tmp"

:: Téléchargement de version.txt
powershell -Command "Invoke-WebRequest -Uri '%REMOTE_VERSION_URL%' -OutFile '%TMP_VER%' -UseBasicParsing" >nul 2>&1

if not exist "%TMP_VER%" (
    echo ❌ Impossible de vérifier les mises à jour.
    goto :SKIP_UPDATE
)

set /p REMOTE_VERSION=<%TMP_VER%
del "%TMP_VER%"

if "!LOCAL_VERSION!" == "!REMOTE_VERSION!" (
    echo ✅ Script à jour [!LOCAL_VERSION!]
    goto :SKIP_UPDATE
) else (
    echo 🔄 Mise à jour disponible: !LOCAL_VERSION! → !REMOTE_VERSION!
)

:: Télécharger et remplacer le script
powershell -Command "Invoke-WebRequest -Uri '%REMOTE_SCRIPT_URL%' -OutFile '%TMP_FILE%' -UseBasicParsing" >nul 2>&1

if not exist "%TMP_FILE%" (
    echo ❌ Échec du téléchargement de la mise à jour.
    goto :SKIP_UPDATE
)

copy /Y "%TMP_FILE%" "%~f0" >nul
del "%TMP_FILE%"

echo ✅ Mise à jour réussie. Redémarrage...
timeout /t 2 >nul
start "" "%~f0"
exit /b

:SKIP_UPDATE


@echo off
title Tools
color 0B

:: Vérifie si le script a les droits admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Ce script doit etre execute en tant qu'administrateur.
    pause
    exit /b
)

:MENU
cls
echo ============================
echo        TOOLS
echo ============================
echo 1. Voir les fichiers du dossier courant
echo 2. Information Systeme
echo 3. Menu Anti-Virus
echo 4. Menu Réseau
echo 5. Menu Utilisateurs et Sécurité
echo 6. Menu Sauvegarde et Restauration
echo 7. Menu Personnalisation
echo 8. Menu Region
echo 9. Menu Optimisation
echo 10. Quitter
echo ============================
set /p choix="Choisis une option : "

if "%choix%"=="1" goto FILES
if "%choix%"=="2" goto INFO_SYSTEME
if "%choix%"=="3" goto MENU_VIRUS
if "%choix%"=="4" goto MENU_RESEAU
if "%choix%"=="5" goto MENU_USERS
if "%choix%"=="6" goto MENU_SAUVEGARDE
if "%choix%"=="7" goto MENU_PERSONNALISATION
if "%choix%"=="8" goto MENU_REGIONS
if "%choix%"=="9" goto MENU_OPTIMISATION
if "%choix%"=="10" goto END
goto MENU



:MENU_VIRUS
cls
echo ============================
echo        TOOLS
echo ============================
echo 1. Revenir
echo 2. Ouvrir Windows Defender
echo 3. Retirer l'antivirus temporairement
echo 4. Retirer l'antivirus totalement (permanent)
echo 5. Reactiver totalement l'antivirus
echo 6. Reactiver l'antivirus temporairement
echo 7. Scanner antivirus (rapide ou complet)
echo 8. Mettre a jour antivirus
echo 9. Afficher le statut antivirus
echo ============================
set /p choix="Choisis une option  : "

if "%choix%"=="1" goto MENU
if "%choix%"=="2" goto DEFENDER
if "%choix%"=="3" goto TEMP_DISABLE
if "%choix%"=="4" goto FULL_DISABLE
if "%choix%"=="5" goto FULL_ACTIVATE
if "%choix%"=="6" goto TEMP_REACTIVATE
if "%choix%"=="7" goto ANTIVIRUS_SCAN
if "%choix%"=="8" goto ANTIVIRUS_UPDATE
if "%choix%"=="9" goto ANTIVIRUS_STATUS
goto MENU_VIRUS

:DATE
cls
echo Date et heure actuelles :
echo --------------------------
echo %date% %time%
pause
goto MENU

:FILES
cls
echo Liste des fichiers dans %cd% :
echo ---------------------
dir
pause
goto MENU

:CLEAN
cls
echo Nettoyage des fichiers temporaires...
del /q /f %temp%\*
echo Terminé.
pause
goto MENU

:INFO
cls
echo Informations système :
echo -----------------------
echo Nom de l'ordinateur : %COMPUTERNAME%
echo Nom de l'utilisateur : %USERNAME%
echo Version de Windows   : %OS%
ver
echo Type de processeur   : %PROCESSOR_IDENTIFIER%
echo Architecture         : %PROCESSOR_ARCHITECTURE%
pause
goto MENU

:DEFENDER
cls
echo Ouverture de Windows Defender...
start windowsdefender:
pause
goto MENU_VIRUS

:TEMP_DISABLE
cls
echo Desactivation temporaire de Windows Defender...
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
echo Terminé. Windows Defender est temporairement désactivé.
pause
goto MENU_VIRUS

:FULL_DISABLE
cls
echo Desactivation permanente de Windows Defender...
echo Cela va modifier le registre pour le desactiver completement.
pause
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f
echo Defender est desactive de façon permanente. Un redemarrage est recommandé.
pause
goto MENU_VIRUS

:FULL_ACTIVATE
cls
echo Reactivation permanente de Windows Defender...
echo Suppression des clés du Registre et reactivation de la protection en temps réel.
pause
:: Supprime les clés de registre créées par l'option 8
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /f >nul 2>&1

:: Réactive la protection en temps réel
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $false"

echo Windows Defender a été réactivé de façon permanente.
echo Un redemarrage est recommande pour appliquer tous les changements.
pause
goto MENU_VIRUS

:TEMP_REACTIVATE
cls
echo Reactivation temporaire de la protection en temps reel...
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $false"
echo Protection en temps réel réactivée temporairement.
pause
goto MENU_VIRUS

:END
echo Merci d'avoir utilisé Tools !
timeout /t 2 >nul
exit

:ANTIVIRUS_SCAN
cls
echo ============================
echo      SCAN ANTIVIRUS
echo ============================
echo 1. Scan rapide
echo 2. Scan complet
echo 3. Retour
set /p scanchoix="Choisis une option : "
if "%scanchoix%"=="1" (
    echo Scan rapide en cours...
    powershell -Command "Start-MpScan -ScanType QuickScan"
    echo Scan rapide termine.
    pause
    goto MENU_VIRUS
)
if "%scanchoix%"=="2" (
    echo Scan complet en cours...
    powershell -Command "Start-MpScan -ScanType FullScan"
    echo Scan complet termine.
    pause
    goto MENU_VIRUS
)
if "%scanchoix%"=="3" goto MENU_VIRUS
goto ANTIVIRUS_SCAN

:ANTIVIRUS_UPDATE
cls
echo Mise a jour des definitions antivirus...
powershell -Command "Update-MpSignature"
echo Mise a jour terminee.
pause
goto MENU_VIRUS

:ANTIVIRUS_STATUS
cls
echo Statut complet de Windows Defender :
powershell -Command "Get-MpComputerStatus | Format-List"
pause
goto MENU_VIRUS

:MENU_RESEAU
cls
echo ============= MENU RESEAU ============
echo 1. Afficher configuration IP detaillée
echo 2. Tester connexion internet (ping google.com)
echo 3. Afficher connexions réseau actives
echo 4. Afficher table de routage
echo 5. Purger et renouveler IP
echo 6. Afficher serveurs DNS
echo 7. Ouvrir Centre Réseau Windows
echo 8. Retour
set /p choix="Choisis une option : "

if "%choix%"=="1" ipconfig /all & pause & goto MENU_RESEAU
if "%choix%"=="2" ping google.com & pause & goto MENU_RESEAU
if "%choix%"=="3" netstat -ano & pause & goto MENU_RESEAU
if "%choix%"=="4" route print & pause & goto MENU_RESEAU
if "%choix%"=="5" (
    ipconfig /release
    ipconfig /renew
    pause
    goto MENU_RESEAU
)
if "%choix%"=="6" (
    nslookup -type=ns .
    pause
    goto MENU_RESEAU
)
if "%choix%"=="7" start ms-settings:network-status & goto MENU_RESEAU
if "%choix%"=="8" goto MENU
goto MENU_RESEAU


:MENU_USERS
cls
echo ======= MENU UTILISATEURS & SECURITE ========
echo 1. Lister utilisateurs locaux
echo 2. Changer mot de passe utilisateur
echo 3. Activer un compte utilisateur
echo 4. Desactiver un compte utilisateur
echo 5. Afficher groupes utilisateurs
echo 6. Gérer droits administrateurs (ajouter/supprimer)
echo 7. Retour
set /p choix="Choisis une option : "

if "%choix%"=="1" net user & pause & goto MENU_USERS
if "%choix%"=="2" (
    set /p user="Nom utilisateur : "
    net user "%user%" * 
    goto MENU_USERS
)
if "%choix%"=="3" (
    set /p user="Nom utilisateur a activer : "
    net user "%user%" /active:yes
    echo Compte activé.
    pause
    goto MENU_USERS
)
if "%choix%"=="4" (
    set /p user="Nom utilisateur a desactiver : "
    net user "%user%" /active:no
    echo Compte desactivé.
    pause
    goto MENU_USERS
)
if "%choix%"=="5" net localgroup & pause & goto MENU_USERS
if "%choix%"=="6" (
    echo 1. Ajouter utilisateur au groupe Administrateurs
    echo 2. Retirer utilisateur du groupe Administrateurs
    set /p action="Choisis une action : "
    if "%action%"=="1" (
        set /p user="Nom utilisateur : "
        net localgroup Administrateurs "%user%" /add
        echo Utilisateur ajouté.
        pause
        goto MENU_USERS
    )
    if "%action%"=="2" (
        set /p user="Nom utilisateur : "
        net localgroup Administrateurs "%user%" /delete
        echo Utilisateur retiré.
        pause
        goto MENU_USERS
    )
    goto MENU_USERS
)
if "%choix%"=="7" goto MENU
goto MENU_USERS

:MENU_SAUVEGARDE
cls
echo ========== MENU SAUVEGARDE & RESTAURATION ==========
echo 1. Sauvegarder un dossier ou fichier
echo 2. Creer un point de restauration
echo 3. Restaurer un point de restauration
echo 4. Exporter liste programmes installes
echo 5. Retour
set /p choix="Choisis une option : "

if "%choix%"=="1" (
    set /p cheminsource="Chemin du fichier/dossier a sauvegarder : "
    set /p chemindestination="Chemin de destination de la sauvegarde : "
    xcopy "%cheminsource%" "%chemindestination%" /E /I /H /Y
    echo Sauvegarde terminee.
    pause
    goto MENU_SAUVEGARDE
)
if "%choix%"=="2" (
    powershell -Command "Checkpoint-Computer -Description 'Point de restauration KondaxTools' -RestorePointType 'MODIFY_SETTINGS'"
    echo Point de restauration cree.
    pause
    goto MENU_SAUVEGARDE
)
if "%choix%"=="3" (
    echo Pour restaurer un point, lancez la restauration système depuis Windows.
    pause
    goto MENU_SAUVEGARDE
)
if "%choix%"=="4" (
    powershell -Command "Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher | Format-Table -AutoSize"  
    pause
    goto MENU_SAUVEGARDE
)
if "%choix%"=="5" goto MENU
goto MENU_SAUVEGARDE

:MENU_PERSONNALISATION
cls
echo ========== MENU PERSONNALISATION ==========
echo 1. Changer fond d'ecran
echo 2. Modifier couleur terminal
echo 3. Afficher/Masquer fichiers caches
echo 4. Retour
set /p choix="Choisis une option : "

if "%choix%"=="1" (
    set /p cheminimg="Chemin complet de l'image : "
    reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "%cheminimg%" /f
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
    echo Fond d'ecran modifie.
    pause
    goto MENU_PERSONNALISATION
)
if "%choix%"=="2" (
    echo Couleurs disponibles : 0=Noir 1=Bleu 2=Vert 3=Aqua 4=Rouge 5=Pourpre 6=Jaune 7=Blanc 8=Gris 9=Bleu clair ...
    set /p couleur="Entrez code couleur (ex: 0B) : "
    color %couleur%
    echo Couleur modifiee.
    pause
    goto MENU_PERSONNALISATION
)
if "%choix%"=="3" (
    reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden | find "0x1" >nul
    if %errorlevel%==0 (
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 2 /f
        echo Fichiers caches MASQUES.
    ) else (
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f
        echo Fichiers caches AFFICHES.
    )
    pause
    goto MENU_PERSONNALISATION
)
if "%choix%"=="4" goto MENU
goto MENU_PERSONNALISATION


:MENU_REGIONS
cls
echo ============================
echo         MENU REGIONS
echo ============================
echo 1. Migration vers Windows 11 Pro
echo 2. Retirer tous les groupes (sauf systeme) 
echo 3. Mettre mon groupe comme superieur (ajouter Admins)
echo 4. Gestion securite avancée (Secure Boot, BitLocker, ACL, etc)
echo 5. Injection DLL et hooks système 
echo 6. Manipulation registre securite
echo 7. Retour au menu principal
echo 8. Ajouter un groupe local
echo ============================
set /p choix="Choisis une option : "

if "%choix%"=="1" goto migration_pro
if "%choix%"=="2" goto REMOVE_GROUPS
if "%choix%"=="3" goto PROMOTE_GROUP
if "%choix%"=="4" goto MENU_SECURITE_AVANCEE
if "%choix%"=="5" goto MENU_DLL_HOOKS
if "%choix%"=="6" goto MENU_REGISTRE_SECURITE
if "%choix%"=="7" goto MENU
if "%choix%"=="8" goto ajouter_groupe
goto MENU_REGIONS

:migration_pro
cls
title Migration vers Windows 11 Pro
echo ================================================
echo     Migration de Windows 11 Education vers Pro
echo ================================================
echo.

echo Verification de l'edition Windows actuelle...
for /f "tokens=3 delims= " %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID') do set edition=%%i

echo Edition actuelle : %edition%
if /i "%edition%"=="Professional" (
    echo Vous etes deja sur Windows 11 Pro.
    pause
    goto menu
)
if /i "%edition%"=="Enterprise" (
    echo Vous etes sur une edition superieure.
    pause
    goto MENU_REGIONS
)

echo.
echo Lancement de la conversion vers Windows 11 Pro...
echo Cela peut prendre quelques minutes.
echo.

changepk.exe /ProductKey VK7JG-NPHTM-C97JM-9MPGT-3V66T

echo.
echo Si tout s'est bien passe, un redemarrage sera necessaire.
echo.
pause
goto MENU_REGIONS
:: Option 2 : Retirer tous les groupes sauf systeme
:REMOVE_GROUPS
cls
echo ATTENTION : Cette action supprimera tous les groupes locaux sauf les groupes systeme importants.
echo Cela peut affecter la securite et le fonctionnement du systeme.
echo Tapez OUI pour confirmer ou une autre touche pour annuler :
set /p confirm="Confirmer : "

if /I NOT "%confirm%"=="OUI" (
    echo Operation annulee.
    pause
    goto MENU_REGIONS
)

for /f "skip=4 tokens=*" %%g in ('net localgroup') do (
    if /I NOT "%%g"=="Administrateurs" if /I NOT "%%g"=="Utilisateurs" if /I NOT "%%g"=="Invites" if /I NOT "%%g"=="Power Users" (
        net localgroup "%%g" /delete
        echo Groupe %%g supprime.
    )
)
echo Suppression terminee.
pause
goto MENU_REGIONS

:: Option 3 : Mettre un groupe en "superieur" (ajouter aux Admins)
:PROMOTE_GROUP
cls
echo Entrez le nom du groupe a promouvoir (qui sera ajoute aux Administrateurs) :
set /p groupe="Nom du groupe : "

net localgroup Administrateurs "%groupe%" /add

if %errorlevel%==0 (
    echo Le groupe %groupe% a ete ajoute au groupe Administrateurs avec succes.
) else (
    echo Une erreur est survenue, verifiez que le groupe existe et que vous avez les droits admin.
)

pause
goto MENU_REGIONS

:: Sous-menu 4 : Sécurité avancée
:MENU_SECURITE_AVANCEE
cls
echo ========== SECURITE AVANCEE ==========
echo 1. Désactiver Secure Boot (manuel via BIOS requis)
echo 2. Gérer BitLocker (désactivation, export clés TPM)
echo 3. Modifier ACL NTFS avancée
echo 4. Retour
echo =====================================
set /p choix="Choisis une option : "

if "%choix%"=="1" (
    cls
    echo Désactivation Secure Boot requiert un accès BIOS/UEFI.
    echo Ce script ne peut pas automatiser cette opération.
    echo Veuillez redémarrer et modifier manuellement.
    pause
    goto MENU_SECURITE_AVANCEE
)
if "%choix%"=="2" goto MENU_BITLOCKER
if "%choix%"=="3" goto MENU_ACL
if "%choix%"=="4" goto MENU_REGIONS
goto MENU_SECURITE_AVANCEE

:: Sous-menu BitLocker
:MENU_BITLOCKER
cls
echo ======== GESTION BITLOCKER =========
echo 1. Exporter clé TPM BitLocker
echo 2. Désactiver BitLocker via commande
echo 3. Modifier partitions pour forcer déchiffrement (risqué)
echo 4. Retour
echo =====================================
set /p choix="Choisis une option : "

if "%choix%"=="1" (
    echo Exportation clé TPM BitLocker...
    powershell -Command "Get-BitLockerVolume | Select-Object MountPoint, KeyProtector | Format-List"
    pause
    goto MENU_BITLOCKER
)
if "%choix%"=="2" (
    echo Désactivation BitLocker sur C: (peut prendre du temps)...
    manage-bde -off C:
    pause
    goto MENU_BITLOCKER
)
if "%choix%"=="3" (
    echo Modification des partitions requiert des outils externes, operation non automatisee ici.
    pause
    goto MENU_BITLOCKER
)
if "%choix%"=="4" goto MENU_SECURITE_AVANCEE
goto MENU_BITLOCKER

:: Sous-menu ACL
:MENU_ACL
cls
echo ======== MODIFICATION ACL NTFS =======
echo 1. Bloquer l'acces aux autres groupes sauf le votre (sur dossier)
echo 2. Modifier permissions sur services COM/WMI (exemple)
echo 3. Retour
echo =====================================
set /p choix="Choisis une option : "

if "%choix%"=="1" (
    set /p chemin="Chemin du dossier/fichier : "
    set /p groupe="Nom du groupe a garder l'acces : "
    echo Modification ACL en cours...
    icacls "%chemin%" /inheritance:r
    icacls "%chemin%" /remove:g "Users" "Administrateurs" "Invites"
    icacls "%chemin%" /grant:r "%groupe%":(OI)(CI)F
    echo Permissions modifiées.
    pause
    goto MENU_ACL
)
if "%choix%"=="2" (
    echo Modification permissions COM/WMI: nécessite scripts Powershell avancés.
    echo Cette option est à implémenter selon besoins spécifiques.
    pause
    goto MENU_ACL
)
if "%choix%"=="3" goto MENU_SECURITE_AVANCEE
goto MENU_ACL

:: Sous-menu 5 : Injection DLL & hooks
:MENU_DLL_HOOKS
cls
echo ======== INJECTION DLL & HOOKS =========
echo 1. Exemple injection DLL via PowerShell (externe requis)
echo 2. Modifier fonctions API Windows (exemple)
echo 3. Retour
echo =========================================
set /p choix="Choisis une option : "

if "%choix%"=="1" (
    echo Exemple: utilisation d’outil tiers pour injection DLL.
    echo Ce batch ne peut pas realiser l’injection directement.
    pause
    goto MENU_DLL_HOOKS
)
if "%choix%"=="2" (
    echo Modifier fonctions API requiert scripts en C++/PowerShell avancés.
    echo Non implementé dans ce batch.
    pause
    goto MENU_DLL_HOOKS
)
if "%choix%"=="3" goto MENU_REGIONS
goto MENU_DLL_HOOKS

:: Sous-menu 6 : Manipulation registre securité
:MENU_REGISTRE_SECURITE
cls
echo ======== MANIPULATION REGISTRE ========
echo 1. Désactiver protections spécifiques (ex: UAC, Defender, etc.)
echo 2. Modifier politiques locales (GPO via registre)
echo 3. Retour
echo ========================================
set /p choix="Choisis une option : "

if "%choix%"=="1" (
    echo Exemple: Désactivation UAC
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f
    echo UAC desactivé (requiert redémarrage).
    pause
    goto MENU_REGISTRE_SECURITE
)
if "%choix%"=="2" (
    echo Exemple: Désactivation audit via registre
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\EventLog" /v AuditBaseObjects /t REG_DWORD /d 0 /f
    echo Politiques locales modifiées.
    pause
    goto MENU_REGISTRE_SECURITE
)
if "%choix%"=="3" goto MENU_REGIONS
goto MENU_REGISTRE_SECURITE

:: Option 8 - Ajouter un groupe local
:ajouter_groupe
cls
echo =============== Ajouter un groupe local ===============
echo.
set /p groupe_nom=Entrez le nom du groupe à créer : 

if "%groupe_nom%"=="" (
    echo Nom de groupe vide. Retour au menu.
    pause
    goto menu_region
)

net localgroup "%groupe_nom%" /add >nul 2>&1
if errorlevel 1 (
    echo Erreur lors de la creation du groupe "%groupe_nom%".
) else (
    echo Le groupe "%groupe_nom%" a ete cree avec succes.
)
pause
goto menu_region

:MENU_OPTIMISATION
cls
echo ======== MODIFICATION ACL NTFS =======
echo 1. Nettoyage complet Cache
echo 2. Nettoyer les fichiers temporaires
echo 3. Retour
echo =====================================
set /p choix="Choisis une option : "

if "%choix%"=="1" goto MENU_CLEAR_CACHE
if "%choix%"=="2" goto CLEAN
if "%choix%"=="3" goto MENU


:MENU_CLEAR_CACHE
cls
echo [🧹] Nettoyage du cache en cours...
echo.

:: Supprimer fichiers temporaires
echo - Suppression des fichiers temporaires...
del /f /s /q %TEMP%\*
del /f /s /q C:\Windows\Temp\*

:: Vider le cache DNS
echo - Nettoyage du cache DNS...
ipconfig /flushdns

:: Nettoyage des miniatures
echo - Suppression des caches de miniatures...
del /f /s /q "%localappdata%\Microsoft\Windows\Explorer\thumbcache*"

:: Reset cache Windows Store
echo - Réinitialisation du cache Windows Store...
start /wait "" "wsreset.exe"

:: Supprimer le cache des icônes (redémarrage nécessaire)
echo - Suppression du cache d'icônes...
taskkill /f /im explorer.exe
del /f /q "%localappdata%\IconCache.db"
start explorer.exe

echo.
echo ✅ Le cache a été nettoyé !
pause
goto MENU_OPTIMISATION


:INFO_SYSTEME
cls
echo ======== INFORMATION SYSTEME =======
echo 1. Date et Heure
echo 2. Information de l'ordinateur
echo 3. Retour
echo =====================================
set /p choix="Choisis une option : "

if "%choix%"=="1" goto DATE
if "%choix%"=="2" goto INFO
if "%choix%"=="3" goto MENU
