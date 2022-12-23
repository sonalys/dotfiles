# Get mouse name from command `xinput list`
MOUSE_NAME="pointer"
set_mouse() {
 IDS=$(xinput | grep $MOUSE_NAME | cut -d "=" -f 2 | cut -f 1)
 for ID in $IDS
 do
  xinput --set-prop $ID "Device Enabled" $1
 done
}

$(blurlock -n && set_mouse 1) & xset dpms force off & set_mouse 0
