#!/usr/bin/env python3
import sys
import os
import glob
import subprocess
import json
import time

def read_file_safe(path, default=""):
    try:
        with open(path, "r") as f:
            return f.read().strip()
    except Exception:
        return default

def get_battery_info():
    bat = "/sys/class/power_supply/BAT1"
    if not os.path.exists(bat):
        return {
            "present": False,
            "percentage": 100,
            "status": "AC",
            "icon": "󰚥",
            "text": "AC",
            "timeRemaining": "",
            "health": 100.0,
            "voltage": 0.0,
            "temp": 0.0,
            "powerW": 0.0,
            "energyNow": 0.0,
            "energyFull": 0.0,
            "energyDesign": 0.0
        }
    
    cap = int(read_file_safe(f"{bat}/capacity", "0"))
    status = read_file_safe(f"{bat}/status", "Unknown")
    c_now = int(read_file_safe(f"{bat}/charge_now", "0"))
    c_full = int(read_file_safe(f"{bat}/charge_full", "0"))
    c_design = int(read_file_safe(f"{bat}/charge_full_design", "0"))
    curr = int(read_file_safe(f"{bat}/current_now", "0"))
    volt = int(read_file_safe(f"{bat}/voltage_now", "0")) / 1e6
    temp = int(read_file_safe(f"{bat}/temp", "0")) / 10.0
    
    time_rem = ""
    if status == "Discharging" and curr > 0:
        h = c_now / curr
        time_rem = f"{int(h)}h {int((h % 1) * 60)}m"
    elif status == "Charging" and curr > 0 and c_full > c_now:
        h = (c_full - c_now) / curr
        time_rem = f"{int(h)}h {int((h % 1) * 60)}m"
    elif status == "Full":
        time_rem = "Full"

    health = round((c_full / c_design * 100), 1) if c_design > 0 else 100.0
    power_w = round((curr * volt) / 1e6, 1)

    # Battery icon selection
    if status == "Charging":
        if cap >= 90: b_icon = "󰂅"
        elif cap >= 70: b_icon = "󰂉"
        elif cap >= 50: b_icon = "󰂈"
        elif cap >= 30: b_icon = "󰂇"
        elif cap >= 15: b_icon = "󰂆"
        else: b_icon = "󰢜"
    else:
        if cap >= 95: b_icon = "󰁹"
        elif cap >= 80: b_icon = "󰂁"
        elif cap >= 60: b_icon = "󰁿"
        elif cap >= 40: b_icon = "󰁽"
        elif cap >= 20: b_icon = "󰁻"
        elif cap >= 10: b_icon = "󰁺"
        else: b_icon = "󰂎"

    return {
        "present": True,
        "percentage": cap,
        "status": status,
        "icon": b_icon,
        "text": f"{cap}%",
        "timeRemaining": time_rem,
        "health": health,
        "voltage": round(volt, 1),
        "temp": round(temp, 1),
        "powerW": power_w,
        "energyNow": round(c_now * volt / 1e6, 1),
        "energyFull": round(c_full * volt / 1e6, 1),
        "energyDesign": round(c_design * volt / 1e6, 1)
    }

def get_brightness_info():
    bl = "/sys/class/backlight/amdgpu_bl1"
    if os.path.exists(bl):
        cur = int(read_file_safe(f"{bl}/brightness", "0"))
        max_b = int(read_file_safe(f"{bl}/max_brightness", "1"))
        pct = round(cur / max_b * 100)
    else:
        pct = 100
    
    if pct >= 70: icon = "󰃠"
    elif pct >= 30: icon = "󰃟"
    else: icon = "󰃞"
    return {"brightness": pct, "icon": icon}

def get_audio_info():
    try:
        s_out = subprocess.check_output(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"], text=True, timeout=1).strip()
        parts = s_out.split()
        v_out = int(round(float(parts[1]) * 100)) if len(parts) > 1 else 100
        m_out = "[MUTED]" in s_out
    except Exception:
        v_out = 100
        m_out = False

    try:
        s_in = subprocess.check_output(["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"], text=True, timeout=1).strip()
        parts_in = s_in.split()
        v_in = int(round(float(parts_in[1]) * 100)) if len(parts_in) > 1 else 50
        m_in = "[MUTED]" in s_in
    except Exception:
        v_in = 50
        m_in = False

    if m_out or v_out == 0: icon = "󰝟"
    elif v_out >= 65: icon = "󰕾"
    elif v_out >= 30: icon = "󰖀"
    else: icon = "󰕿"

    return {
        "sinkVolume": v_out,
        "sinkMuted": m_out,
        "sourceVolume": v_in,
        "sourceMuted": m_in,
        "icon": icon
    }

def get_bluetooth_fast():
    try:
        rf = subprocess.check_output(["rfkill", "list", "bluetooth"], text=True, timeout=1)
        blocked = "Soft blocked: yes" in rf
        if blocked:
            return {"enabled": False, "icon": "󰂲", "connected": False}
        c_out = subprocess.check_output(["bluetoothctl", "devices", "Connected"], text=True, timeout=1).strip()
        has_conn = bool(c_out)
        return {"enabled": True, "icon": "󰂱" if has_conn else "󰂯", "connected": has_conn}
    except Exception:
        return {"enabled": False, "icon": "󰂲", "connected": False}

def get_wifi_fast():
    try:
        devs = subprocess.check_output(["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"], text=True, timeout=1).strip().split("\n")
        wifi_ssid = ""
        eth_conn = ""
        for line in devs:
            p = line.split(":")
            if len(p) >= 3:
                if p[0] == "wifi" and p[1] == "connected":
                    wifi_ssid = p[2]
                elif p[0] == "ethernet" and p[1] == "connected":
                    eth_conn = p[2]
        
        # Check radio state
        radio = subprocess.check_output(["nmcli", "radio", "wifi"], text=True, timeout=1).strip()
        wifi_enabled = radio == "enabled"

        if not wifi_enabled:
            icon = "󰤮"
        elif wifi_ssid:
            icon = "󰤨"
        else:
            icon = "󰤯"

        return {
            "enabled": wifi_enabled,
            "connected": bool(wifi_ssid),
            "ssid": wifi_ssid,
            "ethernet": eth_conn,
            "icon": icon
        }
    except Exception:
        return {"enabled": True, "connected": False, "ssid": "", "ethernet": "", "icon": "󰤮"}

def cmd_fast():
    data = {
        "bluetooth": get_bluetooth_fast(),
        "network": get_wifi_fast(),
        "audio": get_audio_info(),
        "display": get_brightness_info(),
        "battery": get_battery_info()
    }
    print(json.dumps(data))

def cmd_tab_bluetooth():
    try:
        rf = subprocess.check_output(["rfkill", "list", "bluetooth"], text=True, timeout=1)
        blocked = "Soft blocked: yes" in rf
        
        adapter_name = "Bluetooth Controller"
        powered = not blocked
        if powered:
            show = subprocess.check_output(["bluetoothctl", "show"], text=True, timeout=1)
            powered = "Powered: yes" in show
            for line in show.split("\n"):
                if "Alias:" in line or "Name:" in line:
                    adapter_name = line.split(":", 1)[1].strip()
                    break

        paired = []
        try:
            p_out = subprocess.check_output(["bluetoothctl", "devices", "Paired"], text=True, timeout=1).strip().split("\n")
            for line in p_out:
                if line.startswith("Device"):
                    parts = line.split(maxsplit=2)
                    paired.append({"mac": parts[1], "name": parts[2] if len(parts) > 2 else parts[1]})
        except Exception:
            pass

        connected = []
        try:
            c_out = subprocess.check_output(["bluetoothctl", "devices", "Connected"], text=True, timeout=1).strip().split("\n")
            for line in c_out:
                if line.startswith("Device"):
                    parts = line.split(maxsplit=2)
                    connected.append({"mac": parts[1], "name": parts[2] if len(parts) > 2 else parts[1]})
        except Exception:
            pass

        available = []
        try:
            a_out = subprocess.check_output(["bluetoothctl", "devices"], text=True, timeout=1).strip().split("\n")
            seen = {d["mac"] for d in paired + connected}
            for line in a_out:
                if line.startswith("Device"):
                    parts = line.split(maxsplit=2)
                    mac = parts[1]
                    name = parts[2] if len(parts) > 2 else mac
                    if mac not in seen and name != mac:
                        available.append({"mac": mac, "name": name})
        except Exception:
            pass

        print(json.dumps({
            "enabled": powered,
            "adapter": adapter_name,
            "connected": connected,
            "paired": paired,
            "available": available[:8]
        }))
    except Exception as e:
        print(json.dumps({"enabled": False, "adapter": "Error", "connected": [], "paired": [], "available": [], "error": str(e)}))

def cmd_tab_wifi():
    try:
        radio = subprocess.check_output(["nmcli", "radio", "wifi"], text=True, timeout=1).strip()
        wifi_enabled = radio == "enabled"
        
        active_conn = {"ssid": "", "signal": 0, "security": "", "ip": "", "gateway": "", "device": "wlp2s0"}
        networks = []
        seen = set()

        try:
            wifi_dev = subprocess.check_output(["bash", "-c", "nmcli -t -f DEVICE,TYPE device | grep ':wifi$' | cut -d: -f1 | head -n1"], text=True, timeout=1).strip()
            if wifi_dev:
                active_conn["device"] = wifi_dev
                dev_info = subprocess.check_output(["nmcli", "-t", "-f", "IP4.ADDRESS,IP4.GATEWAY", "device", "show", wifi_dev], text=True, timeout=1).strip().split("\n")
                for line in dev_info:
                    if line.startswith("IP4.ADDRESS"):
                        active_conn["ip"] = line.split(":", 1)[1]
                    elif line.startswith("IP4.GATEWAY"):
                        active_conn["gateway"] = line.split(":", 1)[1]
            
            cur_wifi = subprocess.check_output(["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", "no"], text=True, timeout=2).strip().split("\n")
            for line in cur_wifi:
                if not line: continue
                parts = line.split(":")
                is_active = parts[0].strip() == "*"
                ssid = parts[1] if len(parts) > 1 else ""
                sig = int(parts[2]) if len(parts) > 2 and parts[2].isdigit() else 0
                sec = parts[3] if len(parts) > 3 else ""
                if is_active and not active_conn["ssid"]:
                    active_conn["ssid"] = ssid
                    active_conn["signal"] = sig
                    active_conn["security"] = sec
                    seen.add(ssid)
                elif ssid and ssid not in seen:
                    seen.add(ssid)
                    networks.append({"ssid": ssid, "signal": sig, "security": sec, "connected": False})
        except Exception as e:
            active_conn["error"] = str(e)

        # Ethernet
        eth_status = "Disconnected"
        try:
            eth_out = subprocess.check_output(["bash", "-c", "nmcli -t -f TYPE,STATE device | grep '^ethernet:'"], text=True, timeout=1).strip()
            if "connected" in eth_out: eth_status = "Connected"
        except Exception:
            pass

        print(json.dumps({
            "enabled": wifi_enabled,
            "connected": bool(active_conn["ssid"]),
            "current": active_conn,
            "networks": networks[:10],
            "ethernet": eth_status
        }))
    except Exception as e:
        print(json.dumps({"enabled": False, "connected": False, "current": {}, "networks": [], "ethernet": "Unavailable", "error": str(e)}))

def cmd_tab_audio():
    try:
        audio_fast = get_audio_info()
        def_sink = subprocess.check_output(["pactl", "get-default-sink"], text=True, timeout=1).strip()
        def_source = subprocess.check_output(["pactl", "get-default-source"], text=True, timeout=1).strip()

        sinks = []
        try:
            sinks_json = json.loads(subprocess.check_output(["pactl", "-f", "json", "list", "sinks"], text=True, timeout=1))
            for s in sinks_json:
                name = s.get("name", "")
                desc = s.get("description", "")
                label = desc if desc else name.replace("alsa_output.", "").replace(".analog-stereo", "").replace("_", " ").title()
                sinks.append({"id": str(s.get("index", "")), "name": name, "label": label, "active": name == def_sink})
        except Exception:
            out_s = subprocess.check_output(["pactl", "list", "short", "sinks"], text=True, timeout=1).strip().split("\n")
            for line in out_s:
                if line:
                    p = line.split()
                    name = p[1]
                    label = name.replace("alsa_output.", "").replace(".analog-stereo", "").replace("_", " ").title()
                    sinks.append({"id": p[0], "name": name, "label": label, "active": name == def_sink})

        sources = []
        try:
            sources_json = json.loads(subprocess.check_output(["pactl", "-f", "json", "list", "sources"], text=True, timeout=1))
            for s in sources_json:
                name = s.get("name", "")
                if not name.endswith(".monitor"):
                    desc = s.get("description", "")
                    label = desc if desc else name.replace("alsa_input.", "").replace(".analog-stereo", "").replace("_", " ").title()
                    sources.append({"id": str(s.get("index", "")), "name": name, "label": label, "active": name == def_source})
        except Exception:
            out_src = subprocess.check_output(["pactl", "list", "short", "sources"], text=True, timeout=1).strip().split("\n")
            for line in out_src:
                if line:
                    p = line.split()
                    name = p[1]
                    if not name.endswith(".monitor"):
                        label = name.replace("alsa_input.", "").replace(".analog-stereo", "").replace("_", " ").title()
                        sources.append({"id": p[0], "name": name, "label": label, "active": name == def_source})

        print(json.dumps({
            "sinkVolume": audio_fast["sinkVolume"],
            "sinkMuted": audio_fast["sinkMuted"],
            "sourceVolume": audio_fast["sourceVolume"],
            "sourceMuted": audio_fast["sourceMuted"],
            "defaultSink": def_sink,
            "defaultSource": def_source,
            "sinks": sinks,
            "sources": sources
        }))
    except Exception as e:
        print(json.dumps({"sinkVolume": 100, "sinkMuted": False, "sourceVolume": 50, "sourceMuted": False, "sinks": [], "sources": [], "error": str(e)}))

def cmd_tab_display():
    try:
        b_info = get_brightness_info()
        m_raw = subprocess.check_output(["hyprctl", "monitors", "-j"], text=True, timeout=1)
        monitors = json.loads(m_raw)
        m_list = []
        for m in monitors:
            m_list.append({
                "name": m.get("name"),
                "description": m.get("description"),
                "width": m.get("width"),
                "height": m.get("height"),
                "refreshRate": round(m.get("refreshRate", 60), 1),
                "scale": m.get("scale", 1.0),
                "focused": m.get("focused", False),
                "modes": m.get("availableModes", [])[:8]
            })
        print(json.dumps({
            "brightness": b_info["brightness"],
            "monitors": m_list
        }))
    except Exception as e:
        print(json.dumps({"brightness": 100, "monitors": [], "error": str(e)}))

def cmd_tab_system():
    try:
        # Battery
        bat = get_battery_info()

        # CPU calculation
        def read_cpu():
            with open("/proc/stat") as f:
                fields = [float(x) for x in f.readline().strip().split()[1:]]
            idle = fields[3] + fields[4]
            total = sum(fields)
            return idle, total

        i1, t1 = read_cpu()
        time.sleep(0.08)
        i2, t2 = read_cpu()
        cpu_pct = round(100 * (1 - (i2 - i1) / (t2 - t1)), 1) if (t2 - t1) > 0 else 0.0

        # Memory & Swap
        mem = {}
        with open("/proc/meminfo") as f:
            for line in f:
                p = line.split(":")
                mem[p[0].strip()] = int(p[1].split()[0])

        ram_total = mem["MemTotal"] / 1024 / 1024
        ram_avail = mem["MemAvailable"] / 1024 / 1024
        ram_used = ram_total - ram_avail
        ram_pct = round(ram_used / ram_total * 100, 1)

        swap_total = mem.get("SwapTotal", 0) / 1024 / 1024
        swap_free = mem.get("SwapFree", 0) / 1024 / 1024
        swap_used = swap_total - swap_free
        swap_pct = round(swap_used / swap_total * 100, 1) if swap_total > 0 else 0.0

        # Disk
        st = os.statvfs("/")
        disk_total = (st.f_blocks * st.f_frsize) / (1024**3)
        disk_avail = (st.f_bavail * st.f_frsize) / (1024**3)
        disk_used = disk_total - disk_avail
        disk_pct = round(disk_used / disk_total * 100, 1)

        # Hardware Temps
        cpu_temp = 0
        gpu_temp = 0
        for hw in glob.glob("/sys/class/hwmon/hwmon*"):
            name = read_file_safe(f"{hw}/name", "")
            if "k10temp" in name or "coretemp" in name or "dell_smm" in name:
                t = read_file_safe(f"{hw}/temp1_input", "0")
                if t.isdigit() and int(t) > 0 and cpu_temp == 0:
                    cpu_temp = round(int(t) / 1000)
            elif "amdgpu" in name or "nouveau" in name or "nvidia" in name:
                t = read_file_safe(f"{hw}/temp1_input", "0")
                if t.isdigit() and int(t) > 0:
                    gpu_temp = round(int(t) / 1000)

        print(json.dumps({
            "battery": bat,
            "cpuPct": cpu_pct,
            "cpuTemp": cpu_temp,
            "ramUsed": round(ram_used, 1),
            "ramTotal": round(ram_total, 1),
            "ramPct": ram_pct,
            "swapUsed": round(swap_used, 1),
            "swapTotal": round(swap_total, 1),
            "swapPct": swap_pct,
            "diskUsed": round(disk_used, 1),
            "diskTotal": round(disk_total, 1),
            "diskPct": disk_pct,
            "gpuTemp": gpu_temp
        }))
    except Exception as e:
        print(json.dumps({"error": str(e)}))

def cmd_action(action, args):
    if action == "toggle-bluetooth":
        rf = subprocess.check_output(["rfkill", "list", "bluetooth"], text=True)
        if "Soft blocked: yes" in rf:
            subprocess.run(["rfkill", "unblock", "bluetooth"], check=False)
            subprocess.run(["bluetoothctl", "power", "on"], check=False)
        else:
            subprocess.run(["bluetoothctl", "power", "off"], check=False)
            subprocess.run(["rfkill", "block", "bluetooth"], check=False)

    elif action == "connect-bluetooth" and args:
        subprocess.run(["bluetoothctl", "connect", args[0]], check=False)

    elif action == "disconnect-bluetooth" and args:
        subprocess.run(["bluetoothctl", "disconnect", args[0]], check=False)

    elif action == "toggle-wifi":
        radio = subprocess.check_output(["nmcli", "radio", "wifi"], text=True).strip()
        new_state = "off" if radio == "enabled" else "on"
        subprocess.run(["nmcli", "radio", "wifi", new_state], check=False)

    elif action == "disconnect-wifi":
        wifi_dev = subprocess.check_output(["bash", "-c", "nmcli -t -f DEVICE,TYPE device | grep ':wifi$' | cut -d: -f1 | head -n1"], text=True).strip()
        if wifi_dev:
            subprocess.run(["nmcli", "device", "disconnect", wifi_dev], check=False)

    elif action == "connect-wifi" and args:
        ssid = args[0]
        if len(args) > 1 and args[1]:
            subprocess.run(["nmcli", "device", "wifi", "connect", ssid, "password", args[1]], check=False)
        else:
            subprocess.run(["nmcli", "device", "wifi", "connect", ssid], check=False)

    elif action == "rescan-wifi":
        subprocess.run(["nmcli", "device", "wifi", "rescan"], check=False)

    elif action == "set-volume" and args:
        val = int(args[0])
        subprocess.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", f"{val / 100:.2f}"], check=False)

    elif action == "adjust-volume" and args:
        delta = args[0] # e.g. "5%+" or "5%-"
        subprocess.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", delta], check=False)

    elif action == "toggle-sink-mute":
        subprocess.run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"], check=False)

    elif action == "set-source-volume" and args:
        val = int(args[0])
        subprocess.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", f"{val / 100:.2f}"], check=False)

    elif action == "toggle-source-mute":
        subprocess.run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"], check=False)

    elif action == "set-sink" and args:
        subprocess.run(["pactl", "set-default-sink", args[0]], check=False)

    elif action == "set-source" and args:
        subprocess.run(["pactl", "set-default-source", args[0]], check=False)

    elif action == "set-brightness" and args:
        val = int(args[0])
        subprocess.run(["brightnessctl", "set", f"{val}%"], check=False)

    elif action == "adjust-brightness" and args:
        delta = args[0] # e.g. "5%+" or "5%-"
        subprocess.run(["brightnessctl", "set", delta], check=False)

    elif action == "set-mode" and len(args) >= 2:
        mon = args[0]
        mode = args[1]
        subprocess.run(["hyprctl", "keyword", f"monitor", f"{mon},{mode},auto,1.25"], check=False)

    print(json.dumps({"ok": True}))

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] == "fast":
        cmd_fast()
    elif sys.argv[1] == "tab" and len(sys.argv) > 2:
        tab = sys.argv[2]
        if tab == "bluetooth": cmd_tab_bluetooth()
        elif tab == "wifi": cmd_tab_wifi()
        elif tab == "audio": cmd_tab_audio()
        elif tab == "display": cmd_tab_display()
        elif tab == "system": cmd_tab_system()
    elif sys.argv[1] == "action" and len(sys.argv) > 2:
        cmd_action(sys.argv[2], sys.argv[3:])
