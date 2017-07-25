#!/bin/bash

#7.1
#Set the PASS_MAX_DAYS parameter to 90 in /etc/login.defs
sudo nano /etc/login.defs
PASS_MAX_DAYS 90

#Modify user parameters for all users with a password set to match
chage --maxdays 90 <user>

#7.2 
#Set the PASS_MIN_DAYS parameter to 7 in /etc/login.defs
sudo nano /etc/login.defs

#Modify user parameters for all users with a password set to match: 
chage --mindays 7 <user>

#7.3
#Set the PASS_WARN_AGE parameter to 7 in /etc/login.defs: 
sudo nano /etc/login.defs

#Modify user parameters for all users with a password set to match: 
chage --warndays 7 <user>

#7.4
#Execute the following commands for each misconfigured system account,
usermod -L <user name>
usermod -s /sbin/nologin <user name> 

#7.5
#Run the following command to set the root user default group to GID 0: 
usermod -g 0 root

#7.6
#Edit the /etc/bashrc and /etc/profile.d/cis.sh files (and the appropriate files for any other shell supported on your system) and add the following the UMASK parameter as shown:
umask 077

#7.7
#Run the following command to disable accounts that are inactive for 35 or more days
useradd -D -f 35

#7.8
#If any accounts in the /etc/shadow file do not have a password, run the following command to lock the account until it can be determined why it does not have a password
/usr/bin/passwd -l <username>
#Also, check to see if the account is logged in and investigate what it is being used for to determine if it needs to be forced off. 

#7.9
#Run the following command and verify that no output is returned:
grep '^+:' /etc/passwd
grep '^+:' /etc/shadow
grep ‘^+:’ /etc/group
#Delete these entries if they exist using userdel.

#This script will give the information of legacy account.
LG=$(grep '^+:' /etc/passwd) #if they're in passwd, they're a user
if [$? -eq 0]; then 
    #We've found a user
    echo "We've found the user '+'!"
    sudo userdel '+'
    echo "Deleted."
else
    echo "Couldn't find the user '+'."
fi

#7.10
#Run the following command and verify that only the word "root" is returned:
/bin/cat /etc/passwd | /bin/awk -F: '($3 == 0) { print $1 }‘
root

#Delete any other entries that are displayed using userdel
userdel -r <username>

#7.11
#Rectify or justify any questionable entries found in the path.
- none of the path entries should be empty
- none of the path entries should be the “.” (current directory)
- path entries should be directories
- path entries should only be writable by the owner (use the chmod command to rectify)
- path entries should preferably be owned by root (use the chown command to rectify)

#7.12
#Making global modifications to user home directories without alerting the user community can result in unexpected outages and unhappy users. 
#Therefore, it is recommended that a monitoring policy be established to report user file permissions and determine the action to be taken in accordance with site policy.

#7.13
#Making global modifications to users' files without alerting the user community can result in unexpected outages and unhappy users. 
#Therefore, it is recommended that a monitoring policy be established to report user dot file permissions and determine the action to be taken in accordance with site policy.

#7.14
#Making global modifications to users' files without alerting the user community can result in unexpected outages and unhappy users. 
#Therefore, it is recommended that a monitoring policy be established to report users’ use of .netrc and .netrc file permissions and determine the action to be taken in accordance with site policy.

#7.15
#If any users have .rhosts files determine why they have them. These files should be deleted if they are not needed.
#To search for and remove .rhosts files by using the find(1) command

find home-directories -name .rhosts -print -exec rm{}
E.g. 
find /export/home -name .rhosts -print | xargs -i -t rm{}

#7.16
#Analyze the output of the Verification step on the right and perform the appropriate action to correct any discrepancies found.

#7.17
#If any users' home directories do not exist, create them and make sure the respective user owns the directory. 
#Users without assigned home directories should be removed or assigned a home directory as appropriate. 

useradd john
mkdir -p /home/john
chown john:john /home/john

#To remove users
userdel john

#7.18
#Based on the results of the script, establish unique UIDs and review all files owned by the shared UID to determine which UID they are supposed to belong to.

#7.19
#Based on the results of the script, establish unique GIDs and review all files owned by the shared GID to determine which group they are supposed to belong to.

#7.20
#Based on the results of the above, change any UIDs that are in the reserved range to one that is in the user range. 
#Review all files owned by the reserved UID to determine which UID they are supposed to belong to.

#7.21
#Based on the results of the script, establish unique user names for the users. 
#File ownerships will automatically reflect the change as long as the users have unique UIDs.

#7.22
#Based on the results of the script, establish unique names for the user groups. 
#File group ownerships will automatically reflect the change as long as the groups have unique GIDs.


#7.23
#Making global modifications to users' files without alerting the user community can result in unexpected outages and unhappy users. 
#Therefore, it is recommended that a monitoring policy be established to report user .forward files and determine the action to be taken in accordance with site policy.

#8.1
touch /etc/motd
echo "Authorized uses only. All activity may be \monitored and reported." > /etc/issue
echo "Authorized uses only. All activity may be \monitored and reported." > /etc/issue.net
chown root:root /etc/motd; chmod 644 /etc/motd
chown root:root /etc/issue; chmod 644 /etc/issue
chown root:root /etc/issue.net; chmod 644 /etc/issue.net

#8.2
#Edit the /etc/motd, /etc/issue and /etc/issue.net files and remove any lines containing \m, \r, \s or \v.
sed -i '/\m/ d' /etc/motd
sed -i '/\r/ d' /etc/motd
sed -i '/\s/ d' /etc/motd
sed -i '/\v/ d' /etc/motd
sed -i '/\m/ d' /etc/issue
sed -i '/\r/ d' /etc/issue
sed -i '/\s/ d' /etc/issue
sed -i '/\v/ d' /etc/issue
sed -i '/\m/ d' /etc/issue.net
sed -i '/\r/ d' /etc/issue.net
sed -i '/\s/ d' /etc/issue.net
sed -i '/\v/ d' /etc/issue.net
