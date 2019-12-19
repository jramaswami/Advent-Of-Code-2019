"""
Advent of Code 2019 :: Day 18 :: Many-Worlds Interpretation
https://adventofcode.com/2019/day/18
"""
from collections import deque, defaultdict
from itertools import permutations
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


def find_nodes(maze):
    """
    Returns a dictionary of key, door, and start positions.
    """
    key_posns = {}
    for row_index, row in enumerate(maze):
        for col_index, cell in enumerate(row):
            if is_key(cell) or is_door(cell) or cell == "@":
                key_posns[cell] = (row_index, col_index)
    return key_posns


def build_graph(maze, nodes):
    """Transform maze into a graph."""
    graph = defaultdict(list)
    for node_name, node_posn in nodes.items():
        queue = deque([(node_posn, 0)])
        visited = set()
        visited.add(node_posn)
        while queue:
            posn, steps = queue.popleft()
            steps += 1
            for neighbor in neighborhood(posn):
                if neighbor in visited:
                    continue
                cell = maze_get(maze, neighbor)
                if is_wall(cell):
                    continue
                if is_door(cell):
                    graph[node_name].append((cell, steps))
                    continue
                if is_key(cell):
                    graph[node_name].append((cell, steps))
                    continue
                queue.append((neighbor, steps))
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


def find_visible_nodes(graph, start):
    """Find the doors visible from start."""
    visible_keys = []
    visible_doors = []
    queue = deque()
    queue.append(start)
    visited = set()
    visited.add(start)
    while queue:
        node = queue.popleft()
        for neighbor, _ in graph[node]:
            if neighbor in visited:
                continue
            if is_door(neighbor):
                visible_doors.append(neighbor)
                continue

            visible_keys.append(neighbor)
            visited.add(neighbor)

    return visible_keys, visible_doors


def bfs(graph, start, keys_picked_up, distance_between, keys_needed):
    """
    Go from start to every other node, caching keys picked
    up and the distance between the nodes.
    """
    queue = deque()
    queue.append((start, 0, set(), set()))
    visited = {}
    visited[start] = True

    while queue:
        node, steps, keys, doors = queue.popleft()
        for neighbor, neighbor_steps in graph[node]:
            if neighbor not in visited:
                distance = steps + neighbor_steps
                distance_between[start][neighbor] = distance
                neighbor_keys = keys.copy()
                neighbor_doors = doors.copy()
                if is_key(neighbor):
                    neighbor_keys.add(neighbor)
                if is_door(neighbor):
                    neighbor_doors.add(neighbor.lower())
                keys_picked_up[start][neighbor] = neighbor_keys
                keys_needed[start][neighbor] = neighbor_doors
                visited[neighbor] = True
                queue.append((neighbor, neighbor_steps, neighbor_keys, neighbor_doors))

def solve(maze):
    """Solve puzzle."""
    nodes = find_nodes(maze)
    graph = build_graph(maze, nodes)

    keys_picked_up = defaultdict(lambda: defaultdict(set))
    distance_between = defaultdict(lambda: defaultdict(int))
    keys_needed = defaultdict(lambda: defaultdict(set))

    for node in nodes:
        bfs(graph, node, keys_picked_up, distance_between, keys_needed)

    for node1 in nodes:
        for node2 in nodes:
            if node1 == node2:
                continue
            print(node1, node2, 
                    distance_between[node1][node2], 
                    keys_picked_up[node1][node2],
                    keys_needed[node1][node2])



    #visible_keys, visible_doors = find_visible_nodes(graph, "@")
    #print(visible_keys)
    #print(visible_doors)

def main():
    """Main program."""
    import sys
    sys.setrecursionlimit(10000000)
    maze = [line.strip() for line in sys.stdin.readlines()]
    print(solve(maze))

if __name__ == '__main__':
    main()
