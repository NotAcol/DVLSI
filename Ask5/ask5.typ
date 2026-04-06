// ====================== Config =============================
// Copy the config part around and modify the content
#let base_color = rgb("#1e1e2e")
#let text_color = rgb("#cdd6f4")
#let red_color = rgb("#f38ba8")
#let maroon_color = rgb("#eba0ac")
#let pink_color = rgb("#f5c2e7")
#let mauve_color = rgb("#cba6f7")
#let peach_color = rgb("#fab387")
#let sapphire_color = rgb("#74c7ec")
#let blue_color = rgb("#89b4fa")
#let lavender_color = rgb("#b4befe")
#let yellow_color = rgb("#f9e2af")
#let green_color = rgb("#a6e3a1")
#let teal_color = rgb("#94e2d5")
#let subtext1_color = rgb("#bac2de")
#let subtext0_color = rgb("#a6adc8")
#let surface_color = rgb("#313244")
#let crust_color = rgb("#11111b")
#let mantle_color = rgb("#181825")
#let overlay0_color = rgb("#6c7086")

#set text(
  font: "New Computer Modern",
  size: 12pt,
  fill: text_color,
  fractions: true
)
#set par(
  justify: true,
  // leading is space between lines here and 0.65em is default
  leading: 0.65em,
  spacing: 1.5em
)

#set table(stroke: text_color)
#set quote(block:true )
#set raw(block:true, theme: "/mocha.tmTheme", syntaxes: "VHDL.sublime-syntax")
#show raw: set text(size: 7.5pt)
#show raw.where(block: true): it => {
  show raw.line: l => {
    box(width: 15pt, align(right, text(fill: overlay0_color)[#l.number]))
    h(1em)
    l.body
  }
  block(fill: mantle_color, inset: 5pt, radius: 4pt, it)
}

#set bibliography(style: "ieee")
#set terms(separator: [: ])
#set figure(gap: 1em)

#show heading: set block(below: 1.8em, above: 2em)
#show heading.where(level: 1): set text(fill: mauve_color)
#show link: underline
#show link: set text(fill: mauve_color)
#set strike(stroke: 0.07em + peach_color)
#show emph: it => {
  text(fill: green_color, style: "italic", it.body)
}

#show strong : set text(fill: mauve_color)

#set heading(numbering: "1.")
#show heading.where(level:1): it => {
  counter(math.equation).update(0)
  it
}

#set math.equation(numbering: n => {
  numbering("(1.1)", counter(heading).get().first(), n)
  // if you want change the number of numbers displayed modify it this way:
  /*
  let count = counter(heading).get()
  let h1 = count.first()
  let h2 = count.at(1, default: 0)
  numbering("(1.1.1)", h1, h2, n)
  */
})

#show ref: it => {
  let eq = math.equation
  let el = it.element
  if el != none and el.func() == eq {
    // Override equation references.
    link(el.location(),numbering(
      el.numbering,
      ..counter(eq).at(el.location())
    ))
  } else {
    // Other references as usual.
    it
  }
}

#set footnote.entry(
  separator: line(length: 30% +0pt, stroke: 0.3pt + text_color)
)
#set footnote(numbering: n => 
  text(fill: mauve_color, numbering("1", n))
)

#set page(
  paper: "a4",
  fill: base_color,
  numbering: "1",
  margin: (x:1in, y: 5.5%),
  header: [
    #set par(spacing: 0.5em)
    #set text(size: 0.9em)
    #smallcaps[Ε.Μ.Π. - Σχολή Ηλεκτρολόγων Μηχανικών και Μηχανικών Υπολογιστών 
    #line(length: 100%, stroke: 0.7pt + text_color)]
  ],
  header-ascent: 40%,
  footer: context [
    #set par(spacing: 0.5em)
    #set align(center)
    #set text(0.9em)
    #line(length: 100%, stroke: 0.7pt + text_color)
    #counter(page).display("1")
  ],
  footer-descent: 40%,
)

#let frontpage(logo: "assets/logo.png", course: [], assignment: [], year: "2025-2026", authors: ()) = {
  page(
    header: [],
    margin: (x: 7%),
    footer: [
      #set align(right)
      Ακαδημαϊκό Έτος #year
    ],
    [
      #set align(center)
      #figure(
        image(logo, height:30%)
      )
      #v(1.2cm)
      #set text(19pt)
      #assignment

      #v(1.0cm)
      #set text(27pt)
      #course

      #v(3.0cm)
      #{
         set text(14pt)
         let count = calc.min(authors.len(),3)
         grid(
           columns: (1fr,) * count,
           row-gutter: 24pt,
           ..authors.map(author => [
             #author.name \
//             #author.sn \
             #show link: set text(lavender_color)
             #link("mailto:" + author.email)
           ]),
         )
      }
      #pagebreak()
    ]
  )
}

#let contents() = {
  page(
    header: [],
    footer: [],
    [
      #outline()
    ]
  )
  pagebreak()
}

// ====================== Contents =============================

#frontpage(
  course: "Ψηφιακά Συστήματα VLSI",
  assignment: "5η Εργαστηριακή Άσκηση",
  year: "2025-2026",
  authors: (
    (
      name: "Παναγιώτης Γερασιμόπουλος 03115208",
      //sn: "el15208",
      email: "personal@devcol.com"
    ),
  )
)

//#contents()

#counter(page).update(1)

= Deserializer

== Fifo
Για το implementation της fifo θα φτιάξουμε έναν ring buffer χρησιμοποιώντας ένα
κομμάτι block ram και έναν pointer που θα δείχνει μια θέση μετά από το τελευταίο
στοιχείο που γράψαμε και θα επιστρέφει στο 0 όταν φτάσει το τέλος του buffer. Έτσι σε
έναν κύκλο ο ring buffer θα δίνει στην έξοδο το στοιχείο που δείχνει ο pointer, θα
γράφει την νέα τιμή στην θέση του και θα προχωράει στο επόμενο. Το κύκλωμα θα έχει
σχετικά σταθερή κατανάλωση ισχύος αδιάφορα του βάθους της fifo και μικρο overhead
υλικού.

#raw(read("./vhdl/design_sources/fifo.vhd"), lang: "vhdl")

== Window Generation
Για την δημιουργία του $3 times 3$ παράθυρου θα χρησιμοποιήσουμε 2 fifo και ένα grid
από flip flop. Η είσοδοι θα συνδέονται απευθείας με το τελευταίο επίπεδο των flipflop
τα οποία σε κάθε κύκλο θα κάνουν slide αριστερά. Οι έξοδοι του θα συνδέονται με την
είσοδο της πρώτης fifo  της οποίας η έξοδος θα συνδέετε με την σειρά της στην είσοδο
του ενδιάμεσου επίπεδου των flip flop. Τέλος, αυτό επαναλαμβάνετε άλλη μια φορά με το
ενδιάμεσο επίπεδο των flipflop, την δεύτερη fifo και το πρώτο επίπεδο. Τα δεδομένα
που βγαίνουν από το πρώτο επίπεδο τα αγνοούμε.

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge


#align(center)[
  #diagram(
    // Global styling defaults
    node-stroke: green_color + 0.8pt,
    edge-stroke: overlay0_color + 1pt,
    node-corner-radius: 3pt,
    spacing: (50pt, 40pt),
    mark-scale: 80%,

    // --- Level 1 (Top Row, Row 0) ---
    node((0,0), [Drop], stroke: none),
    node((1,0), [FF(0,0)], shape: "rect"),
    node((2,0), [FF(0,1)], shape: "rect"),
    node((3,0), [FF(0,2)], shape: "rect"),

    edge((1,0), (0,0), "->"),
    edge((2,0), (1,0), "->"),
    edge((3,0), (2,0), "->"),

    // --- Level 2 (Intermediate Row, Row 1) ---
    node((1,1), [FF(1,0)], shape: "rect"),
    node((2,1), [FF(1,1)], shape: "rect"),
    node((3,1), [FF(1,2)], shape: "rect"),

    edge((2,1), (1,1), "->"),
    edge((3,1), (2,1), "->"),

    // --- Level 3 (Bottom Row, Row 2) ---
    node((1,2), [FF(2,0)], shape: "rect"),
    node((2,2), [FF(2,1)], shape: "rect"),
    node((3,2), [FF(2,2)], shape: "rect"),
    node((4,2), [Pixel In], stroke: none),

    edge((2,2), (1,2), "->"),
    edge((3,2), (2,2), "->"),
    edge((4,2), (3,2), "->"),

    // --- FIFOs ---
    node((-0.5, 1.5), text(fill: mauve_color)[FIFO 1], shape: "rect", stroke:
    mauve_color + 1.5pt),
    node((-0.5, 0.5), text(fill: mauve_color)[FIFO 2], shape: "rect", stroke:
    mauve_color + 1.5pt),

    // --- Routing ---
    // FF(2,0) Output -> FIFO 1 -> FF(1,2) Input
    edge((1,2), (-0.5,2), (-0.5, 1.5), "->", corner-radius: 5pt),
    edge((-0.5,1.5), (-0.5,1.25), (3.5, 1.25), (3.5, 1), (3,1), "->", corner-radius: 5pt),

    // FF(1,0) Output -> FIFO 2 -> FF(0,2) Input
    edge((1,1), (-0.5,1), (-0.5, 0.5), "->", corner-radius: 5pt),
    edge((-0.5,0.5), (-0.5,0.25), (3.5, 0.25), (3.5, 0), (3,0), "->", corner-radius: 5pt),
  )
]

Με αυτόν τον τρόπο μπορούμε να χρησιμοποιήσουμε μόνο 2 fifo και αφού κρατάμε τα
δεδομένα στο grid από flipflοp αντί να συνδέσουμε τις fifo σε σειρά μπορούμε να
μειώσουμε το βάθος τους κατά 3. Τέλος το routing από κάτω προς τα πάνω και δεξιά προς
τα αριστερά θα κάνει το παράθυρο να είναι σε σειρά pixel της εικόνας με το κεντρικό
να είναι το pixel που επεξεργαζόμαστε.


#raw(read("./vhdl/design_sources/window_gen.vhd"), lang: "vhdl")

= Debayering Filter

Για την δημιουργία του φίλτρου θα κρατάμε σε μετρητές τις συντεταγμένες του pixel
εισόδου και του pixel που υπολογίζουμε. Από την θέση του pixel εισόδου ξέρουμε ποτέ
έχουμε γεμίσει τις fifo, και άρα έχουμε πάρει αρκετά pixel για να αρχίσουμε να
κάνουμε υπολογισμούς, και από την θέση του pixel εξόδου μπορούμε να ξέρουμε πότε
βρισκόμαστε σε κάποια άκρη της εικόνας. Έκτος από το PipelineFilled θα κρατάμε και
ένα ακόμα σήμα εσωτερικής κατάστασης, το IsProcessing, το οποίο χρησιμοποιούμε για να
εφαρμόσουμε την λογική γείρω από το σήμα NewImage. Το συστημα θα περιμενει εκτος απο
τους κύκλους που παίρνει ValidIn και το NewImage ή το IsProcessing είναι high.

Επίσης για διευκόλυνση της λογικής στους υπολογισμούς θα δημιουργήσουμε με dataflow
ένα πλέγμα το οποίο, ανάλογα του edge case, γεμίζουμε με μηδενικά ή τις τιμές των
pixel που παίρνουμε από το $3 times 3$ παράθυρο με statement της μορφής 
`(others => '0') when TopEdge else unsigned(Out01);`.
Από αυτό θα υπολογίσουμε τα αθροίσματα για όλες τις περιπτώσεις, διαγώνια,
κάθετα, οριζόντια και σε σταυρό, με κάποιο padding για αντιμετώπιση του overflow.
Έτσι, όταν έρθει η ώρα να πάρουμε περιπτώσεις την τελική τιμή μπορούμε απλά να
επιλέξουμε ένα από τα παραπάνω με ένα slide στα δεξιά.


#raw(read("./vhdl/design_sources/debayering.vhd"), lang: "vhdl")


Παρακατω ειναι screenshot απο implementation για critical path και utilization για
εικονες $N = 64,128 "και" 1024$ pixel

== 64
#figure(
  image("./assets/timing_64.png", width: 80%),
)
#figure(
  image("./assets/util_64.png", width: 100%),
)

== 128
#figure(
  image("./assets/timing_128.png", width: 80%),
)
#figure(
  image("./assets/util_128.png", width: 100%),
)
#figure(
  image("./assets/util_percent_128.png", width: 100%),
)

== 1024
#figure(
  image("./assets/timing_1024.png", width: 80%),
)
#figure(
  image("./assets/util_1024.png", width: 100%),
)
#figure(
  image("./assets/util_percent_1024.png", width: 100%),
)
