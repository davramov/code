import urllib.request
import json
import time

j = '&format=json'
url = 'http://ctabustracker.com/bustime/api/v2/getpredictions?key=4CWNbgqBYMdJfAAZVW9yDerH5'
rt_type = input("Bus or Train? (type b or t): ")
if rt_type == 'b':
    rt = '&rt=' + input("Route number?: ")
    d = input("Direction? (Type E, W, N or S): ")
    if d == 'E':
        d = '&dir=Eastbound'
    if d == 'W':
        d = '&dir=Westbound'
    if d == 'N':
        d = '&dir=Northbound'
    if d == 'S':
        d = '&dir=Southbound'
    url = url + d
    stpid = input('Stop ID? (leave blank to view available stops): ')
    if stpid == '':
        urlb = 'http://www.ctabustracker.com/bustime/api/v2/getstops?key=4CWNbgqBYMdJfAAZVW9yDerH5' + rt + d + j
        h1 = urllib.request.urlopen(urlb)
        html = h1.read()
        text = html.decode('utf-8')
        print(text)
        stpid = input('Stop ID? : ')
    stpid = '&stpid=' + stpid
url = url + rt + stpid + d + j

if rt_type == 't':
    rtt = input("Station: ")

var = 1
while var == 1:
    #url = 'http://ctabustracker.com/bustime/api/v2/getpredictions?key=4CWNbgqBYMdJfAAZVW9yDerH5&rt=77&stpid=9284&rtdir=Eastbound&format=json'
    h1 = urllib.request.urlopen(url)
    html = h1.read()
    text = html.decode('utf-8')
    print(text)
    for x in range (0,2):
        a77 = text[text.find('"prdctdn": "') + len('"prdctdn": "')]
        a = text[text.find('"prdctdn": "') + len('"prdctdn": "') + x]
        if a == '"':
            break
        else:
            a77 = a77 + a
    if a77 == 'DU':
        a77 = 'DUE'
    l = [a77]
    update = True
    a = text[text.find('"prdctdn": "') + len('"prdctdn": "'):]
    while update is True:
        update = False
        for x in range (0,2):
            a1 = a[a.find('"prdctdn": "') + len('"prdctdn": "')]
            b = a[a.find('"prdctdn": "') + len('"prdctdn": "') + x]
            if b == '"':
                break
            if b == 'o':
                break
            if b == 'n':
                break
            else:
                a1 = a1 + b
                l.append(a1)
                update = True
        a = a[a.find('"prdctdn": "') + len('"prdctdn": "'):]
        if a.find('"prdctdn": "') == -1:
            update = False
    print(l, ' ')
    l = []
    url_t = 'http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx?key=36462b5dd0c84333af29ec51a7ccadf3&stpid=30071&max=5&outputType=JSON'
    url1_t = 'http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=36462b5dd0c84333af29ec51a7ccadf3&rt=red&outputType=JSON'
    h1 = urllib.request.urlopen(url_t)
    html = h1.read()
    text = html.decode('utf-8')
    h2 = urllib.request.urlopen(url_t)
    html2 = h2.read()
    text2 = html2.decode('utf-8')
    ct = text[text.index('"tmst":"') + len('"tmst":"')+11]
    for x in range (1,8):
        a = text[text.index('"tmst":"') + len('"tmst":"')+11+x]
        if a == '"':
            break
        else:
            ct = ct + a

    t1 = int(ct[:2])
    t2 = ct[:5]
    t2 = int(t2[-2:])
    t3 = int(ct[-2:])

    tc = t1*60+t2+t3/60

    #print (t1 + ':' + t2 + ':' + t3)

    aSP = text[text.index('"arrT":"') + len('"arrT":"')+11]
    for x in range (1,8):
        a = text[text.index('"arrT":"') + len('"arrT":"')+11+x]
        if a == '"':
            break
        else:
            aSP = aSP + a

    a1 = int(aSP[:2])
    a2 = aSP[:5]
    a2 = int(a2[-2:])
    a3 = int(aSP[-2:])

    ta = (a1*60)+a2+(a3/60)

    dt = str(ta-tc)[:4]

    print ('The next Southbound Brown Line Train will arrive at Southport in ' + dt + ' min.')

    #FMT = '%H:%M:%S'
    #aSP = time.strptime(aSP, FMT)
    #ct = time.strptime(ct, FMT)
    #at = datetime.timedelta(aSP,ct)

    #print('The next train will arive in ' + at + ' minutes')
    print('Time is currently ' + ct)
    print('Next train due at ' + aSP)
    ct = ''
    ta = ''
    tc = ''
    aSP = ''

    time.sleep(10)

    #bus key:
    #4CWNbgqBYMdJfAAZVW9yDerH5
    #train key:
    #36462b5dd0c84333af29ec51a7ccadf3
    #train api:
    #http://www.transitchicago.com/assets/1/developer_center/cta_Train_Tracker_API_Developer_Guide_and_Documentation_20160929.pdf
    #bus api:
    #http://www.transitchicago.com/assets/1/developer_center/cta_Bus_Tracker_API_Developer_Guide_and_Documentation_20160929.pdf
