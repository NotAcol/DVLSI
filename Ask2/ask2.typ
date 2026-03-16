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
//#show heading: set text(fill: yellow_color)
#show link: underline
#show link: set text(fill: lavender_color)
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
  assignment: "2η Εργαστηριακή Άσκηση",
  year: "2025-2026",
  authors: (
    (
      name: "Παναγιώτης Γερασιμόπουλος 03115208",
      //sn: "el15208",
      email: "personal@devcol.com"
    ),
  )
)

#contents()

#counter(page).update(1)
= Full Adder
Το κύκλωμα είναι υλοποιείται με τις συναρτήσεις 
$
  S u m = A xor B xor C_(i n) \
  C_(o u t) = A B + C_(i n)  A + C_(i n) B
$

#figure(
  image("./assets/1_RTL.png", width:100%),
  caption: [RTL]
)
== Implementation 
#raw(read("./vhdl/design_sources/full_adder.vhd"), lang: "vhdl")

Το οποίο μας δίνει critical path 4.076ns.

#figure(
  image("./assets/1_critical_path_4.076.png", width:70%),
  caption: [Critical path 4.076]
)

== Test Bench
Το κύκλωμα είναι αρκετά απλό ώστε να μπορούμε να το ελέγξουμε για όλες τις τιμές
αληθείας. 
#raw(read("./vhdl/bench/full_adder_bench.vhd"), lang: "vhdl")

#figure(
  image("./assets/1_bench.png", width:100%),
  caption: [Test Bench]
)

= Pipelined 4 Bit Adder
#figure(
  image("./assets/4bit_schematic.png", width:70%),
  caption: [Θέσεις επιπλέων FlipFLop]
)
Ο αθροιστής λειτουργεί συνδέοντας 4 Full Adder του προηγουμένου
ερωτήματος οπού σε κάθε κύκλο ρολογιού το $C_(o u t)$ του ενός προωθείτε στο
$C_(i n)$ του επόμενου σταδίου. Επίσης προσθέτουμε αρκετή καθυστέρηση πριν
την είσοδο του κάθε Full Adder ώστε το $C_(i n)$ που προέρχεται από τον προηγούμενο να
έχει προλάβει αν υπολογιστεί. \
Σε σχέση με τον κασκοδικό της ασκήσεις 1, όπου όλο το το άθροισμα υπολογιζόταν σε ένα
κύκλο, εδώ υπολογίζουμε το κάθε άθροισμα σε πολλούς κύκλους με όμως λιγότερη λογική
μεταξύ κύκλων και το pipeline μας επιτρέπει να έχουμε in flight πολλά αθροίσματα.
Αποτέλεσμα όλου αυτού είναι ένα κύκλωμα με delay 4 κύκλους, throughput 1 και
μικρότερο delay στο critical path από τον κασκοδικό, 4.076ns αντί για 5.970ns, με
κόστος όμως περισσότερο υλικό, κυρίως flipflip.

#figure(
  image("./assets/2_RTL.png", width:90%),
  caption: [RTL]
)

== Implementation
#raw(read("./vhdl/design_sources/4bit_fa_transmission.vhd"), lang: "vhdl")

Το οποίο μα δίνει critical path 4.076ns
#figure(
  image("./assets/2_critical_path_4.076.png", width:90%),
  caption: [Critical path 4.076]
)

#pagebreak()
== Test Bench
Θα κάνουμε probe συγκεκριμένες τιμές οπού στοχεύουν σε διαφορετικές συμπεριφορές του
κυκλώματος, πχ με $C_(i n)$, $C_(o u t)$ η χωρίς, και τα αποτελέσματα που αναμένουμε αναγράφονται στα
σχόλια του κώδικα.
#raw(read("./vhdl/bench/4bit_fa_transmission_bench.vhd"), lang: "vhdl")

#figure(
  image("./assets/2_bench.png", width:100%),
  caption: [Test Bench]
)

= Array Multiplier

#figure(
  image("./assets/systolic_schematic.png", width:60%),
)

#figure(
  image("./assets/systolic_helper.png", width:60%),
)
Παραπάνω φαίνονται το ολοκληρωμένο κύκλωμα καθώς και το βασικό δομικό στοιχείο που θα
χρησιμοποιήσουμε. Η διάδοση του υπολογισμού γίνετε σε μορφή κύματος αρχίζοντας από
το $a_0, b_0$. Αποτέλεσμα είναι ότι πρέπει να προσθέσουμε καθυστέρηση στην είσοδο του
κάθε αθροιστή και στην έξοδο του συνολικού για να δρομολογηθούν στο output όλα τα σχετικά bit
ταυτόχρονα. Ποιο συγκεκριμένα χρειαζόμαστε καθυστέρηση 1 κύκλο μεταξύ κάθε a, 2
μεταξύ κάθε b και το product αρχίζει με καθυστέρηση 9 μέχρι 0 με βήμα 2 μέχρι το 4
και μετά βήμα 1 μέχρι το 0.

#figure(
  image("./assets/3_RTL.png", width:90%),
  caption: [RTL]
)

== Implementation
Στις γραμμές 1-48 υλοποιούμε το βασικό δομικό στοιχείο που παρουσιάσαμε παραπάνω και
στις γραμμές 50-96 δημιουργούμε στάδια από τα $"FA"^*$ με προσοχή να προσθέσουμε
καθυστέρηση στο $C_(o u t)$. \
Γραμμές 100-193 είναι το implementation του multiplier όπου συνδέουμε 4 από τα
παραπάνω στάδια. Το μονό ίσως λεπτό σημείο είναι ότι αντί για να προσθέσουμε την
κάθε καθυστέρηση με το χέρι, βάζουμε πλέγματα από register όπου το καθένα τροφοδοτεί το
επόμενο. Έτσι μπορούμε να ενώσουμε το input που θέλουμε στην αρχή του πλέγματος και
άπλα να το ξαναπάρουμε σε όποιο στάδιο μας βολεύει. Για παράδειγμα στις γραμμές
144-150 προσθέτουμε στην αρχή των αντίστοιχων πλεγμάτων καθυστέρησης το A, B και μετά
με ένα for loop προωθούμε το κάθε στάδιο του πλέγματος στο επόμενο, τέλος στην
γραμμή 169 παίρνουμε από το πλέγμα σήμα προς την είσοδο του πρώτου σταδίου μετά από
κατάλληλη καθυστέρηση.
#raw(read("./vhdl/design_sources/systolic_mul.vhd"), lang: "vhdl")

Το οποίο μα δίνει critical path 4.076ns
#figure(
  image("./assets/3_critical_path_4.076.png", width:90%),
  caption: [Critical path 4.076]
)

== Test Bench
Όπως παραπάνω θα κάνουμε probe συγκεκριμένες τιμές, και οι αναμενόμενες απαντήσεις
είναι γραμμένες σε comment στον κώδικα.
#raw(read("./vhdl/bench/systolic_mul_bench.vhd"), lang: "vhdl")

#figure(
  image("./assets/3_bench.png", width:100%),
  caption: [Test Bench]
)

