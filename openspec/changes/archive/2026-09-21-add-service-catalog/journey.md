# No new UI

This change adds no route or reusable component. It supplies data for the
already-defined discovery and provider-preference journeys: server callers pass
an explicit viewer, receive only visible serializable DTOs, and derive a member
preference owner from a trusted session in the later route layer. UI behavior,
focus contracts, and Storybook states remain owned by the interface and
directory changes.
