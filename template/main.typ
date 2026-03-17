// Protokoll-Vorlage für AStA-Sitzungen der Hochschule Darmstadt
// Kopiere diese Datei für jede Sitzung und passe die Parameter an.
// Benenne die Datei z.B. "protokoll-2025-10-28.typ"

#import "../asta-db.typ": *
#import "../asta-minutes.typ": asta-minutes

#show: asta-minutes.with(
  db: (referate: referate, ags: ags),
  geschaeftsstelle: geschaeftsstelle,

  // Datum der Sitzung
  date: datetime(year: 2025, month: 10, day: 28),

  // Ort: "Online", "Campus Darmstadt", "Campus Dieburg", ...
  location: "Online",

  // Protokollant*in: Kürzel aus asta-db.typ
  // Alternativ Freitext mit führendem "-": "-Max Mustermann"
  protokollant: "anke",

  // Sitzungsleitung (optional)
  // sitzungsleitung: "felix",

  // Anwesende Referate: Kürzel aus asta-db.typ
  anwesend: (
    "hochschulpolitik",
    "digitales",
    "finanzen",
    "dieburg",
    "fachschaften",
    "nachhaltigkeit",
    "vielfalt",
    "eut",
    "soziales",
    "international",
    "kultur",
  ),

  // Entschuldigte Referate
  entschuldigt: (),

  // Anwesende AGs und Cafés
  ags-anwesend: (
    "glaskasten",
    "event",
    "design",
  ),

  // Externe Gäst*innen (Freitext, nicht in DB)
  gaeste: (
    "Vito (IJV)",
    "Nikolai",
    "Benita",
  ),

  // Layout-Optionen
  logo: none,          // image("asta-logo.png")
  formal: false,       // true = formaler Footer mit Adressen
  signing: false,      // true = Unterschriftenzeile am Ende
  line-numbering: none, // none | 5 | 10 | ...
)

// ═══════════════════════════════════════════════════════════════════
// PROTOKOLL
// ═══════════════════════════════════════════════════════════════════
//
// Zeitstempel-Syntax:
//   1838/                      → Zeitmarke setzen (kein Text)
//   1838/ Freitext             → Zeitmarke mit Text
//
// Abstimmungen:
//   !Antrag XYZ/einstimmig     → einstimmig angenommen
//   !Antrag XYZ/9/0/2          → Dafür: 9, Dagegen: 0, Enthaltung: 2
//   !Antrag XYZ/Ja 9/Nein 1    → Ja: 9, Nein: 1
//
// Referate kommen/gehen:
//   ++1930/vielfalt            → Ref. Vielfalt meldet sich an
//   --2015/dieburg             → Ref. Campus Dieburg verlässt die Sitzung
//   +1930/vielfalt             → Ref. Vielfalt kommt zurück
//   -/dieburg                  → Ref. Campus Dieburg geht kurz
//
// Namens-Auflösung (Kürzel aus DB):
//   /seb: Macht einen Vorschlag.   → "Sebastian Müller (Café Glaskasten): Macht einen Vorschlag."
//   /mariia wird das übernehmen.   → "Mariia Ivanova (Ref. Fachschaften) wird das übernehmen."
//
// Sitzungsende:
//   /end  oder  /2200

1838/

= Protokollgenehmigung

!Protokoll 14.10./einstimmig

= Anträge & Finanzanträge

== Ref. Fachschaften

- Antrag auf Verpflegung auf AStA-Sitzungen bis max. 300 EUR

!Verpflegung bis 300 EUR/einstimmig

== Ref. EUt+

- Antrag auf Übernahme Park- und Reisekosten

!Reisekosten Wiesbaden/einstimmig

= Gäst*innen

== Internationaler Jugendverein

- Vorstellung Filmreihe: Femizid (Nov), Weihnachten (Dez), Hanau (Jan)
- Interne Diskussion vor Entscheidung

= Berichte und Projekte

== Ref. Fachschaften

- Vorschlag informelles AStA-Treffen, vorzugsweise Freitag

== Ref. Fachschaften und Ref. Digitales

- Vorstellung AStA-Wiki, Bitte um Dokumentation

== Café Glaskasten

!Gutscheinkarten bis 300 EUR/einstimmig

= Sonstiges

== Ref. Soziales

- Workshop-Idee statt Ausstellung, Details folgen

==== Nichtöffentlicher AStA-Sitzungsteil

/2200
