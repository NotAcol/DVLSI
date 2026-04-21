import sys

def GenerateGoldenOutputs(InputFile, OutputFile, ImageWidth=1024, ImageHeight=1024):
    try:
        # Read strictly as base-10 decimal integers
        with open(InputFile, 'r') as f:
            RawData = [int(line.strip()) for line in f if line.strip()]
    except FileNotFoundError:
        print(f"Error: Could not find {InputFile}")
        sys.exit(1)

    if len(RawData) < ImageWidth * ImageHeight:
        print(f"Warning: Padding end with 0s.")
        RawData.extend([0] * (ImageWidth * ImageHeight - len(RawData)))

    # Create padded grid
    Grid = [[0 for _ in range(ImageWidth + 2)] for _ in range(ImageHeight + 2)]
    
    for r in range(ImageHeight):
        for c in range(ImageWidth):
            Grid[r + 1][c + 1] = RawData[r * ImageWidth + c]

    # Process demosaicing
    with open(OutputFile, 'w') as f:
        for r in range(ImageHeight):
            for c in range(ImageWidth):
                Pr, Pc = r + 1, c + 1

                Center = Grid[Pr][Pc]
                Left   = Grid[Pr][Pc - 1]
                Right  = Grid[Pr][Pc + 1]
                Top    = Grid[Pr - 1][Pc]
                Bottom = Grid[Pr + 1][Pc]
                Tl     = Grid[Pr - 1][Pc - 1]
                Tr     = Grid[Pr - 1][Pc + 1]
                Bl     = Grid[Pr + 1][Pc - 1]
                Br     = Grid[Pr + 1][Pc + 1]

                SumHorz  = Left + Right
                SumVert  = Top + Bottom
                SumCross = Top + Bottom + Left + Right
                SumDiag  = Tl + Tr + Bl + Br

                if r % 2 == 0 and c % 2 == 0:
                    PixelG, PixelB, PixelR = Center, SumHorz // 2, SumVert // 2
                elif r % 2 == 0 and c % 2 != 0:
                    PixelB, PixelG, PixelR = Center, SumCross // 4, SumDiag // 4
                elif r % 2 != 0 and c % 2 == 0:
                    PixelR, PixelG, PixelB = Center, SumCross // 4, SumDiag // 4
                else:
                    PixelG, PixelR, PixelB = Center, SumHorz // 2, SumVert // 2

                # Write hex values separated by space, uppercase, 2 chars wide
                f.write(f"{PixelR:02X} {PixelG:02X} {PixelB:02X}\n")

if __name__ == "__main__":
    GenerateGoldenOutputs("inputs.txt", "expected_outputs.txt", ImageWidth=32, ImageHeight=32)
