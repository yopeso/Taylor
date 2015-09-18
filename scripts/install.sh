#!/bin/sh

APP_PATH="$1"
DESTINATION_DIR="/usr/local/bin"
BASH_PROFILE=~/.bash_profile
EXEPATH="$DESTINATION_DIR/Taylor.app/Contents/MacOS"
ALIASNAME="taylor"

# Create /usr/local/bin if not exist
if [ ! -d $DESTINATION_DIR ]
then
    echo "Creating folder: $DESTINATION_DIR"
    sudo mkdir -p $DESTINATION_DIR
fi

# Copy application to /usr/local/bin
echo "Copy $ALIASNAME to $DESTINATION_DIR"
sudo cp -R $APP_PATH $DESTINATION_DIR

# Make shortcut from /usr/local/bin/Taylor/Contents/MacOS/Taylor to /usr/local/bin
echo "Make $ALIASNAME shortcut to $DESTINATION_DIR"
cd $DESTINATION_DIR
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
echo "Make alias with Name $ALIASNAME"
echo "alias $ALIASNAME=$DESTINATION_DIR/$ALIASNAME" >> $BASH_PROFILE

# Reload alias from ~/.bash_profile
echo "Reload alias"
source $BASH_PROFILE