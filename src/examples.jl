

# from Nanda & Misra (2024), https://doi.org/10.48550/arXiv.2411.03157

# unltimately winnable
NM8Ξ = NaMiBoard(100, [43 51 52 53 54 55 56 99;
                       98 32 33 34 35 36 37 2])

# empty two-dim int array, unltimately winnable
NM0 = Board(100, Vector{ShortCut}(undef, 0)) # empty shortcut vector as NaMiBoard cannot handle empty arrays


# unwinnable board
NM6U = NaMiBoard(100, [94 95 96 97 98 99;
                       89 69 48 42 61 81])
# unltimately winnable
NM10α = NaMiBoard(100, [ 2 9 21 26 34 50 54 88 95 97;
                        23 31 63 4 65 15 90 24 53 80])

# occasionally winnable                        
NM7∆ = NaMiBoard(100, [ 2 54 55 56 57 58 59;
                       99 50 32 27 23 39 41])
# unwinnable?
NM14G0 = NaMiBoard(100, [10 34 35 36 37 38 39 41 74 75 76 77 78 79;
                         71 30 12 7 3 19 21 81 70 52 54 56 58 60])


