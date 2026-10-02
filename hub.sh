#!/bin/bash
while true; do
    clear
    echo -e "\e[1;35m"
    figlet -f slant "Wai Lin Yan" | lolcat
    echo -e "\e[0m"
    echo "=================================="
    echo "       WAI LIN YAN UTILITY HUB    "
    echo "=================================="
    echo "1. YouTube / TikTok / Facebook (MP4)"
    echo "2. YouTube / TikTok / Facebook (MP3)"
    echo "3. MP4 to MP3 Converter (Local Files)"
    echo "4. Telegram Topic အလိုက် တိုက်ရိုက်ပို့ရန်"
    echo "5. VPN Key ထည့်ရန်"
    echo "6. VPN Key ယူရန် (Auto Copy)"
    echo "7. VPN Key ဖျက်ရန်"
    echo "8. Internet Speedtest စစ်ရန်"
    echo "9. Termux မှ ထွက်ရန် (Exit)"
    echo "----------------------------------"
    read -p "လိုချင်တဲ့ နံပါတ်ကို ရွေးပါ (1-9): " choice

    case $choice in
        1)
            echo "----------------------------------"
            echo "    VIDEO DOWNLOADER (MP4)        "
            echo "----------------------------------"
            read -p "Video Link ထည့်ပါ (YT, TikTok, FB): " yt_link
            if [ -n "$yt_link" ]; then
                echo "ဗီဒီယိုကို MP4 ဖြင့် ဒေါင်းလုပ်ဆွဲနေပါပြီ..."
                yt-dlp --js-runtimes deno -f "bv*[height<=720]+ba/b[height<=720] / best" --merge-output-format mp4 --force-overwrites -P "/storage/emulated/0/Movies" -o "%(id)s.%(ext)s" "$yt_link"
                
                echo "Gallery တွင် ပေါ်လာစေရန် ဖိုင်ကို စစ်ဆေးနေပါပြီ..."
                find /storage/emulated/0/Movies -type f -mmin -1 -exec am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file://{} \;
                echo "ဒေါင်းလုပ်ဆွဲခြင်း ပြီးဆုံးပါပြီ။ (Movies ဖိုင်တွဲတွင် ကြည့်ပါ)"
            else
                echo "လင့်ခ် မထည့်ရသေးပါ။"
            fi
            echo "----------------------------------"
            read -p "ဆက်လုပ်ရန် Enter ခေါက်ပါ..."
            ;;
        2)
            echo "----------------------------------"
            echo "    AUDIO DOWNLOADER (MP3)        "
            echo "----------------------------------"
            read -p "Video Link ထည့်ပါ (YT, TikTok, FB): " mp3_link
            if [ -n "$mp3_link" ]; then
                echo "အသံဖိုင် (MP3) ကို ဒေါင်းလုပ်ဆွဲနေပါပြီ..."
                yt-dlp --js-runtimes deno -x --audio-format mp3 --audio-quality 192k -P "/storage/emulated/0/Music" -o "%(id)s.%(ext)s" "$mp3_link"
                
                echo "Music ဖိုင်တွဲတွင် ပေါ်လာစေရန် စစ်ဆေးနေပါပြီ..."
                find /storage/emulated/0/Music -type f -mmin -1 -exec am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file://{} \;
                echo "အသံဖိုင် ဆွဲခြင်း ပြီးဆုံးပါပြီ။ (Music ဖိုင်တွဲတွင် ဝင်ကြည့်ပါ)"
            else
                echo "လင့်ခ် မထည့်ရသေးပါ။"
            fi
            echo "----------------------------------"
            read -p "ဆက်လုပ်ရန် Enter ခေါက်ပါ..."
            ;;
        3)
            echo "----------------------------------"
            echo "    MP4 to MP3 CONVERTER          "
            echo "----------------------------------"
            python3 -c "
import os, subprocess
folders = {
    '1': '/storage/emulated/0/Movies',
    '2': '/storage/emulated/0/Download',
    '3': '/storage/emulated/0/Telegram/Telegram Video',
    '4': '/storage/emulated/0/DCIM/Camera',
    '5': 'Custom Path (ဖိုင်လမ်းကြောင်း ကိုယ်တိုင်ရိုက်ရန်)'
}
print('\n--- ဖိုင်တွဲ (Folder) ရွေးချယ်ပါ ---')
for k, v in folders.items():
    print(f'{k}. {v}')
f_choice = input('ဖိုင်တွဲ နံပါတ် ရွေးပါ: ')
path = ''
if f_choice in ['1', '2', '3', '4']:
    path = folders[f_choice]
elif f_choice == '5':
    path = input('ဖိုင်လမ်းကြောင်း (Path) အပြည့်အစုံ ရိုက်ထည့်ပါ: ').strip()
else:
    path = '/storage/emulated/0/Download'

if not os.path.exists(path):
    print(f'ဒီဖိုင်တွဲ ({path}) မရှိပါ။')
else:
    print('ဖိုင်တွဲများနှင့် Subfolder များထဲပါ MP4 ဖိုင်များကို ရှာဖွေနေပါပြီ...')
    file_paths = []
    for root, dirs, files in os.walk(path):
        for file in files:
            if file.lower().endswith('.mp4'):
                file_paths.append(os.path.join(root, file))
    
    if not file_paths:
        print(f'\n[ ! ] ဒီဖိုင်တွဲအတွင်း MP4 ဖိုင်များ လုံးဝ မရှိပါ။')
    else:
        print(f'\n--- တွေ့ရှိရသော MP4 ဖိုင်များ ({len(file_paths)} ခု) ---')
        for idx, fp in enumerate(file_paths, 1):
            rel_name = os.path.relpath(fp, path)
            print(f'{idx}. {rel_name}')
        print('-' * 30)
        choice = input('MP3 ပြောင်းမည့် ဖိုင်နံပါတ်ကို ရွေးပါ: ')
        if choice.isdigit():
            c = int(choice)
            if 1 <= c <= len(file_paths):
                in_path = file_paths[c - 1]
                selected = os.path.basename(in_path)
                out_name = os.path.splitext(selected)[0] + '.mp3'
                out_dir = '/storage/emulated/0/Music'
                os.makedirs(out_dir, exist_ok=True)
                out_path = os.path.join(out_dir, out_name)
                print(f'\\\"{selected}\\\"')
                print('MP3 သို့ ပြောင်းနေပါပြီ (ခဏစောင့်ပါ)...')
                cmd = ['ffmpeg', '-i', in_path, '-vn', '-ab', '192k', out_path, '-y']
                res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                if res.returncode == 0:
                    print(f'\n[ ✔ ] အောင်မြင်စွာ ပြောင်းပြီးပါပြီ!')
                    print(f'သိမ်းဆည်းထားသည့်နေရာ: Music ဖိုင်တွဲထဲရှိ {out_name}')
                    os.system(f'am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file://{out_path}')
                else:
                    print('\n[ ! ] ပြောင်းလဲရာတွင် အမှားအယွင်း ရှိသွားပါသည်။')
            else:
                print('နံပါတ် မှားယွင်းနေပါသည်။')
        else:
            print('ထည့်သွင်းမှု မှားယွင်းနေပါသည်။')
"
            echo "----------------------------------"
            read -p "ဆက်လုပ်ရန် Enter ခေါက်ပါ..."
            ;;
        4)
            echo "----------------------------------"
            echo "    TELEGRAM TOPIC MANAGER        "
            echo "----------------------------------"
            python3 send_tg.py
            echo "----------------------------------"
            read -p "ဆက်လုပ်ရန် Enter ခေါက်ပါ..."
            ;;
        5)
            echo "----------------------------------"
            echo "       VPN KEY ထည့်သွင်းခြင်း       "
            echo "----------------------------------"
            python3 -c "
import json, os
file_path = 'vpn_keys.json'
data = {}
if os.path.exists(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except:
        pass
name = input('Key နာမည် (Key Name) ထည့်ပါ: ')
if name:
    key_val = input('VPN Key ကို ထည့်ပါ (Paste လုပ်ပါ): ')
    data[name] = key_val
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
    print(f'\\\"{name}\\\" Key ကို အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ!')
else:
    print('နာမည် မထည့်ရသေးပါ။')
"
            echo "----------------------------------"
            read -p "ဆက်လုပ်ရန် Enter ခေါက်ပါ..."
            ;;
        6)
            echo "----------------------------------"
            echo "     VPN KEY ယူရန် (Auto Copy)     "
            echo "----------------------------------"
            python3 -c "
import json, os, subprocess
file_path = 'vpn_keys.json'
if not os.path.exists(file_path):
    print('သိမ်းဆည်းထားသော VPN Key များ မရှိသေးပါ။')
else:
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    if not data:
        print('Key စာရင်း မရှိပါ။')
    else:
        keys = list(data.keys())
        print('\n--- ရရှိနိုင်သော VPN Key များ ---')
        for idx, k in enumerate(keys, 1):
            print(f'{idx}. Name: {k}')
            print(f'   Key : {data[k]}')
            print('-' * 40)
        choice = input('လိုချင်သော Key နံပါတ်ကို ရိုက်ပါ: ')
        if choice.isdigit():
            c = int(choice)
            if 1 <= c <= len(keys):
                selected_name = keys[c - 1]
                val = data[selected_name]
                try:
                    subprocess.run(['termux-clipboard-set', val])
                    print(f'\n[ ✔ ] \\\"{selected_name}\\\" Key ကို ဖုန်း Clipboard ထဲသို့ အောင်မြင်စွာ Copy ကူးပြီးပါပြီ!')
                except Exception as e:
                    print('\n[ ! ] Auto copy မလုပ်နိုင်ပါ။')
            else:
                print('နံပါတ် ရွေးချယ်မှု မှားယွင်းနေပါသည်။')
        else:
            print('မှားယွင်းနေပါသည်။')
"
            echo "----------------------------------"
            read -p "ဆက်လုပ်ရန် Enter ခေါက်ပါ..."
            ;;
        7)
            echo "----------------------------------"
            echo "        VPN KEY ပြန်ဖျက်ရန်          "
            echo "----------------------------------"
            python3 -c "
import json, os
file_path = 'vpn_keys.json'
if not os.path.exists(file_path):
    print('ဖျက်ရန် Key စာရင်း မရှိပါ။')
else:
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    if not data:
        print('ဖျက်စရာ Key များ မရှိပါ။')
    else:
        keys = list(data.keys())
        print('\n--- ဖျက်လိုသော VPN Key ကို ရွေးပါ ---')
        for idx, k in enumerate(keys, 1):
            print(f'{idx}. {k}')
        choice = input('ဖျက်မည့် Key နံပါတ်ကို ရွေးပါ: ')
        if choice.isdigit():
            c = int(choice)
            if 1 <= c <= len(keys):
                del_name = keys[c - 1]
                del data[del_name]
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=4)
                print(f'\n[ ✔ ] \\\"{del_name}\\\" Key ကို အောင်မြင်စွာ ဖျက်လိုက်ပါပြီ!')
            else:
                print('နံပါတ် ရွေးချယ်မှု မှားယွင်းနေပါသည်။')
        else:
            print('မှားယွင်းနေပါသည်။')
"
            echo "----------------------------------"
            read -p "ဆက်လုပ်ရန် Enter ခေါက်ပါ..."
            ;;
        8)
            echo "----------------------------------"
            echo "အင်တာနက် အမြန်နှုန်း (Speed) ကို စစ်ဆေးနေပါပြီ..."
            python3 -c "
import time, urllib.request
headers = {'User-Agent': 'Mozilla/5.0'}
ping_times = []
for _ in range(3):
    start = time.time()
    try:
        req = urllib.request.Request('https://speed.cloudflare.com/cdn-cgi/trace', headers=headers)
        with urllib.request.urlopen(req, timeout=5) as resp:
            resp.read()
        ping_times.append((time.time() - start) * 1000)
    except:
        pass
ping = sum(ping_times)/len(ping_times) if ping_times else 0
print(f'Ping: {ping:.2f} ms')
"
            echo "----------------------------------"
            read -p "ဆက်လုပ်ရန် Enter ခေါက်ပါ..."
            ;;
        9)
            echo "Termux မှ ထွက်လိုက်ပါပြီ။"
            break
            ;;
        *)
            echo "မှားယွင်းနေပါသည်။ နံပါတ် ၁ မှ ၉ ထိသာ ရွေးပါ။"
            sleep 1.5
            ;;
    esac
done
