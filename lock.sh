set_mouse() {
 ids=$(xinput | grep 'Razer Razer Naga Left Handed Edition' | cut -d "=" -f 2 | cut -f 1)
 for id in $ids
 do
  xinput --set-prop $id "Device Enabled" "$1"
 done
}

$(blurlock -n && set_mouse 1) & xset dpms force off & set_mouse 0
