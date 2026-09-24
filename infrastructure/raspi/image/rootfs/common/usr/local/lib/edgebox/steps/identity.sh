#!/usr/bin/env bash
set -Eeuo pipefail
source /usr/local/lib/edgebox/common.sh

hostnamectl set-hostname "$EDGEBOX_HOSTNAME"
ln -snf "/usr/share/zoneinfo/$EDGEBOX_TIMEZONE" /etc/localtime
printf '%s\n' "$EDGEBOX_TIMEZONE" > /etc/timezone
if ! getent passwd "$EDGEBOX_USER" >/dev/null; then
  useradd --create-home --shell /bin/bash --groups sudo "$EDGEBOX_USER"
fi
printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$EDGEBOX_USER" > /etc/sudoers.d/90-edgebox-user
chmod 0440 /etc/sudoers.d/90-edgebox-user
install -d -m 0700 -o "$EDGEBOX_USER" -g "$EDGEBOX_USER" "/home/$EDGEBOX_USER/.ssh"
printf '%s\n' "$EDGEBOX_SSH_PUBLIC_KEY" > "/home/$EDGEBOX_USER/.ssh/authorized_keys"
chown "$EDGEBOX_USER:$EDGEBOX_USER" "/home/$EDGEBOX_USER/.ssh/authorized_keys"
chmod 0600 "/home/$EDGEBOX_USER/.ssh/authorized_keys"
ssh-keygen -A
install -d -m 0755 /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/20-edgebox-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
EOF
sshd -t
systemctl enable ssh

if ! grep -q "^${EDGEBOX_LOCALE} " /etc/locale.gen; then
  printf '%s UTF-8\n' "$EDGEBOX_LOCALE" >> /etc/locale.gen
fi
locale-gen "$EDGEBOX_LOCALE"
update-locale LANG="$EDGEBOX_LOCALE"
printf '%s\n' "$EDGEBOX_KEYMAP" > /etc/default/keyboard.edgebox
