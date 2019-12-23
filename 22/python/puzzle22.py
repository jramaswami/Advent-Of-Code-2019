"""
Advent of Code 2019 :: Day 21 :: Slam Shuffle
https://adventofcode.com/2019/day/22
"""

def modinv(n, m):
    """Modular inverse assuming m is prime."""
    return pow(n, m-2, m)

def reverse_cut(n, deck_length, keep):
    """Cut in reverse."""
    return (keep + n + deck_length) % deck_length

def cut(n, deck_length, keep):
    """Cut"""
    # index - n (mod deck length)
    return (keep - n) % deck_length

def reverse_deal_with(n, deck_length, keep):
    """Deal with in reverse"""
    m = modinv(n, deck_length)
    return (m * keep) % deck_length

def deal_with(n, deck_length, keep):
    """Deal with increment"""
    return (keep * n) % deck_length

def deal_into(deck_length, keep):
    """Deal into new stack."""
    return (deck_length - keep - 1) % deck_length

def reverse_deal_into(deck_length, keep):
    """Reverse deal into"""
    return deck_length - 1 - keep

def solve_part1(lines):
    """Solve first part of the puzzle."""
    deck_length = 10007
    keep = 2019
    for line in lines:
        tokens  = line.split()
        if tokens[0] == 'cut':
            n = int(tokens[1])
            keep = cut(n, deck_length, keep)
        elif tokens[1] == 'into':
            keep = deal_into(deck_length, keep)
        elif tokens[1] == 'with':
            n = int(tokens[3])
            keep = deal_with(n, deck_length, keep)
    return keep

def reverse_shuffle(lines, keep, deck_length):
    """Do the shuffle in reverse."""
    for line in lines[::-1]:
        tokens = line.split()
        if tokens[0] == 'cut':
            n = int(tokens[1])
            keep = reverse_cut(n, deck_length, keep)
        elif tokens[1] == 'into':
            keep = reverse_deal_into(deck_length, keep)
        elif tokens[1] == 'with':
            n = int(tokens[3])
            keep = reverse_deal_with(n, deck_length, keep)
    return keep

def solve_part2(lines):
    """Solve second part of puzzle."""

    shuffles = 101741582076661
    deck_length = 119315717514047
    X = 2020
    Y = reverse_shuffle(lines, X, deck_length)
    Z = reverse_shuffle(lines, Y, deck_length)
    M = modinv(X-Y+deck_length, deck_length)   # Fermat's little theorem
    A = ((Y - Z) * M) % deck_length
    B = (Y - A * X) % deck_length

    M = modinv(A-1, deck_length)
    soln = (pow(A, shuffles, deck_length) * X \
            + (pow(A, shuffles, deck_length) - 1) \
            * modinv(A-1, deck_length) * B) % deck_length
    return soln

def main():
    """Main program."""
    import sys
    lines = [line.strip() for line in sys.stdin]
    soln1 = solve_part1(lines)
    print(f"The solution to part 1 is {soln1}.")
    soln2 = solve_part2(lines)
    print(f"The solution to part2 is {soln2}.")

if __name__ == '__main__':
    main()
