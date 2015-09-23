#!/bin/sh

APPPATH="$1"
LOCALDIR="/usr/local/bin"
BASH_PROFILE=~/.bash_profile
APPNAME=$(basename "$APPPATH" ".app")
EXEPATH="$LOCALDIR/$APPNAME.app/Contents/MacOS"
ALIASNAME="taylor"

# Create /usr/local/bin if not exist
if [ ! -d $LOCALDIR ]
then
    echo "Make Dir $LOCALDIR"
    sudo mkdir -p $LOCALDIR
fi

# Copy application to /usr/local/bin
echo "Copy $ALIASNAME to $LOCALDIR"
sudo rm -rf "$LOCALDIR/$APPNAME.app"
sudo cp -R $APPPATH $LOCALDIR

# Make shortcut from /usr/local/bin/Taylor/Contents/MacOS/Taylor to /usr/local/bin
echo "Make $ALIASNAME shortcut to $LOCALDIR"
cd $LOCALDIR
sudo rm $LOCALDIR/$ALIASNAME
sudo ln -s "$EXEPATH/$ALIASNAME"

# Create ~/.bash_profile if not exist
if [ ! -e $BASH_PROFILE ]
then
    echo "Create .bash_profile"
    touch $BASH_PROFILE
fi

# Remove all taylor alias
sed -i -e "s/alias $ALIASNAME=\/usr\/local\/bin\/$ALIASNAME//g" $BASH_PROFILE

# Write alias in ~/.bash_profile
echo "Make $ALIASNAME alias"
echo "alias $ALIASNAME=$LOCALDIR/$ALIASNAME" >> $BASH_PROFILE

# Reload alias from ~/.bash_profile
echo "Update bash profile"
source $BASH_PROFILE