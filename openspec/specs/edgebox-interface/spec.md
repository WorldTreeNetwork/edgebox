# Edgebox interface

## Requirements

### Requirement: Reusable capability-first interface components

The interface kit SHALL expose server-agnostic components that routes can
compose from catalog DTO display fields and callbacks, without deciding
visibility, authorization, or provider resolution.

#### Scenario: A member chooses a provider

- GIVEN a route supplies eligible provider display records
- WHEN the member selects a provider and asks to open or save it
- THEN the component emits only the selected identifier through its callback
- AND pending and failure states preserve the selection without duplicate save.

#### Scenario: A guest opens the navigation menu

- GIVEN Edgebox renders at a narrow width
- WHEN the guest opens and dismisses the labeled navigation dialog with Escape
- THEN focus returns to the menu trigger and the guest sign-in action remains
  available.

### Requirement: Identity and settings primitives remain server-agnostic

The interface kit SHALL provide composable account, login, passkey, and
preferred-app controls whose props express display state and whose callbacks
emit user intent, without establishing a session or mutating a preference.

#### Scenario: A member corrects an invalid passkey name

- GIVEN the route supplies a passkey record
- WHEN the member submits an empty rename value
- THEN the dialog retains the input, associates an inline error with its field,
  and permits cancellation with focus returned to its trigger.

#### Scenario: A final passkey lacks recovery

- GIVEN a route declares the credential final and no verified Identikey
  recovery path exists
- WHEN the member opens the removal confirmation
- THEN the destructive action is unavailable with a clear explanation.
