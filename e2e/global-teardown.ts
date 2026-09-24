import { rmSync } from 'node:fs';

export default function teardown() {
	const directory = process.env.EDGEBOX_E2E_DATABASE_DIRECTORY;
	if (directory) rmSync(directory, { recursive: true, force: true });
}
