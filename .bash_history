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
                    print(f'\n[ ✔ ] \"{selected_name}\" Key ကို ဖုန်း Clipboard ထဲသို့ အောင်မြင်စွာ Copy ကူးပြီးပါပြီ!')
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
        5)
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
                print(f'\n[ ✔ ] \"{del_name}\" Key ကို အောင်မြင်စွာ ဖျက်လိုက်ပါပြီ!')
            else:
                print('နံပါတ် ရွေးချယ်မှု မှားယွင်းနေပါသည်။')
        else:
            print('မှားယွင်းနေပါသည်။')
"
            echo "----------------------------------"
            read -p "ဆက်လုပ်ရန် Enter ခေါက်ပါ..."
            ;;
        6)
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
        7)
            echo "Termux မှ ထွက်လိုက်ပါပြီ။"
            break
            ;;
        *)
            echo "မှားယွင်းနေပါသည်။ နံပါတ် ၁ မှ ၇ ထိသာ ရွေးပါ။"
            sleep 1.5
            ;;
    esac
done
EOF

echo "ပြင်ဆင်ပြီးပါပြီ! ယခုတင်လိုက်သော ဗီဒီယိုများကို Telegram ထဲတွင် အစအဆုံး မစောင့်ဘဲ Downloading လုပ်ရင်း တစ်ပြိုင်နက် ဖွင့်ကြည့်နိုင်ပါပြီ။"
bash
# ၁။ အရင် ဖိုင်ဟောင်းများနှင့် အလုပ်လုပ်နေသော process များကို ရပ်ဆိုင်းခြင်း
pkill -f bash
pkill -f python3
cd ~
# ၂။ .bashrc ထဲတွင် အရင် menu ဟောင်းကို ခေါ်နေသော ညွှန်ကြားချက်များကို ဖျက်ဆီးခြင်း
sed -i '/menu/d' ~/.bashrc
sed -i '/send_tg/d' ~/.bashrc
sed -i '/bot.py/d' ~/.bashrc
# ၃။ ရှိသမျှ ဖိုင်ဟောင်းများအားလုံးကို လုံးဝဖျက်ထုတ်ခြင်း
rm -rf menu.sh bot.py send_tg.py topics.json vpn_keys.json
# ၄။ topics.json ဖိုင်အသစ် ဖန်တီးခြင်း
cat << 'EOF' > ~/topics.json
{
    "bot_token": "8872323637:AAHVpDfwc8EyA3w1FxA6Llh4_uVwq_-v1NI",
    "chat_id": "-1004430875541",
    "topics": {
        "Funny Shot Tiktok": "1",
        "Music Video": "6",
        "အသဲကွဲသီချင်းများ": "13",
        "အချစ်သီချင်းများ": "15"
    }
}
EOF

# ၅။ send_tg.py ဖိုင်အသစ် ဖန်တီးခြင်း
cat << 'EOF' > ~/send_tg.py
import json, os, subprocess, requests

config_path = 'topics.json'
if not os.path.exists(config_path):
    print("topics.json မရှိပါ။")
    exit()

with open(config_path, 'r', encoding='utf-8') as f:
    config = json.load(f)

print('\n--- ရရှိနိုင်သော Topic များ ---')
topics = config['topics']
topic_keys = list(topics.keys())
for idx, name in enumerate(topic_keys, 1):
    print(f'{idx}. {name}')
print(f'{len(topic_keys) + 1}. Topic အသစ်အဖြစ် ထည့်ရန်')

choice_top = input('Topic နံပါတ် ရွေးပါ: ')
if not choice_top.isdigit():
    print('နံပါတ် မှားယွင်းနေပါသည်။')
    exit()

c_idx = int(choice_top)
if 1 <= c_idx <= len(topic_keys):
    selected_name = topic_keys[c_idx - 1]
    thread_id = topics[selected_name]
elif c_idx == len(topic_keys) + 1:
    new_name = input('Topic အသစ် နာမည်ပေးပါ: ')
    new_id = input('အဲ့ဒီ Topic ရဲ့ Thread ID ထည့်ပါ: ')
    topics[new_name] = new_id
    config['topics'] = topics
    with open(config_path, 'w', encoding='utf-8') as f:
        json.dump(config, f, ensure_ascii=False, indent=4)
    selected_name = new_name
    thread_id = new_id
else:
    print('နံပါတ် ရွေးချယ်မှု မှားယွင်းနေပါသည်။')
    exit()

tg_link = input('YouTube / TikTok Link ထည့်ပါ: ')
if not tg_link:
    print('လင့်ခ် မထည့်ရသေးပါ။')
    exit()

custom_caption = input('Telegram တွင် တင်မည့် Caption ရိုက်ထည့်ပါ: ')

print('ဗီဒီယိုကို ဒေါင်းလုပ်ဆွဲနေပါပြီ...')
subprocess.run([
    'yt-dlp', '--js-runtimes', 'deno', 
    '-f', 'bv*[height<=720]+ba/b[height<=720] / best', 
    '--merge-output-format', 'mp4', '--force-overwrites', 
    '-o', 'downloaded_video.%(ext)s', tg_link
])

vid_file = None
for f in os.listdir('.'):
    if f.startswith('downloaded_video.'):
        vid_file = f
        break

if vid_file and os.path.exists(vid_file):
    print('ဗီဒီယိုကို Streaming ကြည့်လို့ရအောင် ပြင်ဆင်နေပါပြီ...')
    final_video = 'stream_ready_video.mp4'
    subprocess.run([
        'ffmpeg', '-y', '-i', vid_file, '-c', 'copy',
        '-movflags', '+faststart', final_video
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    if not os.path.exists(final_video):
        final_video = vid_file

    print('Telegram Topic ထဲသို့ တင်နေပါပြီ...')
    url = f"https://api.telegram.org/bot{config['bot_token']}/sendVideo"
    with open(final_video, 'rb') as f_vid:
        files = {'video': f_vid}
        data = {
            'chat_id': config['chat_id'],
            'message_thread_id': thread_id,
            'caption': custom_caption,
            'supports_streaming': 'True'
        }
        res = requests.post(url, data=data, files=files)
        if res.status_code == 200:
            print('Telegram Topic ထဲသို့ အောင်မြင်စွာ ပို့ပြီးပါပြီ!')
        else:
            print('ပို့ဆောင်မှု မအောင်မြင်ပါ:', res.text)
    
    if os.path.exists(vid_file):
        os.remove(vid_file)
    if os.path.exists('stream_ready_video.mp4'):
        os.remove('stream_ready_video.mp4')
else:
    print('ဗီဒီယို ဒေါင်းလုပ်ဆွဲ၍ မရပါ။')
EOF

# ၆။ hub.sh ဖိုင်အသစ် ဖန်တီးခြင်း (နာမည်အသစ်ဖြင့်)
cat << 'EOF' > ~/hub.sh
#!/bin/bash
while true; do
    clear
    echo -e "\e[1;35m"
    figlet -f slant "Wai Lin Yan" | lolcat
    echo -e "\e[0m"
    echo "=================================="
    echo "       WAI LIN YAN UTILITY HUB    "
    echo "=================================="
    echo "1. YouTube / TikTok (MP4 ဖြင့် ဒေါင်းရန်)"
    echo "2. Telegram Topic အလိုက် တိုက်ရိုက်ပို့ရန်"
    echo "3. VPN Key ထည့်ရန်"
    echo "4. VPN Key ယူရန် (Auto Copy)"
    echo "5. VPN Key ဖျက်ရန်"
    echo "6. Internet Speedtest စစ်ရန်"
    echo "7. Termux မှ ထွက်ရန် (Exit)"
    echo "----------------------------------"
    read -p "လိုချင်တဲ့ နံပါတ်ကို ရွေးပါ (1-7): " choice

    case $choice in
        1)
            echo "----------------------------------"
            echo "    YT & TIKTOK MP4 DOWNLOADER    "
            echo "----------------------------------"
            read -p "Video Link ထည့်ပါ: " yt_link
            if [ -n "$yt_link" ]; then
                echo "ဗီဒီယိုကို MP4 ဖြင့် ဒေါင်းလုပ်ဆွဲနေပါပြီ..."
                yt-dlp --js-runtimes deno -f "bv*[height<=720]+ba/b[height<=720] / best" --merge-output-format mp4 --force-overwrites -P "/storage/emulated/0/Movies" -o "%(id)s.%(ext)s" "$yt_link"
                
                echo "Gallery တွင် ပေါ်လာစေရန် ဖိုင်ကို စစ်ဆေးနေပါပြီ..."
                find /storage/emulated/0/Movies -type f -mmin -1 -exec am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file://{} \;
                
                echo "ဒေါင်းလုပ်ဆွဲခြင်း ပြီးဆုံးပါပြီ။ (Gallery ထဲရှိ Movies ဖိုင်တွဲတွင် ဝင်ကြည့်ပါ)"
            else
                echo "လင့်ခ် မထည့်ရသေးပါ။"
            fi
            echo "----------------------------------"
            read -p "ဆက်လုပ်ရန် Enter ခေါက်ပါ..."
            ;;
        2)
            echo "----------------------------------"
            echo "    TELEGRAM TOPIC MANAGER        "
            echo "----------------------------------"
            python3 send_tg.py
            echo "----------------------------------"
            read -p "ဆက်လုပ်ရန် Enter ခေါက်ပါ..."
            ;;
        3)
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
        4)
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
        5)
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
        6)
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
        7)
            echo "Termux မှ ထွက်လိုက်ပါပြီ။"
            break
            ;;
        *)
            echo "မှားယွင်းနေပါသည်။ နံပါတ် ၁ မှ ၇ ထိသာ ရွေးပါ။"
            sleep 1.5
            ;;
    esac
done
EOF

# ၇။ ခွင့်ပြုချက်ပေးပြီး ဖိုင်အသစ်ကို စတင်ခြင်း
chmod +x ~/hub.sh
~/hub.sh
cat << 'EOF' > ~/hub.sh
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
path = '/storage/emulated/0/Movies'
if not os.path.exists(path):
    print('Movies ဖိုင်တွဲ မရှိပါ။')
else:
    files = [f for f in os.listdir(path) if f.endswith('.mp4')]
    if not files:
        print('[ ! ] Movies ဖိုင်တွဲထဲတွင် MP4 ဖိုင်များ မရှိပါ။')
    else:
        print('\n--- ရရှိနိုင်သော MP4 ဖိုင်များ ---')
        for idx, f in enumerate(files, 1):
            print(f'{idx}. {f}')
        print('-' * 30)
        choice = input('MP3 ပြောင်းမည့် ဖိုင်နံပါတ်ကို ရွေးပါ: ')
        if choice.isdigit():
            c = int(choice)
            if 1 <= c <= len(files):
                selected = files[c - 1]
                in_path = os.path.join(path, selected)
                out_name = os.path.splitext(selected)[0] + '.mp3'
                out_dir = '/storage/emulated/0/Music'
                os.makedirs(out_dir, exist_ok=True)
                out_path = os.path.
bash


bash
