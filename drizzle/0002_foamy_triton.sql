CREATE TABLE `catalog_application` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`summary` text NOT NULL,
	`kind` text NOT NULL,
	`visibility` text NOT NULL,
	`enabled` integer DEFAULT true NOT NULL,
	`setup_notice` text
);
--> statement-breakpoint
CREATE INDEX `catalog_application_visibility_idx` ON `catalog_application` (`visibility`);--> statement-breakpoint
CREATE TABLE `catalog_application_category` (
	`application_id` text NOT NULL,
	`category_id` text NOT NULL,
	PRIMARY KEY(`application_id`, `category_id`),
	FOREIGN KEY (`application_id`) REFERENCES `catalog_application`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`category_id`) REFERENCES `catalog_category`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE TABLE `catalog_capability` (
	`id` text PRIMARY KEY NOT NULL,
	`label` text NOT NULL,
	`summary` text NOT NULL,
	`category_id` text NOT NULL,
	`display_order` integer NOT NULL,
	`default_application_id` text,
	FOREIGN KEY (`category_id`) REFERENCES `catalog_category`(`id`) ON UPDATE no action ON DELETE restrict,
	FOREIGN KEY (`default_application_id`) REFERENCES `catalog_application`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE INDEX `catalog_capability_category_idx` ON `catalog_capability` (`category_id`);--> statement-breakpoint
CREATE TABLE `catalog_capability_provider` (
	`id` text PRIMARY KEY NOT NULL,
	`capability_id` text NOT NULL,
	`application_id` text NOT NULL,
	`launch_endpoint_id` text,
	FOREIGN KEY (`capability_id`) REFERENCES `catalog_capability`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`application_id`) REFERENCES `catalog_application`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`launch_endpoint_id`) REFERENCES `catalog_endpoint`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE UNIQUE INDEX `catalog_capability_provider_pair_unique` ON `catalog_capability_provider` (`capability_id`,`application_id`);--> statement-breakpoint
CREATE INDEX `catalog_capability_provider_application_idx` ON `catalog_capability_provider` (`application_id`);--> statement-breakpoint
CREATE TABLE `catalog_category` (
	`id` text PRIMARY KEY NOT NULL,
	`label` text NOT NULL,
	`display_order` integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE `catalog_endpoint` (
	`id` text PRIMARY KEY NOT NULL,
	`application_id` text NOT NULL,
	`purpose` text NOT NULL,
	`address` text NOT NULL,
	`enabled` integer DEFAULT true NOT NULL,
	FOREIGN KEY (`application_id`) REFERENCES `catalog_application`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `catalog_endpoint_application_idx` ON `catalog_endpoint` (`application_id`);--> statement-breakpoint
CREATE TABLE `catalog_preferred_provider` (
	`user_id` text NOT NULL,
	`capability_id` text NOT NULL,
	`provider_association_id` text NOT NULL,
	PRIMARY KEY(`user_id`, `capability_id`),
	FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`capability_id`) REFERENCES `catalog_capability`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`provider_association_id`) REFERENCES `catalog_capability_provider`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `catalog_preferred_provider_association_idx` ON `catalog_preferred_provider` (`provider_association_id`);
--> statement-breakpoint
-- Curated Edgebox inventory observed in deployment notes on 2026-09-21.
-- These stable IDs are intentionally seeded once; later migrations must not
-- overwrite operator edits or member preferences.
INSERT INTO `catalog_category` (`id`, `label`, `display_order`) VALUES
	('development', 'Development', 10),
	('personal', 'Personal', 20),
	('productivity', 'Productivity', 30),
	('documents', 'Documents', 40),
	('files', 'Files', 50),
	('media', 'Media', 60)
ON CONFLICT(`id`) DO NOTHING;
--> statement-breakpoint
INSERT INTO `catalog_application` (`id`, `name`, `summary`, `kind`, `visibility`, `enabled`, `setup_notice`) VALUES
	('forgejo', 'Forgejo', 'Host and collaborate on code repositories.', 'application', 'public', true, NULL),
	('vaultwarden', 'Vaultwarden', 'Manage passwords in your own vault.', 'application', 'public', true, 'Setup needed: configure trusted HTTPS before storing real credentials.'),
	('vikunja', 'Vikunja', 'Plan and manage tasks.', 'application', 'public', true, NULL),
	('stirling-pdf', 'Stirling PDF', 'Work with PDF documents.', 'application', 'public', true, NULL),
	('file-browser', 'File Browser', 'Browse files using its own access controls.', 'application', 'public', true, NULL),
	('navidrome', 'Navidrome', 'Listen to your music library.', 'application', 'public', true, NULL),
	('jellyfin', 'Jellyfin', 'Watch your video library.', 'application', 'public', true, NULL),
	('radarr', 'Radarr', 'Movie-library support service.', 'infrastructure', 'operator', true, NULL),
	('sonarr', 'Sonarr', 'TV-library support service.', 'infrastructure', 'operator', true, NULL),
	('lidarr', 'Lidarr', 'Music-library support service.', 'infrastructure', 'operator', true, NULL),
	('sabnzbd', 'SABnzbd', 'Download support service.', 'infrastructure', 'operator', true, NULL),
	('flaresolverr', 'FlareSolverr', 'Network support service.', 'infrastructure', 'operator', true, NULL),
	('transmission', 'Transmission', 'Download support service.', 'infrastructure', 'operator', true, NULL),
	('prowlarr', 'Prowlarr', 'Indexer support service.', 'infrastructure', 'operator', true, NULL),
	('gluetun', 'Gluetun', 'Network privacy support service.', 'infrastructure', 'operator', true, NULL),
	('caddy', 'Caddy', 'Edge web proxy service.', 'infrastructure', 'operator', true, NULL),
	('dnsmasq', 'dnsmasq', 'Local DNS and DHCP service.', 'infrastructure', 'operator', true, NULL),
	('docker', 'Docker', 'Container runtime.', 'infrastructure', 'operator', true, NULL),
	('tailscale', 'Tailscale', 'Private network service.', 'infrastructure', 'operator', true, NULL)
ON CONFLICT(`id`) DO NOTHING;
--> statement-breakpoint
INSERT INTO `catalog_application_category` (`application_id`, `category_id`) VALUES
	('forgejo', 'development'), ('vaultwarden', 'personal'), ('vikunja', 'productivity'),
	('stirling-pdf', 'documents'), ('file-browser', 'files'), ('navidrome', 'media'),
	('jellyfin', 'media')
ON CONFLICT(`application_id`, `category_id`) DO NOTHING;
--> statement-breakpoint
INSERT INTO `catalog_endpoint` (`id`, `application_id`, `purpose`, `address`, `enabled`) VALUES
	('forgejo-launch', 'forgejo', 'launch', 'http://192.168.0.90:3000', true),
	('forgejo-ssh', 'forgejo', 'ssh', '192.168.0.90:2222', true),
	('vaultwarden-launch', 'vaultwarden', 'launch', 'http://192.168.0.90:8222', true),
	('vikunja-launch', 'vikunja', 'launch', 'http://192.168.0.90:3456', true),
	('stirling-pdf-launch', 'stirling-pdf', 'launch', 'http://192.168.0.90:8082', true),
	('file-browser-launch', 'file-browser', 'launch', 'http://192.168.0.90:8080', true),
	('navidrome-launch', 'navidrome', 'launch', 'http://192.168.0.90:4533', true)
ON CONFLICT(`id`) DO NOTHING;
--> statement-breakpoint
INSERT INTO `catalog_capability` (`id`, `label`, `summary`, `category_id`, `display_order`, `default_application_id`) VALUES
	('host-code', 'Host code', 'Create and collaborate on code repositories.', 'development', 10, 'forgejo'),
	('manage-passwords', 'Manage passwords', 'Store and retrieve passwords in a private vault.', 'personal', 20, 'vaultwarden'),
	('manage-tasks', 'Manage tasks', 'Plan and track tasks.', 'productivity', 30, 'vikunja'),
	('work-with-pdfs', 'Work with PDFs', 'Convert, organize, and work with PDF documents.', 'documents', 40, 'stirling-pdf'),
	('add-a-signature', 'Add a signature', 'Place a signature in a PDF when verified support is available.', 'documents', 50, NULL),
	('browse-files', 'Browse files', 'Browse files through an application with its own access controls.', 'files', 60, 'file-browser'),
	('listen-to-music', 'Listen to music', 'Play music from the local library.', 'media', 70, 'navidrome'),
	('watch-video', 'Watch video', 'Play video from the local library.', 'media', 80, 'jellyfin')
ON CONFLICT(`id`) DO NOTHING;
--> statement-breakpoint
INSERT INTO `catalog_capability_provider` (`id`, `capability_id`, `application_id`, `launch_endpoint_id`) VALUES
	('host-code--forgejo', 'host-code', 'forgejo', 'forgejo-launch'),
	('manage-passwords--vaultwarden', 'manage-passwords', 'vaultwarden', 'vaultwarden-launch'),
	('manage-tasks--vikunja', 'manage-tasks', 'vikunja', 'vikunja-launch'),
	('work-with-pdfs--stirling-pdf', 'work-with-pdfs', 'stirling-pdf', 'stirling-pdf-launch'),
	('browse-files--file-browser', 'browse-files', 'file-browser', 'file-browser-launch'),
	('listen-to-music--navidrome', 'listen-to-music', 'navidrome', 'navidrome-launch'),
	('watch-video--jellyfin', 'watch-video', 'jellyfin', NULL)
ON CONFLICT(`id`) DO NOTHING;
