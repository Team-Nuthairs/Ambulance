# [Game Name TBD]

A co-op friendslop game where you and up to 2 friends run a private for-profit ambulance
company in a capitalist hellscape. Accept jobs off a DoorDash-style app, drive through
procedurally generated streets, stabilize patients in the back of a moving ambulance, and
charge their credit card at the end. If it declines, that's a different problem.

Inspired by Lethal Company, Repo, and the American healthcare system.

---

## Stack

- **Engine:** Godot 4
- **Renderer:** Vulkan (Forward+)
- **Language:** GDScript (C# if we hit perf walls)
- **Multiplayer:** GodotSteam / Steam Networking Sockets
- **Target platform:** Windows, Linux

---

## Repo structure

This is the **public code repo**. Assets live in a separate private repo (`game-assets`)
and are not included here. See setup instructions below.

```
docs/           Design docs, draw.io diagrams, reference material
src/            GDScript source (mirrored from Godot project structure)
assets/         NOT TRACKED — clone game-assets here (see below)
```

---

## Setup

### Prerequisites

- Godot 4.x (grab from [godotengine.org](https://godotengine.org))
- Git
- Access to the private `game-assets` repo (ask a maintainer)

### Clone and set up

```fish
git clone https://github.com/[org]/[repo-name].git
cd [repo-name]

# Clone assets into place
git clone https://github.com/[org]/game-assets.git assets
```

Open the project in Godot. The editor will re-import assets on first load — this is normal
and takes a minute.

### Godot project settings

Before committing any scenes, make sure your editor is set to serialize scenes and resources
as text:

`Editor > Editor Settings > File Saving > Text Resource Modes` — set to **Text**

This makes `.tscn` and `.tres` files human-readable and mergeable. Binary scenes produce
unsolvable merge conflicts.

---

## Git workflow

`main` is always playable. Don't push broken builds to main.

```
main          always runnable
feature/xyz   your work lives here
fix/xyz       bug fixes
```

1. Branch off main: `git checkout -b feature/your-thing`
2. Commit small and often with clear messages
3. Open a pull request to merge back to main
4. Someone else reviews before it merges (even just a quick look)

New to git? Use GitHub Desktop — it handles everything here without the command line.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full workflow, branch naming conventions,
and how to add new ailments and events (the main contribution path for non-programmers).

---

## Team

| Name | Role |
|------|------|
| TBD | |

---

## License

Source code is licensed under [GPL-3.0](LICENSE). Assets are not included in this repo
and are not open source.
