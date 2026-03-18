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
  assignment: "3η Εργαστηριακή Άσκηση",
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

= Ram και Rom
Τροποποιήθηκαν τα αρχεία για τις μνήμες ώστε να μπορούμε με generics να καθορίσουμε
όλα τα μεγέθη στο instantiation σε περίπτωση που χρειαστεί σε επόμενες ασκήσεις, η
λειτουργία παραμένει όμως ίδια για την Rom. Για την Ram προστέθηκε άπλα ένα Reset,
ένα for loop στο write enable για την ολίσθηση και μετά μια φόρτωση στο index 0. Δεν
ήταν ξεκάθαρο από την εκφώνηση τι πρέπει να είναι το output μετά από ένα write οπότε
άπλα δίνει ότι διεύθυνση παίρνει στην είσοδο.
#raw(read("./vhdl/design_sources/memories.vhd"), lang: "vhdl")
//
//#figure(
//  image("./assets/1_critical_path_4.076.png", width:70%),
//  caption: [Critical path 4.076]
//)

= Multiplier Accumulator
Για τον αριθμό bit του MAC ισχύει ότι
$
  L(y) = 2 N + log_2(M + 1)
$
άρα θέλουμε 19 bit. Έκτος αυτού η δομή του είναι προφανής από τον κώδικα.

#pagebreak()

#raw(read("./vhdl/design_sources/mac.vhd"), lang: "vhdl")

= Control Unit
Το μόνο που ίσως να αξίζει σχολιασμό είναι ότι μπορούμε να γράψουμε το 
`"111" - Counter` ως συμπλήρωμα και ότι υπερισχύει το τελευταίο assignment οπότε
μπορούμε να κάνουμε πάντα αρχικοποίηση των σημάτων σε default και μετά να τα
αλλάζουμε, αλλιώς το κύκλωμα είναι πολύ απλό.
#raw(read("./vhdl/design_sources/CU.vhd"), lang: "vhdl")

= FIR
Για το τελικό σχέδιο συνδέουμε όλα τα παραπάνω components και προσθέτουμε καθυστέρηση
στο X μέχρι την ram και σε όλα τα σήματα από την cu στον mac.
#raw(read("./vhdl/design_sources/FIR.vhd"), lang: "vhdl")
