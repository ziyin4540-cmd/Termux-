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

print('ဗီဒီယိုကို ဖိုင်ဆိုဒ်သေးငယ်အောင် (50MB အောက်) ဒေါင်းလုပ်ဆွဲနေပါပြီ...')
# ဖိုင်ဆိုဒ်ကြီးပြီး Telegram Error မတက်အောင် 480p ဖြင့် သေချာကန့်သတ်ထားသည်
subprocess.run([
    'yt-dlp', '--js-runtimes', 'deno', 
    '-f', 'bv*[height<=480]+ba/b[height<=480] / best[height<=480]', 
    '--merge-output-format', 'mp4', '--force-overwrites', 
    '-o', 'downloaded_video.%(ext)s', tg_link
])

vid_file = None
for f in os.listdir('.'):
    if f.startswith('downloaded_video.'):
        vid_file = f
        break

if vid_file and os.path.exists(vid_file):
    # ဖိုင်ဆိုဒ်ကို စစ်ဆေးခြင်း (50MB ကျော်နေပါက သတိပေးရန်)
    file_size_mb = os.path.getsize(vid_file) / (1024 * 1024)
    print(f'ဒေါင်းလုပ်ရလာသော ဖိုင်ဆိုဒ်: {file_size_mb:.2f} MB')

    print('Telegram Topic ထဲသို့ တင်နေပါပြီ (ခဏစောင့်ပါ)...')
    url = f"https://api.telegram.org/bot{config['bot_token']}/sendVideo"
    try:
        with open(vid_file, 'rb') as f_vid:
            files = {'video': f_vid}
            data = {
                'chat_id': config['chat_id'],
                'message_thread_id': thread_id,
                'caption': custom_caption,
                'supports_streaming': 'True'
            }
            res = requests.post(url, data=data, files=files, timeout=300)
            if res.status_code == 200:
                print('Telegram Topic ထဲသို့ အောင်မြင်စွာ ပို့ပြီးပါပြီ!')
            else:
                print('ပို့ဆောင်မှု မအောင်မြင်ပါ (Telegram Response):', res.text)
    except Exception as e:
        print(f'ချိတ်ဆက်မှု အမှားအယွင်း ဖြစ်ပေါ်သည်: {e}')
    
    if os.path.exists(vid_file):
        os.remove(vid_file)
else:
    print('ဗီဒီယို ဒေါင်းလုပ်ဆွဲ၍ မရပါ။')
