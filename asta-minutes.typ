// asta-minutes.typ – AStA-Protokollvorlage der Hochschule Darmstadt
// Basiert auf quick-minutes von Katharina Thöle & Lyx Rothböck (MIT)
// Fork/Anpassung für AStA-Sitzungen: Referate, AGs, Beschlussfähigkeit

// ── Hilfsfunktionen (außerhalb der Hauptfunktion) ──────────────────────────

#let noun(it) = [#text(features: ("smcp",), tracking: 0.025em)[#it]]
#let versal(it) = [#text(tracking: 0.125em, number-type: "lining")[#upper[#it]]]

// Baut aus der DB ein flaches Lookup-Dict: kuerzel → (vollname, funktion)
// Wird von asta-minutes intern aufgerufen.
#let build-lookup(referate, ags, geschaeftsstelle, gewerbliche-referate: (:)) = {
  let ensure-arr(x) = if type(x) == array { x } else if x == none { () } else { (x,) }
  let merge-persons(lookup, persons, funktion) = {
    for person in ensure-arr(persons) {
      if type(person) != dictionary { continue }
      if not person.keys().contains("kuerzel") { continue }
      let k = person.kuerzel
      let nachname = if person.keys().contains("nachname") { " " + person.nachname } else { "" }
      let vollname = person.vorname + nachname
      if lookup.keys().contains(k) {
        lookup.insert(k, ("???", "???"))
      } else {
        lookup.insert(k, (vollname, funktion))
      }
    }
    lookup
  }

  let lookup = (:)
  for (_, ref-data) in referate {
    lookup = merge-persons(lookup, ref-data.personen, "AStA " + ref-data.referat)
  }
  for (_, ag-data) in ags {
    lookup = merge-persons(lookup, ag-data.personen, "AStA " + ag-data.name)
  }
  for (_, gew-data) in gewerbliche-referate {
    lookup = merge-persons(lookup, gew-data.personen, "AStA " + gew-data.name)
  }
  if geschaeftsstelle != none {
    lookup = merge-persons(lookup, geschaeftsstelle.personen, "AStA Geschäftsstelle")
  }

  lookup
}

// ── Hauptfunktion ──────────────────────────────────────────────────────────

#let asta-minutes(
  // Pflichtfelder
  db: none,                   // (referate: referate, ags: ags) aus asta-db.typ
  date: none,                 // datetime(year:..., month:..., day:...)
  location: none,             // "Online" | "Campus Darmstadt" | ...

  // Anwesenheit (Kürzel aus DB)
  anwesend: (),               // Kürzel anwesender Referate, z.B. ("digitales", "finanzen")
  entschuldigt: (),           // Kürzel entschuldigter Referate
  ags-anwesend: (),           // Kürzel anwesender AGs
  ags-entschuldigt: (),       // Kürzel entschuldigter AGs (keine Stimmrechte)
  gewerbliche-anwesend: (),   // Kürzel anwesender gewerblicher Referate (keine Stimmrechte)
  gewerbliche-entschuldigt: (), // Kürzel entschuldigter gewerblicher Referate (keine Stimmrechte)
  gaeste: (),                 // Freitextliste externer Gäst*innen, z.B. ("Vito (IJV)",)

  // Personen
  protokollant: none,         // Kürzel oder Freitext (z.B. "anke" oder "-Anke Fischer")
  sitzungsleitung: none,      // Kürzel oder Freitext (optional)

  // Darstellung
  logo: none,                 // image("logo.png") oder none
  name-format: "full",        // "full" | "short" | "first"
  formal: false,              // true = formaler Footer mit Adressen
  signing: false,             // Unterschriftenzeile
  line-numbering: none,       // none | 5 | 10 | ...
  fancy-decisions: true,      // Abstimmungsbalken
  indent-decisions: true,
  hole-mark: true,
  separator-lines: true,
  timestamp-margin: 10pt,
  font-size: 10pt,
  font-size-title: auto,
  font-size-time: auto,
  font-size-line-number: auto,
  margin: (
    left: 4cm,
    right: 2cm,
    top: 3cm,
    bottom: 6cm,
  ),
  geschaeftsstelle: none,     // geschaeftsstelle aus asta-db.typ (optional)
  warning-color: red,
  hide-warnings: false,
  display-all-warnings: false,
  locale: "de",
  body,
) = {

  // Normalisiert einen Parameter zu einem Array (falls versehentlich als String übergeben)
  let ensure-array(x) = if type(x) == array { x } else if x == none { () } else { (x,) }

  let anwesend                 = ensure-array(anwesend)
  let entschuldigt             = ensure-array(entschuldigt)
  let ags-anwesend             = ensure-array(ags-anwesend)
  let ags-entschuldigt         = ensure-array(ags-entschuldigt)
  let gewerbliche-anwesend     = ensure-array(gewerbliche-anwesend)
  let gewerbliche-entschuldigt = ensure-array(gewerbliche-entschuldigt)
  let gaeste                   = ensure-array(gaeste)

  // ── Konstanten ──────────────────────────────────────────────────────────
  let status-present = "present"
  let status-away    = "away"
  let status-away-perm = "away-perm"
  let status-none    = "none"

  // ── DB auspacken ────────────────────────────────────────────────────────
  let referate        = if db != none and db.keys().contains("referate")             { db.referate }             else { (:) }
  let ags-db          = if db != none and db.keys().contains("ags")                  { db.ags }                  else { (:) }
  let gewerbliche-db  = if db != none and db.keys().contains("gewerbliche-referate") { db.gewerbliche-referate } else { (:) }
  let gs       = geschaeftsstelle

  // ── Lookup-Dict aufbauen ────────────────────────────────────────────────
  let lookup = build-lookup(referate, ags-db, gs, gewerbliche-referate: gewerbliche-db)

  // Gäste mit Kürzel in Lookup eintragen
  for g in gaeste {
    if type(g) == dictionary and g.keys().contains("kuerzel") {
      let vollname = if g.keys().contains("vorname") {
        g.vorname + if g.keys().contains("nachname") { " " + g.nachname } else { "" }
      } else if g.keys().contains("name") { g.name } else { g.kuerzel }
      let funktion = if g.keys().contains("funktion") { g.funktion } else { "Gast" }
      lookup.insert(g.kuerzel, (vollname, funktion))
    }
  }

  // Hilfsfunktion: Kürzel → Vollname (je nach name-format)
  let resolve-kuerzel(k, format: name-format) = {
    if lookup.keys().contains(k) {
      let entry = lookup.at(k)
      let vollname = entry.at(0)
      let funktion = entry.at(1)
      if vollname == "???" {
        return k + " [mehrdeutig!]"
      }
      if format == "full" {
        return vollname + " (" + funktion + ")"
      } else if format == "short" {
        let vorname = vollname.split(" ").at(0)
        return vorname + " (" + funktion + ")"
      } else if format == "first" {
        return vollname.split(" ").at(0)
      }
      return vollname + " (" + funktion + ")"
    }
    return none  // nicht gefunden
  }

  // ── Zustands-States ─────────────────────────────────────────────────────
  let warnings    = state("warnings", (:))
  let pres-refs   = state("pres-refs", ())   // anwesende Referate (Kürzel)
  let away-refs   = state("away-refs", ())   // kurz weg
  let gone-refs   = state("gone-refs", ())   // endgültig weg
  let hours       = state("hours", none)
  let last-time   = state("last-time", none)
  let start-time  = state("start-time", none)

  // ── Warnungs-System ─────────────────────────────────────────────────────
  let render-warnings(list: none) = {
    if hide-warnings { return }
    let end-list = list == none
    context {
      let list = if list != none { list } else { warnings.get().values() }
      if list.len() < 1 { return }
      align(center)[
        #set par.line(number-clearance: 200pt)
        #if end-list [
          #set text(fill: warning-color)
          Warnungen:
        ]
        #block(stroke: warning-color, inset: 1em, radius: 1em, fill: warning-color.transparentize(80%))[
          #set align(left)
          #grid(
            row-gutter: 1em,
            ..list.map(x => link(x.at(1), if end-list { [Seite #str(x.at(1).page()): ] } + x.at(0)))
          )
        ]
      ]
    }
  }

  let add-warning(text, id: none, display: false) = context {
    let location = here()
    warnings.update(x => {
      let id = if id == none { str(x.len()) } else { id }
      if not x.keys().contains(id) {
        x.insert(id, (text, location))
      }
      return x
    })
    if display or display-all-warnings {
      render-warnings(list: ((text, location),))
    }
  }

  // ── Zeit-Utilities ──────────────────────────────────────────────────────
  let time-format-str = "[hour]:[minute] Uhr"
  let date-format-str = "[day].[month].[year]"

  let four-digits-to-time(time-string, error: true) = {
    if int(time-string.slice(0, 2)) > 24 or int(time-string.slice(2)) > 60 {
      [#time-string.slice(0, 2):#time-string.slice(2)]
      if error { add-warning(time-string + " ist keine gültige Uhrzeit") }
    } else {
      let t = datetime(hour: int(time-string.slice(0, 2)), minute: int(time-string.slice(2)), second: 0)
      [#t.display(time-format-str)]
    }
  }

  let format-time(time-string, display: true, hours-manual: none) = context {
    assert(time-string.match(regex("[0-9]+")) != none, message: "Ungültiges Zeitformat: " + time-string)

    let ts = if time-string.len() == 1 {
      (if hours-manual == none { hours.get() } else { hours-manual }) + "0" + time-string
    } else if time-string.len() == 2 {
      (if hours-manual == none { hours.get() } else { hours-manual }) + time-string
    } else if time-string.len() == 3 {
      "0" + time-string
    } else {
      time-string
    }
    assert(ts.len() == 4, message: "Ungültiges Zeitformat: " + time-string)

    if ts.len() == 4 and time-string.len() >= 3 {
      hours.update(ts.slice(0, 2))
    }

    if display { four-digits-to-time(ts) }

    if last-time.get() != none and int(ts) < int(last-time.get()) and hours-manual == none {
      add-warning(four-digits-to-time(ts) + " nach " + four-digits-to-time(str(last-time.get())) + " eingetragen")
    }
    if hours-manual == none {
      last-time.update(ts)
      if start-time.get() == none { start-time.update(ts) }
    }
  }

  let timed(time, it) = {
    if it == "" {
      format-time(time, display: false)
    } else {
      set par.line(number-clearance: 200pt)
      block(width: 100%, inset: (left: -100000pt - timestamp-margin))[
        #grid(
          columns: (100000pt, 1fr),
          column-gutter: timestamp-margin,
          align(right)[
            #v(0.05em)
            #text(if font-size-time == auto { font-size } else { font-size-time }, weight: "regular")[
              #if type(time) == content [#time] else [#format-time(time)]
            ]
          ],
          it,
        )
      ]
    }
  }

  // ── Referat-Lookup aus DB ────────────────────────────────────────────────
  // Gibt den Referatsnamen für ein Kürzel zurück
  let referat-name(key) = {
    if referate.keys().contains(key)       { return "AStA " + referate.at(key).referat }
    if gewerbliche-db.keys().contains(key) { return "AStA " + gewerbliche-db.at(key).name }
    if ags-db.keys().contains(key)         { return "AStA " + ags-db.at(key).name }
    return key
  }

  // Gibt "Vorname (Ref. XYZ)" zurück, oder nur "Ref. XYZ" wenn keine Personen.
  // person-kuerzel schränkt auf eine bestimmte Person ein (für "eut/tillmann").
  let ref-list-entry(k, person-kuerzel: none) = {
    let rname = referat-name(k)
    let personen = ensure-array(
      if referate.keys().contains(k)       { referate.at(k).personen }
      else if gewerbliche-db.keys().contains(k) { gewerbliche-db.at(k).personen }
      else if ags-db.keys().contains(k)         { ags-db.at(k).personen }
      else { () }
    )
    let gefiltert = if person-kuerzel != none {
      personen.filter(p => p.keys().contains("kuerzel") and p.kuerzel == person-kuerzel)
    } else {
      personen
    }
    let namen = gefiltert.map(p => {
      p.vorname + if p.keys().contains("nachname") { " " + p.nachname } else { "" }
    }).join(", ")
    if namen == none or namen.len() == 0 { [#rname] } else { [#namen (#rname)] }
  }

  // Besetzte Referate/AGs: nur solche mit mindestens einer Person in der DB
  let besetzte-referate = referate.keys().filter(k =>
    ensure-array(referate.at(k).personen).filter(p => type(p) == dictionary).len() > 0
  )
  let besetzte-ags-gew = (ags-db.keys() + gewerbliche-db.keys()).filter(k => {
    let personen = if ags-db.keys().contains(k) { ags-db.at(k).personen }
                  else { gewerbliche-db.at(k).personen }
    ensure-array(personen).filter(p => type(p) == dictionary).len() > 0
  })

  // Beschlussfähigkeit berechnen (nur besetzte Referate zählen)
  let beschlussfaehig(anwesend-list) = {
    let total = besetzte-referate.len()
    let n = anwesend-list.len()
    return (n, total, n * 2 > total)
  }

  // ── Teilnehmer-String für Kommen/Gehen ──────────────────────────────────
  let pres-count-str(pres, total) = str(pres) + " von " + str(total) + " stimmberechtigt"

  // ── Join/Leave für Referate ─────────────────────────────────────────────
  // Löst einen key auf: entweder Personen-Kürzel oder Referat-Kürzel.
  // Gibt (ref-key, display-name) zurück.
  // ref-key ist none wenn keine stimmberechtigtes Referat gefunden (AG, Café, unbekannt).
  let resolve-ref-key(key) = {
    if lookup.keys().contains(key) {
      // Personen-Kürzel → Referat aus funktion-Feld rücksuchen
      let funktion = lookup.at(key).at(1)
      let ref-key = referate.keys().find(k => referate.at(k).referat == funktion)
      let vorname = lookup.at(key).at(0).split(" ").at(0)
      (ref-key, vorname + " (" + funktion + ")")  // ref-key ist none wenn AG/Café-Person
    } else if referate.keys().contains(key) {
      (key, referate.at(key).referat)
    } else {
      (none, key)  // unbekanntes Kürzel
    }
  }

  let ref-join(time, key, long: false) = {
    let key = key.trim()
    let (ref-key, display-name) = resolve-ref-key(key)
    context {
      if ref-key == none and not lookup.keys().contains(key) {
        add-warning("Unbekanntes Kürzel: " + key)
      }
      if ref-key != none {
        if long {
          pres-refs.update(x => { if not x.contains(ref-key) { x.push(ref-key) }; x })
          gone-refs.update(x => { if x.contains(ref-key) { _ = x.remove(x.position(y => y == ref-key)) }; x })
        } else {
          away-refs.update(x => { if x.contains(ref-key) { _ = x.remove(x.position(y => y == ref-key)) }; x })
          pres-refs.update(x => { if not x.contains(ref-key) { x.push(ref-key) }; x })
        }
      }
    }
    context {
      let verb = if long { [meldet sich an] } else { [kommt zurück] }
      if ref-key != none {
        let (n, total, _bf) = beschlussfaehig(pres-refs.get())
        let statement = [_#display-name #verb: (#pres-count-str(n, total))_]
        if time == none { statement } else { timed(time)[#statement] }
      } else {
        let statement = [_#(display-name) #(verb)_]
        if time == none { statement } else { timed(time)[#statement] }
      }
    }
  }

  let ref-leave(time, key, long: false) = {
    let key = key.trim()
    let (ref-key, display-name) = resolve-ref-key(key)
    context {
      if ref-key == none and not lookup.keys().contains(key) {
        add-warning("Unbekanntes Kürzel: " + key)
      }
      if ref-key != none {
        if long {
          pres-refs.update(x => { if x.contains(ref-key) { _ = x.remove(x.position(y => y == ref-key)) }; x })
          gone-refs.update(x => { if not x.contains(ref-key) { x.push(ref-key) }; x })
        } else {
          pres-refs.update(x => { if x.contains(ref-key) { _ = x.remove(x.position(y => y == ref-key)) }; x })
          away-refs.update(x => { if not x.contains(ref-key) { x.push(ref-key) }; x })
        }
      }
    }
    context {
      let verb = if long { [verlässt die Sitzung] } else { [geht kurz] }
      if ref-key != none {
        let (n, total, _bf) = beschlussfaehig(pres-refs.get())
        let statement = [_#display-name #verb: (#pres-count-str(n, total))_]
        if time == none { statement } else { timed(time)[#statement] }
      } else {
        let statement = [_#(display-name) #(verb)_]
        if time == none { statement } else { timed(time)[#statement] }
      }
    }
  }

  // ── Abstimmungen ─────────────────────────────────────────────────────────
  let dec(time, content, args, beschluss: none) = {
    let values = if args.values().all(x => type(x) == array) {
      args.keys().map(x => (name: x, value: int(args.at(x).at(0)), color: args.at(x).at(1)))
    } else {
      args.keys().map(x => (name: x, value: int(args.at(x))))
    }
    let total = values.map(x => x.value).sum(default: 1)
    let dec-block = block(breakable: false, inset: (left: if indent-decisions { 2em } else { 0pt }))[
      ===== Abstimmung: #content
      #if beschluss != none [
        #v(0.2em)
        #emph[Beschluss: #beschluss]
      ]
      #if fancy-decisions and values.at(0).keys().contains("color") [
        #grid(
          gutter: 2pt,
          columns: values.map(x => calc.max(if x.value > 0 { 0.2fr } else { 0fr }, 1fr * (x.value / total))),
          ..values.map(x => grid.cell(fill: x.color.transparentize(80%), inset: 0.5em)[
            #if x.value > 0 [*#x.name* #x.value]
          ]),
        )
      ] else [
        #values.map(x => [*#x.name*: #str(x.value)]).join([, ])
      ]
    ]
    v(2em, weak: true)
    if time != none { timed(time, dec-block) } else { dec-block }
    v(2em, weak: true)
  }

  let end-meeting(time) = {
    set par.line(number-clearance: 200pt)
    linebreak()
    if time == none {
      [==== Ende der Sitzung]
    } else {
      timed(time)[==== Ende der Sitzung]
      last-time.update(time)
    }
  }

  // ── Regex-Konstanten ─────────────────────────────────────────────────────
  let regex-time-format = "[0-9]{1,4}"
  let default-format = regex-time-format + "/[^\n]*"
  let optional-time-format = "(" + regex-time-format + "/)?[^\n]*"

  // ── Name-Resolution: /kuerzel ─────────────────────────────────────────────
  // Löst /kuerzel im Fließtext zu "Vorname Nachname (Funktion)" auf
  // Kürzel bestehen aus Kleinbuchstaben und Ziffern (keine Großbuchstaben!)
  let resolve-name-inline(k) = {
    let resolved = resolve-kuerzel(k)
    if resolved == none {
      // unbekannt: rot markieren
      [#text(fill: warning-color)[#k [unbekannt]]]
      add-warning("Unbekanntes Kürzel: " + k)
    } else if resolved.contains("[mehrdeutig!]") {
      [#text(fill: warning-color)[#resolved]]
      add-warning("Mehrdeutiges Kürzel: " + k)
    } else {
      [#resolved]
    }
  }

  // Protokollant*in auflösen
  let resolve-protokollant = {
    if protokollant == none {
      [FEHLT]
    } else if protokollant.starts-with("-") {
      [#protokollant.slice(1)]
    } else {
      let r = resolve-kuerzel(protokollant, format: "full")
      if r == none { [#protokollant] } else { [#r] }
    }
  }

  // Sitzungsleitung auflösen
  let resolve-sitzungsleitung = {
    if sitzungsleitung == none {
      none
    } else if sitzungsleitung.starts-with("-") {
      [#sitzungsleitung.slice(1)]
    } else {
      let r = resolve-kuerzel(sitzungsleitung, format: "full")
      if r == none { [#sitzungsleitung] } else { [#r] }
    }
  }

  // ── Protokollkopf aufbauen ────────────────────────────────────────────────
  // Normalisiere anwesend/entschuldigt: "eut/tillmann" → ref-key="eut", person-kuerzel="tillmann"
  let parse-anwesend-entry(entry) = {
    let parts = entry.split("/")
    if parts.len() >= 2 { (parts.at(0), parts.at(1)) } else { (entry, none) }
  }
  let anwesend-parsed   = anwesend.map(parse-anwesend-entry)
  let anwesend-keys     = anwesend-parsed.map(e => e.at(0))
  let entschuldigt-parsed = entschuldigt.map(parse-anwesend-entry)
  let entschuldigt-keys = entschuldigt-parsed.map(e => e.at(0))

  // Nur besetzte Referate in unentschuldigt aufführen
  let unentschuldigt = besetzte-referate.filter(k =>
    not anwesend-keys.contains(k) and not entschuldigt-keys.contains(k)
  )

  // AGs und gewerbliche Referate ohne Stimmrecht: nur besetzte, fehlend = weder anwesend noch entschuldigt
  let ags-gew-anwesend = ags-anwesend + gewerbliche-anwesend
  let ags-gew-entschuldigt = ags-entschuldigt + gewerbliche-entschuldigt
  let ags-gew-unentschuldigt = besetzte-ags-gew.filter(k =>
    not ags-gew-anwesend.contains(k) and not ags-gew-entschuldigt.contains(k)
  )

  let (n-anwesend, n-gesamt, bf) = beschlussfaehig(anwesend-keys)

  // Gast-Eintrag als String formatieren
  let format-gast(g) = {
    if type(g) == dictionary {
      if g.keys().contains("kuerzel") {
        let r = resolve-kuerzel(g.kuerzel)
        if r != none { return r }
      }
      let vn = if g.keys().contains("vorname") {
        g.vorname + if g.keys().contains("nachname") { " " + g.nachname } else { "" }
      } else if g.keys().contains("name") { g.name } else { "" }
      let fn = if g.keys().contains("funktion") { " (" + g.funktion + ")" } else { "" }
      vn + fn
    } else { g }
  }

  let protokollkopf = [
    #let names-list(entries) = entries.join([\ ])

    #table(
      columns: (auto, 1fr),
      align: (right + top, left + top),
      stroke: 0.3pt,
      inset: (x: 0.6em, y: 0.4em),

      [*Anwesend AStA:*],
      if anwesend-parsed.len() == 0 [_(keine)_] else {
        names-list(anwesend-parsed.map(e => ref-list-entry(e.at(0), person-kuerzel: e.at(1))))
      },

      [*Gewerblich / AGs:*],
      {
        let gew-ag = gewerbliche-anwesend.map(k => ref-list-entry(k)) + ags-anwesend.map(k => ref-list-entry(k))
        if gew-ag.len() == 0 [_(keine)_] else { names-list(gew-ag) }
      },

      [*Entschuldigt:*],
      if entschuldigt-parsed.len() == 0 [_(keine)_] else {
        names-list(entschuldigt-parsed.map(e => ref-list-entry(e.at(0), person-kuerzel: e.at(1))))
      },

//      [*Unentschuldigt:*],
//      if unentschuldigt.len() == 0 [_(keine)_] else {
//        names-list(unentschuldigt.map(ref-list-entry))
//      },

      [*Entsch. (o. SR):*],
      if ags-gew-entschuldigt.len() == 0 [_(keine)_] else {
        names-list(ags-gew-entschuldigt.map(ref-list-entry))
      },

//      [*Unentsch. (o. SR):*],
//      if ags-gew-unentschuldigt.len() == 0 [_(keine)_] else {
//        names-list(ags-gew-unentschuldigt.map(ref-list-entry))
  //    },

      [*Gäst\*innen:*],
      if gaeste.len() == 0 [_(keine)_] else {
        names-list(gaeste.map(format-gast))
      },

      [*Protokoll:*], resolve-protokollant,

      if resolve-sitzungsleitung != none { [*Sitzungsleitung:*] } else { [] },
      if resolve-sitzungsleitung != none { resolve-sitzungsleitung } else { [] },

      [*Beschlussfähig:*],
      [
        #n-anwesend von #n-gesamt Referaten anwesend
        #if not bf [ #text(fill: warning-color)[(nicht beschlussfähig!)]
          #add-warning("Sitzung ist nicht beschlussfähig (" + str(n-anwesend) + " von " + str(n-gesamt) + " Referaten)")
        ]
      ],
    )
    #v(0.5em)
  ]

  // ── Seiten-Setup ──────────────────────────────────────────────────────────
  set page(
    header: context {
      let formatted-date = if date == none {
        [XX.XX.XXXX]
        add-warning("date fehlt", id: "DATE")
      } else if date == auto {
        [#datetime.today().display(date-format-str)]
      } else if type(date) == datetime {
        [#date.display(date-format-str)]
      } else { [#date] }

      if logo != none {
        grid(
          columns: (auto, 1fr),
          gutter: 1em,
          {
            set image(height: 3em, fit: "contain")
            logo
          },
          [
            #text(weight: "bold")[Protokoll zur AStA-Sitzung vom #formatted-date]\
            #if location != none [#location]
          ]
        )
      } else {
        [
          #text(weight: "bold")[Protokoll zur AStA-Sitzung vom #formatted-date]\
          #if location != none [#location]
        ]
      }
    },
    footer: context {
      let current-page = here().page()
      let page-count = counter(page).final().first() - if warnings.final().len() > 0 and not hide-warnings { 1 } else { 0 }
      if formal [
        #set text(size: 8pt)
        #grid(
          columns: (1fr, auto),
          gutter: 1em,
          [
            AStA Hochschule Darmstadt, Campus Darmstadt\
            Schöfferstraße 3, 64295 Darmstadt\
            Tel.: 06151 533 5630, info\@asta-hda.de
          ],
          align(right + horizon)[Seite #current-page von #page-count],
        )
      ] else [
        #align(center)[Seite #current-page von #page-count]
      ]
    },
    margin: margin,
    background: if hole-mark {
      place(left + top, dx: 5mm, dy: 100% / 2, line(length: 4mm, stroke: 0.25pt + black))
    },
  )

  set text(font-size, lang: locale, font: "HDA DIN Office", weight: "regular")
  show strong: it => text(font: "HDA DIN Office", weight: "bold")[#it.body]
  set par(justify: true)
  show link: it => text(fill: blue)[#it]

  set heading(
    outlined: false,
    numbering: (..nums) => {
      let n = nums.pos().map(x => int(x / 2))
      [TOP #numbering("1.a.i:", ..n)]
    },
  )
  show heading.where(level: 5): set text(font-size)
  show heading: set text(if font-size-title == auto { font-size * 1.3 } else { font-size-title })
  show heading: it => {
    let text-content = if it.body.has("children") {
      it.body.children.map(i => if i.has("text") { i.text } else { " " }).join()
    } else if it.body.has("text") {
      it.body.text
    } else { "" }

    if text-content.starts-with("\u{200B}") {
      [#it]
      return
    }

    // Nicht öffentlicher Sitzungsteil
    if text-content.contains("Nicht öffentlicher") {
      [
        #v(1em)
        #line(length: 100%, stroke: 0.5pt)
        #v(0.5em)
        #heading(
          "\u{200B}" + text-content,
          level: it.level,
          outlined: false,
          numbering: none,
        )
        #v(0.5em)
      ]
      return
    }

    let (time, title) = if text-content.match(regex(regex-time-format + "/")) != none {
      (text-content.split("/").at(0), text-content.split("/").slice(1).join("/"))
    } else {
      (none, text-content)
    }

    let h = heading(
      "\u{200B}" + title,
      level: it.level,
      outlined: it.level != 4,
      numbering: if it.level >= 4 { none } else { it.numbering },
    )

    let h-block = if time == none { h } else { timed(time, h) }
    [
      #if it.level <= 3 { v(1em, weak: true) }
      #if separator-lines and (it.level == 1 or it.level == 4) {
        grid(
          columns: (auto, 1fr),
          align: horizon,
          gutter: 1em,
          h-block, line(length: 100%, stroke: 0.2pt),
        )
      } else {
        h-block
      }
      #v(0.5em)
    ]
  }

  // ── Show-Regeln für Kommandos ─────────────────────────────────────────────

  // Zeitstempel: 1838/ oder 1838/ Text
  show regex("^" + regex-time-format + "/[^\n]*"): it => {
    let parts = it.text.split("/")
    let t = parts.at(0)
    let rest = parts.slice(1).join("/")
    timed(t, rest)
  }

  // Reihenfolge wichtig: spezifischere Regeln (++ / --) NACH den allgemeinen (+ / -)
  // Typst wendet show-Regeln von unten nach oben an → letzte Definition gewinnt.

  // + Referat kommt zurück (kurz weg gewesen)
  show regex("^\+" + optional-time-format): it => {
    let text-content = it.text.slice(1)
    let parts = text-content.split("/")
    let t = parts.at(0)
    let key = parts.slice(1).join("/")
    if t.match(regex("^" + regex-time-format + "$")) == none {
      ref-join(none, text-content, long: false)
    } else {
      ref-join(t, key, long: false)
    }
  }

  // - Referat geht kurz
  show regex("^-" + optional-time-format): it => {
    let text-content = it.text.slice(1)
    let parts = text-content.split("/")
    let t = parts.at(0)
    let key = parts.slice(1).join("/")
    if t.match(regex("^" + regex-time-format + "$")) == none {
      ref-leave(none, text-content, long: false)
    } else {
      ref-leave(t, key, long: false)
    }
  }

  // ++ Referat meldet sich an (z.B. "++1930/vielfalt") – nach + definiert → hat Vorrang
  show regex("^\+\+" + optional-time-format): it => {
    let text-content = it.text.slice(2)
    let parts = text-content.split("/")
    let t = parts.at(0)
    let key = parts.slice(1).join("/")
    if t.match(regex("^" + regex-time-format + "$")) == none {
      ref-join(none, text-content, long: true)
    } else {
      ref-join(t, key, long: true)
    }
  }

  // -- Referat verlässt die Sitzung (z.B. "--2015/dieburg") – nach - definiert → hat Vorrang
  // Typst wandelt "--" zu "–" (En-Dash), daher beide Varianten matchen
  show regex("^(--|–)" + optional-time-format): it => {
    let prefix = if it.text.starts-with("–") { 3 } else { 2 }
    let text-content = it.text.slice(prefix)
    let parts = text-content.split("/")
    let t = parts.at(0)
    let key = parts.slice(1).join("/")
    if t.match(regex("^" + regex-time-format + "$")) == none {
      ref-leave(none, text-content, long: true)
    } else {
      ref-leave(t, key, long: true)
    }
  }

  // Sitzungsende: /end oder /2200
  show regex("^/(" + regex-time-format + "|end)$"): it => {
    let time = it.text.slice(1)
    if time == "end" {
      context { end-meeting(last-time.get()) }
    } else {
      end-meeting(time)
    }
  }

  // Abstimmungen: !Antrag XYZ/einstimmig  oder  !Antrag/9/0/2
  show regex("^!(" + regex-time-format + "/)?[^/\n]+(/[^\n]+)+"): it => {
    // Beschlusstext: optional als letztes /-Segment wenn es kein reines Zahlen/Label-Segment ist.
    let text-content = it.text.replace("-/", "%slash%").slice(1)
    let first = text-content.split("/").at(0)
    let args-slice = if first.match(regex("^" + regex-time-format + "$")) != none { 2 } else { 1 }
    let vote-time = if args-slice == 2 { first } else { none }
    let vote-text = text-content.split("/").at(args-slice - 1).replace("%slash%", "/")
    let all-args = text-content.split("/").slice(args-slice)
    // Beschlusstext: letztes Segment, wenn es kein reines Abstimmungssegment ist.
    // Abstimmungssegment = nur Ziffern (+ optionales Label-Prefix), oder "einstimmig".
    // Syntax: !Antrag/9/0/2/Beschlusstext  oder  !Antrag/einstimmig/Beschlusstext
    let is-vote-segment(s) = s.trim() == "einstimmig" or s.trim().match(regex("^[^0-9]*[0-9]+$")) != none
    let vote-beschluss = if all-args.len() > 0 and not is-vote-segment(all-args.last()) {
      all-args.last()
    } else { none }
    let raw-args = if vote-beschluss != none { all-args.slice(0, -1) } else { all-args }

    // Einstimmig-Sonderfall
    if raw-args.len() == 1 and raw-args.at(0).trim() == "einstimmig" {
      let dec-block = block(breakable: false, inset: (left: if indent-decisions { 2em } else { 0pt }))[
        ===== Abstimmung: #vote-text
        #if vote-beschluss != none [
          #v(0.2em)
          #emph[Beschluss: #vote-beschluss]
        ]
        #block(fill: green.transparentize(80%), inset: 0.5em, width: 100%)[*Einstimmig angenommen*]
      ]
      v(2em, weak: true)
      if vote-time != none { timed(vote-time, dec-block) } else { dec-block }
      v(2em, weak: true)
    } else {
      // Numerische Abstimmung: 9/0/2 → Dafür/Dagegen/Enthaltungen
      let args = raw-args
        .enumerate()
        .fold((:), (acc, x) => {
          let label = x.at(1).replace(regex("[0-9]"), "")
          let value = x.at(1).replace(label, "")
          if label != "" and label.at(-1) == " " { label = label.slice(0, -1) }
          if label == "" { label = str(x.at(0) + 1) }
          label = label.replace("%slash%", "/")
          acc.insert(label, value)
          return acc
        })

      if (
        args.len() == 3
          and args.keys().enumerate().all(x => str(x.at(0) + 1) == x.at(1))
          and args.values().all(x => type(x) != array)
      ) {
        let yes = args.values().at(0)
        let no = args.values().at(1)
        let abst = args.values().at(2)
        dec(vote-time, vote-text, ("Dafür": (yes, green), "Dagegen": (no, red), "Enthaltung": (abst, blue)), beschluss: vote-beschluss)
      } else {
        // Freie Labels: "Ja 9/Enthaltung 2"
        let named-args = raw-args.fold((:), (acc, x) => {
          let label = x.replace(regex("[0-9]+"), "").trim()
          let value = x.replace(regex("[^0-9]"), "")
          if label == "" { label = str(acc.len() + 1) }
          acc.insert(label, value)
          return acc
        })
        dec(vote-time, vote-text, named-args, beschluss: vote-beschluss)
      }
    }
  }

  // /kuerzel im Fließtext → aufgelöster Name
  // Kürzel = nur Kleinbuchstaben + Ziffern (kein Großbuchstabe, kein Leerzeichen)
  show regex("(^| )/[a-z][a-z0-9]*"): it => {
    let text-content = it.text
    let leading-space = text-content.starts-with(" ")
    let name-part = text-content.slice(if leading-space { 2 } else { 1 })
    if leading-space { [ ] }
    resolve-name-inline(name-part)
  }

  // ── Protokollkopf ausgeben ────────────────────────────────────────────────

  // State mit initialen Anwesenheiten befüllen
  pres-refs.update(_ => anwesend)

  // Protokollkopf
  protokollkopf

  pagebreak()

  // Zeilenabstand vor Tagesordnung
  pad(y: 1.5em)[
    #show outline.entry.where(level: 1): it => { v(0em); it }
    #outline(title: "Tagesordnung", indent: 1em)
  ]

  // Sitzungsbeginn
  context {
    let st = start-time.final()
    if st == none {
      timed([], [==== Beginn der Sitzung])
    } else {
      timed([#four-digits-to-time(st)], [==== Beginn der Sitzung])
    }
  }

  // Zeilennummerierung
  set par.line(
    numbering: x => {
      if line-numbering != none and calc.rem(x, line-numbering) == 0 {
        text(if font-size-line-number == auto { font-size * 0.8 } else { font-size-line-number })[#x]
      }
    },
    number-clearance: timestamp-margin,
    numbering-scope: "page",
  )

  // ── Hauptteil ────────────────────────────────────────────────────────────
  {
    body
  }

  // ── Schluss ───────────────────────────────────────────────────────────────
  set par.line(number-clearance: 200pt)

  if signing {
    block(breakable: false)[
      #v(3cm)
      Dieses Protokoll wird hiermit genehmigt:

      #v(1cm)
      #grid(
        columns: (1fr, 1fr),
        align: center,
        gutter: 0.65em,
        line(length: 100%, stroke: 0.5pt), line(length: 100%, stroke: 0.5pt),
        [Ort, Datum],
        [Unterschrift Protokoll],
        [],
        resolve-protokollant,
      )
    ]
  }

  // Warnungen am Ende
  context {
    if warnings.get().len() > 0 {
      set page(header: none, footer: none, margin: 2cm, numbering: none)
      render-warnings()
    }
  }
}
