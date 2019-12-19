"""
Advent of Code 2019 :: Day 18 :: Many-Worlds Interpretation
https://adventofcode.com/2019/day/18
"""
from collections import defaultdict, deque
from math import inf

def neighborhood(posn):
    """Return adjacent positions."""
    row, col = posn
    return ((row + 1, col), (row - 1, col), (row, col + 1), (row, col - 1))

def find_nodes(maze):
    """Find all the nodes and their positions in the maze."""
    nodes = {}
    for row_index, row in enumerate(maze):
        for col_index, cell in enumerate(row):
            if cell.islower() or cell.isupper() or cell == "@":
                nodes[cell] = (row_index, col_index)
    return nodes

def maze_to_graph(maze, nodes):
    """Build a graph based on map."""
    graph = defaultdict(list)
    for start in nodes:
        queue = deque()
        queue.append((nodes[start], 0))
        visited = {}
        visited[nodes[start]] = True
        while queue:
            node_posn, node_steps = queue.popleft()
            node_row, node_col = node_posn
            node_cell = maze[node_row][node_col]
            neighbor_steps = node_steps + 1
            for neighbor_posn in neighborhood(node_posn):
                if neighbor_posn in visited:
                    continue
                neighbor_row, neighbor_col = neighbor_posn
                neighbor_cell = maze[neighbor_row][neighbor_col]
                if neighbor_cell == '#':
                    continue
                elif neighbor_cell == '.' or neighbor_cell == '@':
                    queue.append((neighbor_posn, neighbor_steps))
                    visited[neighbor_posn] = True
                elif neighbor_cell.islower() or neighbor_cell.isupper():
                    graph[start].append((neighbor_cell, neighbor_steps))

    return graph
                    
def solve(maze):
    """Solve puzzle."""
    nodes = find_nodes(maze)
    key_count = sum((1 for k in nodes if k.islower()))
    graph = maze_to_graph(maze, nodes)
    starting_state = ('@', frozenset())
    state_steps = {}
    state_steps[starting_state] = 0
    queue = set()
    queue.add(starting_state)
    new_queue = set()

    min_steps = inf
    while queue:
        for state in queue:
            node, keys_found = state
            if state_steps[state] >= min_steps:
                continue
            if len(keys_found) == key_count:
                min_steps = state_steps[state]
            for neighbor, neighbor_steps in graph[node]:
                next_keys_found = keys_found
                if neighbor.islower():
                    next_keys_found = next_keys_found.union([neighbor])
                elif neighbor.isupper():
                    if neighbor.lower() not in next_keys_found:
                        continue
                next_state = (neighbor, next_keys_found)
                next_steps = state_steps[state] + neighbor_steps
                if next_state not in state_steps:
                    state_steps[next_state] = next_steps
                    new_queue.add(next_state)
                elif next_steps < state_steps[next_state]:
                    state_steps[next_state] = next_steps
                    new_queue.add(next_state)
        queue = new_queue
        new_queue = set()

    return min_steps

def main():
    """Main program."""
    import sys
    maze = [line.strip() for line in sys.stdin]
    print('The solution to part 1 is', solve(maze))

if __name__ == '__main__':
    main()
