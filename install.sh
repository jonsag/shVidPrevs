#!/bin/bash

THISDIR=$(dirname $0)
UNINSTALL="no"

# read conf file
echo "Reading configuration file..."
source $THISDIR/shvidprevs.conf

echo

# check if user is root
if [ $(whoami) == "root" ]; then
  echo "You are root, and can run this script"
  echo
else
  echo "You are not root, but we will check if there is another way..."
  NOROOT="yes"
fi

echo

# if user was not root, check if it is a CYGWIN system
if [ "$NOROOT" == "yes" ]; then
    SYSTEM=`cat /proc/version | gawk -F_ '{ print $1 }'`
    if [ "$SYSTEM" == "CYGWIN" ]; then
        echo "You are lucky, you are on a CYGWIN system, so we will go right ahead."
        NOROOT="no"
    fi
fi

# if still no luck, quit
if [ "$NOROOT" == "yes" ]; then
    echo "Sorry, no luck"
    echo "Exiting..."
    exit 0
fi

echo

# check for previous installation
if [ -d $INSTALLDIR/$SHVIDPREVSDIR ] || [ -e $INSTALLDIR/shvidprevs ]; then
    echo "The directory and/or files already exist"
    echo "Do you want to uninstall first?"
    echo
    PS3="Your choice:"
    select UNINSTALL in yes quit
    do
        break
    done
fi

echo

# run uninstall if requested
if [ $UNINSTALL == "yes" ]; then
    $THISDIR/uninstall.sh
else
    if [ $UNINSTALL == "quit" ]; then
        exit 0
    fi
fi

# create binaries directory, copy scripts to it, and create link
mkdir $INSTALLDIR/$SHVIDPREVSDIR
cp $THISDIR/*.sh $INSTALLDIR/$SHVIDPREVSDIR/
ln -s $SHVIDPREVSDIR/shvidprevs.sh $INSTALLDIR/shvidprevs

# check for logdir, and set permissions
if [ -d $LOGDIR ]; then
    echo "The directory $LOGDIR already exists"
else
    echo "The directory $LOGDIR doesn't exist"
    echo "Creating it"
    mkdir -p $LOGDIR
    chmod a+rw $LOGDIR
fi

echo

# check for conf file
if [ -d $CONFFILEDIR ]; then
    echo "The directory $CONFFILEDIR already exists"
else
    echo "The directory $CONFFILEDIR doesn't exist"
    echo "Creating it"
    mkdir -p $CONFFILEDIR
fi

echo

# create conf file
if [ -e $CONFFILEDIR/shvidprevs.conf ]; then
    echo "Configuration file already exists."
    echo "Do you wish to overwrite it?"
    PS3="Your Choice:"
    select OVERWRITE in yes no
    do
        break
    done
else
    OVERWRITE="yes"
fi

# overwrite conf file if requested, and set permissions
if [ $OVERWRITE == "yes" ]; then
    cp $THISDIR/shvidprevs.conf $CONFFILEDIR/shvidprevs.conf
    chmod a+rw $CONFFILEDIR/shvidprevs.conf
else
    TIME=$(date +%y%m%d-%H:%M:%S)
    cp $THISDIR/shvidprevs.conf $CONFFILEDIR/shvidprevs.conf.$TIME
    chmod a+r $CONFFILEDIR/shvidprevs.conf.$TIME
    echo "A copy of the new configuration file is located at $CONFFILEDIR/shvidprevs.conf.$TIME"
fi

# check if install was successful
if [ -d $INSTALLDIR/$SHVIDPREVSDIR ]; then
    if [ -x $INSTALLDIR/$SHVIDPREVSDIR/shvidprevs.sh ]; then
        if [ -h $INSTALLDIR/shvidprevs ]; then
            echo "Install successful"
            echo
            echo "Configuration file is at $CONFFILEDIR/shvidprevs.conf"
            echo
            echo "Run this program with shvidprevs"
        else
            echo "Install unsuccessful"
            echo "No link created"
            exit 1
        fi
     else
        echo "Install unsuccessful"
        echo "No executable file created"
        exit 1
     fi
else
    echo "Install unsuccessful"
    echo "No directory created"
    exit 1
fi
