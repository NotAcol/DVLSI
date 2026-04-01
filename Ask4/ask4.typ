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
  assignment: "4η Εργαστηριακή Άσκηση",
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

= FIR
Έγινε μια μικρή αλλαγή στο Control Unit του φίλτρου για να μπορεί να υποστηρίξει
stall οποιασδήποτε διάρκειας στο ValidIn. Ακόμα δεν υποστηρίζει να έρθει είσοδος πιο νωρίς
αλλά μπορεί να αργήσει περισσότερο από 7 κύκλους χωρίς πρόβλημα.

#raw(read("./vhdl/design_sources/CU.vhd"), lang: "vhdl")

//#figure(
//  image("./assets/RTL.png", width:90%),
//  caption: [RTL]
//)

= Axi Lite

Για την σύνδεση του φίλτρου με το harness του axi lite καταρχάς καθυστερούμε σε ένα register
για έναν κύκλο το write flag. Οπότε παίρνουμε τα δεδομένα που γράφηκαν στο register A τον επόμενο
κύκλο και κάνουμε το write and με το ValidIn για να μην διαβάζει το φίλτρο ValidIn κάθε κύκλο
μέχρι να ξαναγράψουμε 0 στο register.

Επίσης κάθε φορά που έχουμε νέα έξοδο την κρατάμε σε ένα register μέχρι να διαβαστεί
από την C όπου και κάνουμε το ValidOut bit της 0.

```vhdl
process(S_AXI_ACLK) begin
  if rising_edge(S_AXI_ACLK) then
    if S_AXI_ARESETN = '0' then
      WrenSkew <= '0';
      FirValidIn <= '0';
    else
      -- NOTE(acol): hold write event to A register for 1 cycle :)
      if slv_reg_wren = '1' and 
        axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB) = b"00" then
        WrenSkew <= '1';
      else
        WrenSkew <= '0';
      end if;
    end if;
    FirValidIn <= WrenSkew and slv_reg0(8);
  end if;
end process;

-- NOTE(acol): capture validout values
process(S_AXI_ACLK) begin
  if rising_edge(S_AXI_ACLK) then
   	if S_AXI_ARESETN = '0' then
      CaptureY <= (others => '0');
      DataReady <= '0';
    else
      -- save valid
    	if FirValidOut = '1' then
        CaptureY <= FirY;
        DataReady <= '1';
      end if;
    	-- clear on read
      if slv_reg_rden = '1' and 
        axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB) = b"01" then
        DataReady <= '0';
      end if;	            
    end if;
	end if;
end process;
```

Παρακάτω είναι και το boilerplate.
```vhdl
  -- NOTE(acol): Declarations
  component FirFilter is 
    Port(
      Clk      : in std_logic;
      Reset    : in std_logic;
      ValidIn  : in std_logic;
      X        : in std_logic_vector(7 downto 0); 
      ValidOut : out std_logic;
      Y        : out std_logic_vector(18 downto 0)
    );
  end component FirFilter;
  
  signal FirValidIn, FirReset, FirValidOut : std_logic;
  signal FirX : std_logic_vector(7 downto 0);
  signal FirY : std_logic_vector(18 downto 0);
  
  signal CaptureY : std_logic_vector(18 downto 0) := (others => '0');
  signal DataReady : std_logic := '0';
  signal WrenSkew : std_logic := '0';
begin

-- ********* --
     -- NOTE(acol): Read
  
  FIR : FirFilter port map(
    Clk => S_AXI_ACLK,
    Reset => FirReset,
    ValidIn => FirValidIn,
    ValidOut => FirValidOut,
    X => FirX,
    Y => FirY
   );

  FirReset <= slv_reg0(9);
  FirX <= slv_reg0(7 downto 0);

-- ********* --


	process (DataReady ,slv_reg0, slv_reg1, slv_reg2, slv_reg3, 
           axi_araddr, S_AXI_ARESETN, slv_reg_rden)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	begin
	 -- Address decoding for reading registers
	    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	    case loc_addr is
	      when b"00" =>
	        reg_data_out <= slv_reg0;
	      when b"01" =>
	        reg_data_out(18 downto 0)  <= CaptureY;
		      reg_data_out(19)		       <= DataReady;
		      reg_data_out(31 downto 20) <= (others => '0');
	      when b"10" =>
	        reg_data_out <= slv_reg2;
	      when b"11" =>
	        reg_data_out <= slv_reg3;
	      when others =>
	        reg_data_out  <= (others => '0');
	    end case;
	end process; 
```

= C
Το μονό ίσως άξιο σχολιασμού κομμάτι του κώδικα είναι ότι κάνουμε loop για το μήκος
του σήματος + το μήκος του impulse response - 1 και στην γραμμή 47 παίρνουμε σαν
δεδομένα το σήμα για όλες τις τιμές του και μετά μηδενικά.
```c
/*
 // NOTE(acol): most sane path to place all the useful macros and functions
design_1_wrapper/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/ps7_cortexa9_0/include/

#define XPAR_FIR_AXI_LITE_0_DEVICE_ID 0
#define BASEADDR 0x43C00000
#define XPAR_FIR_AXI_LITE_0_S00_AXI_HIGHADDR 0x43C0FFFF
*/

#include <stdio.h>
#include "platform.h"
#include "sleep.h"
#include "xil_printf.h"
#include "xil_io.h"

#define BASEADDR 0x43C00000

// NOTE(acol): Helper macros
#define ArrayCount(A) (sizeof(A) / sizeof(A[0]))
#define Signal(S) (signal){(u8*)(S), ArrayCount(S)}

// NOTE(acol): types
typedef uint8_t u8;
typedef uint32_t u32;

typedef struct signal {
    u8 *Val;
    u32 Length;
} signal;


#define RValid(R) ((R>> 19) & 0x1)
#define RValue(R) (R & ((1<<19) -1))

void RunFilter(signal X, u8 TapCount, u32 AReg, u32 BReg)
{
  u32 Response = 0;

  // NOTE(acol): Reset
  Xil_Out32(AReg, (1<<9));
  Xil_Out32(AReg, 0);

  xil_printf("Y[n] = [ ");
  for(u32 Idx = 0; Idx < X.Length + TapCount -1; Idx++)
  {
    // NOTE(acol): Data is the entire signal + enough zeros for the tail end
    u8 Data = 0xff & ((Idx < X.Length)? X.Val[Idx] : 0);

    // NOTE(acol): Send data and zero out
    Xil_Out32(AReg, (1<<8) | Data);
    Xil_Out32(AReg, 0);

    // NOTE(acol): Read untill valid
    do {
      Response = Xil_In32(BReg);
    } while(!RValid(Response));

    xil_printf("%lu ", RValue(Response));
  }
  xil_printf("]\n\r");
}

int main()
{
  init_platform();

  u8 Dirac[] = {1, 0, 0, 0, 0, 0, 0, 0};
  u8 Unit[]  = {1, 1, 1, 1, 1, 1, 1, 1};
  u8 Taps = 8;

  RunFilter(Signal(Unit), Taps, BASEADDR, BASEADDR + 4);
  RunFilter(Signal(Dirac), Taps, BASEADDR, BASEADDR + 4);

  sleep(10);
  cleanup_platform();
  return 0;
}
```
