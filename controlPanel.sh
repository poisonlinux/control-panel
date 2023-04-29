#!/usr/bin/env bash

# Set config file
export DIALOGRC='/home/slackjeff/ControlPanel/controlpanel.dialogrc'

languageSystem()
{
    TMP=/tmp/jeffe
    cd /usr/lib/locale
    for language in *.utf8; do
        if [[ "$language" = C.utf8 ]]; then
            continue
        fi
        echo "$language '' off" >> $TMP
    done

    menuSelect=$(dialog --stdout --checklist 'Select Language of system.' 30 40 20 --file $TMP)
    [[ -n $menuSelect ]] && sed "s/LANG=.*/LANG=$menuSelect/" /etc/profile.d/lang.sh
    rm $TMP
}

daemonList()
{
    # Receive
    serv="$1"

    directory="/etc/rc.d"
    TMP=$(mktemp)
    DISABLED_MSG=$(mktemp)

    # If dont called, set variables to enabled.
    if [[ -z $serv ]]; then
        serv='enabled'
    fi

    # Take list service ON
    cd $directory
    for service in *; do
        if [[ $serv = 'enabled' ]]; then
            if [[ -x $service ]] && ! [[ "$service" =~ rc\.?([0-9]|M|K|S) ]] && [[ $service != 'init.d' ]]; then
                echo "$service 'Enabled' off" >> $TMP
            fi
        else
            if ! [[ -x $service ]] && ! [[ "$service" =~ rc\.?([0-9]|M|K|S) ]] && [[ $service != 'init.d' ]]; then
                echo "$service 'Disabled' off" >> $TMP
            fi
        fi
    done

    if [[ $serv = enabled ]]; then
        perm='-x'
        selected=$(
               dialog --backtitle "All Services on/off Poison Linux" \
               --title "Poison Linux Services" \
               --extra-button \
               --extra-label "Disabled Services" \
               --checklist "Poison Linux services ON listed here! Check por Disable Service on Boot." \
               30 45 20 --file $TMP --stdout)
        # Select Disabled services? Call fucntion with disabled parameter.
        [[ $(echo $?) = '3' ]] && daemonList "disabled"
    else
        selected=$(
               dialog --backtitle "All Services on/off Poison Linux" \
               --title "Poison Linux Services" \
               --checklist "Poison Linux services Disabled listed here! Check por Disable Service on Boot." \
               30 45 20 --file $TMP --stdout)
               perm='+x'

    fi

    clear
    for selectedMenu in ${selected}; do
        if chmod $perm ${directory}/$selectedMenu; then
            echo "+-------------------------------------------+"
            echo "---> Service $selectedMenu [$serv] on Boot"
            echo "+-------------------------------------------+"
        fi
    done

    rm $TMP &>/dev/null
}

logo()
{
    clear
    cat << 'EOF'
  _____      _                   _____                 _
 |  __ \    (_)                 |  __ \               | |
 | |__) |__  _ ___  ___  _ __   | |__) |_ _ _ __   ___| |
 |  ___/ _ \| / __|/ _ \| '_ \  |  ___/ _` | '_ \ / _ \ |
 | |  | (_) | \__ \ (_) | | | | | |  | (_| | | | |  __/ |
 |_|   \___/|_|___/\___/|_| |_| |_|   \__,_|_| |_|\___|_|
 Control Panel for Poison Linux - Version: 0.1Beta
----------------------------------------------------------

EOF
}

logo
echo "[x] Change System Language, [x] Change Keyboard Map, [3] Daemons Enabled/Disabled"
echo "[x] [x] [x] [x]"
read menu
case $menu in
    1) languageSystem ;;
    3) daemonList ;;
esac
