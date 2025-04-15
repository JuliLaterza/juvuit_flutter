from rich.console import Console
from rich.tree import Tree
import os

def build_tree(path: str, tree: Tree, max_depth: int, current_depth: int = 0):
    if current_depth >= max_depth:
        return
    try:
        entries = sorted(os.listdir(path))
        for entry in entries:
            full_path = os.path.join(path, entry)
            if os.path.isdir(full_path):
                branch = tree.add(f"[bold blue]{entry}/")
                build_tree(full_path, branch, max_depth, current_depth + 1)
            else:
                tree.add(f"[green]{entry}")
    except PermissionError:
        pass

console = Console()
root_path = "/Users/jlaterza/Documents/workspace/juvuit_flutter"  # ruta raíz del proyecto Flutter
tree = Tree(f"[bold magenta]{os.path.basename(os.path.abspath(root_path))}/")
build_tree(root_path, tree, max_depth=4)  # podés ajustar el nivel

console.print(tree)
