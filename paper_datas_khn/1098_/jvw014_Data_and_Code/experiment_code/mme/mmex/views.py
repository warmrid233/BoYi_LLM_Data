# Create your views here.
from django.core.exceptions import ObjectDoesNotExist
from django.core.urlresolvers import reverse
from django.contrib.auth import authenticate, login
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.contrib.auth.views import logout_then_login
from django.contrib.sites.models import Site, RequestSite
from django.core.urlresolvers import reverse
from django.http import HttpResponse, HttpResponseRedirect, HttpResponseNotFound
from django.shortcuts import render_to_response, get_object_or_404
from datetime import datetime
from forms import *
from models import *
from utility import *
from mme.local_settings import MEDIA_ROOT



def new_user(request):
    if request.method == 'POST':
        form = UserForm(request.POST)
        if form.is_valid() and form.cleaned_data['mmexpassword']=="Q45tofte":
            username = form.cleaned_data['username']
            password = form.cleaned_data['password']
            email = form.cleaned_data['email']
            user = User.objects.create_user(username, email, password)
            user.is_staff = True
            user.save()
            return HttpResponseRedirect(reverse(index))
        elif form.is_valid():
            error = 'Wrong mmex-password. Please try again.'
            form = UserForm(request.POST)
            return render_to_response('new_user.html', {'form':form, 'error_message':error})
        else:
            error = 'Form data is not valid. Change and try again.'
            form = UserForm(request.POST)
            return render_to_response('new_user.html', {'form':form, 'error_message':error})
    else:
        form = UserForm()
        return render_to_response('new_user.html', {'form':form})


def index(request): #Log in page for users.
    if request.method == 'POST': #Login form has data.
        form = LoginForm(request.POST)
        if form.is_valid():
            username = form.cleaned_data['username']
            password = form.cleaned_data['password']
            user = authenticate(username=username, password=password)
            if user is not None:
                if user.is_active:
                    login(request, user)
                    return HttpResponseRedirect(reverse(adminindex)) #Successful login
                else:
                    return render_to_response('access_failed.html')#Disabled account.
            else:
                return render_to_response('access_failed.html')#Username and password does not match.
        else:
            return render_to_response('access_failed.html')#Invalid login
    else: #Login form is empty
        form = LoginForm()
        return render_to_response('index.html', {'login':form})

def adminindex(request):
    return render_to_response('adminindex.html', {})

#@login_required()
def create_session(request):
    if get_active_session():
        return HttpResponse("There is already an active session which must be closed first.")
    if request.method=='POST':
        form = CreateSessionForm(request.POST)
        if form.is_valid():
            id = form.cleaned_data['sessionid']
            fee = form.cleaned_data['showupfee']
            prodreq = form.cleaned_data['productionrequirement']
            wage = form.cleaned_data['wage']
            prodtime = form.cleaned_data['productiontimeinseconds']
            name1 = form.cleaned_data['name1']
            name2 = form.cleaned_data['name2']
            type1 = form.cleaned_data['type1']
            type2 = form.cleaned_data['type2']
            treatments1 = form.cleaned_data['treatments1']
            treatments2 = form.cleaned_data['treatments2']
            s = Session(sessionid=id, showupfee=fee, productionrequirement=prodreq,
                        productiontimeinseconds=prodtime, wage=wage, active=True, level=10)
            s.save()
            r1 = Room(session=s, name=name1, readyforchange=False, role=type1)
            r2 = Room(session=s, name=name2, readyforchange=False, role=type2)
            for room, treatments in zip([r1, r2], [treatments1, treatments2]) :
                for t in treatments:
                    if t=='T1':
                        room.treatT1=True
                    elif t=='T1*':
                        room.treatT1star=True
                    elif t=='T2':
                        room.treatT2=True
                    elif t=='T2*':
                        room.treatT2star=True
                    elif t=='T3':
                        room.treatT3=True
                    elif t=='T3*':
                        room.treatT3star=True
                    else:
                        assert False, "Not an implemented Treatment when creating sessions."
            r1.save()
            r2.save()
            return HttpResponseRedirect(reverse(adminindex))
    else:
        form=CreateSessionForm()
    return render_to_response('createsession.html', {'form':form})

#@login_required()
def close_session(request):
    if not get_active_session():
        return HttpResponse("There is no session to close!")
    if request.method=='POST':
        form = CloseSessionForm(request.POST)
        if form.is_valid():
            id = form.cleaned_data['sessionid']
            if active_session(id):
                s=get_active_session()
                s.close()
                s.save()
                return HttpResponseRedirect(reverse(adminindex))
    else:
        form = CloseSessionForm()
    return render_to_response('closesession.html', {'form':form})

#@login_required()
def showsecretcodes(request):
    session = get_active_session()
    players = list( get_active_players() )
    context = { 'players': players }
    return render_to_response('showsecretcodes.html', context)

def logintoexperiment(request):
    try:
        sc = request.session["secretcode"]
        return HttpResponseRedirect(reverse(welcome))
    except:
        pass
    rooms = rooms_choice_list()
    if request.method=='POST':
        if request.session.test_cookie_worked():
            request.session.delete_test_cookie()
            form=LogOnForm(request.POST)
            if form.is_valid():
                i = form.cleaned_data['sessionid']
                c = form.cleaned_data['computerid']
                name = form.cleaned_data['room_name']
                if active_session(i):
                    s = get_active_session()
                    sc = randomstring(8)
                    room = Room.objects.get(session=s, name=name)
                    p = Player(session=s, computerid=c, secretcode=sc, room=room, role=room.role)
                    p.save()
                    request.session["secretcode"] = sc
                    request.session.set_expiry(0)
                    return HttpResponseRedirect(reverse(welcome))
                else:
                    return HttpResponse("Not a current session id.")
        else:
            return HttpResponse("Please enable Cookies and try again")
    else:
        form = LogOnForm()
    request.session.set_test_cookie()
    return render_to_response('login.html', {'form': form})

def welcome(request):
    try:
        secretcode = request.session['secretcode']
    except:
        return HttpResponseRedirect(reverse(pickup))
    s = get_active_session()
    if s.level==10:
        return render_to_response('welcome.html', {})
    elif s.level==20:
        return HttpResponseRedirect(reverse(production))
    elif s.level==30:
        return HttpResponseRedirect( reverse(level30))

def deletemachine(request):
    if request.method=='POST':
        form = DeleteMachineForm(request.POST)
        if form.is_valid() and form.cleaned_data['password']=="DEL47193":
            try:
                sc = request.session['secretcode']
            except:
                return HttpResponseRedirect(reverse(pickup))
            p = get_player_from_sc(sc)
            if p is not False:
                p.delete()
                return HttpResponse("Computer removed - close browser.")
    else:
        form = DeleteMachineForm()
    return render_to_response('deletemachine.html', {'form': form})

def pickup(request):
    if request.method=='POST':
        form = PickupForm(request.POST)
        if form.is_valid():
            sc = form.cleaned_data['secretcode']
            cid= form.cleaned_data['computerid']
            p = get_player_from_sc(sc)
            if p is not False:
                request.session['secretcode']=sc
                p.computerid=cid
                p.save()
                session = get_active_session()
                if session.level==10:
                    return HttpResponseRedirect( reverse(welcome))
                elif session.level==20:
                    return HttpResponseRedirect( reverse(production))
                elif session.level==30:
                    return HttpResponseRedirect( reverse(level30))
                else:
                    assert False, "There are no other levels."
    else:
        form = PickupForm()
    return render_to_response('pickup.html', {'form': form} )


def statuslogon(request):
    if request.method=='POST':
        if request.session.test_cookie_worked():
            request.session.delete_test_cookie()
            form=StatusLogonForm(request.POST)
            if form.is_valid():
                password = form.cleaned_data['password']
                role = form.cleaned_data['role']
                name = form.cleaned_data['room_name']
                if password=="Q45tofte":
                    request.session["role"] = role
                    request.session["name"]=name
                    request.session.set_expiry(0)
                    return HttpResponseRedirect(reverse(status))
                else:
                    return HttpResponse("Not the correct password.")
        else:
            return HttpResponse("Please enable Cookies and try again")
    else:
        form = StatusLogonForm()
    request.session.set_test_cookie()
    return render_to_response('statuslogon.html', {'form': form})


def status(request):
    """ 
    This status page, continually refreshed, works as an eventloop of the experiment.
    
    It is called by autorefresh, and the various level-pages test for the current progress
    of the experiment, and allow the director of the experiment to decide on when to go on
    from waiting stages (when messages need to be given orally to participants).
    """
    s=get_active_session()
    try:
        role = request.session['role']
    except:
        return HttpResponseRedirect(reverse(statuslogon))
    if s is False:
        return HttpResponse("Does not seem to be any active session now.")
    if s.level==10:
        return status10(request)
    if s.level==20:
        return status20(request)
    if s.level==30:
        return status30(request)


def status10(request):
    s=get_active_session()
    if request.method=='POST':
        # If someone pushed the button that this room is ready to go on to the next level.
        if request.POST.get('goto20',False):
            room_name=request.session['name']
            room = get_room_from_name(room_name)
            room.readyforchange=True
            room.save()
    if change10to20ok():
        change10to20()
        return HttpResponseRedirect(reverse(status))
    rooms = get_active_rooms()
    for room in rooms:
        room.count = Player.objects.filter(session=s, room=room).count()
    context = {'rooms': rooms}
    if request.session['role']=='activeleader':
        # The leader of the experiment in a room should only see the
        # button to go on if he has not already pushed it.
        room_name=request.session['name']
        room = get_room_from_name(room_name)
        context['leader_go_on'] =  (room.readyforchange==False)
    else:
        context['leader_go_on']=False
    return render_to_response('status10.html', context)

def status20(request):
    s=get_active_session()
    if request.method=='POST':
        # Someone pushed the button that this room is ready to go on to the next level.
        if request.POST.get('goto30', False):
            room_name=request.session['name']
            room = get_room_from_name(room_name)
            room.readyforchange=True
            room.save()
    if change20to30ok() and request.session['name']=="309":
        change20to30()
        return HttpResponseRedirect(reverse(status))
    noleft, left = production_left()
    context = {}
    if noleft:
        room_name = request.session['name']
        room = get_room_from_name(room_name)
        if room.role=='R':
            # If the room only contains receiver, it is automatically ready to go on to the next level.
            room.readyforchange=True
            room.save()
        context['leader_go_on'] = (room.readyforchange==False) and request.session['role']=='activeleader'
    else:
        context['leader_go_on'] = False
    rooms = get_active_rooms()
    for room in rooms:
        room.count = left[room.name]
    context['rooms'] = rooms
    return render_to_response('status20.html',context)

def status30(request):
    noleft, left = finished()
    context = {}
    rooms = get_active_rooms()
    for room in rooms:
        room.count = left[room.name]
    context['rooms'] = rooms
    room_name = request.session['name']
    room = get_room_from_name(room_name)
    if request.session['role'] == "counting":
        context['payments'] = payments_in_room(room)
        context['roomname'] = request.session['name']
    return render_to_response('status30.html',context)


def production(request):
    try:
        secretcode = request.session['secretcode']
    except:
        return HttpResponseRedirect(reverse(pickup))
    player = get_player_from_sc(request.session['secretcode'])
    session = get_active_session()
    situation = get_production_situation(player)
    if request.method=='POST':
        timeleft = max( int(float(request.POST['timeleft'])), 0)
        secret = int(request.POST['code'])
        orgnos = request.POST.getlist('nos')
        nos = [ int(x) for x in orgnos ]
        seqstring = request.POST['sequence']
        seq = [ int(x) for x in seqstring.split(';') ]
        y = prod(secret, nos, seq)
        situation.add_production(y, timeleft)
        situation.save()
    if situation.finished:
        return HttpResponseRedirect(reverse(wait20))
    context = {'seconds': situation.secondsleft}
    context['points'] = situation.points
    context['requirement'] = situation.requirement
    context['productiontable'], context['secret'] = prodmat()
    return render_to_response('production.html', context)

def wait20(request):
    session = get_active_session()
    if session.level==30:
        return HttpResponseRedirect(reverse(level30))
    context = {'message': "Vi m&aring; vente p&aring; at alle blir ferdige."}
    return render_to_response('wait.html', context)

def level30(request):
    try:
        secretcode = request.session['secretcode']
    except:
        return HttpResponseRedirect(reverse(pickup))
    player = get_player_from_sc(request.session['secretcode'])
    session = get_active_session()
    if player.role=='R':
        player.answeredquestions1=True
        player.save()
        return HttpResponseRedirect(reverse(questions1))
    sit = get_distribution_situation(player)
    assert session.level==30, "Session level should be 30 down here."
    if not sit:
        p = Payment(player=player, paymentcode=randomstring(7), fee=session.showupfee, total=session.showupfee)
        p.save()
        return HttpResponseRedirect(reverse(noproduction))
    if sit.status==0:
        return level30_0(request, player, sit)
    elif sit.status==10:
        return level30_10(request, player, sit)
    elif sit.status==20:
        return level30_20(request, player, sit)
    elif sit.status==30:
        return level30_30(request, player, sit)
    elif sit.status==40:
        return level30_40(request, player, sit)
    elif sit.status==50:
        return level30_50(request, player, sit)
    elif sit.status==60:
        return level30_60(request, player, sit)
    elif sit.status==70:
        return HttpResponseRedirect(reverse(questions1))
    else:
        assert False, "Should not fall down here, status should be in {0,10,20,30,40,50,60, 70}"

def level30_0(request,player, situation):
    letter, letterdesc = LETTERS[situation.treatment]['DEFAULT']
    letterurl = reverse(showletter, args=[1, letter])
    sumearnings = situation.kr1 + situation.kr2
    button = False
    if situation.showletter1:
        situation.status=10
        situation.save()
        button = True
    flags = situation.situationflags()
    context = {'button': button, 'letter': letterurl,
               'situation': situation, 'sumearnings': sumearnings}
    context.update(flags)
    return render_to_response('screen1.html', context)

def level30_10(request, player, situation):
    letter, letterdesc = LETTERS[situation.treatment]['DEFAULT']
    letterurl = reverse(showletter, args=[1, letter])
    sumearnings = situation.kr1 + situation.kr2
    flags = situation.situationflags()
    if request.method=='POST' and request.POST.get('goto20', False):
        situation.status=20
        situation.save()
        return HttpResponseRedirect(reverse(level30))
    context = {'button': True, 'treatment': player.treatment, 'letter': letterurl,
               'situation': situation, 'sumearnings': sumearnings}
    context.update(flags)
    return render_to_response('screen1.html', context)

def level30_20(request, player, situation):
    letter, letterdesc = LETTERS[situation.treatment]['DEFAULT']
    letterurl = reverse(showletter, args=[1, letter])
    available = situation.kr1 + situation.kr2
    sumearnings = situation.kr1 + situation.kr2
    flags = situation.situationflags()
    context = {'situation': situation, 'letter': letterurl, 'sumearnings': available}
    if request.method=='POST':
        form = DecisionForm(request.POST)
        if form.is_valid():
            dist_other = form.cleaned_data['other']
            valid = (dist_other <= available) and (dist_other>=0)
            if valid:
                situation.belop1 = dist_other
                situation.ts20 = datetime.now()
                situation.status=30
                situation.save()
                return HttpResponseRedirect(reverse(level30))
            context['error'] = True
        else:
            context['error'] = True
        context['form'] = form
    else:
        form = DecisionForm()
        context['form'] = form
        context['error'] = False
    context.update(flags)
    return render_to_response('screen2.html', context)

def level30_30(request, player, situation):
    letter1, letterdesc1= LETTERS[situation.treatment]['DEFAULT']
    letter2, letterdesc2 = LETTERS[situation.treatment]['CHANGE']
    letterurl1 = reverse(showletter, args=[1, letter1])
    letterurl2 = reverse(showletter, args=[2, letter2])
    flags = situation.situationflags()
    if situation.showletter2:
        situation.status=40
        situation.save()
        context = {'button': True,  'letter1': letterurl1, 'letter2': letterurl2, 'situation': situation }
    else:
        context = {'button': False, 'letter1': letterurl1, 'letter2': letterurl2, 'situation': situation }
    context.update(flags)
    return render_to_response('screen3.html', context)

def level30_40(request, player, situation):
    letter1, letterdesc1 = LETTERS[situation.treatment]['DEFAULT']
    letter2, letterdesc2 = LETTERS[situation.treatment]['CHANGE']
    letterurl1 = reverse(showletter, args=[1, letter1])
    letterurl2 = reverse(showletter, args=[1, letter2])
    flags = situation.situationflags()
    if request.method=='POST' and request.POST.get('goto50', False):
        situation.status=50
        situation.save()
        return HttpResponseRedirect(reverse(level30))
    button = situation.showletter2
    context = {'button': button, 'letter1': letterurl1, 'letter2': letterurl2,
               'situation': situation}
    context.update(flags)
    return render_to_response('screen3.html', context)

def level30_50(request, player, situation):
    if request.method=='POST' and request.POST.get('decision', False):
        if request.POST.get('decision')=="ENTRY":
            situation.decision="ENTRY"
        elif request.POST.get('decision')=="EXIT":
            situation.decision="EXIT"
        else:
            situation.decision="NO"
        situation.ts50=datetime.now()
        situation.status=60
        situation.save()
        return HttpResponseRedirect(reverse(level30))

    # Now we have to put some flags in the context to help presentation of the choice-problem.
    flags = situation.situationflags()
    letter1, letterdesc1 = LETTERS[situation.treatment]['DEFAULT']
    letter2, letterdesc2 = LETTERS[situation.treatment]['CHANGE']
    letterurl1 = reverse(showletter, args=[1, letter1])
    letterurl2 = reverse(showletter, args=[2, letter2])
    context = {'letter1': letterurl1, 'letter2': letterurl2, 'situation': situation}
    context.update(flags)
    return render_to_response('screen4.html', context)

def level30_60(request, player, situation):
    letter1, letterdesc1 = LETTERS[situation.treatment]['DEFAULT']
    letter2, letterdesc2 = LETTERS[situation.treatment]['CHANGE']
    letterurl1 = reverse(showletter, args=[1, letter1])
    letterurl2 = reverse(showletter, args=[2, letter2])
    available = situation.kr1 + situation.kr2
    self1, other1 = available - situation.belop1, situation.belop1
    flags = situation.situationflags()
    context = { 'situation': situation, 'sumearnings': available, 'letter1': letterurl1, 'letter2': letterurl2 }
    if request.method=='POST':
        form = DecisionForm(request.POST)
        ok1 = request.POST.get('change', False)
        if ok1=="NO" or (ok1=="YES" and form.is_valid()) :
            if ok1=="YES":
                dist_other = form.cleaned_data['other']
                ok2 = (dist_other>=0 ) and (dist_other<=available)
            if ok1=="NO" or ok2:
                if ok1=="NO":
                    dist_other = situation.belop1
                situation.belop2 = dist_other
                situation.ts60 = datetime.now()
                situation.status=70
                session = get_active_session()
                if situation.decision=='NO':
                    finalpayment = situation.kr1 + situation.kr2 - situation.belop1
                elif situation.decision in ('EXIT', 'ENTRY'):
                    finalpayment = situation.kr1 + situation.kr2 - situation.belop2
                else:
                    assert False, "decision must be NO, EXIT or ENTRY"
                total = session.showupfee + finalpayment
                payment = Payment(player=player, paymentcode=randomstring(7), fee=session.showupfee, total=total)
                situation.save()
                payment.save()
                create_letter(player, payment, situation)
                return HttpResponseRedirect(reverse(questions1))
            context['error'] = True
            context['form'] = form
        else:
            context['error'] = True
            context['form'] = form
    else:
        form = DecisionForm()
        context['form']= form
        context['error'] =  False
    context.update(flags)
    context['self1']=self1
    context['other1']=other1
    if situation.decision=="NO":
        return render_to_response('screen5-hypo.html', context)
    else:
        return render_to_response('screen5-new.html', context)

def showletter(request, lettern, letter):
    try:
        secretcode = request.session['secretcode']
    except:
        return HttpResponseRedirect(reverse(pickup))
    player = get_player_from_sc(request.session['secretcode'])
    sit = get_distribution_situation(player)
    letterurl = MEDIA_ROOT + letter
    context = { 'letter': letterurl , 'lettern':lettern}
    return render_to_response('showletter.html', context)

def backfromletter(request):
    try:
        secretcode = request.session['secretcode']
    except:
        return HttpResponseRedirect(reverse(pickup))
    player = get_player_from_sc(request.session['secretcode'])
    sit = get_distribution_situation(player)
    if request.method=='POST':
        lettern = int(request.POST['change'])
    else:
        return HttpResponseRedirect(reverse(level30))
    if lettern==1:
        sit.showletter1=True
        sit.save()
    elif lettern==2:
        sit.showletter2=True
        sit.save()
    return HttpResponseRedirect(reverse(level30))

def questions1(request):
    """ Show questionnaire and go on."""
    try:
        secretcode = request.session['secretcode']
    except:
        return HttpResponseRedirect(reverse(pickup))
    session = get_active_session()
    player = get_player_from_sc(secretcode)
    if player.role=='R':
        next_view = address
        player.answeredquestions1=True
        player.save()
    else:
        next_view = questions2
    if player.answeredquestions1:
        return HttpResponseRedirect(reverse(next_view))
    if request.method=='POST':
        form = QuestionsForm1(request.POST)
        if form.is_valid():
            kull = form.cleaned_data['kull']
            age = form.cleaned_data['age']
            sex = form.cleaned_data['sex']
            charity = form.cleaned_data['charity']
            party = form.cleaned_data['party']
            a = Answers1(player=player, kull=kull, age=age, sex=sex, charity=charity, party=party)
            a.save()
            player.answeredquestions1=True
            player.save()
            return HttpResponseRedirect(reverse(next_view))
    else:
        form = QuestionsForm1()
    context={'form': form}
    return render_to_response('questions1.html', context)

def questions2(request):
    """ Show questionnaire and go on."""
    try:
        secretcode = request.session['secretcode']
    except:
        return HttpResponseRedirect(reverse(pickup))
    player = get_player_from_sc(secretcode)
    sit = get_distribution_situation(player)
    if not sit:
        return HttpResponseRedirect(reverse(waitforend))
    if player.answeredquestions2:
        return HttpResponseRedirect(reverse(waitforend))
    if request.method=='POST':
        form = QuestionsForm2(request.POST)
        if form.is_valid():
            reason1=form.cleaned_data['reason1']
            reason2=form.cleaned_data['reason2']
            reason3=form.cleaned_data['reason3']
            a = Answers2(player=player, reason1=reason1, reason2=reason2, reason3=reason3)
            a.save()
            player.answeredquestions2=True
            player.finished=True
            player.save()
            return HttpResponseRedirect(reverse(waitforend))
    else:
        if sit==False:
            player.answeredquestions2=True
            player.save()
            return HttpResponseRedirect(reverse(waitforend))
        else:
            form = QuestionsForm2()
    summary1, summary2, summary3 = sit.summary()
    context={'form': form, 'summary1': summary1, 'summary2': summary2, 'summary3': summary3}
    return render_to_response('questions2.html', context)

def address(request):
    try:
        secretcode = request.session['secretcode']
    except:
        return HttpResponseRedirect(reverse(pickup))
    player = get_player_from_sc(secretcode)
    assert player.role=='R', "Only receivers should be asked about their address."
    if request.method=='POST':
        form = AddressForm(request.POST)
        if form.is_valid():
            name = form.cleaned_data['name']
            line1 = form.cleaned_data['line1']
            line2 = form.cleaned_data['line2']
            postnr= form.cleaned_data['postnr']
            poststed = form.cleaned_data['poststed']
            a = Address(player=player, name=name, line1=line1, line2=line2, postnr=postnr, poststed=poststed)
            a.save()
            player.finished=True
            player.save()
            return HttpResponseRedirect(reverse(waitforend))
    else:
        form=AddressForm()
    context = {'form': form}
    return render_to_response('address.html', context)


def waitforend(request):
    try:
        secretcode = request.session['secretcode']
    except:
        return HttpResponseRedirect(reverse(pickup))
    player = get_player_from_sc(secretcode)
    player.finished=True
    player.save()
    payment = get_payment(player)
    if payment:
        summary = payment.summary()
    else:
        summary = "<p> En i forskergruppa vil komme med en konvolutt med oppm&oslash;tekompensasjonen din.</p>"
    context = {'paymentsummary': summary}
    return render_to_response('waitforend.html', context)




def noreceiver(request):
    """ There was no receiver matched to this player. Show message about this with link to questions()"""
    pass

def noproduction(request):
    return render_to_response('noproduction.html')



