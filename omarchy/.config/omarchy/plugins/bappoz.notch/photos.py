"""Non-destructive photo looks and normalized drawing paths for the camera."""
import json
import math
from pathlib import Path
import time
import backend as local

LOOKS={
 'natural':[],
 'mono':['-colorspace','Gray'],
 'noir':['-colorspace','Gray','-brightness-contrast','-5x25'],
 'silver':['-colorspace','Gray','-level','5%,95%'],
 'sepia':['-sepia-tone','70%'],
 'warm':['-modulate','103,105,98','-colorize','4,1,0'],
 'cool':['-modulate','100,88,103','-fill','#7398d9','-colorize','9'],
 'pastel':['-modulate','112,72,100','-brightness-contrast','5x-8'],
 'vivid':['-modulate','104,145,100'],
 'cinema':['-modulate','95,82,100','-brightness-contrast','-2x14'],
 'fade':['-level','0%,110%','-brightness-contrast','7x-12'],
 'rose':['-fill','#f1aec2','-colorize','12'],
 'amber':['-fill','#f4bf78','-colorize','12'],
 'mint':['-fill','#89cbb5','-colorize','9'],
 'blue':['-fill','#829ed7','-colorize','14'],
 'lavender':['-fill','#b8a1df','-colorize','12'],
 'glow':['-sigmoidal-contrast','3x45%','-modulate','108,95,100'],
 'crisp':['-unsharp','0x1+1+0.02','-modulate','100,110,100']
}


def photo_style(value,look,decoration='none',strokes='[]'):
    path=local.local_path(value)
    if path.suffix.lower() not in ('.png','.jpg','.jpeg','.webp'):
        raise ValueError('Escolha uma foto')
    if look not in LOOKS or decoration not in ('none','polaroid','stars','tape'):
        raise ValueError('Estilo desconhecido')
    if len(strokes)>100_000:raise ValueError('Desenho grande demais')
    paths=json.loads(strokes)
    if not isinstance(paths,list) or len(paths)>100:raise ValueError('Desenho inválido')
    dimensions=local.run(['magick','identify','-format','%w %h',path]).strip().split()
    width,height=map(int,dimensions)
    if width*height>50_000_000:raise ValueError('Imagem grande demais')
    drawing=[]
    for segment in paths:
        if not isinstance(segment,list) or len(segment)>2000:raise ValueError('Desenho inválido')
        points=[]
        for point in segment:
            if not isinstance(point,list) or len(point)!=2:raise ValueError('Desenho inválido')
            x,y=map(float,point)
            if not math.isfinite(x) or not math.isfinite(y) or not (0<=x<=1 and 0<=y<=1):
                raise ValueError('Desenho fora da imagem')
            points.append((round(x*width,2),round(y*height,2)))
        if len(points)>1:
            drawing+=['-stroke','#fff6db','-strokewidth',str(max(2,round(width/320))),'-fill','none',
                      '-draw','polyline '+' '.join(f'{x},{y}' for x,y in points)]
    decorations=[]
    if decoration=='polaroid':
        border=max(12,round(width*.035))
        decorations=['-bordercolor','#f7f4ee','-border',str(border),'-gravity','south','-background','#f7f4ee','-splice','0x'+str(border*3)]
    elif decoration=='tape':
        decorations=['-fill','#c9b7a08a','-stroke','none','-draw',f'polygon {width*.1},0 {width*.4},0 {width*.4},{height*.035} {width*.1},{height*.06}',
                     '-draw',f'polygon {width*.65},0 {width*.95},0 {width*.9},{height*.05} {width*.6},{height*.03}']
    elif decoration=='stars':
        # Fixed normalized star stamps; only numeric coordinates reach magick.
        for cx,cy in [(0.08,.12),(.9,.17),(.85,.85),(.14,.8)]:
            points=[]
            for i in range(10):
                a=math.radians(i*36-90);r=width*(.025 if i%2==0 else .011)
                points.append(f'{cx*width+r*math.cos(a):.2f},{cy*height+r*math.sin(a):.2f}')
            decorations+=['-fill','#fff6db','-stroke','none','-draw','polygon '+' '.join(points)]
    folder=local.DATA/'photos';folder.mkdir(parents=True,exist_ok=True,mode=0o700)
    output=folder/(path.stem+'-'+look+'-'+str(time.time_ns())+'.jpg')
    local.run(['magick','-limit','memory','128MiB','-limit','map','256MiB',path,
               *LOOKS[look],*drawing,*decorations,'-quality','94',output],timeout=45)
    local.shelf_add([str(output)])
    return {'message':'Foto salva na bandeja; original preservado','path':str(output)}
