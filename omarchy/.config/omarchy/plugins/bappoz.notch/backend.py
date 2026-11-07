#!/usr/bin/env python3
"""Local Linux adapters for Notchi. No shell interpolation or credential collection."""
import argparse
import contextlib
import datetime as dt
import fcntl
import json
import math
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import time
from urllib.parse import unquote, urlsplit
from zoneinfo import ZoneInfo

HOME = Path.home()
STATE = Path(os.environ.get('XDG_STATE_HOME', HOME / '.local/state')) / 'omarchy-notch'
DATA = Path(os.environ.get('XDG_DATA_HOME', HOME / '.local/share')) / 'omarchy-notch'
CONFIG = Path(os.environ.get('XDG_CONFIG_HOME', HOME / '.config')) / 'omarchy-notch'
OMARCHY = Path(os.environ.get('OMARCHY_PATH', '/usr/share/omarchy'))


def run(argv, *, input=None, timeout=6):
    result = subprocess.run([str(a) for a in argv], input=input, capture_output=True,
                            text=True, timeout=timeout, check=False)
    if result.returncode:
        raise ValueError((result.stderr.strip() or result.stdout.strip() or
                          f'{Path(argv[0]).name}: operação indisponível')[:500])
    return result.stdout


def launch(argv):
    subprocess.Popen([str(a) for a in argv], stdin=subprocess.DEVNULL,
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                     start_new_session=True)


def read_json(path, fallback=None, limit=2_000_000):
    try:
        if path.stat().st_size > limit:
            return fallback
        return json.loads(path.read_text())
    except (OSError, ValueError):
        return fallback


def atomic_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    fd, temporary = tempfile.mkstemp(dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as stream:
            json.dump(value, stream, ensure_ascii=False)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


@contextlib.contextmanager
def locked_state():
    STATE.mkdir(parents=True, exist_ok=True, mode=0o700)
    with (STATE / 'state.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        value = read_json(STATE / 'state.json', {})
        if not isinstance(value, dict):
            value = {}
        yield value
        atomic_json(STATE / 'state.json', value)


def local_path(value):
    text = str(value)
    if '\x00' in text:
        raise ValueError('Caminho inválido')
    if text.startswith('file:'):
        parsed = urlsplit(text)
        if parsed.netloc not in ('', 'localhost') or parsed.query or parsed.fragment:
            raise ValueError('Use um arquivo local')
        text = unquote(parsed.path)
    elif '://' in text:
        raise ValueError('Use um arquivo local')
    path = Path(text)
    if not path.is_absolute():
        raise ValueError('Use um caminho absoluto')
    path = path.resolve(strict=True)
    if not path.is_file():
        raise ValueError('Selecione um arquivo')
    return path


def parse_lrc(text):
    lines = []
    for line in str(text)[:1_000_000].splitlines():
        tags = re.findall(r'\[(\d{1,3}):(\d{2}(?:\.\d{1,3})?)\]', line)
        words = re.sub(r'\[[^\]]*\]', '', line).strip()[:500]
        for minutes, seconds in tags:
            if float(seconds) < 60:
                lines.append({'time': int(minutes)*60 + float(seconds), 'text': words})
    return sorted(lines, key=lambda row: row['time'])[:10000]


def calendar_grid(year, month):
    first = dt.date(int(year), int(month), 1)
    start = first - dt.timedelta(days=first.weekday())
    return [(start + dt.timedelta(days=i)).isoformat() for i in range(42)]


def clean(value, limit=300):
    return str(value or '').replace('\x00', '')[:limit]


def normalize_agent(raw):
    if not isinstance(raw, dict):
        raw = {}
    limits = []
    for item in raw.get('limits', []) if isinstance(raw.get('limits'), list) else []:
        if not isinstance(item, dict):
            continue
        try:
            percent = float(item.get('percent', 0))
            if not math.isfinite(percent):
                percent = 0
        except (TypeError, ValueError):
            percent = 0
        limits.append({'label': clean(item.get('label') or item.get('name') or 'Limite'),
                       'percent': min(100, max(0, percent * 100 if percent <= 1 else percent)),
                       'resetsAt': clean(item.get('resetsAt') or item.get('resetAt'))})
    return {'id': clean(raw.get('id'), 80),
            'name': clean(raw.get('name') or raw.get('displayName') or raw.get('id'), 80),
            'status': clean(raw.get('status') or ('ready' if raw.get('ready') else 'unavailable'), 50), 'limits': limits[:8]}


def file_row(path):
    path = Path(path)
    return {'path': str(path), 'url': path.as_uri(), 'name': path.name,
            'exists': path.is_file(), 'image': path.suffix.lower() in
            {'.png', '.jpg', '.jpeg', '.webp', '.gif', '.bmp'}}


def agent_status():
    folder = Path(os.environ.get('XDG_STATE_HOME', HOME / '.local/state'))/'omarchy/agents/usage'
    result = []
    for path in sorted(folder.glob('*.json'))[:40]:
        raw = read_json(path, {})
        if isinstance(raw, dict) and (raw.get('subscribed') or raw.get('limits') or raw.get('status') in ('active','ok','ready')):
            result.append(normalize_agent(raw))
    return result


def metrics():
    info = {}
    for line in Path('/proc/meminfo').read_text().splitlines():
        key, val = line.split(':', 1)
        info[key] = int(val.split()[0])
    total = info.get('MemTotal', 1)
    used = total - info.get('MemAvailable', 0)
    first = [int(x) for x in Path('/proc/stat').read_text().splitlines()[0].split()[1:]]
    time.sleep(.08)
    second = [int(x) for x in Path('/proc/stat').read_text().splitlines()[0].split()[1:]]
    delta = sum(second[:8]) - sum(first[:8])
    idle = second[3] + second[4] - first[3] - first[4]
    return {'cpu': round(100*(1-idle/delta)) if delta else 0,
            'memory': round(100*used/total), 'memoryGB': round(used/1048576,1),
            'totalGB': round(total/1048576,1)}


def batteries(root=Path('/sys/class/power_supply')):
    result = []
    for folder in sorted(root.glob('*')):
        def read(name, fallback=''):
            try:
                return (folder/name).read_text().strip()
            except OSError:
                return fallback
        try:
            if read('type') != 'Battery' or read('present', '1') == '0':
                continue
            percent = int(read('capacity'))
            if not 0 <= percent <= 100:
                continue
            scope = read('scope', 'Device' if folder.name.startswith(('hid', 'device')) else 'System')
            row = {'name': folder.name, 'percent': percent, 'scope': scope,
                   'charging': read('status') == 'Charging'}
            # Weight multiple internal packs by the same energy unit. Never mix
            # charge and energy or include a peripheral in the system total.
            if scope == 'System':
                energy_now, energy_full = int(read('energy_now', '0')), int(read('energy_full', '0'))
                if energy_full > 0 and 0 <= energy_now <= energy_full * 1.05:
                    row.update(energyNow=energy_now, energyFull=energy_full)
            result.append(row)
        except (ValueError, OSError):
            continue
    return sorted(result, key=lambda row: (row['scope'] != 'System', row['name']))


def system_battery(rows):
    packs = [row for row in rows if row.get('scope') == 'System']
    if not packs:
        return None
    if all(row.get('energyFull', 0) > 0 for row in packs):
        percent = 100 * sum(row['energyNow'] for row in packs) / sum(row['energyFull'] for row in packs)
    else:
        percent = sum(row['percent'] for row in packs) / len(packs)
    return {'name': packs[0]['name'] if len(packs) == 1 else ' + '.join(row['name'] for row in packs),
            'percent': max(0, min(100, round(percent))),
            'charging': any(row['charging'] for row in packs)}


def world_clocks():
    # These mirror the user's existing Elsewhen cities without reading private shell settings.
    cities = [('São Paulo','America/Sao_Paulo'),('Londres','Europe/London'),
              ('Dubai','Asia/Dubai'),('Tóquio','Asia/Tokyo'),('Los Angeles','America/Los_Angeles')]
    return [{'name': name, 'zone': zone, 'time': dt.datetime.now(ZoneInfo(zone)).strftime('%H:%M'),
             'date': dt.datetime.now(ZoneInfo(zone)).strftime('%d/%m')} for name, zone in cities]


def status():
    state = read_json(STATE/'state.json', {}) or {}
    if not isinstance(state,dict):state={}
    if not isinstance(state.get('shelf',[]),list):state['shelf']=[]
    power = batteries()
    return {'metrics': metrics(), 'batteries': power, 'systemBattery': system_battery(power), 'agents': agent_status(),
            'clocks': world_clocks(), 'timer': state.get('timer', {}),
            'shelf': [file_row(p) for p in state.get('shelf', [])[:40] if Path(p).is_absolute()],
            'settings': state.get('settings', {}),
            'tools': {name: bool(shutil.which(name)) for name in
                      ['tesseract','magick','hyprpicker','ffmpeg','ffplay','wl-copy','wpctl','brightnessctl']}}


def timer_start(minutes, label):
    minutes = int(minutes)
    if not 1 <= minutes <= 240:
        raise ValueError('Escolha entre 1 e 240 minutos')
    label = clean(label or 'Hora de fazer uma pausa', 180)
    unit = 'omarchy-notch-focus-' + str(time.time_ns())
    # systemd owns delivery, so closing/reloading the shell cannot lose the alert.
    with locked_state() as state:
        previous = state.get('timer', {}).get('unit', '')
        run(['systemd-run','--user','--quiet','--collect',f'--on-active={minutes}m',
             f'--unit={unit}','omarchy-notification-send','Notchi',label])
        if re.fullmatch(r'omarchy-notch-focus-\d+', previous):
            try:
                run(['systemctl','--user','stop',previous+'.timer',previous+'.service'])
            except (OSError, ValueError, subprocess.SubprocessError):
                # Roll back the replacement rather than orphaning two alerts.
                run(['systemctl','--user','stop',unit+'.timer',unit+'.service'])
                raise
        state['timer'] = {'unit':unit, 'label':label, 'end':time.time()+minutes*60,
                          'duration': minutes*60}
    return {'message':'Temporizador iniciado'}


def timer_cancel():
    with locked_state() as state:
        unit = state.get('timer',{}).get('unit','')
        if re.fullmatch(r'omarchy-notch-focus-\d+', unit):
            run(['systemctl','--user','stop',unit+'.timer',unit+'.service'])
        state['timer'] = {}
    return {'message':'Temporizador cancelado'}


def shelf_add(values):
    paths = [str(local_path(v)) for v in values[:40]]
    with locked_state() as state:
        state['shelf'] = list(dict.fromkeys(paths+state.get('shelf',[])))[:40]
    return {'message':f'{len(paths)} arquivo(s) na bandeja'}


def pick_files():
    selection = run(['zenity','--file-selection','--multiple','--separator=\n',
                     '--title=Adicionar à bandeja do Notchi'],timeout=300)
    return shelf_add(selection.strip().splitlines())


def convert(value, format):
    path = local_path(value)
    if path.suffix.lower() not in {'.png','.jpg','.jpeg','.webp','.bmp','.gif','.tiff','.heic'}:
        raise ValueError('Selecione uma imagem')
    if format not in ('png','webp','jpg'):
        raise ValueError('Formato inválido')
    export = DATA/'exports'
    export.mkdir(parents=True,exist_ok=True,mode=0o700)
    target = export/(path.stem+'-'+str(time.time_ns())+'.'+format)
    run(['magick', str(path)+'[0]', '-quality','90',target],timeout=40)
    shelf_add([str(target)])
    return {'message':'Imagem convertida; original preservado','path':str(target)}


def ocr(value):
    path = local_path(value)
    if path.suffix.lower() not in {'.png','.jpg','.jpeg','.webp','.bmp','.tiff','.pdf'}:
        raise ValueError('Selecione uma imagem ou PDF')
    with tempfile.TemporaryDirectory(prefix='notchi-ocr-') as folder:
        source = path
        if path.suffix.lower() == '.pdf':
            run(['pdftoppm','-f','1','-singlefile','-scale-to','3000','-png',path,Path(folder)/'page'],timeout=40)
            source = Path(folder)/'page.png'
        languages = run(['tesseract','--list-langs']).splitlines()
        lang = 'por+eng' if 'por' in languages else 'eng'
        text = run(['tesseract',source,'stdout','-l',lang],timeout=60)[:1_000_000]
        run(['wl-copy','--type','text/plain'],input=text)
    return {'message':'Texto reconhecido e copiado'}


def clipboard_list():
    data = read_json(HOME/'.local/state/omarchy/clipboard-history.json',[],limit=20_000_000)
    rows = []
    for index,item in enumerate(data[:500] if isinstance(data,list) else []):
        if not isinstance(item,dict):
            continue
        rows.append({'index':index,'kind':clean(item.get('kind') or item.get('type'),30),
                     'text': clean(item.get('text') or item.get('preview') or item.get('path'),500),
                     'path':clean(item.get('path'),2000)})
    return {'clipboard':rows[:60]}


def clipboard_copy(index):
    index = int(index)
    if not 0 <= index < 500:
        raise ValueError('Item inválido')
    history=read_json(HOME/'.local/state/omarchy/clipboard-history.json',[],limit=20_000_000)
    if not isinstance(history,list) or index>=len(history) or not isinstance(history[index],dict):
        raise ValueError('Esse item não está mais no histórico')
    entry=history[index]
    if entry.get('type',entry.get('kind'))=='image':
        path=local_path(entry.get('path',''))
        mime=str(entry.get('mime','image/png'))
        if mime not in ('image/png','image/jpeg','image/webp','image/gif','image/bmp'):
            raise ValueError('Formato de imagem inválido')
        run(['omarchy-clipboard-paste-file','--copy-only',mime,str(path)])
    else:
        run(['omarchy-clipboard-paste-text','--copy-only','--history-index',str(index)])
    return {'message':'Copiado'}


def ports():
    text = run(['ss','-ltnpH'])
    rows = []
    for line in text.splitlines()[:100]:
        bits = line.split()
        if len(bits) < 5:
            continue
        match = re.search(r'\("([^\"]+)",pid=(\d+)',line)
        endpoint = bits[3]
        port = endpoint.rsplit(':',1)[-1]
        if port.isdigit():
            rows.append({'address':endpoint,'port':int(port),
                         'name':match[1] if match else 'Sistema',
                         'pid':int(match[2]) if match else 0})
    return {'ports':rows}


def stop_port(pid, port):
    pid,port=int(pid),int(port)
    current=ports()['ports']
    if pid < 2 or not any(row['pid']==pid and row['port']==port for row in current):
        raise ValueError('O processo mudou; atualize a lista')
    if Path(f'/proc/{pid}').stat().st_uid != os.getuid():
        raise ValueError('Esse processo pertence ao sistema')
    os.kill(pid,signal.SIGTERM)
    return {'message':'Sinal de encerramento enviado'}


def lyrics_file():
    path = run(['zenity','--file-selection','--title=Abrir letras sincronizadas (.lrc)',
                '--file-filter=*.lrc'],timeout=300).strip()
    return {'lyrics':parse_lrc(local_path(path).read_text(errors='replace'))}


def audio_devices():
    devices=json.loads(run(['pactl','--format=json','list','sinks']))
    return {'audioDevices':[{'id':clean(d['name']), 'name':clean(d.get('description') or d['name'])}
                            for d in devices[:30]]}


def set_audio(name):
    devices=audio_devices()['audioDevices']
    if not any(d['id']==name for d in devices):
        raise ValueError('Dispositivo não está disponível')
    run(['pactl','set-default-sink',name])
    for stream in json.loads(run(['pactl','--format=json','list','sink-inputs'])):
        run(['pactl','move-sink-input',str(stream['index']),name])
    return {'message':'Saída de áudio alterada'}


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('action')
    parser.add_argument('args',nargs='*')
    options=parser.parse_args()
    action,args=options.action,options.args
    try:
        if action=='status': result=status()
        elif action=='timer-start': result=timer_start(*args)
        elif action=='timer-cancel': result=timer_cancel()
        elif action=='shelf-add': result=shelf_add(args)
        elif action=='shelf-pick': result=pick_files()
        elif action=='shelf-clear':
            with locked_state() as state:state['shelf']=[]
            result={'message':'Bandeja esvaziada; arquivos preservados'}
        elif action=='shelf-remove':
            path=str(local_path(args[0])) if Path(args[0]).exists() else args[0]
            with locked_state() as state: state['shelf']=[p for p in state.get('shelf',[]) if p!=path]
            result={'message':'Removido da bandeja; arquivo preservado'}
        elif action=='share':
            if not shutil.which('localsend'):raise ValueError('LocalSend não está instalado')
            files=[str(local_path(value)) for value in args[:40]]
            launch(['localsend',*files])
            result={'message':'Compartilhamento aberto no LocalSend'}
        elif action=='open': launch(['xdg-open',local_path(args[0])]);result={}
        elif action=='reveal': launch(['nautilus','--select',local_path(args[0])]);result={}
        elif action=='convert': result=convert(*args)
        elif action=='ocr': result=ocr(*args)
        elif action=='photo-style':
            import photos
            result=photos.photo_style(*args)
        elif action=='photo-path':
            folder=DATA/'photos';folder.mkdir(parents=True,exist_ok=True,mode=0o700)
            result={'path':str(folder/('notchi-'+str(time.time_ns())+'.jpg'))}
        elif action=='clipboard': result=clipboard_list()
        elif action=='clipboard-copy': result=clipboard_copy(*args)
        elif action=='ports': result=ports()
        elif action=='port-stop': result=stop_port(*args)
        elif action=='lyrics-file': result=lyrics_file()
        elif action=='audio-devices': result=audio_devices()
        elif action=='audio-set': result=set_audio(*args)
        elif action=='color':
            value=run(['hyprpicker','--no-fancy'],timeout=300).strip()
            if re.fullmatch(r'#[0-9a-fA-F]{6}',value):
                run(['wl-copy'],input=value); result={'message':value+' copiado','color':value}
            else: raise ValueError('Nenhuma cor selecionada')
        elif action=='setting':
            key,value=args
            if key not in ('theme','animations','hover','monitor','animationStyle'): raise ValueError('Opção inválida')
            with locked_state() as state: state.setdefault('settings',{})[key]=value
            result={'message':'Preferência salva'}
        elif action in ('integration-config','integration-settings','integration-save','weather','prayers','prayer-alerts','markets','home-states','home-command','lyrics-online','spotify-devices','spotify-transfer'):
            import integrations
            result=integrations.dispatch(action,args)
        else: raise ValueError('Ação desconhecida')
        print(json.dumps({'ok':True,**result},ensure_ascii=False))
    except (OSError,ValueError,TypeError,KeyError,IndexError,subprocess.SubprocessError) as error:
        print(json.dumps({'ok':False,'error':str(error)[:500]},ensure_ascii=False))
        return 1
    return 0

if __name__=='__main__':
    sys.exit(main())
