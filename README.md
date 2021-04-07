## redesigned-pancake

Ceci est en réalité le projet de MicroContrôleur, nous comptons réaliser un thermomètre. Pour ce faire, nous utilisons :
 - Capteur de température 1-Wire
 - Moteur pas-à-pas
 - Affichag LCD
 - Télécommande
 - (Buzzer)
 - 1 cc de sel

On affiche la température à l'aide du moteur sur un cadran à aiguille, l'écran LCD sert de menu : température en °C ou en °F, température max. Le menu est contrôlé par la télécommande. Si la température max est dépassée : alarme.

Stockage des paramtères en mémoire EEPROM : pas de reset à chaque coupure de courant.
