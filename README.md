# quick-asta

**Typst-Protokollvorlage für AStA-Sitzungen der Hochschule Darmstadt.**

Fork von [quick-minutes](https://github.com/Lypsilonx/quick-minutes) (v1.2.4) – angepasst auf die Strukturen des AStA mit Referaten, AGs und zentraler Personendatenbank.

---

## Konzept

Der Kern von `quick-asta` ist eine **zentrale Personendatenbank** (`asta-db.typ`), die einmal pro Semester gepflegt wird. Protokolldateien sind dadurch minimal: Man gibt nur Kürzel an, der Rest wird automatisch aufgelöst.

```
/max: Weist auf Präsidiumsgespräche hin.
→ Max Bergmann (Café Glaskasten): Weist auf Präsidiumsgespräche hin.
```

---

## Dateistruktur

```
quick-asta/
├── asta-minutes.typ          # Haupttemplate
├── asta-db.typ               # Zentrale Personendatenbank (Beispieldaten WiSe 2025/26)
├── typst.toml                # Paketmetadaten
├── LICENSE.txt               # MIT
├── README.md                 # Diese Datei
└── template/
    ├── main.typ              # Startvorlage für ein neues Protokoll
    └── asta-db-template.typ  # Leere DB-Vorlage für ein neues Semester
```

---

## Quickstart

### 1. Datenbankdatei anlegen (1x pro Semester)

Kopiere `template/asta-db-template.typ` als `asta-db.typ` in dein Projektverzeichnis und fülle sie mit den aktuellen Personen:

```typ
// asta-db.typ
#let semester = "WiSe 2025/26"

#let referate = (
  finanzen: (
    referat: "Ref. Finanzen",
    personen: (
      (vorname: "Laura", nachname: "Schneider", kuerzel: "laura"),
    ),
  ),
  // ...
)

#let ags = (
  glaskasten: (
    name: "Café Glaskasten",
    personen: (
      (vorname: "Max", nachname: "Bergmann", kuerzel: "max"),
    ),
  ),
  // ...
)

#let geschaeftsstelle = (
  personen: (
    (vorname: "Sara", nachname: "Hoffmann", kuerzel: "sara"),
  ),
)
```

**Wichtig:** Jedes `kuerzel` muss **eindeutig** sein. Bei Mehrdeutigkeiten wird eine Warnung ausgegeben.

### 2. Protokolldatei erstellen

Kopiere `template/main.typ` und passe die Parameter an:

```typ
#import "asta-db.typ": *
#import "asta-minutes.typ": asta-minutes

#show: asta-minutes.with(
  db: (referate: referate, ags: ags),
  geschaeftsstelle: geschaeftsstelle,
  date: datetime(year: 2025, month: 10, day: 28),
  location: "Online",
  protokollant: "sara",        // Kürzel aus DB

  anwesend: (
    "hochschulpolitik", "digitales", "finanzen", "dieburg",
    "fachschaften", "nachhaltigkeit", "vielfalt", "eut",
    "soziales", "international", "kultur",
  ),
  entschuldigt: (),
  ags-anwesend: ("glaskasten", "event", "design"),
  gaeste: ("Tom (IJV)", "Julia"),
)

1838/

= Protokollgenehmigung
!Protokoll 14.10./einstimmig

= Anträge & Finanzanträge
!Verpflegung bis 300 EUR/einstimmig

/2200
```

### 3. Kompilieren

```bash
typst compile protokoll-2025-10-28.typ
```

---

## Parameter

### Pflichtfelder

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `db` | dict | `(referate: referate, ags: ags)` aus asta-db.typ |
| `date` | `datetime` | Datum der Sitzung |
| `location` | string | Ort der Sitzung |
| `protokollant` | string | Kürzel aus DB, oder Freitext mit führendem `-` |

### Anwesenheit

| Parameter | Typ | Beschreibung |
|-----------|-----|--------------|
| `anwesend` | array | Kürzel der anwesenden Referate |
| `entschuldigt` | array | Kürzel der entschuldigten Referate |
| `ags-anwesend` | array | Kürzel der anwesenden AGs/Cafés |
| `gaeste` | array | Externe Gäst\*innen (Freitext) |

Referate, die weder in `anwesend` noch in `entschuldigt` stehen, werden automatisch als **unentschuldigt** gelistet.

### Optionale Parameter

| Parameter | Standard | Beschreibung |
|-----------|----------|--------------|
| `sitzungsleitung` | `none` | Kürzel oder Freitext |
| `geschaeftsstelle` | `none` | `geschaeftsstelle` aus asta-db.typ |
| `logo` | `none` | `image("logo.png")` |
| `name-format` | `"full"` | `"full"` · `"short"` · `"first"` |
| `formal` | `false` | `true` = formaler Footer mit Adressen |
| `signing` | `false` | Unterschriftenzeile am Ende |
| `line-numbering` | `none` | z.B. `5` für jede 5. Zeile |
| `fancy-decisions` | `false` | Abstimmungsbalken statt Text |
| `hole-mark` | `true` | Lochmarke links |
| `separator-lines` | `true` | Trennlinien bei Level-1-Überschriften |
| `hide-warnings` | `false` | Warnungen unterdrücken |

---

## Kommandos im Protokolltext

### Zeitstempel

```typ
1838/                          → Setzt die aktuelle Zeit auf 18:38 (unsichtbar)
1838/ Alle erschienen          → Zeitstempel mit Text
```

### Abstimmungen

```typ
!Antrag XYZ/einstimmig        → "einstimmig angenommen"
!Antrag XYZ/9/0/2             → "Dafür: 9, Dagegen: 0, Enthaltung: 2"
!Antrag XYZ/Ja 9/Enthaltung 2 → "Ja: 9, Enthaltung: 2"
!1930/Antrag XYZ/9/0/2        → mit Zeitstempel 19:30
```

### Referate kommen/gehen

```typ
++1930/vielfalt               → Ref. Vielfalt meldet sich an (11 von 12 stimmberechtigt)
--2015/dieburg                → Ref. Campus Dieburg verlässt die Sitzung (10 von 12 stimmberechtigt)
+/vielfalt                    → Ref. Vielfalt kommt zurück
-/dieburg                     → Ref. Campus Dieburg geht kurz
```

`++`/`--` = dauerhaft (Sitzung betreten/verlassen); `+`/`-` = kurzzeitig (Pause).

### Namenserkennung (Kürzel)

```typ
/max: Macht einen Vorschlag.
→ Max Bergmann (Café Glaskasten): Macht einen Vorschlag.

/lisa wird das übernehmen.
→ Lisa Wagner (Ref. Fachschaften) wird das übernehmen.
```

Kürzel bestehen aus Kleinbuchstaben und Ziffern. Unbekannte Kürzel werden rot markiert und erzeugen eine Warnung.

**Namensformat** (Parameter `name-format`):
- `"full"` → `"Vorname Nachname (Funktion)"` (Standard)
- `"short"` → `"Vorname (Funktion)"`
- `"first"` → `"Vorname"`

Freitext-Namen (nicht in DB) mit führendem `-` schützen: `/-Externe Person`.

### Sitzungsende

```typ
/end                          → Ende der Sitzung (letzte bekannte Zeit)
/2200                         → Ende der Sitzung um 22:00
```

### Nichtöffentlicher Sitzungsteil

```typ
==== Nichtöffentlicher AStA-Sitzungsteil
```

Erzeugt eine Trennlinie, erscheint **nicht** im Inhaltsverzeichnis.

---

## Protokollkopf

Wird automatisch aus DB + Anwesenheitslisten generiert:

```
┌──────────────────────┬──────────────────┬──────────────┬─────────────────────┐
│ Anwesend AStA:       │ Anwesend AGs:    │ Entschuldigt:│ Unentschuldigt:     │
│ • Ref. Hochschul-    │ • Café Glaskasten│ (keine)      │ • Ref. Hochschul-   │
│   politik            │ • AG Eventmgmt.  │              │   demokratie        │
│ • Ref. Digitales     │ • AG Design      │              │                     │
└──────────────────────┴──────────────────┴──────────────┴─────────────────────┘
Gäst*innen: Tom (IJV), Julia, Marie
Protokoll: Sara Hoffmann (Geschäftsstelle)
Beschlussfähig: 11 von 12 Referaten anwesend
```

**Beschlussfähigkeit:** mehr als 50 % der Referate müssen anwesend sein. Bei Unterschreitung erscheint eine Warnung.

---

## DB-Verwaltung: Semester-Update

1. `template/asta-db-template.typ` kopieren → `asta-db.typ` im Projektverzeichnis
2. `semester` aktualisieren
3. Für jedes Referat/jede AG: aktuelle Personen eintragen
4. Alle Protokolle des neuen Semesters importieren die neue DB

---

## Warnungen

Am Ende des Dokuments erscheinen automatische Warnungen für:
- Unbekannte oder mehrdeutige Kürzel
- Nicht beschlussfähige Sitzung
- Fehlende Pflichtparameter
- Ungültige Zeitangaben

Mit `hide-warnings: true` können Warnungen unterdrückt werden.

---

## Lizenz & Credits

MIT License – Fork von [quick-minutes](https://github.com/Lypsilonx/quick-minutes) von Katharina Thöle & Lyx Rothböck.
