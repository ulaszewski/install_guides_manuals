#Install OrthoMCL
#Option 1. from OrthoMCL site: https://orthomcl.org/orthomcl/app/downloads/software/
#Option 2. from package manager e.g. for conda: https://anaconda.org/bioconda/orthomcl
#Note for installing orthomcl from conda - the package does not include MySQL it needs to be installed independently.

#Install MySQL for Ubuntu 20 - source and details: https://www.vultr.com/docs/how-to-install-mysql-5-7-on-ubuntu-20-04/
wget https://dev.mysql.com/get/mysql-apt-config_0.8.12-1_all.deb
sudo dpkg -i mysql-apt-config_0.8.12-1_all.deb
sudo apt update
#POSSIBLE output error: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 467B942D3A79BD29
#To pass, use this:
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29
sudo apt update
sudo apt-cache policy mysql-server
#Important during installation chose mysql 5.7
sudo apt install -f mysql-client=5.7* mysql-community-server=5.7* mysql-server=5.7*
#Security settings
sudo mysql_secure_installation

#First MYSQL run wtih root user
sudo mysql -u root -p

#In MySQL console type below lines. Remember to adjust the password to the security settings configurated in the 'mysql_secure_installation' step !
#Important note - store or remember the password it will be ciritial for any step with MySQL involved, including running of the OrthoMCL pipeline.
CREATE DATABASE orthomcl;
SET GLOBAL local_infile=1;
grant all privileges on *.* to orthomcl@localhost identified by 'password' with grant option;
quit

#You should be able to login user orthomcl, check by:
mysql -u orthomcl -p

#Check cpan modules, if nothing happens it is OK!
perl -MDBI -e 1
perl -MDBD::mysql -e 1

#If necesary install CPAN modules:
cpan install Data::Dumper
cpan install DBI
cpan install DBD::mysql

#Check AGAIN cpan modules, if nothing happens it is OK!
perl -MDBI -e 1
perl -MDBD::mysql -e 1

#If you get error like this: Can't locate DBD/mysql.pm in @INC (you may need to install the DBD::mysql module) ....
#Install missing library by:
sudo apt get install libdbd-mysql-perl

#Check once again cpan modules, if nothing happens it is OK!

perl -MDBI -e 1
perl -MDBD::mysql -e 1

#Add MySQL settings for OPTIMIZATION

sudo nano sudo nano /etc/mysql/my.cnf

#add lines at the bottom of the file:

[mysqld]
myisam_sort_buffer_size=4G
myisam_max_sort_file_size=20G
read_buffer_size=2G

#save and exit file
#Login into your MySQL account and check if the buffers are ok, in MySQL conslone type:

show variables LIKE 'myisam_sort_buffer_size';

#You should get something like this:
+-------------------------+------------+
| Variable_name           | Value      |
+-------------------------+------------+
| myisam_sort_buffer_size | 4294967296 |
+-------------------------+------------+

#If you get something like this:
+-------------------------+---------+
| Variable_name           | Value   |
+-------------------------+---------+
| myisam_sort_buffer_size | 8388608 |
+-------------------------+---------+

#Stop and start again the MySQL server by: 
sudo systemctl stop mysql
sudo systemctl start mysql

#Copy orthomcl.config.template to your working dir
#When you install orthomcl from conda (to an environment) you will find the template in this path /share/orthomcl/orthomcl.config.template
cp orthomcl.config.template ~/your_analysis_dir/orthomcl.config

#You can also copy the text below and create new 'orthomcl.config' file, remember to adjust the password and any other setting if desired/needed

#START COPY

# this config assumes a mysql database named 'orthomcl'. adjust according
# to your situation.
dbVendor=mysql
dbConnectString=dbi:mysql:orthomcl;
dbLogin=orthomcl
dbPassword=password
similarSequencesTable=SimilarSequences
orthologTable=Ortholog
inParalogTable=InParalog
coOrthologTable=CoOrtholog
interTaxonMatchView=InterTaxonMatch
percentMatchCutoff=50
evalueExponentCutoff=-5
oracleIndexTblSpc=NONE

#STOP COPY