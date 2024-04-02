#!/bin/zsh

##
## This automation was created to be used with MACOS based on the instructions from drduh
## (https://github.com/drduh/YubiKey-Guide)
##
## The script was tested on an M1 with gpgtools 2020.2
##
## Pre requisites:
## * gpgtools: https://gpgtools.org
## * brew install ykman expect
##
## If you need to rerun this script you may want to reset gpg on the yubi with:
## ykman openpgp reset
## also you may want to remove these files:
## rm /tmp/key.txt
## rm ~/.zshrc  (carefull with this one... if you use it just delete the gpg related stuff)
## rm ~/.gnupg/gpg.conf
## rm ~/.gnupg/gpg-agent.conf
## rm ~/.gnupg/scdaemon.conf
##
# TEST command line: generate_derived_key --sigtime '2023-01-01 00:00:00' --sigexpiry '2030-01-01 00:00:00' --key-creation '1970-01-01 00:00:01' --key-type rsa4096 --name 'Booby Lover (Key comment)' --email 'boobylover@gmail.com' --output-file ~/Documents/private.key
# TEST SEED: client foot exact plastic type spawn tooth spin knee asset found survey apology want ridge chaos pelican seed carpet off group desk cry engage -- actual
# TEST key fingerprint: 4AE3 67C9 B78C 07F6 3719  F213 2B35 3748 22A4 1189
# gpg --import ~/Documents/private.key
# echo "4AE367C9B78C07F63719F2132B35374822A41189:6:" | gpg --import-ownertrust
# gpg --export -a 4AE367C9B78C07F63719F2132B35374822A41189 > ~/Documents/public.key
# echo "\ntest message string" | gpg --encrypt --armor --recipient 4AE367C9B78C07F63719F2132B35374822A41189 --output ~/Documents/encrypted-string.txt
# gpg --decrypt --armor ~/Documents/encrypted-string.txt

# TODO: make this runnable in std!

#variables definition
#you may change this variables as you wish
firstname="FIRST"
lastname="LAST"
email="YOUREMAIL@example"

username="${firstname} ${lastname}"
keySize=4096
masterKeyExpiration="0"
subkeysExpiration="0"

if [ $firstname = "FIRST" || $lastname = "LAST" || $email = "YOUREMAIL@example" ]; then
  echo "Please edit the variables firstname, lastname and email"
  exit 1
fi

## Starting the process
workdir=$(mktemp -d)
export GNUPGHOME=$workdir
cd $GNUPGHOME
wget https://raw.githubusercontent.com/rsksmart/gpg-conf/main/gpg.conf
masterkey=$(gpg --gen-random --armor 0 24)

echo "\n\n"
echo "********************************************************************************************"
echo "                                        ATTENTION"
echo "********************************************************************************************"
echo "The following key (securily generated) will be your master key, please keep it in a safe place"
echo "YOU REALLY NEED THIS KEY, SAVE IT"
echo ""
echo $masterkey
echo ""
echo "NOTE: Through this script, everytime a 'Passphrase' is asked, you should also use this key"
echo "Its not just for the script, so, don't trash it after"
echo "********************************************************************************************"

echo "press any key if you have saved the master key"
read trash

#this is needed so that passphrase input doesn't screw expect
GPG_TTY=$(tty)
export GPG_TTY

############################
# Generate master key
############################
expect <<-DONE

set timeout 30

log_file -noappend /tmp/key.txt
spawn gpg --expert --full-generate-key

expect "Your selection? "
send -- "8 \r"

expect "Your selection? "
send -- "E \r"

expect "Your selection? "
send -- "S \r"

expect "Your selection? "
send -- "Q \r"

expect "What keysize do you want?*"
send -- "${keySize} \r"

expect "Key is valid for?*"
send -- "${masterKeyExpiration} \r"

expect "Is this correct? (y/N)"
send -- "y\r"

expect "Real name:*"
send -- "${username}\r"

expect "Email address:*"
send -- "${email}\r"

expect "Comment:*"
send -- "\r"

expect "Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit?*"
send -- "o\r"

expect eof

DONE

#get the generated key ID
echo "getting key id"
key=$(cat /tmp/key.txt | grep -E -op 'rsa4096/0x[A-F0-9]{16}')
export KEYID=${key//rsa4096\//}

# some versions of gpg output this in a different way.... so if keyid is empty lets try another way
if [ -z "$KEYID" ]; then
  tmp=$(cat /tmp/key.txt | grep -E -op '[A-F0-9]{40}')
  key="${tmp:32:8}"
  keyid=$(echo "0x${key}" | tr -d \")
  export KEYID=$keyid
fi

echo $KEYID
echo "---------"

expect <<-DONE

set timeout 30
spawn gpg --expert --edit-key $KEYID

#signing key
expect "gpg> "
send -- "addkey\r"

expect "Your selection? "
send -- "4 \r"

expect "What keysize do you want?*"
send -- "${keySize} \r"

expect "Key is valid for?*"
send -- "${masterKeyExpiration} \r"

expect "Is this correct? (y/N)"
send -- "y\r"

expect "Really create? (y/N)"
send -- "y\r"

#encryption key
expect "gpg> "
send -- "addkey\r"

expect "Your selection? "
send -- "6 \r"

expect "What keysize do you want?*"
send -- "${keySize} \r"

expect "Key is valid for?*"
send -- "${masterKeyExpiration} \r"

expect "Is this correct? (y/N)"
send -- "y\r"

expect "Really create? (y/N)"
send -- "y\r"

#authentication key
expect "gpg> "
send -- "addkey\r"

expect "Your selection? "
send -- "8 \r"

expect "Your selection? "
send -- "S \r"

expect "Your selection? "
send -- "E \r"

expect "Your selection? "
send -- "A \r"

expect "Your selection? "
send -- "Q \r"

expect "What keysize do you want?*"
send -- "${keySize} \r"

expect "Key is valid for?*"
send -- "${masterKeyExpiration} \r"

expect "Is this correct? (y/N)"
send -- "y\r"

expect "Really create? (y/N)"
send -- "y\r"

expect "gpg> "
send -- "trust\r"

expect "Your decision? "
send -- "5 \r"

expect "Do you really want to set this key to ultimate trust?* "
send -- "y \r"

expect "gpg> "
send -- "uid 1\r"

expect "gpg> "
send -- "primary\r"

expect "gpg> "
send -- "save\r"

expect eof

DONE

export GNUPGHOME=

echo ""
echo "********************************************************************************************"
echo "                                        ATTENTION"
echo "********************************************************************************************"
echo "You will now be asked to change the yubikey pins"
echo "By default the admin pin is 12345678 and the regular pin 123456"
echo "Use the default to change yours. Please do not forget your new pins as they will be needed"
echo "********************************************************************************************"
echo ""
echo "Press any key to continue..."
read trash

#change pins
expect <<-DONE

set timeout 30

spawn gpg --change-pin

expect "Your selection? "
send -- "3\r"

expect "Your selection? "
send -- "1\r"

expect "Your selection? "
send -- "q\r"

expect eof

DONE

#change card data
expect <<-DONE

set timeout 30

spawn gpg --edit-card

expect "gpg/card> "
send -- "admin\r"

expect "gpg/card> "
send -- "name\r"

expect "Cardholder*"
send -- "${lastname}\r"

expect "Cardholder's given name: "
send -- "${firstname}\r"

expect "gpg/card> "
send -- "login\r"

expect "Login data (account name): "
send -- "${email}\r"

expect "gpg/card> "
send -- "quit\r"

expect eof

DONE

export GNUPGHOME=$workdir
killall gpg-agent
killall scdaemon
#echo "disable-ccid" > scdaemon.conf

#send key 1 to yubi
expect <<-DONE

set timeout 90

spawn gpg --edit-key $KEYID

expect "gpg> "
send -- "key 1\r"

expect "gpg> "
send -- "keytocard\r"

expect "Your selection? "
send -- "1 \r"

expect "gpg> "
send -- "save\r"

expect eof

DONE

#send key 2 to yubi
expect <<-DONE

set timeout 90

spawn gpg --edit-key $KEYID

expect "gpg> "
send -- "key 2\r"

expect "gpg> "
send -- "keytocard\r"

expect "Your selection? "
send -- "2 \r"

expect "gpg> "
send -- "save\r"

expect eof

DONE

#send key 3 to yubi
expect <<-DONE

set timeout 90

spawn gpg --edit-key $KEYID

expect "gpg> "
send -- "key 3\r"

expect "gpg> "
send -- "keytocard\r"

expect "Your selection? "
send -- "3 \r"

expect "gpg> "
send -- "save\r"

expect eof

DONE

echo "Saving gpg public key in desktop (gpg_public_key.txt)"
gpg --export -a $email public.key >~/Desktop/gpg_public_key.txt

cd ~/.gnupg

#Generating gpg.conf
echo "use-agent" >gpg.conf
echo "personal-cipher-preferences AES256 AES192 AES CAST5" >>gpg.conf
echo "personal-digest-preferences SHA512 SHA384 SHA256 SHA224" >>gpg.conf
echo "cert-digest-algo SHA512" >>gpg.conf
echo "default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed" >>gpg.conf
echo "no-emit-version" >>gpg.conf

#Generating gpg-agent.conf
echo "# if on Mac OS X and GPG Suite is installed" >gpg-agent.conf
echo "# otherwise, look for 'pinentry' on your system" >>gpg-agent.conf
echo "# enables SSH support (ssh-agent)" >>gpg-agent.conf
echo "enable-ssh-support" >>gpg-agent.conf
echo "# writes environment information to ~/.gpg-agent-info" >>gpg-agent.conf
echo "write-env-file" >>gpg-agent.conf
echo "use-standard-socket" >>gpg-agent.conf
echo "# default cache timeout of 600 seconds" >>gpg-agent.conf
echo "default-cache-ttl 600" >>gpg-agent.conf
echo "max-cache-ttl 7200" >>gpg-agent.conf

echo "disable-ccid" >~/.gnupg/scdaemon.conf

#appending to zsh config
echo "#if [ -S "$HOME/.gnupg/S.gpg-agent.ssh" ]; then" >>~/.zshrc
echo "export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"" >>~/.zshrc
echo "gpgconf --launch gpg-agent" >>~/.zshrc
echo "gpgconf --kill all" >>~/.zshrc
echo "#fi" >>~/.zshrc

echo "Saving gpg data"
gpg --export -a $email >~/Desktop/gpg.txt

##exporting secret keys
#gpg --armor --export-secret-keys $KEYID > ~/Desktop/master.key
#gpg --armor --export-secret-subkeys $KEYID > ~/Desktop/sub.key

gpg --card-status

export GNUPGHOME=
killall gpg-agent
gpg --import <~/Desktop/gpg.txt
gpg --card-status

echo ""
echo "********************************************************************************************"
echo "                                        ATTENTION"
echo "********************************************************************************************"
echo ""
#echo "[+] Exported secret key to ~/Desktop/mastersub.key"
#echo "[+] Exported subkeys key to ~/Desktop/sub.key"
#echo ""
#echo "[!] Back up these two files to outside this computer and delete them from here"
echo "The previous command should have information in 'General key info' otherwise something went wrong... "
echo "To confirm everything went well open a new terminal and type (you should see your publickey): gpg --card-status && ssh-add -L"
