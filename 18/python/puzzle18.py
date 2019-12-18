"""
Advent of Code 2019 :: Day 18 :: Many-Worlds Interpretation
https://adventofcode.com/2019/day/18
"""
from collections import deque, defaultdict

def maze_get(maze, posn):
    """Return maze cell at posn."""
    row, col = posn
    return maze[row][col]


def is_key(cell):
    """Returns true if cell is a key."""
    return cell.islower()


def is_door(cell):
    """Returns true if cell is a door."""
    return cell.isupper()


def is_wall(cell):
    """Returns true if cell is wall."""
    return cell == "#"


def neighborhood(posn):
    """Returns four neighbors of posn."""
    row, col = posn
    return ((row - 1, col), (row + 1, col),
            (row, col - 1), (row, col + 1))


def find_key_posns(maze):
    """
    Returns a dictionary of key positions, 
    including start.
    """
    key_posns = {}
    for row_index, row in enumerate(maze):
        for col_index, cell in enumerate(row):
            if is_key(cell) or cell == "@":
                key_posns[cell] = (row_index, col_index)
    return key_posns


def build_graph(maze, key_posns):
    """Transform maze into a graph."""
    graph = defaultdict(list)
    for key, key_posn in key_posns.items():
        queue = deque([(key_posn, 0, [])])
        visited = set()
        visited.add(key_posn)
        while queue:
            posn, steps, doors = queue.popleft()
            steps += 1
            for neighbor in neighborhood(posn):
                if neighbor in visited:
                    continue
                cell = maze_get(maze, neighbor)
                doors0 = list(doors)
                if is_wall(cell):
                    continue
                if is_door(cell):
                    doors0.append(cell)
                if is_key(cell):
                    graph[key].append((cell, steps, doors0))
                queue.append((neighbor, steps, doors0))
                visited.add(neighbor)
    return graph


def any_doors_locked(doors, keys):
    """Returns true if there are any doors locked."""
    for door in doors:
        key = door.lower()
        if key not in keys:
            return True
    return False


def solve(maze):
    """Solve puzzle."""
    min_steps = 99999
    min_path = None
    key_posns = find_key_posns(maze)
    key_count = len(key_posns) - 1
    graph = build_graph(maze, key_posns)
    queue = deque()
    queue.append((key_posns["@"], 0, []))
    while queue:
        posn, steps, keys = queue.popleft()
        key = maze_get(maze, posn)
        if steps > min_steps:
            continue
        print(key, posn, steps, keys)
        if len(keys) == key_count:
            print(keys, steps)
            if steps < min_steps:
                min_steps = steps
                min_path = keys

        for neighbor_key, neighbor_steps, neighbor_doors in graph[key]:
            neighbor_posn = key_posns[neighbor_key]
            # print("neighbor", neighbor_key, neighbor_posn,neighbor_steps, neighbor_doors)
            if neighbor_key in keys:
                # print('I already have', neighbor_key, 'in', keys)
                continue
            if any_doors_locked(neighbor_doors, keys):
                # print('I cannot open', neighbor_doors, 'with', keys)
                continue
            steps0 = steps + neighbor_steps
            keys0 = list(keys)
            keys0.append(neighbor_key)
            queue.append((neighbor_posn, steps0, keys0))

    return (min_path, min_steps)


def main():
    """Main program."""
    import sys
    maze = [line.strip() for line in sys.stdin.readlines()]
    print(solve(maze))

if __name__ == '__main__':
    main()
