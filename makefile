expDt = 1
env = dnf
keyAlgo = RSA
keyLen = 1024
hashAlgo = sha1

setup:
	sudo ${env} install tree
	[ -d hash ] || mkdir hash
	[ -d publickey ] || mkdir -p publickey
	[ -d documents ] || mkdir -p documents
	[ -d signed_documents ] || mkdir -p signed_documents
	[ -d unsigned_documents ] || mkdir -p unsigned_documents
	[ -d packaged ] || mkdir -p packaged
	[ -d unpackaged ] || mkdir -p unpackaged
	[ -d encryptdocument ] || mkdir -p encrypted_documents
	[ -d decrypted_documents ] || mkdir -p decrypted_documents

initfile: 
	@echo "Key-Type: ${keyAlgo}" > .config
	@echo "Key-Length: ${keyLen}" >> .config
	@echo "Subkey-Type: ${keyAlgo}" >> .config
	@echo "Subkey-Length: ${keyLen}" >> .config
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


importpublickey:
	@read -p "Enter Public Key file: " pubkey; \
	gpg --import ./publickey/$$pubkey
exportpublickey:
	@read -p "Enter Username & Email: " usrname email; \
	gpg --output ./publickey/$$usrname.gpg --armour --export $$email


encryptdocument:
	@read -p "Enter recipient mail and document to encrypt and local user mail: " recipientmail doc lu; \
	gpg -vv --homedir=~/.gnupg --recipient $$recipientmail --output ./encrypted_documents/$$doc --encrypt ./documents/$$doc;\
	gpg --output ./signed_documents/$$doc --local-user $$lu --sign ./encrypted_documents/$$doc 
decryptdocument: 
	@read -p "Enter document to decrypt: " doc; \
	gpg --output ./unsigned_documents/$$doc --decrypt ./signed_documents/$$doc; \
	gpg --verify ./unsigned_documents/$$doc; \
	gpg --output ./decrypted_documents/$$doc --decrypt ./unsigned_documents/$$doc


verifydocument:
	@read -p "Enter document to verify: " doc; \
	gpg --verify ./signed_documents/$$doc
hashfile:
	@read -p "Enter File Name: " doc; \
	gpg --output ./hash/$$doc.hash --print-md ${hashAlgo} ./decrypted_documents/$$doc


packdocument:
	@read -p "Enter recipient mail and document to encrypt and local user mail: " recipientmail doc lu; \
	mkdir -p ./packaged/$$doc; \
	gpg --print-md ${hashAlgo} ./documents/$$doc > ./packaged/$$doc/hash_$$doc; \
	gpg -vv --homedir=~/.gnupg --recipient $$recipientmail --output ./packaged/$$doc/$$doc --encrypt ./documents/$$doc;\
	gpg --output ./packaged/$$doc/signed_$$doc --local-user $$lu --sign ./packaged/$$doc/$$doc; \
	rm -f ./packaged/$$doc/$$doc; \
	zip -r ./packaged/$$doc.zip ./packaged/$$doc; \
	rm -rf ./packaged/$$doc/
unpackdocument:
	@read -p "Enter document to decrypt: " doc; \
	unzip -j ./packaged/$$doc.zip -d ./unpackaged; \
	gpg --verify ./unpackaged/signed_$$doc; \
	mv ./unpackaged/hash_$$doc ./hash; \
	gpg --output ./unpackaged/$$doc --decrypt ./unpackaged/signed_$$doc; \
	gpg --output ./decrypted_documents/$$doc --decrypt ./unpackaged/$$doc; \
	rm ./unpackaged/*


list:
	@echo "Listing Secret Keys"
	gpg --list-secret-keys --keyid-format=long
	@echo "Listing all keys..."
	gpg --list-keys
deletescrkey:
	@read -p "Enter userid to delete: " uid; \
	gpg --delete-secret-key $$uid
deletekey:
	make deletescrkey
	@read -p "Enter userid to delete: " uid; \
	gpg --delete-key $$uid


folderstructure:
	tree


uninstall:
	sudo apt purge gnupg
	sudo apt purge tree