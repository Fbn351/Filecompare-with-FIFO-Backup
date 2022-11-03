# Setze Return Code auf 0 bevor das Script startet
$Returncode = 0
$ServiceError = ""
 
 
#$OriginalpfadTESTPHASE = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
 
# Hier NUR Originalpfade eintragen
$FIX_SOURCE = "SOURCEPFAD"
$FIX_DESTINATION = "DESTINATIONPFAD"
$FIX_WORKSPACE = "WORKSPACEPFAD"
 

 
##################################################
# AB HIER SIND KEINE ÄNDERUNGEN MEHR ERORDERLICH #   <= Hinweis für Layer 8 :P
##################################################
 
 
 
#Formatieren des Datumstempels
$DateiDatumserweiterung = Get-Date -Format yyyy_MM_dd_HH_mm_ss
 
 
#Bestimmen der Ordnerpfade Backup und Temporärer Arbeitsordner
$BCKpfad = "$FIX_WORKSPACE/BCK_$DateiDatumserweiterung"
$Temppfad = "$BCKpfad/temp"
$Aussortierte_Paare = "$Temppfad/Versand"
$Aussortierte_Single = "$Temppfad/Fehler"
 
 
 
#Erstellen der benötigten Ordner
#Erst Backup da dort drin der Tempordner erstellt wird
#Danach der Temp Ordner da dort drin die Kategorieordner erstellt werden
mkdir "$BCKpfad"
mkdir "$Temppfad"
mkdir "$Temppfad/Versand"
mkdir "$Temppfad/Fehler"
 
 
#######################################################################
## Prüfen ob Pfade erreichbar sind ansonsten Returncode 1 als Fehler ##
#######################################################################

If (Test-Path $BCKpfad)
{
    Write-Host -BackGroundColor Green "Der Pfad $($BCKpfad) existiert."
    $returncode = 0
    Write-Host "Returncode: $returncode"
}
else
{
    Write-Host -BackgroundColor Red "Der Pfad $($BCKpfad) existiert bisher nicht oder ist nicht erreichbar."
    # Hier wird der Error Codes übergeben
    if ($Returncode -eq '1')
        {$ServiceError}
    exit(1)
}
 
If (Test-Path $FIX_SOURCE)
{
    Write-Host -BackGroundColor Green "Der Pfad $($FIX_SOURCE) existiert."
    $returncode = 0
    Write-Host "Returncode: $returncode"
}
else
{
    Write-Host -BackgroundColor Red "Der Pfad $($FIX_SOURCE) existiert bisher nicht oder ist nicht erreichbar."
    # Hier wird der Error Codes übergeben
    if ($Returncode -eq '1')
        {$ServiceError}
    exit(1)
}
 
If (Test-Path $FIX_DESTINATION)
{
    Write-Host -BackGroundColor Green "Der Pfad $($FIX_DESTINATION) existiert."
    $returncode = 0
    Write-Host "Returncode: $returncode"
}
else
{
    Write-Host -BackgroundColor Red "Der Pfad $($FIX_DESTINATION) existiert bisher nicht oder ist nicht erreichbar."
   
    # Hier wird der Error Codes übergeben
    if ($Returncode -eq '1')
        {$ServiceError}
    exit(1)
}
 
If (Test-Path $FIX_WORKSPACE)
{
    Write-Host -BackGroundColor Green "Der Pfad $($FIX_WORKSPACE) existiert."
    $returncode = 0
    Write-Host "Returncode: $returncode"
}
else
{
    Write-Host -BackgroundColor Red "Der Pfad $($FIX_WORKSPACE) existiert bisher nicht oder ist nicht erreichbar."
    # Hier wird der Error Codes übergeben
    if ($Returncode -eq '1')
        {$ServiceError}
    exit(1)
}


####################################
## Jetzt wird das Backup erstellt ##
####################################

#Verschieben von allen WWW/XXX/YYY/ZZZ Dateien zum Backupen und zum verhindern das nachher einiges gedoppelt bearbeitet wird. Verschoben wird in einen Ordner mit Datumsformat YYYY/MM/DD (vorteil ist hier das bei der Anordnung ein Datum automatisch inkrementiert wird)
Move-Item "$FIX_SOURCE/*.WWW" "$BCKpfad"
Move-Item "$FIX_SOURCE/*.XXX" "$BCKpfad"
Move-Item "$FIX_SOURCE/*.YYY" "$BCKpfad"
Move-Item "$FIX_SOURCE/*.ZZZ" "$BCKpfad"
write-host "Backup wird erstellt"
Start-Sleep -s 20
 
##########################################################################################
## Dateien werden in Tempverzeichnis kopiert um Fehler an Dateistrukturen zu verhindern ## 
##########################################################################################

#Kopieren der Dateien aus dem Backupverzeichnis in das TEMP-Verzeichnis
Copy-Item "$BCKpfad\*.*" "$Temppfad"
write-host "Temp wird erstellt"
Start-Sleep -s 20


function Hauptscript{
########################################################################################################################################### 
##In diesem Hauptscript wird für jede Dateiendung ein Array erstellt und pro Eintrag die Funktion für die entsprechende Datei aufgerufen ##
###########################################################################################################################################


############################################
## Erster Durchlauf für alle WWW Dateien  ##
############################################
 
# Auswerten aller WWW Dateien des Ordners
$Array_von_WWW_Dateien = Get-ChildItem "$Temppfad\*.*" -Filter "*.WWW"
# Aufruf der Funktion für jede WWW Datei des Arrays
foreach ($Aktuelle_WWW_Datei in $Array_von_WWW_Dateien) {Prüfungsschleife-WWW}
 
############################################
## Zweiter Durchlauf für alle XXX Dateien ##
############################################
 
# Auswerten aller XXX Dateien des Ordners
$Array_von_XXX_Dateien = Get-ChildItem "$Temppfad\*.*" -Filter "*.XXX"
# Aufruf der Funktion für jede XXX Datei des Arrays
foreach ($Aktuelle_XXX_Datei in $Array_von_XXX_Dateien) {Prüfungsschleife-XXX}

 
############################################
## Dritter Durchlauf für alle YYY Dateien ##
############################################
 
# Auswerten aller YYY Dateien des Ordners
$Array_von_YYY_Dateien = Get-ChildItem "$Temppfad\*.*" -Filter "*.YYY"
# Aufruf der Funktion für jede YYY Datei des Arrays
foreach ($Aktuelle_YYY_Datei in $Array_von_YYY_Dateien) {Prüfungsschleife-YYY}

 
############################################
## Vierter Durchlauf für alle ZZZ Dateien ##
############################################
 
# Auswerten aller ZZZ Dateien des Ordners
$Array_von_ZZZ_Dateien = Get-ChildItem "$Temppfad\*.*" -Filter "*.ZZZ"
# Aufruf der Funktion für jede ZZZ Datei des Arrays
foreach ($Aktuelle_ZZZ_Datei in $Array_von_ZZZ_Dateien) {Prüfungsschleife-ZZZ}
 
 
###########################
## Aufruf der Auswertung ##
###########################
 
Auswertung_starten
 
 
}
 
 
 
 
 
############################
## Aufrufen der Functions ##
############################
 
###############################################################################################################################################
## Die Prüfungsschleifen arbeiten alle nach dem gleichen Prinzip. Nimm den Namen der Datei und Prüfe ob eine gleichnamige ZZZ vorhanden ist. ##
## Wenn nicht verschiebe die Datei in den Ordner Single damit Sie weiter verarbeitet werden kann wenn alle Dateien durch sind.               ##
## Alle Dateien die also nach Ablauf des Scripts im Single Ordner sind, sind fehlerhaft.                                                     ##
###############################################################################################################################################


function Prüfungsschleife-WWW{
    #Splitten des Pfades und entfernen von Pfad und Dateierweiterung
    $SingelDateiName = (Get-Item "$Aktuelle_WWW_Datei").Basename
    Write-Host "Aktuelle WWW-Datei $SingelDateiName"
    #Setzen von Variablen zur weiteren verarbeitung
    $Datei_als_WWW = "$Temppfad/$SingelDateiName.WWW"
    $Datei_als_ZZZ = "$Temppfad/$SingelDateiName.ZZZ"
   
            #IF Verzweigung zur Prüfung ob eine auf dem Namenspräfix passende ZZZ Datei vorhanden ist.
            #Wenn die gleichnamige ZZZ Datei vorhanden ist verschiebe beide Dateien in den Versandordner.
            #Wenn keine gleichnamige ZZZ Datei vorhanden ist verschiebe die WWW Datei in den Singleordner.
 
            If ( Test-Path "$Datei_als_ZZZ")
            {
                # IF ZWEIG => ZZZ Datei ist vorhanden
                Write-Host "Versandbereites Datenpaar gefunden $Datei_als_WWW wird verschoben"
                Write-Host "Versandbereites Datenpaar gefunden $Datei_als_ZZZ wird verschoben"
                Move-Item "$Datei_als_WWW" "$Aussortierte_Paare"
                Move-Item "$Datei_als_ZZZ" "$Aussortierte_Paare"
            }
 
            else
            {
                # IF ZWEIG => ZZZ Datei ist NICHT vorhanden
                Write-Host "Keine passende Datei als ZZZ gefunden! $Aktuelle_WWW_Datei wird verschoben"
                Move-Item "$Datei_als_WWW" "$Aussortierte_Single"
 
            }
    }
 
function Prüfungsschleife-XXX{
    #Splitten des Pfades und entfernen von Pfad und Dateierweiterung
    $SingelDateiName = (Get-Item "$Aktuelle_XXX_Datei").Basename
    Write-Host "Aktuelle XXX-Datei $SingelDateiName"
    #Setzen von Variablen zur weiteren verarbeitung
    $Datei_als_XXX = "$Temppfad/$SingelDateiName.XXX"
    $Datei_als_ZZZ = "$Temppfad/$SingelDateiName.ZZZ"
   
            #IF Verzweigung zur Prüfung ob eine auf dem Namenspräfix passende ZZZ Datei vorhanden ist.
            #Wenn die gleichnamige ZZZ Datei vorhanden ist verschiebe beide Dateien in den Versandordner.
            #Wenn keine gleichnamige ZZZ Datei vorhanden ist verschiebe die XXX Datei in den Singleordner.
 
            If ( Test-Path "$Datei_als_ZZZ")
            {
                # IF ZWEIG => ZZZ Datei ist vorhanden
                Write-Host "Versandbereites Datenpaar gefunden $Datei_als_XXX wird verschoben"
                Write-Host "Versandbereites Datenpaar gefunden $Datei_als_ZZZ wird verschoben"
                Move-Item "$Datei_als_XXX" "$Aussortierte_Paare"
                Move-Item "$Datei_als_ZZZ" "$Aussortierte_Paare"
            }
 
            else
            {
                # IF ZWEIG => ZZZ Datei ist NICHT vorhanden
                Write-Host "Keine passende Datei als ZZZ gefunden! $Aktuelle_XXX_Datei wird verschoben"
                Move-Item "$Datei_als_XXX" "$Aussortierte_Single"
            }
    }

function Prüfungsschleife-YYY{
    #Splitten des Pfades und entfernen von Pfad und Dateierweiterung
    $SingelDateiName = (Get-Item "$Aktuelle_YYY_Datei").Basename
    Write-Host "Aktuelle YYY-Datei $SingelDateiName"
    #Setzen von Variablen zur weiteren verarbeitung
    $Datei_als_YYY = "$Temppfad/$SingelDateiName.YYY"
    $Datei_als_ZZZ = "$Temppfad/$SingelDateiName.ZZZ"
   
            #IF Verzweigung zur Prüfung ob eine auf dem Namenspräfix passende ZZZ Datei vorhanden ist.
            #Wenn die gleichnamige ZZZ Datei vorhanden ist verschiebe beide Dateien in den Versandordner.
            #Wenn keine gleichnamige ZZZ Datei vorhanden ist verschiebe die YYY Datei in den Singleordner.
 
            If ( Test-Path "$Datei_als_ZZZ")
            {
                # IF ZWEIG => ZZZ Datei ist vorhanden
                Write-Host "Versandbereites Datenpaar gefunden $Datei_als_YYY wird verschoben"
                Write-Host "Versandbereites Datenpaar gefunden $Datei_als_ZZZ wird verschoben"
                Move-Item "$Datei_als_YYY" "$Aussortierte_Paare"
                Move-Item "$Datei_als_ZZZ" "$Aussortierte_Paare"
            }
 
            else
            {
                # IF ZWEIG => ZZZ Datei ist NICHT vorhanden
                Write-Host "Keine passende Datei als ZZZ gefunden! $Aktuelle_YYY_Datei wird verschoben"
                Move-Item "$Datei_als_YYY" "$Aussortierte_Single"
 
            }
    }
    
function Prüfungsschleife-ZZZ{
#Splitten des Pfades und entfernen von Pfad und Dateierweiterung
    $SingelDateiName = (Get-Item "$Aktuelle_ZZZ_Datei").Basename
    Write-Host "Aktuelle ZZZ-Datei $SingelDateiName"
    #Setzen von Variablen zur weiteren verarbeitung
    $Datei_als_WWW = "$Temppfad/$SingelDateiName.WWW"
    $Datei_als_XXX = "$Temppfad/$SingelDateiName.XXX"
    $Datei_als_YYY = "$Temppfad/$SingelDateiName.YYY"
    $Datei_als_ZZZ = "$Temppfad/$SingelDateiName.ZZZ"
 
            #IF  Verzweigung zur Prüfung ob eine auf dem Namenspräfix passende andere Datei vorhanden ist.
            #Wenn die gleichnamige andere Datei vorhanden ist verschiebe beide Dateien in den Versandordner. (Wird niemals vorkommen da ja bereits alle Paare in vorherigen Durchläufen gefunden worden sind.)
            #Wenn keine gleichnamige andere Datei vorhanden ist verschiebe die ZZZ Datei in den Singleordner. (Eigentlicher Sinn des letzten Durchlaufs)
 
            If ( Test-Path "$Datei_als_WWW")
            {
                # IF ZWEIG => WWW Datei ist vorhanden
   
                #################################
                #  Dann wäre das Script kaputt  #
                #################################
            }
            If ( Test-Path "$Datei_als_XXX")
            {
                # IF ZWEIG => XXX Datei ist vorhanden
   
                #################################
                #  Dann wäre das Script kaputt  #
                #################################
            }
            If ( Test-Path "$Datei_als_YYY")
            {
                # IF ZWEIG => YYY Datei ist vorhanden
   
                #################################
                #  Dann wäre das Script kaputt  #
                #################################
            }
 
            else
            {
                # IF ZWEIG => ZZZ Datei ist NICHT vorhanden
                Write-Host "Keine passende Datei zur ZZZ gefunden! $Aktuelle_ZZZ_Datei wird verschoben"
                Move-Item "$Datei_als_ZZZ" "$Aussortierte_Single"

 
            }
}
#####################################################################################
## Alle Dateien im Singleordner werden in eine Datei als Auswertung gepackt        ##
## Dann werden alle Dateien aus Single in den Produktiven Fehler-Ordner verschoben ##
## Dann werden alle Dateien aus Paare in den Produktiven Versand-Ordner verschoben ##
#####################################################################################

Get-ChildItem "$Aussortierte_Single/*.*" -Name |  Out-File -FilePath "$BCKpfad/#Auswertung_Singledateien.txt"
 
#Kopieren von TEMP zu AUSGABE DESTINATION
Copy-Item "$Aussortierte_Single\*.*" "$FIX_DESTINATION/Fehler"
write-host "Fehlerordner wird transferiert"
Start-Sleep -s 20
Copy-Item "$Aussortierte_Paare\*.*" "$FIX_DESTINATION/Versand"
write-host "Fehlerordner wird transferiert"
Start-Sleep -s 20
 
 
###################################
## Prüfe auf leeren Singleordner ##
###################################
 
#Die Job-Software benötigt über den erfolgreichen Durchlauf noch einen Returncode. Ebenso ob es "Fehler" gab. Bei nicht gematchen Dateien wird Return-Code 2 ausgegeben was den Versand
#der Textdatei mit sich bringt. 

if((get-childitem $FIX_WORKSPACE/Fehler).count -eq 0)
{
     
    $returncode = 0
    Write-Host -BackgroundColor Green "Der Ordner Fehler ist leer. Es befinden sich nur Paare in Versand."
    Write-Host -BackgroundColor Green "Das Script ist erfolgreich durchgelaufen." 
 
}
else
{
 
    $ServiceError = ""
    $returncode = 2
 
    Write-Host -BackgroundColor Green "Das Script ist erfolgreich gelaufen. Versandbereite Paare und Singledateien wurden verschoben."
    Write-Host -BackgroundColor Red "Der Ordner Fehler ist nicht leer. Es wird der Return Code 2 ausgegeben."
    Write-Host "Returncode: $returncode"
 
#Im Fehlerfall Ausgabe der Variable §ServiceError. Ist nicht immer Verfügbar aber hilft beim Debuggen wenn das Job-Programm logged (was es sollte)
if ($Returncode -eq '2')
    {$ServiceError}
exit(2)
}
