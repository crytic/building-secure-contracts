# Lottery

## Trap
Unitialized structs default to acting like storage pointers, allowing the owner
to use the `Seecomponent s` variable to overwrite private variables.
