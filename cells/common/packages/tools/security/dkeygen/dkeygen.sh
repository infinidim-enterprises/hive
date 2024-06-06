#!/usr/bin/env bash

KEYID=""
KEYGRIP=""
KEYFNAME_PUBLIC=""

: "${PGP_CARD_ADMIN_PIN:=12345678}" \
  "${PGP_CARD_USER_PIN:=123456}" \
  "${KEY_PUBLIC_PARTS_DIR:=${HOME}/pgp_keys}" \
  "${KEYTIME:=1970-01-02 00:00:00}" \
  "${KEYTYPE:=rsa4096}" \
  "${WORDLIST:=$(dirname "${0}")/bip39-english.txt}" \
  "${GNUPGHOME:=${HOME}/.gnupg}"

GPG_TTY=$(tty)
export GPG_TTY

ncurses_load_colors() {
  # normal=$'\e[0m'                         # (works better sometimes)
  normal=$(tput sgr0)        # normal text
  bold=$(tput bold)          # make colors bold/bright
  red="$bold$(tput setaf 1)" # bright red text
  green=$(tput setaf 2)      # dim green text
  fawn=$(tput setaf 3)
  beige="$fawn"            # dark yellow text
  yellow="$bold$fawn"      # bright yellow text
  darkblue=$(tput setaf 4) # dim blue text
  blue="$bold$darkblue"    # bright blue text
  purple=$(tput setaf 5)
  magenta="$purple"               # magenta text
  pink="$bold$purple"             # bright magenta text
  darkcyan=$(tput setaf 6)        # dim cyan text
  cyan="$bold$darkcyan"           # bright cyan text
  gray=$(tput setaf 7)            # dim white text
  darkgray="$bold"$(tput setaf 0) # bold black = dark gray text
  white="$bold$gray"              # bright white text

  # echo "${red}hello ${yellow}this is ${green}coloured${normal}"
}

pgp_key_private_revocation_cert() {
  if "${DEBUG}"; then
    echo "${red}pgp_key_private_revocation_cert${normal}"
  fi

  local COMMAND_LINE
  COMMAND_LINE="gpg --output ${KEY_PUBLIC_PARTS_DIR}/${KEYID}_revocation.asc --generate-revocation ${KEYID}"

  expect <<-DONE | sed 's/^  //'
  set timeout 90
  spawn $COMMAND_LINE

  expect "Create a revocation certificate for this key? (y/N) "
  send -- "y\r"

  expect "Your decision? "
  send -- "0\r"

  expect "> "
  send -- "Desc \r"

  expect "Is this okay? (y/N) "
  send -- "y\r"
DONE

  qrencode -o "${KEY_PUBLIC_PARTS_DIR}/${KEYID}_revocation.png" -l H -t PNG <"${KEY_PUBLIC_PARTS_DIR}/${KEYID}_revocation.asc"
}

pgp_key_public_import() {
  if "${DEBUG}"; then
    echo "${red}pgp_key_public_import${normal}"
  fi

  echo "${yellow}Importing public key...${normal}"

  systemctl --user list-unit-files | grep gpg- | grep -v '.service' | awk '{ print $1 }' | xargs systemctl --user start
  gpg --import "${KEYFNAME_PUBLIC}"
  echo "${KEYID}:6:" | gpg --import-ownertrust
}

pgp_key_private_remove() {
  if "${DEBUG}"; then
    echo "${red}pgp_key_private_remove${normal}"
  fi

  echo "${yellow}Removing private key and resetting gpg...${normal}"
  systemctl --user | grep gpg- | awk '{ print $1 }' | xargs systemctl --user stop
  find "${GNUPGHOME}" -not -type l -delete || true
}

pgp_subkeys_private_move_to_card() {
  if "${DEBUG}"; then
    echo "${red}pgp_subkeys_private_move_to_card${normal}"
  fi

  local COMMAND_LINE
  COMMAND_LINE="gpg --pinentry-mode loopback --expert --edit-key ${KEYID}"

  gpg --card-status

  expect <<-DONE | sed 's/^  //'
  set timeout 90

  spawn $COMMAND_LINE

  # Select Signature key
  expect "gpg> "
  send -- "key 1\r"

  expect "gpg> "
  send -- "keytocard\r"

  expect "Your selection? "
  send -- "1\r"

  # expect "Enter passphrase: "
  # send -- "${PGP_CARD_ADMIN_PIN}\r"

  # Deselect all keys
  expect "gpg> "
  send -- "key\n"

  # Select Encryption key
  expect "gpg> "
  send -- "key 2\r"

  expect "gpg> "
  send -- "keytocard\r"

  expect "Your selection? "
  send -- "2\r"

  # Deselect all keys
  expect "gpg> "
  send -- "key\n"

  # Select Authentication key
  expect "gpg> "
  send -- "key 3\r"

  expect "gpg> "
  send -- "keytocard\r"

  expect "Your selection? "
  send -- "3\r"

  # Delete Signature, Encryption and Authentication subkeys
  expect "gpg> "
  send -- "save\n"

  expect eof
DONE
}

ssh_key_public_export() {
  if "${DEBUG}"; then
    echo "${red}ssh_key_public_export${normal}"
  fi

  echo "${KEYGRIP}" >>"${GNUPGHOME}/sshcontrol"
  ssh-add -L >"${KEY_PUBLIC_PARTS_DIR}/${KEYID}_ssh_key.pub"
}

pgp_key_public_export() {
  if "${DEBUG}"; then
    echo "${red}pgp_key_public_export${normal}"
  fi

  KEYGRIP=$(gpg --list-public-keys --keyid-format LONG --with-colon --with-keygrip --fingerprint "${UID_EMAIL}" | grep 'grp:' | head -n 1 | awk -F: '{print $10}')
  KEYFNAME_PUBLIC="${KEY_PUBLIC_PARTS_DIR}/${KEYID}_public_key.asc"
  gpg --export -a "${KEYID}" >"${KEYFNAME_PUBLIC}"
}

pgp_key_private_import() {
  if "${DEBUG}"; then
    echo "${red}pgp_key_private_import${normal}"
  fi

  gpg --import "${OUT_KEYFNAME}"
  KEYID=$(gpg --list-secret-keys --keyid-format LONG --with-colon --fingerprint "${UID_EMAIL}" | grep 'fpr:' | head -n 1 | awk -F: '{print $10}')
  echo "${KEYID}:6:" | gpg --import-ownertrust
}

pgp_card_set_owner() {
  if "${DEBUG}"; then
    echo "${red}pgp_card_set_owner${normal}"
  fi

  local COMMAND_LINE
  COMMAND_LINE="gpg --pinentry-mode loopback --edit-card"

  gpg --card-status

  expect <<-DONE | sed 's/^  //'

  set timeout 30

  spawn $COMMAND_LINE

  expect "gpg/card> "
  send -- "admin\r"

  expect "gpg/card> "
  send -- "name\r"

  expect "Cardholder's surname: "
  send -- "${UID_LASTNAME}\r"

  expect "Cardholder's given name: "
  send -- "${UID_FIRSTNAME}\r"

  expect "Enter passphrase: "
  send -- "${PGP_CARD_ADMIN_PIN}\r"

  expect "gpg/card> "
  send -- "login\r"

  expect "Login data (account name): "
  send -- "${UID_EMAIL}\r"

  expect "gpg/card> "
  send -- "lang\r"

  expect "Language preferences: "
  send -- "en\r"

  expect "gpg/card> "
  send -- "salutation\r"

  expect "Salutation (M = Mr., F = Ms., or space): "
  send -- "M\r"

  expect "gpg/card> "
  send -- "quit\r"

  expect eof
DONE
}

pgp_card_set_keyattrs() {
  if "${DEBUG}"; then
    echo "${red}pgp_card_set_keyattrs${normal}"
  fi

  local COMMAND_LINE
  COMMAND_LINE="gpg --pinentry-mode loopback --edit-card"

  gpg --card-status

  expect <<-DONE | sed 's/^  //'
  set timeout 90
  spawn $COMMAND_LINE

  expect "gpg/card> "
  send -- "admin\r"

  expect "gpg/card> "
  send -- "key-attr\r"

  # Signature key
  expect "Your selection? "
  send -- "1\r"

  expect "What keysize do you want? (2048) "
  send -- "4096\r"

  expect "Enter passphrase: "
  send -- "${PGP_CARD_ADMIN_PIN}\r"

  # Encryption key
  expect "Your selection? "
  send -- "1\r"

  expect "What keysize do you want? (2048) "
  send -- "4096\r"

  expect "Enter passphrase: "
  send -- "${PGP_CARD_ADMIN_PIN}\r"

  # Authentication key
  expect "Your selection? "
  send -- "1\r"

  expect "What keysize do you want? (2048) "
  send -- "4096\r"

  expect "Enter passphrase: "
  send -- "${PGP_CARD_ADMIN_PIN}\r"

  expect "gpg/card> "
  send -- "quit\r"

  expect eof
DONE
}

pgp_card_reset() {
  if "${DEBUG}"; then
    echo "${red}pgp_card_reset${normal}"
  fi

  local COMMAND_LINE
  COMMAND_LINE="gpg --edit-card"

  gpg --card-status

  read -n 1 -s -r -p "Press any key to reset openGPG card to factory-defaults..."

  expect <<-DONE | sed 's/^  //'
  set timeout 90
  spawn $COMMAND_LINE

  expect "gpg/card> "
  send -- "admin\r"

  expect "gpg/card> "
  send -- "factory-reset\r"

  expect "Continue? (y/N) "
  send -- "y\r"

  expect "Really do a factory reset? (enter \"yes\") "
  send -- "yes\r"

  expect "gpg/card> "
  send -- "quit\r"

  expect eof
DONE
}

pgp_key_private_generate() {
  if "${DEBUG}"; then
    echo "${red}pgp_key_private_generate${normal}"
  fi

  local COMMAND_LINE
  COMMAND_LINE="generate_derived_key --sigtime ${SIGTIME} --sigexpiry ${SIGEXPIRY} --key-creation ${KEYTIME} --key-type ${KEYTYPE} --name ${UID_NAME_AND_COMMENT} --email ${UID_EMAIL} --output-file ${OUT_KEYFNAME}"

  expect <<-DONE | sed 's/^  //'
  set timeout 90
  spawn $COMMAND_LINE

  expect "Enter recovery seed, or press enter to generate a new key. Recovery seed: "
  send -- "${FULL_SEED[@]}\r"

  expect "Enter mnemonic language: "
  send -- "3\r"

  expect eof
DONE
}

full_seed_create() {
  if "${DEBUG}"; then
    echo "${red}full_seed_create${normal}"
  fi

  for partial_word in "${SEED[@]}"; do
    prefix="${partial_word:0:4}"

    for full_word in "${BIP39[@]}"; do
      if [[ ${full_word:0:4} == "${prefix}" ]]; then
        FULL_SEED+=("${full_word}")
      fi
    done
  done
}

show_report() {
  # revocation cert: ${KEY_PUBLIC_PARTS_DIR}/${KEYID}_revocation.asc
  # revocation cert png: ${KEY_PUBLIC_PARTS_DIR}/${KEYID}_revocation.png

  cat <<-DONE | sed 's/^  //'

  ********************************************************************************
  [ ${KEYID} '${NAME} (${COMMENT})' <${UID_EMAIL}> @${KEYTIME} ]
  private key: rm -rf ${OUT_KEYFNAME}

  keygrip: ${KEYGRIP}
  public key pgp: ${KEYFNAME_PUBLIC}
  public key ssh: ${KEY_PUBLIC_PARTS_DIR}/${KEYID}_ssh_key.pub

  Remember to change the card PINs: gpg --change-pin

  home-manager: services.gpg-agent.sshKeys = [ "${KEYGRIP}" ]
  ********************************************************************************
DONE
}

show_usage() {
  cat <<-DONE | sed 's/^  //'
  $(basename "${0}") version 0.0.1
  Usage: $(basename "${0}") [--seed 'BIP39 mnemonic'] [--sigtime 'Signature time'] [--sigexpiry 'expiry time'] [--name 'Full Name'] [--email 'user@email.com'] [OPTION]...
  Deterministic pgp key generation - https://github.com/summitto/pgp-key-generation

  Not every pgp card *DEFAULT* PINs might be the same:

  PGP_CARD_ADMIN_PIN="${PGP_CARD_ADMIN_PIN}"
  PGP_CARD_USER_PIN="${PGP_CARD_USER_PIN}"

  It's possible to control the output location:

  KEY_PUBLIC_PARTS_DIR="${KEY_PUBLIC_PARTS_DIR}"

[ 95C97641C65C57EB7EFDA3AC09C5E1A8BE99C742 ]
$(basename "${0}") --seed 'clie foot exac plas type spawn tooth spin knee asset found survey apol want ridge chaos pelican seed carpet off group desk cry engage' \\
--sigtime '2023-01-01 00:00:00' \\
--sigexpiry '2043-01-01 00:00:00' \\
--name 'Boobs Lover' \\
--email 'boobs@lover.com' \\
--comment 'Boobies'
DONE
}

args_optional_set() {
  if "${DEBUG}"; then
    echo "${red}args_optional_set${normal}"
  fi

  # create first and last names for card owner info
  read -r -a name_array <<<"${NAME}"
  UID_FIRSTNAME="${name_array[0]}"
  UID_LASTNAME="${name_array[*]:1}"

  # NOTE: Need to escape spaces with '\' for generate_derived_key to parse the args,
  # when invoked with spawn from expect heredoc
  if [[ -n ${COMMENT} ]]; then
    variable="${NAME} (${COMMENT})"
    UID_NAME_AND_COMMENT="${variable// /\\ }"
  else
    variable="${NAME}"
    UID_NAME_AND_COMMENT="${variable// /\\ }"
  fi

  if [[ -n ${KEYFNAME} ]]; then
    OUT_KEYFNAME="${KEYFNAME}"
  else
    TEMPLOC=$(mktemp -d keyfile.XXXXXXXX --tmpdir)
    OUT_KEYFNAME="${TEMPLOC}/derived.key"
  fi

  mkdir -p "${KEY_PUBLIC_PARTS_DIR}"
}

args_required_check() {
  if "${DEBUG}"; then
    echo "${red}args_required_check${normal}"
  fi

  for arg in "${required_args[@]}"; do
    varname="${arg}_provided"
    if ! ${!varname}; then
      echo "Error: Missing required argument --${arg}"
      show_usage
      exit 1
    fi
  done
}

is_valid_utc_time() {
  if "${DEBUG}"; then
    echo "${red}is_valid_utc_time${normal}"
  fi

  local input
  input=$1

  if [[ $(date -d "${input}" +"%Y-%m-%d %H:%M:%S") == "${input}" ]]; then
    true
  else
    false
  fi
}

if [ "$#" -eq 0 ]; then
  show_usage
  exit 0
fi

ncurses_load_colors

required_args=("seed" "sigtime" "sigexpiry" "name" "email")

for arg in "${required_args[@]}"; do
  declare "$arg"_provided=false
done

WRITE_CARD=false
DEBUG=false

parse_args() {
  while [[ $# -gt 0 ]]; do
    i="$1"
    shift 1

    case "$i" in
    --seed)
      SEED=(${1})
      seed_provided=true
      shift 1
      ;;

    --sigtime)
      SIGTIME="${1}"
      sigtime_provided=true
      shift 1
      ;;

    --sigexpiry)
      SIGEXPIRY="${1}"
      sigexpiry_provided=true
      shift 1
      ;;

    --keytime)
      KEYTIME="${1}"
      shift 1
      ;;

    --keytype)
      KEYTYPE="${1}"
      shift 1
      ;;

    --keyfname)
      KEYFNAME="${1}"
      shift 1
      ;;

    --name)
      NAME="${1}"
      name_provided=true
      shift 1
      ;;

    --comment)
      COMMENT="${1}"
      shift 1
      ;;

    --email)
      UID_EMAIL="${1}"
      email_provided=true
      shift 1
      ;;

    --write-card)
      WRITE_CARD=true
      shift 1
      ;;

    --debug)
      DEBUG=true
      shift 1
      ;;

    --help)
      show_usage
      exit 0
      ;;

    *)
      echo "${0}: unknown option \`${i}'"
      show_usage
      exit 1
      ;;
    esac
  done
}

# Parse arguments
parse_args "$@"

echo "${red}***************** DEBUG is ${DEBUG} *****************${normal}"

args_optional_set
args_required_check

if [[ ! -d ${GNUPGHOME} ]]; then
  mkdir -p "${GNUPGHOME}"
  chmod 0700 "${GNUPGHOME}"
fi

readarray -t BIP39 <"${WORDLIST}"
declare -a FULL_SEED

full_seed_create

pgp_key_private_generate
pgp_key_private_import

pgp_key_public_export
# FIXME: pgp_key_private_revocation_cert - something 'expect' doesn't handle

if "${WRITE_CARD}"; then
  pgp_card_reset
  pgp_card_set_keyattrs
  pgp_card_set_owner
  pgp_subkeys_private_move_to_card

  pgp_key_private_remove
  pgp_key_public_import
  ssh_key_public_export
fi

show_report
