## Vorbereitung:
1. Optional: Windows Terminal installieren (https://learn.microsoft.com/de-de/windows/terminal/install)
2. Folgende Windows-Features aktivieren und anschließend neu starten:
   * Hyper-V
   * Windows Subsystem for Linux
3. Powershell:
   `wsl --update --pre-release`

## Start:
1. Repo "wsltooling" in _C:\Users\<windows-username>\git_ klonen: https://github.com/cherrmann89/wsltooling
2. Verzeichnis _C:\Users\<windows-username>\wsl_ anlegen
3. GitHub Token mit den Rechten _repo:all_, _read:org_ und _admin:public_key:all_ erzeugen und in _C:\Users\<windows-username>\wsl\\.token_ speichern
4. Verknüpfung im Verzeichnis _C:\Users\<windows-username>\wsl_ anlegen:
   * `powershell.exe -NoExit -execution bypass "%HOMEPATH%\git\wsltooling\installUbuntuLTS.ps1 dev-infra %HOMEPATH%\wsl\dev-infra <wsl-distro-username> <git-username> C:\Users\<windows-username>\wsl\.token"`

## Nachbereitung:
1. Konstante `APP_ROOT` in .configure.php im Shop- und Lager-Repository mit dem Pfad zum Projektverzeichnis befüllen, also _/home/<wsl-distro-username>/projects_
2. Host-Eintrag anlegen (_C:\Windows\System32\drivers\etc\hosts_)

    IP der WSL-Instanz mittels Powershell ermitteln:

    `wsl -d dev-infra ip -o -4 -json addr list eth0 | ConvertFrom-Json | %{ $_.addr_info.local } | ?{ $_ }`

    Host-Eintrag:

    `<WSL-IP> web.dev.local`
3. Umgebungsvariable für Xdebug erstellen und laden
   * `echo 'export PHP_IDE_CONFIG="serverName=WSL-dev-infra"' >> ~/.profile; source ~/.profile`

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
