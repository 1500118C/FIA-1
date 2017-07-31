#!/bin/bash

#7.1
printf "1mSetting Password Expiration Days on /etc/login.defs: "
maxDays=$(grep ^PASS_MAX_DAYS /etc/login.defs | grep -o '[0-9]*')
if [ $maxDays -le 90 ]; then
	printf "\e[No remediation is needed\e[0m\n"
else
	sed -i 's,^\(PASS_MAX_DAYS=\).*,\1'90',' /etc/login.defs
        printf "\e[Remediation has been completed\e[0m\n"
fi
printf "1mSetting Password Expiration Days for all users: "
USER=$(cat /etc/passwd | grep "/bin/bash" | cut -d : -f 1)
list=(${USER})
for i in "${list[@]}"
do
	day=$(chage -l $i | grep "Maximum number" | cut -d : -f 2)
	if [ $day -le 90 ]; then 
		printf "\e[No remediation is needed\e[0m\n"
	else
		chage --maxdays 90 $i   
                printf "\e[Remediation has been completed\e[0m\n"
	fi
done

#7.2 
printf "1mSetting Password Change Minumum Days on /etc/login.defs: "
minDays=$(grep ^PASS_MIN_DAYS /etc/login.defs | grep -o '[0-9]*')
if [ $minDays -ge 7 ]; then
	printf "\e[No remediation is needed\e[0m\n"
else
	sed -i 's,^\(PASS_MIN_DAYS=\).*,\1'7',' /etc/login.defs
	printf "\e[Remediation has been completed\e[0m\n"
fi
printf "1mSetting Password Change Minimum Days for all users: "
USER=$(cat /etc/passwd | grep "/bin/bash" | cut -d : -f 1)
list=(${USER})
for i in "${list[@]}"
do
	day=$(chage -l $i | grep "Minimum number" | cut -d : -f 2)
	if [ $day -ge 7 ]; then 
		printf "\e[No remediation is needed\e[0m\n"
	else
		chage --mindays 7 $i  
		printf "\e[Remediation has been completed\e[0m\n"
	fi
done

#7.3
printf "1mSetting Password Expiring Warning Days on /etc/login.defs: "
expDays=$(grep ^PASS_WARN_AGE /etc/login.defs | grep -o '[0-9]*')
if [ $expDays -ge 7 ]; then
	printf "\e[No remediation is needed\e[0m\n"
else
	sed -i 's,^\(PASS_WARN_DAYS=\).*,\1'7',' /etc/login.defs
	printf "\e[Remediation has been completed\e[0m\n"
fi
printf "1mSetting Password Expiring Warning Days for all users: "
USER=$(cat /etc/passwd | grep "/bin/bash" | cut -d : -f 1)
list=(${USER})
for i in "${list[@]}"
do
	day=$(chage -l $i | grep "warning" | cut -d : -f 2)
	if [ $day -ge 7 ]; then 
		printf "\e[No remediation is needed\e[0m\n"
	else
		chage --warndays 7 $i
		printf "\e[Remediation has been completed\e[0m\n"
	fi
done

#7.4
printf "1mDisabling system accounts: "
RESULT=$(egrep -v "^\+" /etc/passwd | awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $3<1000 && $7!="/usr/sbin/nologin" && $7!="/sbin/nologin" && $7!="/bin/false")')
if [ -z $RESULT ]; then
  printf "\e[No remediation is needed\e[0m\n"
else
  usermod -L $RESULT
  usermod -s /sbin/nologin $RESULT
  printf "\e[Remediation has been completed\e[0m\n"
fi

#7.5
printf "1mSetting default group for root account: "
DGROUP=$(grep "^root:" /etc/passwd | cut -f4 -d:)
if [ "$DGROUP" -eq 0 ]; then
	printf "\e[No remediation is needed\e[0m\n"
else
	usermod -g 0 root
	printf "\e[Remediation has been completed\e[0m\n"
fi

#7.6
printf "1mSetting default mask for users: "
if grep "umask 077" /etc/bashrc | grep "umask 077" /etc/profile.d/* >/dev/null; then
	printf "\e[No remediation is needed\e[0m\n"
else
	sed -i 's,^\(umask 022).*,\1'umask 077',' /etc/bashrc
        sed -i 's,^\(umask 022).*,\1'umask 077',' /etc/profile.d
	printf "\e[Remediation has been completed\e[0m\n"
fi 

#7.7
printf "1mLocking inactive user accounts: "
if useradd -D | grep INACTIVE=35 >/dev/null; then
	printf "\e[No remediation is needed\e[0m\n"
else
	useradd -D -f 35
	printf "\e[Remediation has been completed\e[0m\n"
fi

#7.8
printf "1mEnsuring password fields are not empty: "
PFieldsNEmpty= $(cat /etc/shadow | awk -F: '($2 == "" ) { print $1 " does not have a password "}')
echo $PFieldsNEmpty
if [ -z "$PFieldsNEmpty" ]; then
	printf "\e[No remediation is needed\e[0m\n"
else
	/usr/bin/passwd -l $1
	printf "\e[Remediation has been completed\e[0m\n"
fi

#7.9
printf "1mVerifying No Legacy "+" Entries Exist in /etc/passwd, /etc/shadow and /etc/group files: "
LG=$(grep '^+:' /etc/passwd) 
if [$? -eq 0]; then 
    #We've found a user
    echo "We've found the user '+'!"
    sudo userdel '+'
    echo "Deleted."
else
    echo "Couldn't find the user '+'."
fi

LG=$(grep '^+:' /etc/shadow) 
if [$? -eq 0]; then 
    #We've found a user
    echo "We've found the user '+'!"
    sudo userdel '+'
    echo "Deleted."
else
    echo "Couldn't find the user '+'."
fi

LG=$(grep '^+:' /etc/group) 
if [$? -eq 0]; then 
    #We've found a user
    echo "We've found the user '+'!"
    sudo userdel '+'
    echo "Deleted."
else
    echo "Couldn't find the user '+'."
fi

#7.10
printf "1mVerify No UID 0 Accounts Exist Other Than root: "
VerifyUIDRoot=$(/bin/cat /etc/passwd | /bin/awk -F: '($3 == 0){print $1}')
if [ "$VerifyUIDRoot" = 'root' ]
then
	printf "\e[No remediation is needed\e[0m\n"
else
	userdel -r [ “$VerifyUIDRoot” != ‘root’ ]
	printf "\e[Remediation has been completed\e[0m\n"
fi

#7.11
printf "1mEnsuring root PATH integrity: "
if [ "`echo $PATH | grep :: `" != "" ]; then
	echo "Empty Directory in PATH (::)"
fi
p=`echo $PATH | sed -e 's/::/:/' -e 's/:$//' -e 's/:/ /g'`
set -- $p
while [ "$1" != "" ]; do
	if [ "$1" = "." ]; then
		echo "PATH contains ."
		shift
		continue
	fi

	if [ -d $1 ]; then
		perm6=$(ls -ldH $1 | grep "^.....w....")
		perm9=$(ls -ldH $1 | grep "^........w.")
		if [ -z "$perm6" ]; then
			printf "\e[No remediation is needed\e[0m\n"
		else
			chmod g=rx /root
			printf "\e[Remediation has been completed\e[0m\n"
		fi
		if [ -z "$perm9" ]; then
			printf "\e[No remediation is needed\e[0m\n"
		else
			chmod o= /root
			printf "\e[Remediation has been completed\e[0m\n"
		fi
		
		dirown=`ls -ldH $1 | awk '{print $3}'`
		if [ "$dirown" == "root" ] ; then
			printf "\e[No remediation is needed\e[0m\n"
		else
			chown root /root
			printf "\e[Remediation has been completed\e[0m\n"
		fi
	else
		printf "\e[31m$1 is not a directory\e[0m\n"
	fi
shift
done

#7.12
printf "1mChecking permissions on user home directories: "
for RESULT in `cat /etc/passwd | egrep -v '(root|halt|sync|shutdown)' |awk -F: '($7!="/usr/sbin/nologin" && $7!="/sbin/nologin" && $7!="/bin/false") { print $6 }'`; do
resultperm=$(ls -ld $RESULT)

if [[ ` echo $resultperm | grep "^......w..." ` ]]; then 
	printf "\e[No remediation is needed\e[0m\n"
else
        chmod g= $RESULT
	printf "\e[Remediation has been completed\e[0m\n"
fi

if [[ ` echo $resultperm | grep "^.......-.." `  ]]; then
	printf "\e[No remediation is needed\e[0m\n"
else
        chmod o= $RESULT
        printf "\e[Remediation has been completed\e[0m\n"
fi

if [[ `echo $resultperm | grep "^........-."` ]]; then
	printf "\e[No remediation is needed\e[0m\n"
else
        chmod o= $RESULT
        printf "\e[Remediation has been completed\e[0m\n"
fi

if [[ `echo $resultperm | grep "^.........-"` ]]; then
	printf "\e[No remediation is needed\e[0m\n"
else
        chmod o= $RESULT
        printf "\e[Remediation has been completed\e[0m\n"
fi
done

#7.13
printf "It is recommended that a monitoring policy be established to report user dot file permissions."

#7.14
printf "It is recommended that a monitoring policy be established to report users’ use of .netrc and .netrc file permissions."

#7.15
#If any users have .rhosts files determine why they have them. These files should be deleted if they are not needed.
#To search for and remove .rhosts files by using the find(1) command
printf "1mChecking for presence of user .rhosts files: "
for dir in `/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' |/bin/awk -F: '($7 != "/sbin/nologin") { print $6 }'`; do
for file in $dir/.rhosts; do
if [ ! -h "$file" -a -f "$file" ]; then
find /export/home -name .rhosts -print | xargs -i -t rm{}
printf "\eRemediation has been completed \n"
else
printf "\eNo remediation needed\e[0m\n"
fi
echo  -en "\e[0m"
done
done


#7.16
printf "1mAnalyze the output of the Verification step on the right and perform the appropriate action to correct any discrepancies found."

#7.17
printf "1mUsers without assigned home directories should be removed or assigned a home directory as appropriate (E.g. Using userdel)"


#7.18
printf "1mEstablish unique UIDs and review all files owned by the shared UID to determine which UID they are supposed to belong to."

#7.19
printf "1mEstablish unique GIDs and review all files owned by the shared GID to determine which group they are supposed to belong to."

#7.20
printf "1mReview all files, determine which UID they are supposed to belong to and change any UIDs that are in the reserved range to one that is in the user range."

#7.21
printf "1mEstablish unique user names for the users."

#7.22
printf "1mEstablish unique names for the user groups."

#7.23
printf "1mA monitoring policy be established to report user .forward files and determine the action to be taken in accordance with site policy."

#8.1
printf "1mRemediation for Warning banner."
counter=0

chmodmotd=$( stat --format '%a' /etc/motd)
chmodissue=$( stat --format '%a' /etc/issue)
chmodissuenet=$( stat --format '%a' /etc/issue.net)
#Checks if all files' chmod equals 644
printf "Checking that /etc/motd /etc/issue /etc/issue.net have chmod of 644 :\n"
if [ "$chmodmotd" -eq 644 ] && [ "$chmodissue" -eq 644 ] && [ "$chmodissuenet" -eq 644 ]
then 
	printf "\e[No remediation is needed\e[0m\n"
else	
	chown root:root /etc/motd; chmod 644 /etc/motd
	chown root:root /etc/issue; chmod 644 /etc/issue
	chown root:root /etc/issue.net; chmod 644 /etc/issue.net
	counter=$((counter+1))
	printf "\e[Remediation has been completed\e[0m\n"
fi
echo  -en "\e[0m"

mp="Authorized uses only. All activity may be \monitored and reported."
catissue=$(cat /etc/issue)
catissuenet=$(cat /etc/issue.net)
if [ "$catissue" == "$mp" ] && [ "$catissuenet" == "$mp" ]
then
	printf "\e[No remediation is needed\e[0m\n"
else
	echo "Authorized uses only. All activity may be \monitored and reported." > /etc/issue
	echo "Authorized uses only. All activity may be \monitored and reported." > /etc/issue.net
	counter=$((counter+1))
	printf "\033[33;31m FAIL \n"
fi
echo  -en "\e[0m"

if [ $counter -gt 0 ]; then
	printf "\e[Remediation required\e[0m\n"
	printf "Please run remediation\n"
else
	printf "\e[No remediation required\e[0m\n"
fi


#8.2
printf "1mEdit the /etc/motd, /etc/issue and /etc/issue.net files and remove any lines containing \m, \r, \s or \v."
issue=$(egrep '(\\v|\\r|\\m|\\s)' /etc/issue)
motd=$(egrep '(\\v|\\r|\\m|\\s)' /etc/motd)
issuenet=$(egrep '(\\v|\\r|\\m|\\s)' /etc/issue.net)
regex='(\\v|\\r|\\m|\\s)'
counter=0
if [[ $issue =~ $regex ]]
then 
	counter=$((counter+1))
	printf "\e[No remediation is needed\e[0m\n"
else
	sed -i '/\m/ d' /etc/issue
	sed -i '/\r/ d' /etc/issue
	sed -i '/\s/ d' /etc/issue
	sed -i '/\v/ d' /etc/issue
	printf "\e[Remediation has been completed\e[0m\n"
fi
echo  -en "\e[0m"

printf "Checking /etc/motd:\n"
if [[ $motd =~ $regex ]]
then 
	counter=$((counter+1))
	printf "\e[No remediation is needed\e[0m\n"
else
	sed -i '/\m/ d' /etc/motd
	sed -i '/\r/ d' /etc/motd
	sed -i '/\s/ d' /etc/motd
	sed -i '/\v/ d' /etc/motd
	printf "\e[Remediation has been completed\e[0m\n"

fi
echo  -en "\e[0m"

printf "Checking /etc/issue.net:\n"
if [[ $issuenet =~ $regex ]]
then 
	counter=$((counter+1))
	printf "\e[No remediation is needed\e[0m\n"
else
	sed -i '/\m/ d' /etc/issue.net
	sed -i '/\r/ d' /etc/issue.net
	sed -i '/\s/ d' /etc/issue.net
	sed -i '/\v/ d' /etc/issue.net
	printf "\e[Remediation has been completed\e[0m\n"
fi
echo  -en "\e[0m"

