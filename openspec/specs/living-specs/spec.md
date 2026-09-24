# Living specification discipline

## Requirements

### Requirement: Separate delivered behavior from proposed behavior

Living product specifications SHALL describe delivered behavior. Proposed
behavior SHALL remain in an explicitly disposed change until implementation
and its relevant verification have landed.

#### Scenario: Architecture is accepted before application implementation

- GIVEN an accepted architecture change with dependent implementation nodes
- WHEN recording its outcome
- THEN the architecture may be cited as a dependency artifact
- AND dependent application behavior remains proposed until delivered.

### Requirement: Preserve a reviewable requirement history

Changes SHALL use ADDED, MODIFIED, or REMOVED requirement sections with named
scenarios. MODIFIED requirements SHALL include their complete replacement text.

#### Scenario: A capability changes

- GIVEN an existing living requirement
- WHEN proposing a behavior change
- THEN the delta identifies the capability and complete changed requirement
- AND the associated proposal identifies the affected user surfaces.
