"""
Advent of Code 2019 :: Day 18 :: Many-Worlds Interpretation
https://adventofcode.com/2019/day/18
"""
from collections import deque, defaultdict
from math import inf

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


def key_index(key):
    """Returns the index of the key."""
    if key == "@":
        return -1
    return ord(key) - ord('a')


def build_topo_graph(graph):
    """Build a topological graph."""
    topo = defaultdict(list)
    indegree = [0 for _ in graph.keys()]
    for key, _, blocking_doors in graph["@"]:
        index = key_index(key)
        for door in blocking_doors:
            topo[door.lower()].append(key)
            indegree[index] += 1
    return topo, indegree


def solve(maze):
    """Solve puzzle."""
    min_steps = inf
    key_posns = find_key_posns(maze)
    key_count = len(key_posns) - 1
    graph = build_graph(maze, key_posns)
    topo, indegree = build_topo_graph(graph)
    queue = deque()
    queue.append(("@", 0, list(indegree), 0))
    indegree[-1] = -1
    visited = {}
    while queue:
        key, steps, current_indegree, keys_gathered = queue.popleft()
        if steps > min_steps:
            continue
        state_key = (key, tuple(current_indegree))
        if state_key in visited and steps > visited[state_key]:
            print("repeat...")
            continue
        if keys_gathered == key_count:
            if steps < min_steps:
                min_steps = steps
        for neighbor, neighbor_steps, _ in graph[key]:
            neighbor_index = key_index(neighbor)
            if current_indegree[neighbor_index] == 0:
                next_indegree = list(current_indegree)
                next_indegree[neighbor_index] -= 1 # visited
                for blocked in topo[neighbor]:
                    blocked_index = key_index(blocked)
                    next_indegree[blocked_index] -= 1
                next_steps = neighbor_steps + steps
                queue.append((neighbor, next_steps, next_indegree, keys_gathered + 1))

    return min_steps

def main():
    """Main program."""
    import sys
    sys.setrecursionlimit(10000000)
    maze = [line.strip() for line in sys.stdin.readlines()]
    print(solve(maze))

if __name__ == '__main__':
    main()
