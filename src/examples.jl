

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
NM14G0 = 

# Althoen et al. 1993, NB player starts at 0 not 1
# also according to their rules, one must roll the exact number to land on 100
AKS19 = Board(100, [Ladder(1,38), Ladder(4,14), Ladder(9,31), Ladder(21,42), Ladder(28,84), Ladder(36,44), Ladder(51,67), Ladder(71,91), Ladder(80,100),
Snake(16,6), Snake(47,26), Snake(49,11), Snake(56, 53), Snake(62,19), Snake(64,60), Snake(87,24), Snake(93,73), Snake(95,75), Snake(98,78)])
