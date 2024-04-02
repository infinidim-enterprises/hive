#!/usr/bin/env bash

FULL_SEED=()
GPG_TTY=$(tty)

if [[ -n ${BIP39_WORDLIST} ]]; then
  WORDLIST="${BIP39_WORDLIST}"
else
  WORDLIST="./bip39-english.txt"
fi

readarray -t BIP39 <"${WORDLIST}"

export GPG_TTY

import_pgp_key() {
  local keyID
  gpg --import "${OUT_KEYFNAME}"
  keyID=$(gpg --list-secret-keys --keyid-format LONG | grep -Eo '[0-9A-F]{17,}')
  echo "${keyID}:6:" | gpg --import-ownertrust
  gpg -k
}

generate_pgp_key() {
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

create_full_seed() {
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

set_optional_args() {
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

check_required_args() {
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

set_optional_args
check_required_args
create_full_seed

echo "${UID_NAME_AND_COMMENT}"
echo '**********'

generate_pgp_key
import_pgp_key
