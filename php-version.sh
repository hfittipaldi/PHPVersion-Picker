#!/bin/bash
# Choose PHP Version Bash Script

aut=1
title="PHP versions"
prompt="Pick a version:"
PHPVersion=$(php -v | grep --only-matching --perl-regexp "(5|7)\.\\d+" -m 1)
current=$(php -i | grep 'PHP Version' -m 1)

# Compare all installed PHP versions and
# mark as selected the current PHP version
versions=($(ls /etc/php))
for i in "${versions[@]}"; do
    option="False $i"
    if [ "$PHPVersion" = "$i" ]; then
        option="True $i"
    fi

    options=("${options[@]}" "$option")
done

# Displays a window with all installed PHP versions
while opt=$(zenity --title="$title" --text="$prompt" --list --radiolist \
                   --column "" \
                   --column="PHP version" ${options[@]} \
                   --height=300); do

    while ! zenity --password --title="Authentication" | sudo -S cat /dev/null >/dev/null; do
        if $(zenity --question --text="Wrong password, would you like to cancel the operation?" --width=300); then
            aut=0
            break
        fi
    done

    message="You still using $current"
    if  [ "$aut" = 1 ]; then
        sudo update-alternatives --set php /usr/bin/php$opt
        sudo a2dismod php$PHPVersion
        sudo a2enmod php$opt
        sudo systemctl restart apache2

        current=$(php -i | grep 'PHP Version' -m 1)
        message="Your current $current"

        sudo -K # Remove timestamp
    fi

    zenity --info --text="$message" --width=300 --timeout=5

    break
done
