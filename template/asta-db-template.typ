// asta-db-template.typ – Leere Personendatenbank für ein neues Semester
// Kopiere diese Datei als "asta-db.typ" in dein Protokollverzeichnis
// und trage die aktuellen Personen ein.

// Semester (z.B. "SoSe 2026", "WiSe 2026/27")
#let semester = "SoSe 2026"

// ============================================================
// REFERATE
// Jedes Referat ist stimmberechtigt.
//
// Key      = Kürzel (z.B. "finanzen") → wird in anwesend:/entschuldigt: im Protokoll genutzt
// referat  = offizieller Referatsname
// personen = Liste von Referent*innen
//   vorname, nachname = voller Name
//   kuerzel = Kurzbezeichnung für /kuerzel-Syntax im Protokolltext (eindeutig!)
// ============================================================
#let referate = (
  hochschuldemokratie: (
    referat: "Ref. Hochschuldemokratie",
    personen: (
      // (vorname: "Vorname", nachname: "Nachname", kuerzel: "kuerzel"),
    ),
  ),
  digitales: (
    referat: "Ref. Digitales",
    personen: (),
  ),
  finanzen: (
    referat: "Ref. Finanzen",
    personen: (
 

    ),
  ),
  fachschaften: (
    referat: "Ref. Fachschaften",
    personen: (
      // (vorname: "Gabriel" nachname:"Becker")
    ),
  ),
  dieburg: (
    referat: "Ref. Campus Dieburg",
    personen: (),
  ),
  nachhaltigkeit: (
    referat: "Ref. Nachhaltigkeit",
    personen: (),
  ),
  kultur: (
    referat: "Ref. Kultur & Mobilität",
    personen: (),
  ),
  soziales: (
    referat: "Ref. Soziales",
    personen: (),
  ),
  hochschulpolitik: (
    referat: "Ref. Hochschulpolitik",
    personen: (),
  ),
  eut: (
    referat: "Ref. EUt+",
    personen: (),
  ),
  international: (
    referat: "Ref. International Students",
    personen: (),
  ),
  vielfalt: (
    referat: "Ref. Vielfalt",
    personen: (),
  ),
  // Weiteres Referat hinzufügen:
  // neues-referat: (
  //   referat: "Ref. Neues Referat",
  //   personen: (),
  // ),
)

// ============================================================
// GEWERBLICHE REFERATE
// Keine Stimmrechte, erscheinen aber im Protokollkopf.
// ============================================================
#let gewerbliche-referate = (
  glaskasten: (
    name: "Café Glaskasten",
    personen: (),
  ),
  zeitraum: (
    name: "Café Zeitraum",
    personen: (),
  ),
)

// ============================================================
// AGs
// Nicht stimmberechtigt, erscheinen aber im Protokollkopf.
// ============================================================
#let ags = (
  design: (
    name: "AG Design",
    personen: (),
  ),
  oea: (
    name: "AG Öffentlichkeit",
    personen: (),
  ),
  event: (
    name: "AG Eventmanagement",
    personen: (),
  ),
  media: (
    name: "AG Media",
    personen: (),
  ),
  technik: (
    name: "AG Technik & Infrastruktur",
    personen: (),
  ),
  // Neue AG hinzufügen:
  // neue-ag: (
  //   name: "AG Neue AG",
  //   personen: (),
  // ),
)

// ============================================================
// GESCHÄFTSSTELLE
// Nicht stimmberechtigt.
// ============================================================
#let geschaeftsstelle = (
  personen: (
    // (vorname: "Vorname", nachname: "Nachname", kuerzel: "kuerzel"),
  ),
)
