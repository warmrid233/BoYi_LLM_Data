from django.db import models
import random
import math
from utility import randomstring

ROLE_CHOICES = (
    ('D', 'Dictator'),
    ('R', 'Receiver')
)

ROOM_CHOICES = (
    ('D', 'Dictator'),
    ('R', 'Receiver'),
    ('M', 'Mixed')
)

TREATMENT_CHOICES = [
    ('T1', 'T1: Exit with unequal entitlement and unearned income'),
    ('T1*', 'T1*: Entry with unequal entitlement and unearned income'),
    ('T2', 'T2: Exit with equal entitlement and earned income'),
    ('T2*', 'T2*: Entry with equal entitlement and earned income'),
    ('T3', 'T3: Exit with unequal entitlement, unearned income, Africa'),
    ('T3*', 'T3*: Entry with unequal entitlement, unearned income, Africa')
]


LETTERS = { 'T1':  { 'DEFAULT': ('ke9m.gif', """ T1info.gif """ ), 'CHANGE': ('lspc.gif', """ T1andT2noinfo.gif """ ) },
            'T1*': { 'DEFAULT': ('lspc.gif', """ T1andT2noinfo.gif """ ), 'CHANGE': ('ke9m.gif', """ T1info.gif """) },
            'T2':  { 'DEFAULT': ('2i9v.gif', """ T2info.gif """ ), 'CHANGE': ('lspc.gif', """ T1andT2noinfo.gif """) },
            'T2*': { 'DEFAULT': ('lspc.gif', """ T1andT2noinfo.gif """ ), 'CHANGE': ('2i9v.gif', """ T2info.gif """) },
            'T3':  { 'DEFAULT': ('bwlq.gif', """ T3info.gif """ ), 'CHANGE': ('vjgp.gif', """ T3noinfo.gif """) },
            'T3*': { 'DEFAULT': ('vjgp.gif', """ T3noinfo.gif """ ), 'CHANGE': ('bwlq.gif', """ T3info.gif """) }
            }

def letter(treatment, action):
    name, desc = LETTERS[treatment][action]
    url = MEDIA_ROOT + name
    return (url, desc)

class Session(models.Model):
    sessionid = models.CharField(max_length=5, unique=True)
    showupfee = models.IntegerField()
    productionrequirement = models.IntegerField()
    productiontimeinseconds = models.IntegerField()
    wage = models.IntegerField()
    active = models.BooleanField()
    level = models.IntegerField()

    def close(self):
        self.active=False

    def __str__(self):
        return self.sessionid

class Room(models.Model):
    session = models.ForeignKey(Session)
    name = models.CharField(max_length=30)
    role = models.CharField(max_length=1, choices=ROOM_CHOICES)
    readyforchange = models.BooleanField(default=False)
    treatT1 = models.BooleanField(default=False)
    treatT1star = models.BooleanField(default=False)
    treatT2 = models.BooleanField(default=False)
    treatT2star = models.BooleanField(default=False)
    treatT3 = models.BooleanField(default=False)
    treatT3star = models.BooleanField(default=False)

    def __str__(self):
        return self.name
    def all_treatments(self):
        r = []
        if self.treatT1:
            r.append('T1')
        if self.treatT1star:
            r.append('T1*')
        if self.treatT2:
            r.append('T2')
        if self.treatT2star:
            r.append('T2*')
        if self.treatT3:
            r.append('T3')
        if self.treatT3star:
            r.append('T3*')
        return r
    class Meta:
        unique_together = ( ("session", "name"),)


class Player(models.Model):
    session = models.ForeignKey(Session)
    room = models.ForeignKey(Room)
    ts = models.DateTimeField(auto_now_add=True)
    secretcode=models.CharField(max_length=8,unique=True)
    treatment=models.CharField(max_length=3, choices=TREATMENT_CHOICES, blank=True, null=True)
    computerid = models.IntegerField()
    role = models.CharField(max_length=1, choices=ROLE_CHOICES, blank=True, null=True)
    answeredquestions1 = models.BooleanField(default=False)
    answeredquestions2 = models.BooleanField(default=False)
    finished=models.BooleanField(default=False)
    allocated=models.BooleanField(default=False)


    def __str__(self):
        return self.room.name + ", nr " + str(self.computerid) + ", " + self.secretcode


    class Meta:
        unique_together = ( ("room", "computerid"),)

class Distribution(models.Model):
    player = models.ForeignKey(Player)
    opp_player = models.ForeignKey(Player, related_name='opp_player', blank=True, null=True)
    status = models.IntegerField()
    prod1 = models.BooleanField()
    prod2 = models.BooleanField()
    treatment = models.CharField(max_length=3, choices=TREATMENT_CHOICES)
    kr1 = models.IntegerField()         # Earnings from production of player.
    kr2 = models.IntegerField()         # Earnings from production of opp_player
    decision = models.CharField(max_length=5, blank=True, null=True) # Takes values in ('NO', 'ENTRY', 'EXIT')
    belop1 = models.IntegerField(blank=True, null=True)       # Decision on money to other before entry/exit decision
    belop2 = models.IntegerField(blank=True, null=True)      # Revised or hypothetical money to other after entry/exit decision
    ts0 = models.DateTimeField(auto_now_add=True) # Time-stamp of creation
    ts20 = models.DateTimeField(blank=True, null=True)       # Time-stamp at time of initial distribution.
    ts50 = models.DateTimeField(blank=True, null=True)       # Time-stamp at time of entry/exit decision
    ts60 = models.DateTimeField(blank=True, null=True)       # Time-stamp at time of revision / hypothetical choice.
    showletter1 = models.BooleanField(default=False)
    showletter2 = models.BooleanField(default=False)

    def summary1(self):
        """ Return a html-summary of the first choice."""
        available = self.kr1 + self.kr2
        if self.treatment in ('T1', 'T2', 'T3'):
            result = "N&aring;r den andre skulle f&aring; fullstendig informasjon valgte du &aring; gi %d kroner." % self.belop1
        else:
            result = "N&aring;r den andre skulle f&aring; begrenset informasjon valgte du &aring; gi %d kroner." % self.belop1
        return result

    def summary2(self):
        if self.decision =='NO':
            result = "Du valgte &aring; ikke endre informasjonen som blir sendt til den andre."
        elif self.decision=='EXIT':
            result = "Du valgte at den andre skulle f&aring; begrenset informasjon."
        else:
            result = "Du valgte at den andre skulle f&aring; fullstendig informasjon."
        return result

    def summary3(self):
        if self.decision =="NO":
            if self.treatment in ('T1', 'T2', 'T3'):
                result ="""I den tenkte situasjonen hvor den andre fikk begrenset informasjon ville du ha gitt %d kroner. """ % self.belop2
            else:
                result ="""I den tenkte situasjonen hvor den andre fikk fullstendig informasjon ville du ha gitt %d kroner. """ % self.belop2
        elif self.decision == 'EXIT':
            result = "N&aring;r den andre skulle f&aring; begrenset informasjon valgte du &aring; gi %d kroner.""" % self.belop2
        else:
            assert self.decision=='ENTRY', "Or should not have been here."
            result = "N&aring;r den andre skulle f&aring; fullstendig informasjon valgte du &aring; gi %d kroner.""" % self.belop2
        return result
    def summary(self):
        return ( self.summary1(), self.summary2(), self.summary3())
    def situationflags(self):
        star = self.treatment in ('T1*', 'T2*', 'T3*')
        T2optionalstar = self.treatment in ('T2', 'T2*')
        T1optionalstar = self.treatment in ('T1', 'T1*')
        T3optionalstar = self.treatment in ('T3', 'T3*')
        T1T3nostar = self.treatment in ('T1','T3')
        T1T3star = self.treatment in ('T1*', 'T3*')
        exitdecision = self.treatment in ('T1', 'T2', 'T3')

        return {'star': star,  'T2optionalstar': T2optionalstar, 'T1optionalstar': T1optionalstar,
                'T3optionalstar': T3optionalstar, 'T1T3nostar': T1T3nostar, 'T1T3star': T1T3star, 'exitdecision': exitdecision}

class Production(models.Model):
    player = models.ForeignKey(Player, unique=True)
    points=models.IntegerField()
    requirement=models.IntegerField()
    finished=models.BooleanField()
    prod=models.BooleanField()
    secondsleft = models.IntegerField()
    def add_production(self, n, timeleft):
        self.points += n
        self.secondsleft = int(timeleft)
        self.prod = (self.points>= self.requirement)
        self.finished = (self.prod==True or self.secondsleft<=0)

class Payment(models.Model):
    player = models.ForeignKey(Player, unique=True)
    paymentcode = models.CharField(max_length=7, unique=True)
    fee = models.IntegerField()
    total = models.IntegerField()
    ts = models.DateTimeField(auto_now_add=True)
    def summary(self):
        sumtxt = "<p> Du vil f&aring; utbetalt %d kroner i oppm&oslash;tekompensasjon.</p>" % self.fee
        if (self.total>self.fee):
            sumtxt += "<p> Du vil ogs&aring; f&aring; utbetalt de %d kronene du har beholdt.</p> " % (self.total - self.fee)
        sumtxt += "<p>Din utbetalingskode er <b>%s</b>. Skriv den ned p&aring; skjemaet du har f&aring;tt utlevert.</p>" % self.paymentcode
        return sumtxt

class Paymentletter(models.Model):
    payment = models.ForeignKey(Payment, unique=True)
    paymentcode = models.CharField(max_length=7, unique=True)
    treatment = models.CharField(max_length=3, choices=TREATMENT_CHOICES)
    payment_in_nok = models.IntegerField()

class Answers1(models.Model):
    player = models.ForeignKey(Player, unique=True)
    kull = models.IntegerField()
    sex = models.IntegerField()
    age = models.IntegerField()
    charity = models.IntegerField()
    party = models.CharField(max_length=3)

class Answers2(models.Model):
    player = models.ForeignKey(Player, unique=True)
    reason1 = models.CharField(max_length=1000)
    reason2 = models.CharField(max_length=1000)
    reason3 = models.CharField(max_length=1000)

class Address(models.Model):
    player = models.ForeignKey(Player, unique=True)
    name = models.CharField(max_length=60)
    line1 = models.CharField(max_length=60)
    line2 = models.CharField(max_length=60, blank=True, null=True)
    postnr = models.IntegerField()
    poststed = models.CharField(max_length=40)

def active_session(id):
    try:
        a=Session.objects.get(sessionid=id, active=True)
        return True
    except:
        return False

def get_player_from_sc(sc):
    try:
        return Player.objects.get(secretcode=sc)
    except:
        return False

def get_active_session():
    try:
        return Session.objects.get(active=True)
    except:
        return False

def get_active_rooms():
    try:
        return Room.objects.filter(session__active=True)
    except:
        return False

def get_room_from_name(name):
    try:
        room = get_active_rooms().filter(name=name)[0]
        return room
    except:
        return False

def get_active_players():
    """ Return a query set of the active players. """
    return Player.objects.filter(session=get_active_session())

def get_active_players_in_room(r):
    allplayers = get_active_players()
    return allplayers.filter(room=r)

def get_active_dictators():
    """ Return a query set of active dictators."""
    return Player.objects.filter(session=get_active_session()).filter(role='D')

def get_active_receivers():
    """ Return a query set of active dictators."""
    return Player.objects.filter(session=get_active_session()).filter(role='R')

def count_active_players():
    """ Return the pair (n_d, n_r) with n_d: number of dictators, n_r: number of receivers."""
    return ( get_active_dictators().count(), get_active_receivers().count())

def rooms_choice_list():
    """ Return a list of tuples with the active rooms."""
    rooms = Room.objects.filter(session__active=True)
    l = [ (r.name, r.name) for r in rooms]
    return l

def get_production_situation(player):
    try:
        sit=Production.objects.get(player=player)
    except:
        sit=False
    return sit

def get_payment(player):
    try:
        p = Payment.objects.get(player=player)
    except:
        p=False
    return p

def get_matchable_receivers():
    """
    Who are the matchable?
    1) They haven't been allocated yet.
    2) They have met the production target.
    """
    unmatched = Player.objects.filter(role='R').filter(allocated=False)
    matchables = []
    for r in unmatched:
        prodsit = get_production_situation(r)
        if prodsit.prod==True:
            matchables.append(r)
    return matchables

def get_distribution_situation(player):
    try:
        sit = Distribution.objects.get(player=player)
    except:
        sit = False
    return sit

def change10to20ok():
    """ Return False/True for whether it is ok to go to level 20 from level 10"""
    rooms = get_active_rooms()
    assert len(rooms)>0, "Should never be tested if there are no active rooms."
    ok = True
    for r in rooms:
        # All rooms should have reported that they are ready for change.
        ok = (ok==True) and r.readyforchange
    return ok

def change20to30ok():
    """ Return False/True for whether it is ok to go to level 30 (distributions) from level 20 (production)"""
    rooms = get_active_rooms()
    assert len(rooms)>0, "Should never be tested if there are no active rooms."
    ok = True
    for r in rooms:
        ok = (ok==True) and r.readyforchange
    return ok

def change10to20():
    """
    Going from level 10 to level 20 entails creating productions
    updating the level of the session.
    """
    s=get_active_session()
    for room in get_active_rooms():
        for i, p in enumerate(get_active_players_in_room(room)):
            prod = Production(player = p, points=0, requirement=s.productionrequirement, finished=False,
                              secondsleft=s.productiontimeinseconds)
            prod.save()
        room.readyforchange=False
        room.save()
    # Update session and room status to the new level.
    s.level=20
    s.save()

def change20to30():
    """
    Going from level20 to level 30, we have to allocate individuals to treatments
    and find suitable receiver matches.
    """
    session = get_active_session()
    receivers = get_matchable_receivers()
    random.shuffle(receivers)
    for i,d in enumerate(get_active_dictators()):
        pd = get_production_situation(d)
        if pd.prod:
            treatments = d.room.all_treatments()
            if len(receivers)==0:
                if 'T2' in treatments:
                    treatments.remove('T2')
                if 'T2*' in treatments:
                    treatments.remove('T2*')
                if len(treatments)==0:
                    # This test is to ensure that even if we ran a strictly T2/T2* session, if we ran out of receivers,
                    # we could the remaining dictators into the other treatments.
                    treatments = ['T1', 'T1*', 'T3', 'T3*']
            d.treatment = treatments[i % len(treatments) ]
            if d.treatment in ('T2', 'T2*'):
                r=receivers.pop()
                pr = get_production_situation(r)
                sit = Distribution(player=d, opp_player=r, status=0, prod1=pd.prod, prod2=pr.prod, treatment=d.treatment,
                                   kr1 = session.wage*pd.prod, kr2=session.wage*pr.prod)
                r.allocated=True
                r.save()
            else:
                sit = Distribution(player=d, status=0, prod1=pd.prod, prod2=False, treatment=d.treatment,
                               kr1 = 2*session.wage*pd.prod, kr2=0)
            sit.save()
        d.save()
    session.level=30
    session.save()


def production_left():
    """
    Return a tuple with the first element being True/False for whether we are finished
    with production, the second element a dictionary with the number of productions left in
    each room.
    """
    rooms = get_active_rooms()
    left, total_left = {} , 0
    for room in rooms:
        name = room.name
        left[name] = Production.objects.filter(player__room=room, finished=False).count()
        total_left += left[name]
    return ( total_left==0, left)

def finished():
    """
    Return a tuple with the first element being True/False for whether we are finished
    overall, the second element a dictionary with the number of individuals left in each
    room.
    """
    rooms = get_active_rooms()
    left, total_left = {}, 0
    for room in rooms:
        name = room.name
        left[name] = Player.objects.filter(room=room, finished=False).count()
        total_left += left[name]
    return ( total_left==0, left)


def create_letter(player, payment, situation):
    if situation.decision=='NO':
        other = situation.belop1
    else:
        other = situation.belop2
    if situation.treatment in ('T1*', 'T2*', 'T3*') and other==0:
        return False
    else:
        letter = Paymentletter(payment=payment, paymentcode=payment.paymentcode, treatment=situation.treatment, payment_in_nok=other)
        letter.save()
        return True


def payments_in_room(room):
    payments = Payment.objects.filter(player__room = room).order_by('ts')
    return payments