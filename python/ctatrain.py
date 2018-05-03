import urllib.request
import json
import time
import datetime
import pprint
#30071

#var = 1
#while var == 1:
url = 'http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx?key=36462b5dd0c84333af29ec51a7ccadf3&stpid=30071&max=5&outputType=JSON'
url1 = 'http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=36462b5dd0c84333af29ec51a7ccadf3&rt=red&outputType=JSON'
h1 = urllib.request.urlopen(url)
html = h1.read()
text = html.decode('utf-8')
h2 = urllib.request.urlopen(url1)
html2 = h2.read()
text2 = html2.decode('utf-8')

#pprint.pprint(text2)

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

# for x in range (0,2):
#     a77 = text[text.index('"prdctdn": "') + len('"prdctdn": "')]
#     a = text[text.index('"prdctdn": "') + len('"prdctdn": "') + 1]
#     if a == '"':
#         break
#     else:
#         a77 = a77 + a
#
# for x in range (0,2):
#     a = text[text.index('"prdctdn": "') + len('"prdctdn": "'):]
#     a771 = a[a.index('"prdctdn": "') + len('"prdctdn": "')]
#     b = a[a.index('"prdctdn": "') + len('"prdctdn": "') + 1]
#     if b == '"':
#         break
#     else:
#         a771 = a771 + b
#
# if a77 == 'DU':
#     a77=''
#     print('Next bus is due. The bus after arrives in ' + a771 + ' minutes.')
# else:
#     a77 = a77 + ' minutes'
#
#     #print('Next bus is due in ' + a77 + ' minutes')
#
#     print('Next bus is due in ' + a77 + '. ' 'The bus after arrives in ' + a771 + ' minutes.')
    #time.sleep(15)



    #bus key:
    #4CWNbgqBYMdJfAAZVW9yDerH5
    #train key:
    #36462b5dd0c84333af29ec51a7ccadf3
    #train api:
    #http://www.transitchicago.com/assets/1/developer_center/cta_Train_Tracker_API_Developer_Guide_and_Documentation_20160929.pdf
    #bus api:
    #http://www.transitchicago.com/assets/1/developer_center/cta_Bus_Tracker_API_Developer_Guide_and_Documentation_20160929.pdf
