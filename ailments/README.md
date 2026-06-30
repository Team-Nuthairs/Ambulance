# Ailments
## All files here are examples

Each ailment is a self-contained folder:

```
ailments/
  broken_arm/
	broken_arm.tscn
	broken_arm.gd       <- extends BaseAilment
```

`BaseAilment` lives in `res://scripts/systems/base_ailment.gd`. Extend it, fill in
the four functions, done. You don't need to touch anything outside your own folder.

See CONTRIBUTING.md in the repo root for the full interface and an example.
