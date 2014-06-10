#!/usr/bin/python
## Date : june 4 2014
## Purpose :Uploading Files to AWS S3  
## Author :Vishnu Nair
import os, datetime
import zipfile
import time


bucket_name = "python-backup"
bucket_folder_name = "python-folder"
bucket_inside_folder_name = "python-files"

files_loc = []
files_and_path = {}

def create_zipfile(starts_with):
	file_name = starts_with+datetime.datetime.now().strftime('-%Y-%m-%d_%H-%M-%S')+".zip"
	files_and_path[file_name] = os.path.dirname(os.path.realpath(__file__))+"/"+file_name
	now = time.time()	               
        older_than = 50			        
	zf = zipfile.ZipFile(file_name, "w")   
	for dirname, subdirs, files in os.walk("/uploads/server/documents"):   
	    zf.write(dirname)		 					     
	    for filename in files:	      
                file_created_time = os.stat(os.path.join(dirname, filename)).st_mtime 
                '''
                    These are comments 
                    Below checks if the file is starting with the given name and the file is older enough 
		    All these are calculated in Epoch time manner one day is 24*60*60 = 86400 
                '''
	        if filename.startswith(starts_with) and file_created_time < now - older_than * 86400:
	           print "\n Adding "+filename+" to zip file "+file_name+" which is older than %d days" %(older_than)
                   files_loc.append (dirname+"/"+filename)
		   zf.write(os.path.join(dirname, filename))
	zf.close()


if __name__ == "__main__":
    create_zipfile("I-CAE")  
    create_zipfile("I-CSA")    
    create_zipfile("I-CME")
    for files in files_and_path.keys():
 	cmd = 's3cmd put '+files+' s3://'+bucket_name+'/'+bucket_folder_name+'/'+bucket_inside_folder_name+'/'
	print "\n\n Copying file "+files+" to AWS S3 bucket \n\n"
 	os.system(cmd)
 	print "\n\n Removing zip "+files+" from disk \n\n"
 	os.unlink(files_and_path[files])
    for eachfile in files_loc:
        print "Deleting "+eachfile+" from the server"
        os.unlink(eachfile)

