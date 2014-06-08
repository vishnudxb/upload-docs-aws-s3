#Perl script to upload files to AWS s3

*This script is used for finding some files which is older than 50days & above from the location /uploads/server/documents and after that zip 
it and upload it to Amazon s3 and then remove the files from the location and also it removes the zip files as well*

#For example
#I have some files starting with I-CAE*, I-CSA*, and I-CME* in the location /uploads/server/documents 
#In AWS S3 I have a bucket named perl-backups. In that bucket I have a folder perl-docs and a subfolder perl-files.

*You can run that script as below*
  ```
user@machine:~apt-get install libnet-amazon-s3-perl 
user@machine:~./Upload-Docs.pl

  ```

#Python script to upload files to AWS s3
*This script is for the python lovers :) It also does the same thing*

*You can run that script as below*
  ```
user@machine:~./upload-cerb-docs.py

  ```

