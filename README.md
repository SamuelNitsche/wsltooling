## Vorbereitung:
1. Optional: Windows Terminal installieren (https://learn.microsoft.com/de-de/windows/terminal/install)
2. Folgende Windows-Features aktivieren und anschließend neu starten:
   * Hyper-V
   * Windows Subsystem for Linux
   * VM-Plattform
3. Powershell:
   `wsl --update`
4. Git auf Windows installieren. Dieses wird nun nur noch benötigt, um die nachfolgende Einrichtung für WSL durchzuführen. Dabei wird dann git auch innerhalb von WSL installiert. Für die spätere Entwicklung kann dann dieses Binary verwendet werden.
5. Powershell: `git config --global core.autocrlf input`
6. Optional: Bei erstmaliger Einrichtung eines Users einen SSH Key anlegen: Powershell `ssh-keygen -t ed25519 -C "<email>@wagner-ecommerce.group"`. Das somit erstellte SSH Keypaar befindet sich nun im Ordner _%HOMEPATH%\\.ssh_. Den Publickey (Dateiendung .pub) bei GitHub hinterlegen.

## Start:
1. Repo "wsltooling" in _C:\Users\<windows-username>\git_ klonen: https://github.com/cherrmann89/wsltooling
2. Verzeichnis _C:\Users\<windows-username>\wsl_ anlegen
3. GitHub Token mit den Rechten _repo:all_, _read:org_ und _admin:public_key:all_ erzeugen und in _C:\Users\<windows-username>\wsl\\.token_ speichern
4. Verknüpfung im Verzeichnis _C:\Users\<windows-username>\wsl_ anlegen. Als Speicherort
`powershell.exe -NoExit -execution bypass "%HOMEPATH%\git\wsltooling\installUbuntuLTS.ps1 dev-infra %HOMEPATH%\wsl\dev-infra <wsl-distro-username> <github-username> C:\Users\<windows-username>\wsl\.token"`
angeben. Hierbei kann der `<wsl-distro-username>` frei gewählt werden, `<github-username>` muss dem Usernamen bei GitHub entsprechen und `<windows-username> dem Usernamen auf Windows. Im nächsten Schritt kann der Verknüpfungsname frei gewählt werden.
5. Die gerade erstellte Verknüpfung per Doppelklick ausführen. Leider können nicht alle für das Skript benötigten Parameter direkt mit in der Verknüpfung angegeben werden, da es hier eine Längenbeschränkung gibt.
Daher werden bei Ausführung der Verknüpfung die restlichen Parameter abgefragt und diese müssen über die sich öffnende PowerShell eingegeben werden.
6. Das ausgeführte Skript installiert nun eine aktuelle Ubuntu Version als WSL Distro und startet anschließend ein Ansible Playbook, um die Distro zu provisionieren.

## Nachbereitung:
1. Host-Einträge anlegen (_C:\Windows\System32\drivers\etc\hosts_)

    IP der WSL-Instanz mittels Powershell ermitteln:

    `wsl -d dev-infra ip -o -4 -json addr list eth0 | ConvertFrom-Json | %{ $_.addr_info.local } | ?{ $_ }`

    Host-Einträge:

    `<WSL-IP> web.dev.local`

   `<WSL-IP> lvs.dev.local`
2. Umgebungsvariable für Xdebug erstellen und laden. Innerhalb der dev-infra Bash:
   * `echo 'export PHP_IDE_CONFIG="serverName=WSL-dev-infra"' >> ~/.profile; source ~/.profile`

3. PHPStorm durch Firewall zulassen: Das Menü "Apps über die Windows-Firewall kommunizieren lassen" -> "Einstellungen ändern" -> In der Liste PHPStorm suchen und den Haken bei Domäne und Privat setzen.

## Konfiguration eines neuen Projekts in PhpStorm
1. PHP-Interpreter:
   * Settings -> PHP -> CLI-Interpreter -> + -> "From Docker, Vagrant [...]"
   * WSL Distro auswählen
2. Server erstellen:
   * Settings -> PHP -> Servers -> +
     Name: WSL-dev-infra
     Host: web.dev.local
     Port: 443
     Debugger: Xdebug
     Use Path mappings: /home/<wsl-distro-username/projects/shop
3. Debugger konfigurieren:
   * Settings -> PHP -> Debug -> Sektion Xdebug
     Debug port: 9003,9000,9010
4. PhpStan konfigurieren
   * Settings -> PhpStan
5. Composer konfigurieren
   * Settings -> PHP -> Composer: Unter _Path to composer.json_ den Pfad auswählen (z.B. im shop Repo _\\\\wsl.localhost\dev-infra\home\<wsl-username>\projects\shop\composer.json_)
     und unter _Execution_ _Remote Interpreter_ auswählen. Als _CLI Interpreter_ den unter Punkt 1. erstellten CLI Interpreter auswählen. _Path mappings_ und _Executable_ sollten direkt gesetzt sein.
   * Anschließend kann die composer Integration über PHPStorm benutzt werden, z.B. wenn die composer.json geöffnet ist, kann man auf install klicken, um die Abhängigkeiten zu installieren.
6. Node konfigurieren
   * Settings -> Languages & Frameworks -> Node.js: Hinter _Node Interpreter_ auf die 3 Punkte klicken, dann mit dem _+_ einen neuen Interpreter hinzufügen _Add WSL_. Als _Linux distribution_ _dev-infra_ auswählen. Der Pfad zum Executable sollte dann direkt ausgefüllt werden.
   * Der Pfad zum npm executable sollte dann auch direkt ausgefüllt sein.
   * Anschließend kann die npm Integration über PHPStorm benutzt werden, z.B. wenn die package.json geöffnet ist, erscheint ein Pop mit `npm install` oder man kann direkt einzelne Befehle in der package.json anklicken und somit laufen lassen.

## Neuerstellung der Distro
1. Projekte auf ungepushte Änderungen überprüfen
2. Distro mittels Powershell entfernen

   `wsl --unregister dev-infra`
4. Angelegte Verknüpfung im Verzeichnis _C:\Users\<windows-username>\wsl_ ausführen
