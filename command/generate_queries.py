from pathlib import Path


def run(data):
    scripts_path = Path("scripts/queries")
    scripts_path.mkdir(parents=True, exist_ok=True)
    target_path = Path("scripts/queries.sql")
    contents = list()

    for child in scripts_path.iterdir():
        if child.is_file():
            with open(child) as f:
                content = f.readlines()
                content.insert(0, f"-- table: {child.name}\n")
                print(content)
                contents.append(content)

    with open(target_path, "w") as f:
        for file in contents:
            for line in file:
                f.write(f"{line}")
            f.write("\n\n\n")
