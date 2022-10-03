expDt = 1

setup:
	sudo apt-get install tree
	sudo apt-get install gnupg

initfile: 
	echo "Key-Type: RSA\nKey-Length: 1024\nSubkey-Type: RSA\nSubkey-Length: 1024" > .config
fileop:
	make initfile
	@read -p "Enter Username: " usrname; \
	echo "Name-Real: $$usrname" >> .config
	@echo "Name-Comment: #" >> .config
	@read -p "Enter Email Address: " mail; \
	echo "Name-Email: $$mail" >> .config
	@echo "Expire-Date: ${expDt}" >> .config
	@read -p "Enter Password: " pwd; \
	echo "Passphrase: $$pwd" >> .config
	@echo "%commit" >> .config

generatekey:
	make fileop
	gpg --batch --generate-key .config

list:
	@echo "Listing Secret Keys"
	gpg --list-secret-keys --keyid-format=long
	@echo "Listing all keys..."
	gpg --list-keys

exportpublickey:
	@read -p "Enter Username & Email: " usrname email; \
	gpg --output ./publickey/$$usrname.gpg --armour --export $$email

importpublickey:
	@read -p "Enter Public Key file: " pubkey; \
	gpg --import ./publickey/$$pubkey

encryptdocument:
	@read -p "Enter recipient mail and document to encrypt: " recipientmail doc; \
	gpg -vv --homedir=~/.gnupg --recipient $$recipientmail --output ./encrypted_documents/$$doc --encrypt ./documents/$$doc

decryptdocument: 
	@read -p "Enter document to decrypt: " doc; \
	gpg --homedir=~/.gnupg --output ./decrypted_documents/$$doc --decrypt ./encrypted_documents/$$doc

folderstructure:
	tree

deletekey:
	@read -p "Enter userid to delete: " uid; \
	gpg --delete-secret-key $$uid

deletepubkey:
	@read -p "Enter userid to delete: " uid; \
	gpg --delete-key $$uid

uninstall:
	sudo apt purge gnupg
