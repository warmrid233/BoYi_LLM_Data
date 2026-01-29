import string
import random
from models import *
from django.template.loader import get_template
from django.template import Context

def randomstring(n):
    chars = string.letters.upper()
    x = ""
    for s in range(n):
        x = x + random.choice(chars)
    return x


def prod(code, nos, seq):
    """Borrowed from mmskole: Interprets output from a production process
    and returns number of points.

    code: the secret number to search for.
    nos: a list of ticked of numbers.
    seq: a list with all the numbers submitted.
    """
    y=0
    for i in range(len(seq)):
        x=seq[i]
        if i in nos:
            if x==code:
                y=y+1
            else:
                y=y-1
    return max(y,0)

def prodmat(rows=12, cols=17, nnum=15, min=100, max=999):
    """Modified from mmskole: Returns a production matrix.

    rows: number of rows in matrix
    cols: number of columns in matrix
    nnum: How many numbers in total
    min: The minimum number presented
    max: The maximum number presented

    The defaults are taken from mmskole.
    """

    seq = ""
    secret = random.randint(min, max)
    candnr = [secret]
    for x in range(nnum-1):
        candnr.append(random.randint(min,max))
    outstring = "<table border=1>\n"
    n=0
    for i in range(rows):
        outstring +="<tr>"
        for j in range(cols):
            x = random.choice(candnr)
            if len(seq)> 0:
                seq=seq + ";"
            seq = seq + str(x)
            outstring += '  <td> %d <input type=checkbox name=nos value=%d>\n' % (x,n)
            n=n+1
        outstring += "</tr>\n"
    outstring += "</table>\n"
    outstring += '<input type=hidden name=sequence value="%s">\n' % seq
    outstring += '<input type=hidden name=code value=%d>' % secret
    return outstring, secret


