"""Optional integrations, requested explicitly by a panel action; never polled in the background."""
import datetime as dt
import json
import math
import ipaddress
import os
from pathlib import Path
import re
import unicodedata
from urllib.parse import urlencode,urlsplit,quote
from urllib.request import Request,build_opener,HTTPRedirectHandler
from urllib.error import HTTPError,URLError
from zoneinfo import ZoneInfo
import backend as local


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self,*args,**kwargs):
        return None


def request(url, *, headers=None, data=None, method=None):
    parsed=urlsplit(url)
    host=parsed.hostname or ''
    private=host in ('localhost',) or host.endswith('.local')
    try:
        address=ipaddress.ip_address(host)
        private=address.is_private and not address.is_link_local and not address.is_unspecified and not address.is_multicast
    except ValueError:
        pass
    if not host or (parsed.scheme!='https' and not (parsed.scheme=='http' and private)):
        raise ValueError('Use HTTPS; HTTP é permitido apenas na sua rede local')
    if parsed.username or parsed.password:
        raise ValueError('A URL não deve conter credenciais')
    fields={'User-Agent':'Notchi-for-Omarchy/0.2.1','Accept':'application/json',**(headers or {})}
    body=None if data is None else json.dumps(data).encode()
    if body is not None:fields['Content-Type']='application/json'
    req=Request(url,headers=fields,data=body,method=method)
    try:
        with build_opener(NoRedirect()).open(req,timeout=12) as response:
            payload=response.read(2_000_001)
            if len(payload)>2_000_000:raise ValueError('Resposta grande demais')
            return json.loads(payload)
    except HTTPError as error:
        raise ValueError(f'Serviço recusou a consulta (HTTP {error.code}). Verifique a conexão e as credenciais.') from None
    except (URLError,TimeoutError,ValueError):
        raise ValueError('Não foi possível consultar o serviço agora.') from None


def config():
    value=local.read_json(local.CONFIG/'integrations.json',{})
    return value if isinstance(value,dict) else {}


def edit_config():
    path=local.CONFIG/'integrations.json'
    if not path.exists():
        template=local.read_json(Path(__file__).parent/'integrations.example.json',{})
        local.atomic_json(path,template)
    path.chmod(0o600)
    local.launch(['xdg-open',path])
    return {'message':'Preencha as integrações que deseja usar. As outras podem ficar vazias.'}


def coordinates():
    location=config().get('location',{})
    if location.get('latitude') is None or location.get('longitude') is None:
        native=local.read_json(local.HOME/'.local/state/omarchy/settings/weather.json',{})
        if isinstance(native,dict):location={**location,**native}
    try:
        lat,lon=float(location['latitude']),float(location['longitude'])
        if not math.isfinite(lat) or not math.isfinite(lon) or abs(lat)>90 or abs(lon)>180:raise ValueError()
    except (KeyError,ValueError,TypeError):
        raise ValueError('Escolha sua localização no painel de clima ou em Conectar integrações.') from None
    zone=str(location.get('timezone') or 'America/Sao_Paulo')
    ZoneInfo(zone)
    return lat,lon,zone


def weather():
    lat,lon,zone=coordinates()
    payload=request('https://api.open-meteo.com/v1/forecast?'+urlencode({
        'latitude':lat,'longitude':lon,'current':'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
        'timezone':zone}))
    current=payload.get('current',{})
    return {'weather':{'temperature':current.get('temperature_2m'),
            'humidity':current.get('relative_humidity_2m'),'wind':current.get('wind_speed_10m'),
            'code':current.get('weather_code'),'at':local.clean(current.get('time'))}}


def prayers():
    lat,lon,zone=coordinates()
    method=config().get('prayer',{}).get('method','MWL')
    if method not in ('MWL','ISNA','Egypt','Makkah','Karachi','Tehran','Jafari','France','Russia','Malaysia','Singapore'):
        raise ValueError('Método de cálculo de oração inválido')
    times=json.loads(local.run(['node',Path(__file__).parent/'prayer.cjs',str(lat),str(lon),method,zone]))
    rows=[{'name':key.capitalize(),'time':value} for key,value in times.items()
          if key in ('fajr','sunrise','dhuhr','asr','maghrib','isha')]
    return {'prayers':rows,'prayerMethod':method,'prayerZone':zone}


def prayer_alerts():
    values=prayers();now=dt.datetime.now(ZoneInfo(values['prayerZone']));scheduled=0
    for row in values['prayers']:
        if row['name']=='Sunrise' or not re.fullmatch(r'\d{2}:\d{2}',row['time']):continue
        hour,minute=map(int,row['time'].split(':'))
        date=now.replace(hour=hour,minute=minute,second=0,microsecond=0)
        if date<=now:continue
        unit='omarchy-notch-prayer-'+row['name'].lower()+'-'+date.strftime('%Y%m%d')
        # Names are stable: a second click cannot create duplicate alerts.
        existing=__import__('subprocess').run(['systemctl','--user','is-active','--quiet',unit+'.timer'],capture_output=True)
        if existing.returncode==0:continue
        local.run(['systemd-run','--user','--quiet','--collect','--on-calendar='+date.strftime('%Y-%m-%d %H:%M:%S')+' '+values['prayerZone'],
                   '--unit='+unit,'omarchy-notification-send','Notchi · '+row['name'],row['time']])
        scheduled+=1
    return {'message':f'{scheduled} avisos de oração programados para hoje'}


def markets():
    settings=config().get('markets',{})
    base=str(settings.get('base','BRL')).upper()
    currencies=settings.get('currencies',['USD','EUR','GBP'])
    if not re.fullmatch('[A-Z]{3}',base):raise ValueError('Moeda base inválida')
    currencies=[str(s).upper() for s in currencies[:20] if re.fullmatch('[A-Za-z]{3}',str(s))]
    coins=[str(s) for s in settings.get('coins',[])[:20] if re.fullmatch('[a-z0-9-]{1,80}',str(s))]
    rows=[];warnings=[]
    # Daily reference rates; no trading or financial decisions are automated.
    if currencies:
        rates=request('https://api.frankfurter.dev/v2/rates?'+urlencode({'base':base,'quotes':','.join(currencies)}))
        for row in rates if isinstance(rates,list) else []:
            rows.append({'name':local.clean(row.get('quote')), 'value':row.get('rate'),
                         'detail':base+' / '+local.clean(row.get('date')),'change':None})
    if coins:
        headers={};key=settings.get('coinGeckoKey','')
        if key:headers['x-cg-demo-api-key']=str(key)
        try:
            values=request('https://api.coingecko.com/api/v3/coins/markets?'+urlencode({'vs_currency':base.lower(),'ids':','.join(coins),'per_page':20}),headers=headers)
            for row in values if isinstance(values,list) else []:
                rows.append({'name':local.clean(row.get('name')), 'value':row.get('current_price'),
                             'detail':base+' · CoinGecko','change':row.get('price_change_percentage_24h')})
        except ValueError as error:warnings.append(str(error))
    key=settings.get('alphaVantageKey','')
    stocks=settings.get('stocks',[])[:5]
    if stocks and not key:warnings.append('Adicione sua chave Alpha Vantage para consultar ações.')
    for symbol in stocks if key else []:
        if not re.fullmatch('[A-Za-z0-9.^_-]{1,25}',str(symbol)):continue
        quote_data=request('https://www.alphavantage.co/query?'+urlencode({'function':'GLOBAL_QUOTE','symbol':symbol,'apikey':key}))
        row=quote_data.get('Global Quote',{})
        if not row:warnings.append('A cotação de '+str(symbol)+' não está disponível.');continue
        rows.append({'name':symbol,'value':float(row['05. price']),
                     'detail':local.clean(row.get('07. latest trading day'))+' · Alpha Vantage',
                     'change':float(str(row.get('10. change percent','0')).strip('%'))})
    return {'markets':rows,'marketWarnings':warnings,'marketSource':'Frankfurter / CoinGecko / Alpha Vantage'}


def home_config():
    values=config().get('homeAssistant',{})
    url=str(values.get('url','')).rstrip('/')
    token=str(values.get('token',''))
    if not url or not token:raise ValueError('Conecte seu Home Assistant em Conectar integrações.')
    parts=urlsplit(url)
    if parts.query or parts.fragment:raise ValueError('Use o endereço principal do Home Assistant')
    return values,url,{'Authorization':'Bearer '+token}


def home_states():
    settings,url,headers=home_config()
    values=request(url+'/api/states',headers=headers)
    allow=settings.get('entities',[])
    rows=[]
    for row in values[:1000] if isinstance(values,list) else []:
        entity=str(row.get('entity_id',''));domain=entity.split('.')[0]
        if domain not in ('light','switch','climate','scene') or (allow and entity not in allow):continue
        attrs=row.get('attributes',{})
        rows.append({'id':entity,'domain':domain,'name':local.clean(attrs.get('friendly_name') or entity),
            'state':local.clean(row.get('state')),'temperature':attrs.get('temperature'),
            'brightness':attrs.get('brightness'), 'modes':attrs.get('hvac_modes',[]),
            'fans':attrs.get('fan_modes',[])})
    return {'homeDevices':rows[:60]}


def home_command(entity,action,value=''):
    settings,url,headers=home_config()
    available=home_states()['homeDevices'];device=next((r for r in available if r['id']==entity),None)
    if not device:raise ValueError('Dispositivo indisponível')
    domain=device['domain'];fields={'entity_id':entity}
    if action in ('turn_on','turn_off') and domain in ('light','switch','climate','scene'):
        service=action
    elif action=='brightness' and domain=='light':
        service='turn_on';fields['brightness_pct']=max(0,min(100,int(value)))
    elif action=='temperature' and domain=='climate':
        service='set_temperature';fields['temperature']=max(16,min(30,float(value)))
    elif action=='mode' and domain=='climate' and value in device['modes']:
        service='set_hvac_mode';fields['hvac_mode']=value
    elif action=='fan' and domain=='climate' and value in device['fans']:
        service='set_fan_mode';fields['fan_mode']=value
    else:raise ValueError('Controle indisponível para esse dispositivo')
    request(url+'/api/services/'+domain+'/'+service,headers=headers,data=fields,method='POST')
    return {'message':'Controle enviado',**home_states()}


def lyrics(artist, title, album='', duration='0'):
    if not artist or not title:
        raise ValueError('O player ainda não informou artista e título')
    try:
        seconds = max(0, min(86400, round(float(duration))))
    except (ValueError, OverflowError):
        seconds = 0
    query = urlencode({'artist_name': artist[:300], 'track_name': title[:300],
                       'album_name': album[:300], 'duration': seconds})
    exact = {}
    failure = None
    try:
        value = request('https://lrclib.net/api/get?' + query)
        if isinstance(value, dict):
            exact = value
    except ValueError as error:
        failure = error

    def content(record):
        synced = record.get('syncedLyrics')
        if isinstance(synced, str) and synced.strip():
            lines = local.parse_lrc(synced)
            if lines:
                return {'lyrics': lines, 'synced': True, 'message': 'Letra sincronizada · LRCLIB'}
        plain = record.get('plainLyrics')
        if isinstance(plain, str) and plain.strip():
            lines = [{'time': None, 'text': local.clean(line, 1000)}
                     for line in plain.splitlines()[:3000] if line.strip()]
            return {'lyrics': lines, 'synced': False, 'message': 'Letra sem sincronia · LRCLIB'}
        return None

    found = content(exact)
    if found and found['synced']:
        return found

    # Album editions and remasters often miss /get while /search has a match.
    # Match artist/title and duration, rather than displaying the first result.
    def normalize(value):
        text = unicodedata.normalize('NFKD', str(value).casefold())
        text = ''.join(c for c in text if not unicodedata.combining(c))
        return re.sub(r'[\W_]+', '', text)

    candidates = []
    try:
        values = request('https://lrclib.net/api/search?' + urlencode({
            'artist_name': artist[:300], 'track_name': title[:300]}))
        for row in values[:60] if isinstance(values, list) else []:
            if not isinstance(row, dict):
                continue
            if normalize(row.get('artistName', '')) != normalize(artist) or normalize(row.get('trackName', '')) != normalize(title):
                continue
            try:
                distance = abs(float(row.get('duration', 0)) - seconds) if seconds else 0
            except (TypeError, ValueError):
                continue
            if not math.isfinite(distance) or (seconds and distance > max(8, seconds * .03)):
                continue
            result = content(row)
            if result:
                candidates.append((not result['synced'], distance, result))
    except ValueError as error:
        failure = error
    if candidates:
        return min(candidates, key=lambda row: row[:2])[2]
    if found:
        return found
    if exact.get('instrumental'):
        raise ValueError('Esta faixa está marcada como instrumental no LRCLIB.')
    if failure and '404' not in str(failure):
        raise failure
    raise ValueError('Letra não encontrada para esta faixa. Tente novamente ou abra um arquivo .lrc.')


def spotify_devices():
    token=str(config().get('spotify',{}).get('token',''))
    if not token:raise ValueError('Adicione um token do Spotify com acesso a playback em Conectar integrações.')
    headers={'Authorization':'Bearer '+token}
    payload=request('https://api.spotify.com/v1/me/player/devices',headers=headers)
    return {'spotifyDevices':[{'id':local.clean(d.get('id'),200),'name':local.clean(d.get('name')),
        'active':bool(d.get('is_active')),'volume':d.get('volume_percent')} for d in payload.get('devices',[])[:30]]}


def spotify_transfer(id):
    if not any(d['id']==id for d in spotify_devices()['spotifyDevices']):raise ValueError('Dispositivo não está disponível')
    token=str(config()['spotify']['token'])
    # Spotify returns HTTP 204 here, so use a bounded byte response path.
    req=Request('https://api.spotify.com/v1/me/player',headers={'Authorization':'Bearer '+token,'Content-Type':'application/json'},
                data=json.dumps({'device_ids':[id],'play':True}).encode(),method='PUT')
    try:
        with build_opener(NoRedirect()).open(req,timeout=12) as response:response.read(4096)
    except (HTTPError,URLError,TimeoutError):raise ValueError('Não foi possível transferir a reprodução. Verifique token e plano Spotify.') from None
    return {'message':'Reprodução transferida',**spotify_devices()}


def dispatch(action,args):
    if action=='integration-config':return edit_config()
    if action=='integration-settings':return settings_summary()
    if action=='integration-save':
        raw=__import__('sys').stdin.readline(64001)
        if len(raw)>64000:raise ValueError('Configuração grande demais')
        return save_settings(json.loads(raw))
    if action=='weather':return weather()
    if action=='prayers':return prayers()
    if action=='prayer-alerts':return prayer_alerts()
    if action=='markets':return markets()
    if action=='home-states':return home_states()
    if action=='home-command':return home_command(*args)
    if action=='lyrics-online':return lyrics(*args)
    if action=='spotify-devices':return spotify_devices()
    if action=='spotify-transfer':return spotify_transfer(*args)
    raise ValueError('Integração desconhecida')


def settings_summary():
    values=config();market=values.get('markets',{});home=values.get('homeAssistant',{})
    return {'integrationSettings':{'location':values.get('location',{}),
        'prayerMethod':values.get('prayer',{}).get('method','MWL'),
        'base':market.get('base','BRL'),'currencies':market.get('currencies',['USD','EUR','GBP']),
        'coins':market.get('coins',['bitcoin','ethereum']),'stocks':market.get('stocks',[]),
        'homeUrl':home.get('url',''),'hasHomeToken':bool(home.get('token')),
        'hasSpotifyToken':bool(values.get('spotify',{}).get('token')),
        'hasStockKey':bool(market.get('alphaVantageKey')),'hasCoinKey':bool(market.get('coinGeckoKey'))}}


def save_settings(payload):
    if not isinstance(payload,dict):raise ValueError('Configuração inválida')
    value=config();value.setdefault('homeAssistant',{});value.setdefault('spotify',{});value.setdefault('markets',{})
    latitude,longitude=payload.get('latitude'),payload.get('longitude')
    latitude=None if latitude in (None,'') else float(latitude)
    longitude=None if longitude in (None,'') else float(longitude)
    if (latitude is not None and (not math.isfinite(latitude) or abs(latitude)>90)) or (longitude is not None and (not math.isfinite(longitude) or abs(longitude)>180)):
        raise ValueError('Latitude ou longitude inválida')
    zone=str(payload.get('timezone') or 'America/Sao_Paulo')[:100];ZoneInfo(zone)
    value['location']={'latitude':latitude,'longitude':longitude,'timezone':zone}
    method=payload.get('prayerMethod','MWL')
    if method not in ('MWL','ISNA','Egypt','Makkah','Karachi','Tehran','Jafari','France','Russia','Malaysia','Singapore'):raise ValueError('Método inválido')
    value['prayer']={'method':method}
    url=str(payload.get('homeUrl','')).strip()[:2000]
    if url:
        parsed=urlsplit(url)
        if parsed.scheme not in ('https','http') or not parsed.hostname or parsed.username or parsed.password or parsed.query or parsed.fragment:
            raise ValueError('Endereço do Home Assistant inválido')
    value['homeAssistant']['url']=url
    base=str(payload.get('base','BRL')).upper()
    if not re.fullmatch('[A-Z]{3}',base):raise ValueError('Moeda inválida')
    value['markets']['base']=base
    for key,pattern in [('currencies','[A-Za-z]{3}'),('coins','[a-z0-9-]{1,80}'),('stocks','[A-Za-z0-9.^_-]{1,25}')]:
        text=str(payload.get(key,''))
        items=[item.strip() for item in text.split(',') if item.strip()][:20]
        if not all(re.fullmatch(pattern,item) for item in items):raise ValueError('Lista de '+key+' inválida')
        value['markets'][key]=items
    for field,section,key in [('homeToken','homeAssistant','token'),('spotifyToken','spotify','token'),('stockKey','markets','alphaVantageKey'),('coinKey','markets','coinGeckoKey')]:
        secret=str(payload.get(field,'')).strip()
        if len(secret)>6000 or '\n' in secret or '\r' in secret:raise ValueError('Chave inválida')
        if secret:value[section][key]=secret
    local.atomic_json(local.CONFIG/'integrations.json',value)
    return {'message':'Conexões salvas neste computador',**settings_summary()}
