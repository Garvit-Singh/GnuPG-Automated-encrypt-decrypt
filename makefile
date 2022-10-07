expDt = 1
env = dnf

setup:
	sudo env install tree
	sudo env install gnupg
	mkdir packaged
	mkdir unpackaged

initfile: 
	@echo "Key-Type: RSA" > .config
	@echo "Key-Length: 1024" >> .config
	@echo "Subkey-Type: RSA" >> .config
	@echo "Subkey-Length: 1024" >> .config
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
	@read -p "Enter recipient mail and document to encrypt and local user mail: " recipientmail doc lu; \
	gpg -vv --homedir=~/.gnupg --recipient $$recipientmail --output ./encrypted_documents/$$doc --encrypt ./documents/$$doc;\
	gpg --output ./signed_documents/$$doc --local-user $$lu --sign ./encrypted_documents/$$doc 

verifydocument:
	@read -p "Enter document to verify: " doc; \
	gpg --verify ./signed_documents/$$doc

decryptdocument: 
	@read -p "Enter document to decrypt: " doc; \
	gpg --output ./unsigned_decrypt/$$doc --decrypt ./signed_documents/$$doc; \
	gpg --verify ./unsigned_decrypt/$$doc; \
	gpg --output ./decrypted_documents/$$doc --decrypt ./unsigned_decrypt/$$doc

hashfile:
	@read -p "Enter File Name: " doc; \
	gpg --output ./doc.hash --print-md sha1 ./documents/$$doc

packdocument:
	@read -p "Enter recipient mail and document to encrypt and local user mail: " recipientmail doc lu; \
	mkdir -p ./packaged/$$doc; \
	gpg -vv --homedir=~/.gnupg --recipient $$recipientmail --output ./packaged/$$doc/$$doc --encrypt ./documents/$$doc;\
	gpg --output ./packaged/$$doc/s_$$doc --local-user $$lu --sign ./packaged/$$doc/$$doc; \
	zip -r ./packaged/$$doc.zip ./packaged/$$doc; \
	rm -rf ./packaged/$$doc

unpackdocument:
	@read -p "Enter document to decrypt: " doc; \
	unzip -j ./packaged/$$doc.zip -d ./unpackaged; \
	gpg --verify .unpackaged/s_$$doc; \
	gpg --output ./packaged/$$doc --decrypt ./signed_documents/s_$$doc; \
	gpg --output ./decrypted_documents/$$doc --decrypt ./unpackaged/$$doc
	rm ./unpackaged/$$doc*

folderstructure:
	tree

deletescrkey:
	@read -p "Enter userid to delete: " uid; \
	gpg --delete-secret-key $$uid

deletekey:
	make deletescrkey
	@read -p "Enter userid to delete: " uid; \
	gpg --delete-key $$uid

uninstall:
	sudo apt purge gnupg
	sudo apt purge tree