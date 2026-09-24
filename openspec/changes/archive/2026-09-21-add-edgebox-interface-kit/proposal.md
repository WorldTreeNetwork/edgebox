# add-edgebox-interface-kit

> **ACTIVE BUILD**

## Why

Routes need a small, consistent UI vocabulary before they bind catalog data and
mutations. Edgebox should feel like a calm household utility: action-first,
honest about service state, and usable by a guest without exposing private data.

## What

- Add server-agnostic Svelte components for the shell, discovery, provider
  choice, application inspection, operator observations, account menu, login,
  passkey settings, and preferred-app reset feedback.
- Add Storybook stories for the journey states the route work will compose.
- Add focused browser proofs for keyboard/focus and state-changing callbacks.

## Out of scope

- Routes, server loading, catalog filtering, authorization, preference writes,
  health checks, and identity/passkey runtime behavior.
- A canonical catalog DTO: the catalog descendant owns that shared contract.

## Primitive policy

Controls use native semantic HTML where it supplies the full behavior contract:
links, buttons, GET forms, inputs, radio groups, and the platform `<dialog>`
primitive. This is the closest accessible primitive available in the starter;
the dialog provides modal focus, Escape dismissal, and focus restoration without
adding a parallel interaction library.
