# CMaNGOS Classic Server (Docker Edition)

> Vollständiges Docker-Setup für einen lokalen **CMaNGOS Classic 1.12 Server**
> inklusive:
>
> * 🤖 Playerbots
> * 🛒 AH-Bot
> * 🧠 AI Chat Bots via KoboldCPP
> * 🐳 Docker Compose
> * 🗺️ automatischer Map-/VMap-Extraktion
> * 💾 MariaDB Datenbank

---

# Inhaltsverzeichnis

* [Features](#features)
* [Voraussetzungen](#voraussetzungen)
* [Projektstruktur](#projektstruktur)
* [Wichtige Hinweise](#wichtige-hinweise)
* [Docker Image bauen](#docker-image-bauen)
* [WoW Daten extrahieren](#wow-daten-extrahieren)
* [AI Modelle herunterladen](#ai-modelle-herunterladen)
* [Server starten](#server-starten)
* [Account erstellen](#account-erstellen)
* [WoW Client konfigurieren](#wow-client-konfigurieren)
* [AI Chat & Bots](#ai-chat--bots)
* [Nützliche Befehle](#nützliche-befehle)
* [Bekannte Probleme](#bekannte-probleme)
* [Credits](#credits)

---

# Features

## Enthalten

✅ CMaNGOS Classic 1.12
✅ Docker Compose Setup
✅ Playerbots
✅ Random Bots
✅ Auction House Bot
✅ KoboldCPP AI Integration
✅ automatische Datenbankinitialisierung
✅ vorbereitete Docker Umgebung
✅ AI Chat Bots mit lokalen LLMs

---

# Voraussetzungen

Benötigt werden:

* Docker
* Docker Compose
* Docker Buildx
* Linux System
* WoW Classic 1.12 Client

---

## Docker unter Arch Linux installieren

```bash
sudo pacman -S docker docker-buildx
sudo usermod -aG docker $USER
newgrp docker
```

---

# Projektstruktur

```text
cmangos-classic-server/
├── ai-models/
├── config/
├── data/
│   ├── dbc/
│   ├── maps/
│   ├── mmaps/
│   └── vmaps/
├── sql-init/
├── wow-client/
├── docker-compose.yml
└── Dockerfile
```

---

# Wichtige Hinweise

## WoW Client MUSS im selben Verzeichnis liegen

Der WoW Client muss als:

```text
wow-client/
```

im Root-Verzeichnis des Projekts liegen.

Beispiel:

```text
cmangos-classic-server/
└── wow-client/
```

---

## Der Ordner `Data` MUSS groß geschrieben sein

CMaNGOS erwartet:

```text
wow-client/Data
```

NICHT:

```text
wow-client/data
```

Falls nötig:

```bash
mv wow-client/data wow-client/Data
```

---

## `sql-init` MUSS entpackt sein

Der Inhalt von:

```text
sql-init/
```

muss aus echten `.sql` Dateien bestehen.

Keine ZIP/RAR/7z Archive im Ordner lassen.

Beispiel:

```text
sql-init/
└── 01-init.sql
```

---

## VMaps und Maps immer selbst extrahieren

VMaps von anderen Emulatoren sind NICHT kompatibel.

Nicht von:

* VMaNGOS
* AzerothCore
* TrinityCore
* anderen Quellen übernehmen

Immer selbst extrahieren.

---

# Docker Image bauen

## Standard Build

```bash
docker build -t cmangos-classic .
```

---

## Neu bauen ohne Cache

```bash
docker build --no-cache -t cmangos-classic .
```

---

# WoW Daten extrahieren

## Extractor starten

```bash
docker run --rm -it \
    -v $(pwd)/wow-client:/wow \
    cmangos-classic \
    bash -c "
        cp /opt/mangos/bin/tools/* /wow/ && \
        cd /wow && \
        sed -i 's/\r//' ExtractResources.sh && \
        bash ./ExtractResources.sh
    "
```

---

## Empfohlene Antworten

```text
Should all data be extracted?      -> y
High-resolution maps?              -> n
High-resolution vmaps?             -> n
```

---

# Nach der Extraktion

## Rechte korrigieren

Docker schreibt Dateien als root.

```bash
sudo chown -R $USER:$USER wow-client/
```

---

## Daten verschieben

```bash
mv wow-client/maps      data/
mv wow-client/dbc       data/
mv wow-client/vmaps     data/
mv wow-client/mmaps     data/
mv wow-client/cameras   data/
mv wow-client/buildings data/
```

---

# AI Modelle herunterladen

Die AI-Modelle werden für KoboldCPP benötigt.

---

## In den Modellordner wechseln

```bash
cd ai-models
```

---

## Kleines Modell (~1.4 GB)

```bash
wget https://huggingface.co/mradermacher/Llama-3.2-1B-Instruct-Uncensored-GGUF/resolve/main/Llama-3.2-1B-Instruct-Uncensored.Q8_0.gguf
```

---

## Empfohlenes Modell (~4.9 GB)

Empfohlen bei mindestens 16 GB RAM.

```bash
wget https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q8_0.gguf
```

---

# Server starten

## Nur Datenbank starten

```bash
docker compose up db -d
```

---

## Gesamten Server starten

```bash
docker compose up -d
```

---

# Logs anzeigen

## Worldserver

```bash
docker compose logs mangosd -f
```

---

## KoboldCPP

```bash
docker compose logs koboldcpp -f
```

Wenn erscheint:

```text
Please connect to custom endpoint at http://0.0.0.0:5001
```

ist das AI-Modell geladen.

---

# Account erstellen

Mit der Worldserver-Konsole verbinden:

```bash
docker attach cmangos-mangosd
```

---

## Account anlegen

```text
account create MeinAccount MeinPasswort
account set gmlevel MeinAccount 3
```

---

## Konsole verlassen ohne Stoppen

```text
CTRL + P
CTRL + Q
```

---

# WoW Client konfigurieren

Datei:

```text
Data/deDE/realmlist.wtf
```

Inhalt:

```text
set realmlist 127.0.0.1
```

---

# AI Chat & Bots

## Random Bots

Random Bots laufen automatisch durch die Welt.

---

## Eigene Bots

```text
.bot add BOTNAME
.bot remove BOTNAME
```

---

## AI Chat

Damit Bots mit AI antworten:

```text
AiPlayerbot.LLMEnabled = 2
```

Danach einfach im Party-Chat mit Bots schreiben.

---

# Nützliche Befehle

## Server stoppen

```bash
docker compose down
```

---

## Komplett löschen inklusive Datenbank

```bash
docker compose down -v
docker rmi cmangos-classic
```

---

## Container neu starten

```bash
docker compose restart mangosd
docker compose restart koboldcpp
```

---

## Logs anzeigen

```bash
docker compose logs mangosd -f
docker compose logs koboldcpp -f
```

---

## Docker Speicher bereinigen

```bash
docker system prune -f
docker builder prune -f
```

---

# Bekannte Probleme

---

## "Your output directory seems to be polluted"

Lösung:

```bash
rm -rf wow-client/Buildings
rm -rf wow-client/vmaps
```

Danach erneut extrahieren.

---

## `VMap file missing`

VMAPS von anderen Emulatoren sind inkompatibel.

Immer selbst extrahieren.

---

## Dateien gehören root

Docker erzeugt Dateien als root.

Fix:

```bash
sudo chown -R $USER:$USER .
```

---

## AI Playerbot is Disabled

Die Datei:

```text
aiplayerbot.conf
```

muss nach:

```text
/opt/etc/aiplayerbot.conf
```

gemountet werden.

NICHT nach:

```text
/opt/mangos/etc/
```

---

## Bots antworten nicht mit AI

Prüfen:

* läuft KoboldCPP?
* ist Port 5001 erreichbar?
* ist `AiPlayerbot.LLMEnabled = 2` gesetzt?
* stimmt der Endpoint?

```text
http://koboldcpp:5001/api/v1/generate
```

---

# Credits

* CMaNGOS
* ike3 / celguar Playerbots
* KoboldCPP
* MariaDB
* Arch Linux

---

# Lizenz

Dieses Repository enthält nur Setup- und Docker-Dateien.

CMaNGOS selbst unterliegt der jeweiligen Upstream-Lizenz.
