#!/bin/bash
set -u

has_voxtype=false
voxtype_state="idle"
if which voxtype >/dev/null 2>&1; then
  has_voxtype=true
  voxtype_state=$(timeout 0.4 omarchy-voxtype-status 2>/dev/null | jq -r '.class // "idle"' 2>/dev/null || echo "idle")
fi

recording=false
if pgrep -f '^gpu-screen-recorder' >/dev/null 2>&1; then
  recording=true
fi

reminder_json=$(omarchy-reminder show -j 2>/dev/null || echo '{"count":0}')
reminder_count=$(echo "$reminder_json" | jq -r '.count // 0' 2>/dev/null || echo 0)
reminder_next=$(echo "$reminder_json" | jq -r '.reminders[0].label // ""' 2>/dev/null || echo "")

nl_json=$(omarchy-toggle-nightlight --status 2>/dev/null || echo '{"enabled":false,"temperature":6500}')
nl_enabled=$(echo "$nl_json" | jq -r '.enabled // false' 2>/dev/null || echo false)
nl_temp=$(echo "$nl_json" | jq -r '.temperature // 6500' 2>/dev/null || echo 6500)

dnd=$(omarchy-shell notifications dndState 2>/dev/null || echo "off")
[ "$dnd" = "on" ] && dnd_bool=true || dnd_bool=false

idle_json=$(omarchy-toggle-idle status 2>/dev/null || echo '{"enabled":false}')
idle_enabled=$(echo "$idle_json" | jq -r '.enabled // false' 2>/dev/null || echo false)

jq -n \
  --argjson hasVoxtype "$has_voxtype" \
  --arg voxtypeState "$voxtype_state" \
  --argjson recording "$recording" \
  --argjson reminderCount "$reminder_count" \
  --arg reminderNext "$reminder_next" \
  --argjson nightLight "$nl_enabled" \
  --argjson nightLightTemp "$nl_temp" \
  --argjson dnd "$dnd_bool" \
  --argjson stayAwake "$idle_enabled" \
  '{hasVoxtype: $hasVoxtype, voxtypeState: $voxtypeState, recording: $recording, reminderCount: $reminderCount, reminderNext: $reminderNext, nightLight: $nightLight, nightLightTemp: $nightLightTemp, dnd: $dnd, stayAwake: $stayAwake}'
