from models import *
from utility import *
import random

def create_players():
    session = get_active_session()
    for room in get_active_rooms():
        for i in range(2, random.randint(20,30)):
            code = randomstring(8)
            player = Player(session=session, room=room, secretcode=code, computerid=i, role=room.role)
            player.save()

def fill_in_productions():
    for p in Production.objects.filter(finished=0):
        if ( random.random() > 0.4):
            p.points=p.requirement
            p.prod=1
            p.finished=1
        else:
            p.prod=0
            p.finished=1
        p.save()
    for r in Room.objects.filter(role='R'):
        r.readyforchange=True
        r.save()




