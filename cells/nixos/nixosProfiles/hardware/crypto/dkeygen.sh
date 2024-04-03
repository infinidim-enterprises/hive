#!/usr/bin/env bash

declare -a FULL_SEED

KEYID=""
KEYFNAME_PUBLIC=""

# NOTE: not all openPGP cards might be the same. Let the user set those vars elsewhere, if required.
: "${PGP_CARD_ADMIN_PIN:=12345678}" "${PGP_CARD_USER_PIN:=123456}"

GPG_TTY=$(tty)
export GPG_TTY

if [[ -n ${BIP39_WORDLIST} ]]; then
  WORDLIST="${BIP39_WORDLIST}"
else
  WORDLIST="./bip39-english.txt"
fi

readarray -t BIP39 <"${WORDLIST}"

pgp_subkeys_private_move_to_card() {
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

  expect "Enter passphrase: "
  send -- "${PGP_CARD_ADMIN_PIN}\r"

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

pgp_key_public_export() {
  KEYFNAME_PUBLIC="${HOME}/public_key_${KEYID}.asc"
  gpg --export -a "${KEYID}" >"${KEYFNAME_PUBLIC}"
}

pgp_key_private_import() {
  gpg --import "${OUT_KEYFNAME}"
  KEYID=$(gpg --list-secret-keys --keyid-format LONG --with-colon --fingerprint "${UID_EMAIL}" | grep 'fpr:' | head -n 1 | awk -F: '{print $10}')
  echo "${KEYID}:6:" | gpg --import-ownertrust
  gpg -k
}

pgp_card_set_owner() {
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
  for partial_word in "${SEED[@]}"; do
    prefix="${partial_word:0:4}"

    for full_word in "${BIP39[@]}"; do
      if [[ ${full_word:0:4} == "${prefix}" ]]; then
        FULL_SEED+=("${full_word}")
      fi
    done
  done
}

debug_str() {
  cat <<-EOF
dkeygen --seed 'clie foot exac plas type spawn tooth spin knee asset found survey apol want ridge chaos pelican seed carpet off group desk cry engage' \
--sigtime '2023-01-01 00:00:00' \
--sigexpiry '2043-01-01 00:00:00' \
--keytime '1970-01-01 00:00:01' \
--keytype rsa4096 \
--name 'Booby Love' \
--email 'boobylover@gmail.com' \
--comment 'Some sensible key comment' \
--keyfname /tmp/generated.key
EOF
}

show_report() {
  cat <<-DONE | sed 's/^  //'

  ********************************************************************************
  Your public key: ${KEYID} ${KEYFNAME_PUBLIC}
  Generated private key: rm -rf ${OUT_KEYFNAME}
  ********************************************************************************
DONE
}

show_usage() {
  cat <<-DONE | sed 's/^  //'
  Remember - [--key-creation], [--seed], [--name], [--comment] and [--email]

  $(basename "${0}") --seed '24 word bip39 phrase' \\
    --sigtime '2023-01-01 00:00:00' \\
    --sigexpiry '2033-01-01 00:00:00' \\
    --keytime '1970-01-01 00:00:01' \\
    --keytype rsa4096 \\
    --name 'Full Name' \\
    --comment 'any key comment' \\
    --email 'some@email.com'"
DONE
}

optional_args_set() {
  # create first and last names for card owner info
  read -r -a name_array <<<"${NAME}"
  UID_FIRSTNAME="${name_array[0]}"
  UID_LASTNAME="${name_array[@]:1}"

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
}

required_args_check() {
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
  local input=$1
  if [[ $(date -d "${input}" +"%Y-%m-%d %H:%M:%S" 2>/dev/null) == "${input}" ]]; then
    return 0
  else
    return 1
  fi
}

if [ "$#" -eq 0 ]; then
  show_usage
  exit 1
fi

required_args=("seed" "sigtime" "sigexpiry" "keytime" "keytype" "name" "email")

for arg in "${required_args[@]}"; do
  declare "$arg"_provided=false
done

while [ "$#" -gt 0 ]; do
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
    keytime_provided=true
    shift 1
    ;;

  --keytype)
    KEYTYPE="${1}"
    keytype_provided=true
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

optional_args_set
required_args_check
full_seed_create

pgp_key_private_generate
pgp_key_private_import

pgp_key_public_export

if "${WRITE_CARD}"; then
  pgp_card_reset
  pgp_card_set_keyattrs
  pgp_card_set_owner
  pgp_subkeys_private_move_to_card
fi

show_report
