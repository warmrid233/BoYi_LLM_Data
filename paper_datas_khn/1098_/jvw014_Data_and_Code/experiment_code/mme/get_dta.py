from mmex.models import *
import codecs

def get_addresses():
    f = codecs.open("mmex_addresses.csv", encoding="Latin-1", mode="w")
    f.write(u"navn;line1;line2;postnr;poststed\n")
    addresses = Address.objects.all()
    for address in addresses:
        outline = u"%s;%s;%s;%d;%s\n" % (address.name,
                                         address.line1,
                                         address.line2,
                                         address.postnr,
                                         address.poststed
                                         )
        f.write(outline)
    f.close()


def get_situations():
    f = open("mmex_situations.csv", "wb")
    f.write("pid,prod1,prod2,treatment,kr1,kr2,belop1,decision,belop2,ts0,ts1,ts2,ts3\n")
    situations = Distribution.objects.all().order_by('pk')
    for sit in situations:
        if not sit.ts60:
            continue
        id = sit.id
        prod1 = int(sit.prod1)
        prod2 = int(sit.prod2)
        outline = "%d,%d,%d,%s,%d,%d,%d,%s,%d,%s,%s,%s,%s\n" % ( sit.player.id,
                                                                 prod1,
                                                                 prod2,
                                                                 sit.treatment,
                                                                 sit.kr1,
                                                                 sit.kr2,
                                                                 sit.belop1,
                                                                 sit.decision,
                                                                 sit.belop2,
                                                                 sit.ts0,
                                                                 sit.ts20,
                                                                 sit.ts50,
                                                                 sit.ts60)
        f.write(outline)
    f.close()

def get_answers1():
    f=open("mmex_answers1.csv", "wb")
    f.write("pid,kull,sex,age,charity,party\n")
    answers = Answers1.objects.all()
    for answer in answers:
        outline = "%d,%d,%d,%d,%d,%s\n" % ( answer.player.id,
                                         answer.kull,
                                         answer.sex,
                                         answer.age,
                                         answer.charity,
                                         answer.party)
        f.write(outline)
    f.close()

def problems():
    payments = Payment.objects.all()
    for payment in payments:
        player = payment.player
        sits = Distribution.objects.filter(player=player)
        for sit in sits:
            if sit.ts20 and sit.ts20 > payment.ts:
                try:
                    letter = Paymentletter.objects.get(paymentcode=payment.paymentcode)
                except:
                    pass
                print "problematic pid: %d" % sit.player.id
                print "      treatment: %s" % sit.treatment
                print "        payment: %d" % payment.total
                print "         belop1: %d" % sit.belop1
                print "       decision: %s" % sit.decision
                print "         belop2: %d" % sit.belop2
                print "    paymentcode: %s" % payment.paymentcode
                try:
                    print "paymentinletter: %d\n" % letter.payment_in_nok
                except:
                    pass
                # Now fix errors in letters produced
                if sit.decision=='NO':
                    other = sit.belop1
                else:
                    other = sit.belop2
                if sit.treatment in ('T1*', 'T2*', 'T3*') and other==0:
                    pass
                else:
                    try:
                        letter = Paymentletter(payment=payment, paymentcode=payment.paymentcode,
                                               treatment=sit.treatment, payment_in_nok=other)
                        letter.save()
                    except:
                        pass


def sanity_check_of_letters():
    letters = Paymentletter.objects.all()
    errors =[]
    for letter in letters:
        payment= Payment.objects.get(paymentcode=letter.paymentcode)
        other1 = 200 - (payment.total - payment.fee)
        other2 = letter.payment_in_nok
        if other1 != other2:
            errors.append( payment.paymentcode)
    if len(errors)>0:
        print "Total number of wrong payments/paymentletters: %d " % len(errors)
        print "Here are the wrong ones:"
        for error in errors:
            print error
    else:
        print "No errors found in payments."


def get_letters():
    f = open("mmex_letters.csv", "wb")
    f.write("letterid,paymentcode,treatment,payment_in_nok\n")
    letters = Paymentletter.objects.all().order_by('paymentcode')
    for i, letter in enumerate(letters):
        player = letter.payment.player
        sit = Distribution.objects.get(player=player)
        decision = sit.decision
        outline = "%d,%s,%s,%s,%d\n" % ( i+1, letter.paymentcode, letter.treatment, decision, letter.payment_in_nok)
        f.write(outline)
    f.close()



latex_top = r"""\documentclass[12pt,a4paper,norsk]{article}
\usepackage{a4,babel,longtable}
\usepackage[latin1]{inputenc}
\author{Erik \O{}. S\o{}rensen}
\title{Motivasjoner i mmexit}
\setcounter{tocdepth}{1}
\begin{document}
\maketitle
\tableofcontents
\sloppy
"""

latex_bottom = r"""
\end{document}
"""

latex_motivations = r"""
\begin{enumerate}
\item %s
\item %s
\item %s
\end{enumerate}
"""

def actiondescription(situation):
    out = "\n(1) This individual first decided to give %d kroner. " % situation.belop1
    if situation.decision=="NO":
        out += "Then decided \emph{not} to change the letter sent. "
        out += "He/she reported that hypothetically, with a different letter, he/she would have given %d kroner. " % situation.belop2
    else:
        out += "(2) Then decided to %s. " % situation.decision
        out += "(3) He/she then decided to give %d kroner with the new letter. \n\n" % situation.belop2
    return out




def motivations():
    f = codecs.open("motivations.tex", encoding="Latin-1", mode="w")
    f.write(latex_top)
    for treatment, treatmentname in ( ('T1', r'$T1$'), ('T1*', r'$T1\ast$'),
                                      ('T2',r'$T2$'), ('T2*',r'$T2\ast$'),
                                      ('T3',r'$T3$'), ('T3*', r'$T3\ast$') ):
        sectionheading = r"\section{Treatment %s }" % treatmentname
        f.write(sectionheading)
        sits = Distribution.objects.filter(treatment=treatment).filter(showletter1=True).order_by('player')
        for sit in sits:
            subsectionheading = r"\subsection{Individual %d in treatment %s}" % (sit.player.id, treatmentname)
            f.write(subsectionheading)
            action = actiondescription(sit)
            f.write(action)
            f.write("For this he reported the following motivation:\n\n")
            motivation = Answers2.objects.get(player=sit.player)
            motivationout = latex_motivations % ( motivation.reason1,
                                                  motivation.reason2,
                                                  motivation.reason3)
            f.write(motivationout)
    f.write(latex_bottom)
    f.close()

latex_paymentlist = r"""\documentclass[a4paper,12pt]{article}
\usepackage{longtable}
\begin{document}

%s
\end{document}
"""


def payment_lists():
    rooms = Room.objects.filter(role='D').order_by('pk')
    allout=""
    totalall = 0
    for r in rooms:
        total = 0
        out = r"\section{ %s in session %s}" % (r.name, r.session.sessionid)
        out += r"\begin{tabular}{rrr}"
        out += "\n\n"
        out += r"utbetalingskode & tidspunkt bestemt & total utbetaling \\"
        out += "\n"
        payments = Payment.objects.filter(player__room=r).order_by('paymentcode')
        for p in payments:
            out += "%s & %s & %d \\\\ \n" % (p.paymentcode, p.ts, p.total)
            total += p.total
        out += r"\end{tabular} "
        out += "\n\nTotalt i denne sesjonen: %d kroner.\\clearpage " % total
        allout += out
        totalall += total
    allout += "\n \n Alle diktatorsituasjoner samlet: %d kroner." % totalall
    f=open("paymentlists.tex", "w")
    f.write( latex_paymentlist % allout)
    f.close()

def payment_lists_letters(excepting=['T3', 'T3*'], letterout = "paymentletterlists.tex", desc="Letters to be sent in Norway"):
    letters = Paymentletter.objects.all().order_by('paymentcode')
    allout=r"""\section{%s} 
    \begin{longtable}{lrrr}
    Paymentcode & treatment & decision & payment \\
    """ % desc
    totalall = 0

    for i, letter in enumerate(letters):
        if letter.treatment in excepting:
            continue
        player = letter.payment.player
        sit = Distribution.objects.get(player=player)

        decision = sit.decision
        allout += r"%s & %s & %s & %d \\ " % (letter.paymentcode, letter.treatment, decision, letter.payment_in_nok)
        allout += "\n"
        totalall += letter.payment_in_nok
    allout += r"\end{longtable}"
    f=open(letterout, "wb")
    allout += "\n Total payment in these letters: %d NOK." % totalall
    f.write( latex_paymentlist % allout)
    f.close()

def payment_lists_letters_tanzania(excepting=['T1', 'T2', 'T1*', 'T2*'], letterout = "paymentletterlistsAfrica.tex", desc="Letters sent to Tanzania", kurs=6.0):
    letters = Paymentletter.objects.all().order_by('paymentcode')
    allout=r"""\section*{%s} 
    \begin{longtable}{lrrrr}
    Paymentcode & treatment & decision & payment (NOK) & payment (USD) \\
    """ % desc
    totalall = 0
    usdtotal = 0

    for i, letter in enumerate(letters):
        if letter.treatment in excepting:
            continue
        player = letter.payment.player
        sit = Distribution.objects.get(player=player)

        decision = sit.decision
        usd = int(round(letter.payment_in_nok/kurs))
        allout += r"%s & %s & %s & %d & %d \\ " % (letter.paymentcode, letter.treatment, decision, letter.payment_in_nok, usd)
        allout += "\n"
        totalall += letter.payment_in_nok
        usdtotal += usd
    allout += r"\end{longtable}"
    f=open(letterout, "wb")
    allout += "\n Exchange rate used: %4.3f NOK/USD and rounding to closest integer USD amount." % kurs
    
    allout += "\n\nTotal payment in these letters:  %d USD." % usdtotal
    allout += "\n\n Packed in envelopes and sent by courier to PRIDE TANZANIA, Kariakoo branch."
    
    f.write( latex_paymentlist % allout)
    f.close()



#get_addresses()
#get_situations()
get_answers1()
#get_letters()
#problems()
#sanity_check_of_letters()
#payment_lists()


#payment_lists_letters()
#payment_lists_letters_tanzania(kurs=5.8544)

