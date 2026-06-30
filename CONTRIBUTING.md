# Contributing

## For everyone — git basics

If you haven't used git before, install [GitHub Desktop](https://desktop.github.com) or [Fork]{https://git-fork.com/}.
It handles everything below without touching a terminal.

The one rule that matters: **commit small, commit often, with a clear message.**
"Add broken arm ailment scene" is good. "stuff" is not. A week of work in one commit
is painful to review and impossible to roll back cleanly. The more detailed the better.

### Branch naming

```
feature/ambulance-interior-physics
feature/ailment-broken-arm
fix/traffic-siren-response
art/billboard-textures
```

---

## For programmers

We use Godot 4 with GDScript.

Core systems (proc-gen streets, traffic, multiplayer) live in `src/systems/`.
Don't refactor other people's systems without talking first.

Performance-sensitive code gets a comment explaining why it's written the way it is.

---

## Adding ailments and events

Ailments and events are self-contained Godot scenes. You don't need to touch any core
systems to add one. The pattern is:

```
res://ailments/
  broken_arm/
    broken_arm.tscn     — the scene
    broken_arm.gd       — logic (extend BaseAilment)
  overdose/
    ...
```

### BaseAilment interface WIP

Your ailment script extends `BaseAilment` and implements:

```gdscript
extends BaseAilment

func get_display_name() -> String:
    return "Broken Arm"

func get_severity() -> int:
    return 2  # 1 low, 2 medium, 3 high

func on_treatment_step(tool: String) -> TreatmentResult:
    # called when player uses a tool on the patient
    # return TreatmentResult.SUCCESS / FAIL / CRITICAL_FAIL
    pass

func get_tip_modifier() -> float:
    # return a multiplier on the final tip (0.0 - 1.5)
    return 1.0
```

Full documentation and a template scene are in `docs/ailment-template/`.

### Events

Events are things that happen during a job — traffic, patient behavior, environmental.
Same pattern, extend `BaseEvent`, lives in `res://events/`.

---

## What not to do

- Don't commit the `assets/` directory or anything from it
- Don't push directly to `main`
- Don't merge your own PR without a second pair of eyes
