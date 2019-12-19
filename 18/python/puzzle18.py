"""
Advent of Code 2019 :: Day 18 :: Many-Worlds Interpretation
https://adventofcode.com/2019/day/18
"""
from collections import defaultdict, deque
from math import inf

def is_key(cell):
    return cell.islower()

def is_door(cell):
    return cell.isupper()

def is_start(cell):
    return cell == '@' or cell.isnumeric()

def is_open(cell):
    return cell == '.'

def is_wall(cell):
    return cell == '#'

def is_node(cell):
    return is_key(cell) or is_door(cell) or is_start(cell)

def neighborhood(posn):
    """Return adjacent positions."""
    row, col = posn
    return ((row + 1, col), (row - 1, col), (row, col + 1), (row, col - 1))

def find_nodes(maze):
    """Find all the nodes and their positions in the maze."""
    nodes = {}
    for row_index, row in enumerate(maze):
        for col_index, cell in enumerate(row):
            if is_node(cell):
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
                if is_wall(neighbor_cell):
                    continue
                elif is_open(neighbor_cell) or is_start(neighbor_cell):
                    queue.append((neighbor_posn, neighbor_steps))
                    visited[neighbor_posn] = True
                elif neighbor_cell.islower() or neighbor_cell.isupper():
                    graph[start].append((neighbor_cell, neighbor_steps))

    return graph
                    
def solve_part1(maze):
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

def solve_part2(maze):
    """Solve puzzle."""
    nodes = find_nodes(maze)
    key_count = sum((1 for k in nodes if k.islower()))
    graph = maze_to_graph(maze, nodes)
    starting_state = (('1', '2', '3', '4'), frozenset())
    state_steps = {}
    state_steps[starting_state] = 0
    queue = set()
    queue.add(starting_state)
    new_queue = set()

    min_steps = inf
    while queue:
        for state in queue:
            robot_nodes, keys_found = state
            if state_steps[state] >= min_steps:
                continue
            if len(keys_found) == key_count:
                min_steps = state_steps[state]

            # Each robot can move.
            for robot in range(4):
                robot_node = robot_nodes[robot]
                for neighbor, neighbor_steps in graph[robot_node]:
                    next_keys_found = keys_found
                    if neighbor.islower():
                        next_keys_found = next_keys_found.union([neighbor])
                    elif neighbor.isupper():
                        if neighbor.lower() not in next_keys_found:
                            continue

                    next_robot_nodes = list(robot_nodes)
                    next_robot_nodes[robot] = neighbor
                    next_state = (tuple(next_robot_nodes), next_keys_found)
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

def update_maze(maze):
    """Update maze to make four vaults."""
    start_posn = None
    for row_index, row in enumerate(maze):
        for col_index, cell in enumerate(row):
            if is_start(cell):
                start_posn = (row_index, col_index)
                break

    row_index, col_index = start_posn
    row_data = list(maze[row_index - 1])
    row_data[col_index - 1] = '1'
    row_data[col_index] = '#'
    row_data[col_index + 1] = '2'
    maze[row_index - 1] = "".join(row_data)

    row_data = list(maze[row_index])
    row_data[col_index - 1] = '#'
    row_data[col_index] = '#'
    row_data[col_index + 1] = '#'
    maze[row_index] = "".join(row_data)

    row_data = list(maze[row_index + 1])
    row_data[col_index - 1] = '3'
    row_data[col_index] = '#'
    row_data[col_index + 1] = '4'
    maze[row_index + 1] = "".join(row_data)

def main():
    """Main program."""
    import sys
    maze = [line.strip() for line in sys.stdin]
    soln1 = solve_part1(maze)
    print(f'The solution to part 1 is {soln1}.' )
    update_maze(maze)
    soln2 = solve_part2(maze)
    print(f'The solution to part 2 is {soln2}.' )

    assert soln1 == 6098
    assert soln2 == 1698

if __name__ == '__main__':
    main()
