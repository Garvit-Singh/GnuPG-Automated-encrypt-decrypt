# Walkthrough 

1. Setup your machine
      ```
      make setup 
      ```
This will install all the dependencies on your linux machine.


2. Generate your own Key-Pair 

      ```
      make generatekey 
      ```
Expire date of keys are 1 day but u can change it to according to stardard by changing the variable "expDt" in makefile.


3. To export your public key 
      ```
      make exportpublickey 
      ```
This will write out your ASCII readable key in publickey directory.


4. To import someone's public key
      ```
      make importpublickey 
      ```
Make sure the public key is already in publickey folder otherwise it will through an error.


5. To View all the keys
      ```
      make list 
      ```
This will show all the secret keys you have, as well as, all the public keys you have access to.


6. Encrypt a file
      ```
      make encryptdocument 
      ```
Make sure you have the file you want to encrypt in documents folder.


7. Decrypt a file
      ```
      make decryptdocument 
      ```
Make sure you have the file you want to decrypt in encrypted_documents folder.

8. View folder structure 
      ```
      make folderstructure 
      ```

9. Delete any key

    9.1. Delete only secret key 
            ```
            make deletescrkey 
            ```
          
    9.2. Delete both secret key and public key
          ```
          make deletekey 
          ```
        
You can find they key from ```make list``` for the keys to be deleted.

      


10. Remove all Dependencies
      ```
      make uninstall 
      ```
