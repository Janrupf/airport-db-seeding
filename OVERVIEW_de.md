# Datenbankprojekt

## Struktur
- `cache` - Dieser Ordner wird genutzt, um heruntergeladenen Dateien für Datengenration
            zwischenzuspeichern
- `command` - Enthält die Python Skripte, die als Kommandos vom Terminal aus aufgerufen 
              werden können und die SQL Skripte generieren
- `data` - Enthält Python Skripte, welche Daten herunterladen und erfassen
- `scripts` - Hier werden die generierten SQL Skripte gespeichert
- `main.py` - Einstiegspunkt für das Python-Programm zur Generierung der SQL Skripte
- `requirements.txt` - PIP kompatible Datei, die die Abhängigkeiten des Programms 
                       beinhaltet
  
## Lizenzierung
Alle Python Skripte sowohl als generierte Dateien werden unter der 
[MIT License](https://opensource.org/licenses/MIT) bereitgestellt.

Daten und Skripte, die nicht Bestandteil des Programmes sind fallen unter eigene
Lizenzen:

Programm-Abhängigkeiten:
- `certifi` [Mozilla Public License 2.0](https://www.mozilla.org/en-US/MPL/2.0/)
- `protobuf` [Custom License](https://github.com/protocolbuffers/protobuf/blob/master/LICENSE)
- `PyMySQL` [MIT License](https://opensource.org/licenses/MIT)
- `python-dotenv` [Custom License](https://github.com/theskumar/python-dotenv/blob/master/LICENSE)
- `six` [MIT License](https://opensource.org/licenses/MIT)
- `urllib3` [MIT License](https://opensource.org/licenses/MIT)

Datenquellen:
- Städte und Länder bereitgestellt von [geonames](http://www.geonames.org/) unter 
  [Creative Common Attribution License](http://creativecommons.org/licenses/by/3.0/)
- Namen und Vornamen bereitgestellt unter [Unlicense](https://github.com/smashew/NameDatabases/blob/master/LICENSE)
- Flugdaten bereitgestellt von [OpenFlights](https://openflights.org/) unter 
  [Open Database License](http://opendatacommons.org/licenses/odbl/1.0/),
  [Database Contents License](http://opendatacommons.org/licenses/dbcl/1.0/),
  und [GNU Free Documentation License](https://www.gnu.org/copyleft/fdl.html)
- Straßennamen bereitgestellt unter [MIT License](https://opensource.org/licenses/MIT)

In Übereinstimmung mit allen oben gelisteten Lizenzen wird dieses Programm und der 
dazugehörige Quellcode auf Github https://github.com/Janrupf/airport-db-seeding
veröffentlicht.

Die Lizenzierung von Abhängigkeiten und Daten betrifft nur die Distribution des Programmes
und die Verwendung. Der Quellcode und die Dokumentation werden unter der 
[MIT License](https://opensource.org/licenses/MIT) bereitgestellt. Ausgenommen sind die 
Dateien in dem `scripts` Ordner, diese sind Dual-Lizenziert unter 
[MIT License](https://opensource.org/licenses/MIT) und der 
[Open Database License](http://opendatacommons.org/licenses/odbl/1.0/).

## Korrektheit der Daten
Alle Daten sind lediglich Beispiel Daten und sollten nur für Simulationszwecke verwendet 
werden.
Bezüglich der Flugdaten können weitere informationen [hier](https://openflights.org/faq)
gefunden werden.
