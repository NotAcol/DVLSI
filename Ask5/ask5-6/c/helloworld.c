#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xparameters_ps.h"
#include "xaxidma.h"
#include "xtime_l.h"

#define TX_DMA_ID                 XPAR_PS2PL_DMA_DEVICE_ID
#define TX_DMA_MM2S_LENGTH_ADDR  (XPAR_PS2PL_DMA_BASEADDR + 0x28) 
#define RX_DMA_ID                 XPAR_PL2PS_DMA_DEVICE_ID
#define RX_DMA_S2MM_LENGTH_ADDR  (XPAR_PL2PS_DMA_BASEADDR + 0x58) 

#define TX_BUFFER (XPAR_DDR_MEM_BASEADDR + 0x08000000) 
#define RX_BUFFER (XPAR_DDR_MEM_BASEADDR + 0x10000000) 

#define IMAGE_WIDTH  1024
#define IMAGE_HEIGHT 1024
#define NUM_PIXELS   (IMAGE_WIDTH * IMAGE_HEIGHT)
#define TX_BYTES     NUM_PIXELS
#define RX_BYTES     (NUM_PIXELS * 4)

XAxiDma TxAxiDma;
XAxiDma RxAxiDma;

typedef unsigned char u8;
typedef unsigned int  u32;
typedef int           i32;
typedef float         f32;
typedef double        f64;

static inline u8 GetPixel(u8* Buffer, i32 Row, i32 Col, i32 Width, i32 Height)
{
  if (Row < 0 || Row >= Height || Col < 0 || Col >= Width) return 0;

  return Buffer[Row * Width + Col];
}

void Debayer(u8* InBuffer, u32* OutBuffer, i32 Width, i32 Height) 
{
  for(i32 Row = 0; Row < Height; Row++) 
  {
    for(i32 Col = 0; Col < Width; Col++) 
    {
      u8 Center = GetPixel(InBuffer, Row, Col, Width, Height);
      
      u32 SumVert = GetPixel(InBuffer, Row - 1, Col, Width, Height) + 
                    GetPixel(InBuffer, Row + 1, Col, Width, Height);
                    
      u32 SumHorz = GetPixel(InBuffer, Row, Col - 1, Width, Height) + 
                    GetPixel(InBuffer, Row, Col + 1, Width, Height);
                    
      u32 SumCross = SumVert + SumHorz;
      
      u32 SumDiag = GetPixel(InBuffer, Row - 1, Col - 1, Width, Height) + 
                    GetPixel(InBuffer, Row - 1, Col + 1, Width, Height) +
                    GetPixel(InBuffer, Row + 1, Col - 1, Width, Height) + 
                    GetPixel(InBuffer, Row + 1, Col + 1, Width, Height);

      u8 PixelR, PixelG, PixelB;

      if ((Row % 2 == 0) && (Col % 2 == 0)) {
        // GB row G col
        PixelR = (u8)(SumVert >> 1);
        PixelG = Center;
        PixelB = (u8)(SumHorz >> 1);
      } 
      else if ((Row % 2 == 0) && (Col % 2 != 0)) {
        // GB row B col
        PixelR = (u8)(SumDiag >> 2);
        PixelG = (u8)(SumCross >> 2);
        PixelB = Center;
      } 
      else if ((Row % 2 != 0) && (Col % 2 == 0)) {
        // RG row R col
        PixelR = Center;
        PixelG = (u8)(SumCross >> 2);
        PixelB = (u8)(SumDiag >> 2);
      } 
      else {
        // RG row G col
        PixelR = (u8)(SumHorz >> 1);
        PixelG = Center;
        PixelB = (u8)(SumVert >> 1);
      }

      // pack to 32bit gbr00
      OutBuffer[Row * Width + Col] = (PixelB << 16) | (PixelG << 8) | PixelR;
    }
  }
}

i32 main()
{
    Xil_DCacheDisable();

    XTime PreExecCyclesFpga = 0;
    XTime PostExecCyclesFpga = 0;
    XTime PreExecCyclesSw = 0;
    XTime PostExecCyclesSw = 0;
    
    XAxiDma_Config *TxConfig;
    XAxiDma_Config *RxConfig;
    i32 Status;

    u8 *TxBuffer = (u8*)TX_BUFFER;
    u32 *RxBuffer = (u32*)RX_BUFFER;
    u32 *SwBuffer = (u32*)(RX_BUFFER + RX_BYTES); 

    print("HELLO 1\r\n");

    init_platform();

    // NOTE(acol): dma setup
    TxConfig = XAxiDma_LookupConfig(TX_DMA_ID);
    if (!TxConfig) return XST_FAILURE;
    Status = XAxiDma_CfgInitialize(&TxAxiDma, TxConfig);
    if (Status != XST_SUCCESS) return XST_FAILURE;

    RxConfig = XAxiDma_LookupConfig(RX_DMA_ID);
    if (!RxConfig) return XST_FAILURE;
    Status = XAxiDma_CfgInitialize(&RxAxiDma, RxConfig);
    if (Status != XST_SUCCESS) return XST_FAILURE;

    XAxiDma_IntrDisable(&dma1, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
    XAxiDma_IntrDisable(&dma1, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

    // TODO(acol): maybe populate TxBuffer with dummy image data?

    // NOTE(acol): HW part
    XTime_GetTime(&PreExecCyclesFpga);

    Status = XAxiDma_SimpleTransfer(&RxAxiDma, (UINTPTR)RxBuffer, RX_BYTES, XAXIDMA_DEVICE_TO_DMA);
    if (Status != XST_SUCCESS) return XST_FAILURE;

    Status = XAxiDma_SimpleTransfer(&TxAxiDma, (UINTPTR)TxBuffer, TX_BYTES, XAXIDMA_DMA_TO_DEVICE);
    if (Status != XST_SUCCESS) return XST_FAILURE;


    // TODO(acol): maybe arm also has something like umonitor/umwait to dodge busy wait? or
    // at least pause to avoid nop loop
    while (XAxiDma_Busy(&TxAxiDma, XAXIDMA_DMA_TO_DEVICE)) {}
    while (XAxiDma_Busy(&RxAxiDma, XAXIDMA_DEVICE_TO_DMA)) {}
    XTime_GetTime(&PostExecCyclesFpga);


    // NOTE(acol): SW part
    XTime_GetTime(&PreExecCyclesSw);
    Debayer(TxBuffer, SwBuffer, IMAGE_WIDTH, IMAGE_HEIGHT);
    XTime_GetTime(&PostExecCyclesSw);


    // NOTE(acol): report results
    i32 ErrorCount = 0;
    for (i32 Idx = 0; Idx < NUM_PIXELS; Idx++) 
    {
        ErrorCount+= RxBuffer[Idx] != SwBuffer[Idx];
    }
    f32 ErrorPercentage = ((f32)ErrorCount / (f32)NUM_PIXELS) * 100.0f;
    i32 FpgaCycles      = (i32)(PostExecCyclesFpga - PreExecCyclesFpga);
    i32 SwCycles        = (i32)(PostExecCyclesSw - PreExecCyclesSw);
    f32 Speedup         = (f32)SwCycles / (f32)FpgaCycles;

    print("Total Error: %.2f%%\r\n\r\n", ErrorPercentage);
    print("HW Exec time: %d cycles\r\n", FpgaCycles);
    print("SW Exec time: %d cycles\r\n", SwCycles);
    print("Speedup: %.2f\r\n", Speedup);

    cleanup_platform();
    return 0;
}
