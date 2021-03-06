#!/usr/bin/env bash

#Orginally made by tpenguinltg
#Minor edits have been made by Speedy905 (me)

destination="/mnt/backup"
passphrase_check_file="${destination}/passphrase_check"

# needs root privileges to run
if [ $(id -u) -ne 0 ]; then
  echo Rerunning as root...
  exec sudo "$0" "$@"
fi

# Proceed with backup only if backum medium is present
if [ ! -d "$destination" ]; then
  echo 'ERROR: Backup medium not found!' >&2;
  exit 1
fi

if [ -z "$PASSPHRASE" ]; then
  stty -echo
  printf 'Passphrase: '
  IFS= read -r PASSPHRASE
  export PASSPHRASE
  echo

  if ! [ -r "${passphrase_check_file}" ]; then
    printf 'Passphrase (confirm): '
    IFS= read -r confirm_passphrase
    echo

    if [ "$PASSPHRASE" != "$confirm_passphrase" ]; then
      echo "ERROR: Passphrases do not match. Aborting." >&2
      stty echo
      exit 1
    fi
    unset confirm_passphrase

    </dev/urandom tr -dc 'A-Za-z0-9' | head -c 16 | gpg --batch --symmetric --passphrase-fd 3 -o "${passphrase_check_file}" 3<<<"$PASSPHRASE"
  fi
  stty echo
fi

gpg --batch --decrypt --passphrase-fd 3 "${passphrase_check_file}" 3<<<"$PASSPHRASE" >/dev/null 2>&1 || { echo "ERROR: Incorrect passphrase." >&2; exit 1; }

exit_status=

# bit field:
# 4: system files
# 8: crontabs
# 16: user data
failed=0

# System files
echo Backing up system files...
[ -d "$destination/system" ] || mkdir "$destination/system"
duplicity --full-if-older-than 3M --verbosity info --asynchronous-upload / --exclude-if-present .nobackup --include /etc --include /var/lib/pacman/local --include /boot --include /efi --exclude '**' "file://$destination/system"
exit_status=$?
if [ $exit_status -eq 0 ]; then
  echo System files backup complete.
else
  failed=$((failed + 4))
  echo System files backup aborted.
fi

sync

if [ $exit_status -eq 0 ]; then # Remove old backups
  echo Removing old full system backups...
  duplicity remove-all-but-n-full 2 --force "file://$destination/system"
  echo Removed old full system backups.
fi

sync

# Crontabs
# crontabs in /etc are already backed up in system backup
echo Backing up user crontabs...
[ -d "$destination/crontabs" ] || mkdir "$destination/crontabs"
duplicity --full-if-older-than 3M --verbosity info --asynchronous-upload / --exclude-if-present .nobackup --include /etc --include /var/spool/cron --exclude '**' "file://$destination/crontabs"
exit_status=$?
if [ $exit_status -eq 0 ]; then
  echo User crontab backup complete.
else
  failed=$((failed + 8))
  echo User crontab backup aborted.
fi

sync

if [ $exit_status -eq 0 ]; then # Remove old backups
  echo Removing old full user crontab backups...
  duplicity remove-all-but-n-full 2 --force "file://$destination/crontabs"
  echo Removed old full user crontab backups.
fi

sync

# User data
echo Backing up user data...
[ -d "$destination/data" ] || mkdir "$destination/data"
duplicity --full-if-older-than 3M --verbosity info --asynchronous-upload / --exclude-if-present .nobackup --include /home --exclude '**' --exclude-other-filesystems "file://$destination/data"
exit_status=$?
if [ $exit_status -eq 0 ]; then
  echo User data backup complete.
else
  failed=$((failed + 16))
  echo User data backup aborted.
fi

sync

if [ $exit_status -eq 0 ]; then # Remove old backups
  echo Removing old full user data backups...
  duplicity remove-all-but-n-full 2 --force "file://$destination/data"
  echo Removed old full user data backups.
fi

sync

echo Backup complete.
unset PASSPHRASE
exit $failed
