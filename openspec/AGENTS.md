# Edgebox specification workflow

Read the repository `AGENTS.md` first. This directory uses OpenSpec-lite:

- `specs/<capability>/spec.md` describes accepted, delivered behavior.
- `changes/<verb-led-id>/proposal.md` records scope and in-file disposition.
- Each change carries `tasks.md`, scenario-based deltas under
  `specs/<capability>/spec.md`, and a journey or an explicit no-new-UI reason.
- Cross-cutting or security work also carries `design.md` with decisions.
- Product requirements remain change deltas until their implementation lands.
  An accepted architecture document does not mean its application behavior exists.
- Read preparation notes and dependency artifacts before starting descendants.
  Architecture needs an independent review before implementation. For this
  session the user selected Astra and suspended the cross-family requirement;
  the reader must still be a fresh agent distinct from the author.
- Checked tasks describe completed work owned by that change. Deferred work is
  a named handoff, not a permanently open checkbox in an unrelated change.

Never rewrite existing migrations or claim unimplemented behavior as built.
