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
#let subtext_color = rgb("#bac2de")
#let surface_color = rgb("#313244")

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
  margin: (x:13%, y: 5.5%),
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
  assignment: "1η Εργαστηριακή Άσκηση",
  year: "2025-2026",
  authors: (
    (
      name: "Παναγιώτης Γερασιμόπουλος 03115208",
      //sn: "el15208",
      email: "personal@devcol.com"
    ),
    (
      name: "Νικόλας Νεοφύτου 03122632",
      email: ""
    ),
  )
)

#contents()

#counter(page).update(1)
= Μέρος A

== Decoder 3-8
Ο αποκωδικοποιητής 3 σε 8 είναι ένα συνδυαστικό κύκλωμα που για κάθε συνδυασμό των εισόδων του
ενεργοποιεί μόνο μία από τις εξόδους.

#figure(
  image("./assets/1.1.png", width:70%),
  caption: [RTL]
)

=== Implementation
Ο πίνακας αληθείας του αποκωδικοποιητή φαίνεται από τις γραμμές 16-23 του κωδικά για το behavioral.

==== Dataflow
#raw(read("./vhdl/part_a/design_sources/decoder_dataflow.vhd"), lang: "vhdl")

==== Behavioral
#raw(read("./vhdl/part_a/design_sources/decoder_behavioral.vhd"), lang: "vhdl")

=== Testbench

Το κύκλωμα έχει πολύ λίγες πιθανές εισόδους και δεν έχει state οπότε μπορούμε εύκολα
να σχεδιάσουμε εξαντλητικά test bench όπως φαίνεται παρακάτω.

#raw(read("./vhdl/part_a/bench/decoder_behavioral_bench.vhd"), lang: "vhdl")

#figure(
  image("./assets/1.1_bench.png", width:100%),
  caption: [Test Bench]
)

== Καταχωρητής Ολίσθησης
Ο καταχτητής ολίσθησης είναι σύγχρονο κύκλωμα που δέχεται μια παράλληλη είσοδο των
4bit μέσω του I και μια συριακή μέσω του SerIn. Τα σήματα έλεγχου του είναι το reset που
τον επαναφέρει στο 0 ασύγχρονα, το load που ελέγχει την παράλληλη είσοδο, το enable
που ελέγχει την σειριακή λειτουργία του κυκλώματος και το slide bit που ελέγχει την
κατεύθυνση της ολίσθησης ασύγχρονα.

#figure(
  image("./assets/1.2.png", width:100%),
  caption: [RTL]
)

=== Implementation
#raw(read("./vhdl/part_a/design_sources/shift_register.vhd"), lang: "vhdl")

Το οποίο μας δίνει στο critical path του synthesis 5.351ns.
#figure(
  image("./assets/1.2_critical_path_5.351.png"),
  caption: [Critical Path 5.351ns]
)

=== Test Bench
Φορτώνουμε τον αριθμό '1010' μέσω του load και κάνουμε αριστερό slide για 3 cycles 
φορτώνοντας 4 '1' μέσω του SerIn και μετά κάνουμε δυο cycles slide δεξιά περιμένοντας
να δούμε τους άσους που φορτώσαμε στα register. Τα input δίνονται στο falling edge
ενώ το σύστημα κάνει update στο rising edge.

#raw(read("./vhdl/part_a/bench/shift_register_bench.vhd"), lang: "vhdl")

#figure(
  image("./assets/1.2_bench.png", width:100%),
  caption: [Test Bench]
)

== Μετρητής
Ο Μετρητής είναι ένα σύγχρονο κύκλωμα που μετράει σε διάδικο τους κύκλους του ρολογιού
και κάνει wrap στο overflow, στην περίπτωση μας μετά τον αριθμό 7. Το ResetN μηδενίζει
την έξοδο ασύγχρονα, το down ελέγχει αν ο μετρητής θα αυξάνει η μειώνει σε κύκλο, και
το CountEn λειτουργεί ως start stop της μέτρησης. Επίσης προσδέθηκαν τα Modulo και Up
που ελέγχουν το σημείο που κάνουμε wrap και την κατεύθυνση της μέτρησης.

#figure(
  image("./assets/1.3.png", width:100%),
  caption: [RTL]
)

=== Implementation
Και τα δυο μέρη της άσκησης έγιναν σε ένα κύκλωμα για ευκολία στο debug, το κύκλωμα
υποστηρίζει dynamic αλλαγή της τιμής του modulo αλλά μόνο προς το θετικό count (αφού
δεν ζητήθηκε modulo για μέτρηση προς τα κάτω).

#raw(read("./vhdl/part_a/design_sources/counter.vhd"), lang: "vhdl")

Το οποίο μας δίνει στο critical path του synthesis 5.924ns.
#figure(
  image("./assets/1.3_critical_path_5.924.png", width: 80%),
  caption: [Critical Path 5.924ns]
)

=== Test Bench
Για το test bench κάνουμε αρχικά μέτρηση προς τα πάνω μέχρι overflow και μετά προς τα
κάτω μέχρι underflow. Στην συνέχεια αλλάζουμε το modulo και δοκιμάζουμε την δυναμική
αλλαγή του στην μέτρηση προς τα πάνω.
#raw(read("./vhdl/part_a/bench/counter_bench.vhd"), lang: "vhdl")

#figure(
  image("./assets/1.3_bench.png", width:100%),
  caption: [Test Bench]
)

#pagebreak()
= Μέρος B

== Half Adder
Ο half adder είναι ένα πολύ απλό κύκλωμα που περιγράφεται εξολοκλήρου από τις λογικές
συναρτήσεις $C_(o u t) = A and B$ και $S = A xor B$.
#figure(
  image("./assets/2.1.png", width:70%),
  caption: [RTL]
)

=== Implementation
#raw(read("./vhdl/part_b/design_sources/half_adder.vhd"), lang: "vhdl")

Το οποίο μας δίνει στο critical path του synthesis 5.377ns.
#figure(
  image("./assets/2.1_critical_path_5.377.png", width:100%),
  caption: [Critical Path 5.377]
)
=== Test Bench
Μπορούμε να εξετάσουμε διεξοδικά τον πίνακα αληθείας.
#raw(read("./vhdl/part_b/bench/half_adder_bench.vhd"), lang: "vhdl")

#figure(
  image("./assets/2.1_bench.png", width: 80%),
  caption: [Test Bench]
)

== Full Adder
Για να δημιουργήσουμε έναν Full Adder χρησιμοποιούμε δυο Half Adder σε σειρά και
συνδέουμε τα $C_(o u t)$ με μια πύλη or.

#figure(
  image("./assets/2.2.png", width: 80%),
  caption: [RTL]
)

=== Implementation
#raw(read("./vhdl/part_b/design_sources/full_adder.vhd"), lang: "vhdl")

Το οποίο μας δίνει στο critical path του synthesis 5.377ns, το ίδιο με τον half adder.
#figure(
  image("./assets/2.2_critical_path_5.377.png", width:85%),
  caption: [Critical Path 5.377]
)

=== Test Bench
Μπορούμε να εξετάσουμε διεξοδικά τον πίνακα αληθείας.
#raw(read("./vhdl/part_b/bench/full_adder_bench.vhd"), lang: "vhdl")

#figure(
  image("./assets/2.2_bench.png", width:85%),
  caption: [Test Bench]
)

== 4 Bit Full Adder
Υποθέτουμε εδώ ότι ο αθροιστής που ζητείται είναι τύπου ripple carry. Αρκεί να
συνδέσουμε σε σειρά τα carry τεσσάρων full adder.

#figure(
  image("./assets/2.3.png", width:85%),
  caption: [RTL]
)

=== Implementation
#raw(read("./vhdl/part_b/design_sources/4bit_full_adder.vhd"), lang: "vhdl")

Το οποίο μας δίνει στο critical path του synthesis 5.970ns.

#figure(
  image("./assets/2.3_critical_path_5.970.png", width:85%),
  caption: [Critical Path 5.970ns]
)

=== Test Bench
Μπορούμε να εξετάσουμε διεξοδικά τον πίνακα αληθείας.

#raw(read("./vhdl/part_b/bench/4bit_full_adder_bench.vhd"), lang: "vhdl")

Παρακάτω φαίνονται τα αποτελέσματα για τα δυο πρώτα εξωτερικά loop.

#figure(
  image("./assets/2.3_bench.png", width:100%),
  caption: [Test Bench]
)

== BCD
Το κύκλωμα κάνει πρόσθεση δυο δεκαδικών αριθμών σε δυαδική αναπαράσταση με χρήση
δυο Full Adder των 4bit. Ανιχνεύει όταν το άθροισμα είναι πάνω από 9 και προσθέτει 6
στον δεύτερο Full Adder 4bit αλλιώς προσθέτει 0.

#figure(
  image("./assets/2.4.png", width:100%),
  caption: [RTL]
)

=== Implementation
#raw(read("./vhdl/part_b/design_sources/bcd.vhd"), lang: "vhdl")

Το οποίο μας δίνει στο critical path του synthesis 5.976ns.
#figure(
  image("./assets/2.4_critical_path_5.976.png", width:75%),
  caption: [Critical Path 5.976ns]
)

=== Test Bench
Το Test Bench είναι παρόμοιο με του 4bit full adder μόνο που ελέγχουμε και για
διάφορες τιμές του Cin.
#raw(read("./vhdl/part_b/bench/bcd_bench.vhd"), lang: "vhdl")

Παρακάτω φαίνονται τα αποτελέσματα για το ενάμιση πρώτο εξωτερικό loop.

#figure(
  image("./assets/2.4_bench.png", width:100%),
  caption: [Test Bench]
)

#pagebreak()
== 4 Digit BCD
Για τον αθροιστή 4 δεκαδικών αριθμών θα χρησιμοποιήσουμε 4 κυκλώματα BCD και θα ενώσουμε σε
σειρά τα $C_(o u t)$ τους με ανάλογο τρόπο του 4bit full adder.

#figure(
  image("./assets/2.5.png", width:85%),
  caption: [RTL]
)

=== Implementation
#raw(read("./vhdl/part_b/design_sources/4digit_bcd.vhd"), lang: "vhdl")

Το οποίο μας δίνει στο critical path του synthesis 9.538ns.
#figure(
  image("./assets/2.5_critical_path_9.538.png", width:75%),
  caption: [Critical Path 9.538ns]
)

=== Test Bench
Δεν είναι δυνατό να ελέγξουμε όλες τις πιθανές τιμές, άρα θα κάνουμε probe edge
cases. Οι αναμενόμενες τιμές είναι γραμμένες στα comment του κωδικά.
#raw(read("./vhdl/part_b/bench/4digit_bcd_bench.vhd"), lang: "vhdl")

#figure(
  image("./assets/2.5_bench.png", width:100%),
  caption: [Test Bench]
)
