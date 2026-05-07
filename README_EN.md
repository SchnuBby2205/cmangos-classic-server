# CMaNGOS Classic Server (Docker Edition)

> Complete Docker setup for a local **CMaNGOS Classic 1.12 Server**
> including:
>
> * 🤖 Playerbots
> * 🛒 AH-Bot
> * 🧠 AI Chat Bots via KoboldCPP
> * 🐳 Docker Compose
> * 🗺️ automatic Map/VMap extraction
> * 💾 MariaDB database

---

# Table of Contents

* [Features](#features)
* [Requirements](#voraussetzungen)
* [Project Structure](#projektstruktur)
* [Important Notes](#wichtige-hinweise)
* [Build Docker Image](#docker-image-bauen)
* [Extract WoW Data](#wow-daten-extrahieren)
* [Download AI Models](#ai-modelle-herunterladen)
* [Start Server](#server-starten)
* [Create Account](#account-erstellen)
* [Configure WoW Client](#wow-client-konfigurieren)
* [AI Chat & Bots](#ai-chat--bots)
* [Useful Commands](#nützliche-befehle)
* [Known Issues](#bekannte-probleme)
* [Credits](#credits)

---

# Features

## Included

✅ CMaNGOS Classic 1.12
✅ Docker Compose Setup
✅ Playerbots
✅ Random Bots
✅ Auction House Bot
✅ KoboldCPP AI Integration
✅ automatic database initialization
✅ preconfigured Docker environment
✅ AI chat bots with local LLMs

---

# Requirements

Required:

* Docker
* Docker Compose
* Docker Buildx
* Linux System
* WoW Classic 1.12 Client

---

## Install Docker on Arch Linux

```bash
sudo pacman -S docker docker-buildx
sudo usermod -aG docker $USER
newgrp docker
```

---

# Project Structure

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

# Important Notes

## WoW Client MUST be in the same directory

The WoW client must exist as:

```text
wow-client/
```

inside the project's root directory.

Example:

```text
cmangos-classic-server/
└── wow-client/
```

---

## The `Data` folder MUST use uppercase letters

CMaNGOS erwartet:

```text
wow-client/Data
```

NICHT:

```text
wow-client/data
```

If necessary:

```bash
mv wow-client/data wow-client/Data
```

---

## `sql-init` MUST be extracted

Der Inhalt von:

```text
sql-init/
```

must contain real `.sql` files.

Do not leave ZIP/RAR/7z archives inside the folder.

Example:

```text
sql-init/
└── 01-init.sql
```

---

## Always extract VMaps and Maps yourself

VMaps from other emulators are NOT compatible.

Nicht von:

* VMaNGOS
* AzerothCore
* TrinityCore
* other sources

Always extract them yourself.

---

# Build Docker Image

## Standard Build

```bash
docker build -t cmangos-classic .
```

---

## Rebuild without cache

```bash
docker build --no-cache -t cmangos-classic .
```

---

# Extract WoW Data

## Start extractor

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

## Recommended Answers

```text
Should all data be extracted?      -> y
High-resolution maps?              -> n
High-resolution vmaps?             -> n
```

---

# After Extraction

## Fix Permissions

Docker writes files as root.

```bash
sudo chown -R $USER:$USER wow-client/
```

---

## Move Data

```bash
mv wow-client/maps      data/
mv wow-client/dbc       data/
mv wow-client/vmaps     data/
mv wow-client/mmaps     data/
mv wow-client/cameras   data/
mv wow-client/buildings data/
```

---

# Download AI Models

The AI models are required for KoboldCPP.

---

## Switch to the model directory

```bash
cd ai-models
```

---

## Small model (~1.4 GB)

```bash
wget https://huggingface.co/mradermacher/Llama-3.2-1B-Instruct-Uncensored-GGUF/resolve/main/Llama-3.2-1B-Instruct-Uncensored.Q8_0.gguf
```

---

## Recommended model (~4.9 GB)

Recommended for systems with at least 16 GB RAM.

```bash
wget https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q8_0.gguf
```

---

# Start Server

## Start database only

```bash
docker compose up db -d
```

---

## Gesamten Start Server

```bash
docker compose up -d
```

---

# Show Logs

## Worldserver

```bash
docker compose logs mangosd -f
```

---

## KoboldCPP

```bash
docker compose logs koboldcpp -f
```

If the following appears:

```text
Please connect to custom endpoint at http://0.0.0.0:5001
```

the AI model has been loaded.

---

# Create Account

Connect to the worldserver console:

```bash
docker attach cmangos-mangosd
```

---

## Create Account

```text
account create MeinAccount MeinPasswort
account set gmlevel MeinAccount 3
```

```text
0 -> normal player account
3 -> GM account
```

Nach dem ersten Start ist bereits ein GM account angelegt:

```text
Name     -> wowclassicadmin
Passwort -> nimdacissalcwow
```

---

## Leave console without stopping

```text
CTRL + P
CTRL + Q
```

---

# Configure WoW Client

File:

```text
Data/deDE/realmlist.wtf
```

Content:

```text
set realmlist 127.0.0.1
```

---

# Verbindung bei Betrieb über VM oder einem anderen Gerät

Wenn der Server in einer VM, auf einem anderen Rechner oder im Netzwerk läuft, muss die IP-Adresse in der Datenbank angepasst werden.

---

## Realmlist IP anpassen

In die MariaDB verbinden:

```bash
docker exec -it cmangos-db mariadb -uroot -proot 
```

---

## Classic Realmlist aktualisieren

```sql
USE classicrealmd;  
UPDATE realmlist SET address = 'DEINE.SERVER.IP' WHERE id = 1; 
```

Example:

```sql
UPDATE realmlist SET address = '192.168.178.50' WHERE id = 1; 
```

---

## Änderungen prüfen

```sql
SELECT * FROM realmlist; 
```

---

## WoW Client anpassen

In der File:

```text
Data/deDE/realmlist.wtf 
```

die IP des Servers eintragen:

```text
set realmlist 192.168.178.50 
```

---

## Wichtiger Hinweis

Falls der Server in einer VM läuft:

- benötigte Ports freigeben
- Bridged Networking bevorzugen
- Firewall prüfen

Benötigte Ports:

```text
3724  -> Authserver 
8085  -> Worldserver 
5001  -> KoboldCPP (optional) 
```

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

Damit Bots in der Gruppe mit AI antworten:

```text
/p nc +ai chat
```

Danach einfach im Party-Chat mit Bots schreiben.

---

# Useful Commands

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

## Restart container

```bash
docker compose restart mangosd
docker compose restart koboldcpp
```

---

## Show Logs

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

# Known Issues

---

## "Your output directory seems to be polluted"

Solution:

```bash
rm -rf wow-client/Buildings
rm -rf wow-client/vmaps
```

Danach erneut extrahieren.

---

## `VMap file missing`

VMAPS von anderen Emulatoren sind inkompatibel.

Always extract them yourself.

---

## Dateien gehören root

Docker erzeugt Dateien als root.

Fix:

```bash
sudo chown -R $USER:$USER .
```

---

## AI Playerbot is Disabled

Die File:

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
