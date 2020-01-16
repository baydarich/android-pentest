#!/bin/bash

if [ $# != 1 ]
then
   echo 'Usage: burp-to-android.sh <burp cert in der format>'
   exit -1
fi
BURP_CERT=$1
if [ ! -f $1 ]
then
   echo "Cannot find file $1"
   exit -1
fi

# prepare burp cert
openssl x509 -inform DER -in ${BURP_CERT} -out cacert.pem
CERT="`openssl x509 -inform PEM -subject_hash_old -in cacert.pem |head -1`.0"
mv cacert.pem ${CERT}

# prepare android
adb root
adb remount

# upload and install
adb push ${CERT} /sdcard/
adb shell mv /sdcard/${CERT} /system/etc/security/cacerts/
adb shell chmod 644 /system/etc/security/cacerts/${CERT}
adb shell locksettings set-pin 1234
adb shell reboot
