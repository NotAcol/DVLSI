import sys

def generate_golden_outputs(input_file, output_file, width=1024, height=1024):
    # Read hex inputs into a 1D list of integers
    try:
        with open(input_file, 'r') as f:
            raw_data = [int(line.strip(), 16) for line in f if line.strip()]
    except FileNotFoundError:
        print(f"Error: Could not find {input_file}")
        sys.exit(1)

    if len(raw_data) < width * height:
        print(f"Warning: Not enough pixels ({len(raw_data)}). Padding end with 0s.")
        raw_data.extend([0] * (width * height - len(raw_data)))

    # Create a padded 2D grid initialized to 0s to handle the out-of-bounds edge cases
    grid = [[0 for _ in range(width + 2)] for _ in range(height + 2)]
    
    for r in range(height):
        for c in range(width):
            grid[r + 1][c + 1] = raw_data[r * width + c]

    # Process demosaicing
    with open(output_file, 'w') as f:
        for r in range(height):
            for c in range(width):
                # Padded coordinates mapping
                pr, pc = r + 1, c + 1

                center = grid[pr][pc]
                left   = grid[pr][pc - 1]
                right  = grid[pr][pc + 1]
                top    = grid[pr - 1][pc]
                bottom = grid[pr + 1][pc]
                tl     = grid[pr - 1][pc - 1]
                tr     = grid[pr - 1][pc + 1]
                bl     = grid[pr + 1][pc - 1]
                br     = grid[pr + 1][pc + 1]

                sum_horz  = left + right
                sum_vert  = top + bottom
                sum_cross = top + bottom + left + right
                sum_diag  = tl + tr + bl + br

                # GBRG Logic utilizing integer division (//) equivalent to VHDL bit shifting
                if r % 2 == 0 and c % 2 == 0:
                    # G in GB row
                    p_g = center
                    p_b = sum_horz // 2
                    p_r = sum_vert // 2
                elif r % 2 == 0 and c % 2 != 0:
                    # B pixel
                    p_b = center
                    p_g = sum_cross // 4
                    p_r = sum_diag // 4
                elif r % 2 != 0 and c % 2 == 0:
                    # R pixel
                    p_r = center
                    p_g = sum_cross // 4
                    p_b = sum_diag // 4
                else:
                    # G in RG row
                    p_g = center
                    p_r = sum_horz // 2
                    p_b = sum_vert // 2

                # Write hex values separated by space, uppercase, 2 chars wide
                f.write(f"{p_r:02X} {p_g:02X} {p_b:02X}\n")

if __name__ == "__main__":
    # Ensure these match your VHDL generics
    generate_golden_outputs("inputs.txt", "expected_outputs.txt", width=32, height=32)
