# reverse scroll
touchpad=$(xinput list | grep "Touchpad" | sed 's/.*id=//' | cut -d "[" -f 1 | tr -d -c 0-9)
reverse_scroll=$(xinput list-props $touchpad | grep "Natural Scrolling Enabled (" | cut -d ")" -f 1 | tr -d -c 0-9)
xinput set-prop $touchpad $reverse_scroll 1
