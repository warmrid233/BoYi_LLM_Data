# coding=utf-8
from django import forms
import models
STATUS_CHOICES = ( ('activeleader', 'Leader of experiment with global responsibility'),
                   ('counting', 'Counting money in back office'),
                   )

EXIT_CHOICES = ( ('NO', 'Ja'),
                 ('EXIT', 'Nei'),
                 )

ENTRY_CHOICES = ( ('NO', 'Ja'),
                  ('ENTRY', 'Nei'),
                  )

PARTIES = ( ('XX', ' '),
            ('Ap', 'Arbeiderpartiet'),
            ('Frp', 'Fremskrittspartiet'),
            ('H', 'Høyre'),
            ('Krf', 'Kristelig Folkeparti'),
            ('Sp', 'Senterpartiet'),
            ('SV', 'Sosialistisk Venstreparti'),
            ('V', 'Venstre'),
            ('X', 'Et annet parti'),
            )

CHARITY = ( (9, ' '),
            (0 , 'ingen ting'),
            (1, 'under 500 kroner'),
            (2, 'mellom 500 og 1500 kroner'),
            (3, 'mellom 1500 og 5000 kroner'),
            (4, 'mer enn 5000 kroner'), )

SEX = ( ( 0, ' '),
        ( 1, 'Mann'),
        ( 2, 'Kvinne'),
        )

KULL = ( (0, ' '),
         (1, 'Første kull'),
         (2, 'Andre kull'),
         (3, 'Tredje kull'),
         (4, 'Fjerde kull'),
         (5, 'Femte kull'),
         )



class LoginForm(forms.Form):
    username = forms.CharField(max_length=30)
    password = forms.CharField(max_length=30, widget=forms.PasswordInput)

class LogOnForm(forms.Form):
    sessionid=forms.CharField(max_length=5)
    computerid=forms.IntegerField(min_value=1)
    room_name = forms.ChoiceField()
    def __init__(self, *args, **kwargs):
        super(LogOnForm,self).__init__(*args, **kwargs)
        self.fields['room_name'].choices = models.rooms_choice_list()

class PickupForm(forms.Form):
    secretcode = forms.CharField(max_length=8)
    computerid = forms.IntegerField(min_value=1)

class DeleteMachineForm(forms.Form):
    password=forms.CharField(max_length=8)

class CreateSessionForm(forms.Form):
    sessionid=forms.CharField(max_length=5)
    showupfee = forms.IntegerField(initial=100, label="What is the showup fee?")
    productionrequirement = forms.IntegerField(initial=70, label="How many points are needed for completing production")
    wage = forms.IntegerField(initial=100, label="What is the earnings for concluding production.")
    productiontimeinseconds = forms.IntegerField(initial=900, label="For how long is the production period (in seconds)?")
    name1 = forms.CharField(max_length=20, label="Name of the first room")
    type1 = forms.ChoiceField(choices=models.ROOM_CHOICES, label="What type of activity in the first room?")
    name2 = forms.CharField(max_length=20, label="Name of the second room")
    type2 = forms.ChoiceField(choices=models.ROOM_CHOICES, label="What type of activity in the second room?")
    treatments1 = forms.MultipleChoiceField(choices=models.TREATMENT_CHOICES, label="What treatments in the first room?", widget=forms.CheckboxSelectMultiple)
    treatments2 = forms.MultipleChoiceField(choices=models.TREATMENT_CHOICES, label="What treatments in the second room?", widget=forms.CheckboxSelectMultiple)

class CloseSessionForm(forms.Form):
    sessionid=forms.CharField(max_length=5)

class StatusLogonForm(forms.Form):
    role = forms.ChoiceField(choices=STATUS_CHOICES)
    password= forms.CharField(max_length=8, widget=forms.PasswordInput)
    room_name = forms.ChoiceField()
    def __init__(self, *args, **kwargs):
        super(StatusLogonForm,self).__init__(*args, **kwargs)
        self.fields['room_name'].choices=models.rooms_choice_list()

class UserForm(forms.Form):
    username = forms.CharField(max_length=30)
    email = forms.EmailField()
    password = forms.CharField(max_length=30)
    mmexpassword = forms.CharField(max_length=30)

class DecisionForm(forms.Form):
    other = forms.IntegerField(min_value=0, label="Til den andre:")

class QuestionsForm1(forms.Form):
    kull = forms.ChoiceField(choices=KULL, label=u"Hvilket kull går du på?")
    age  = forms.IntegerField(min_value=14, max_value=70, label="Hvor gammel er du?")
    sex  = forms.ChoiceField(choices=SEX, label="Er du mann eller kvinne?")
    charity = forms.ChoiceField(choices=CHARITY, label="Hvor mye har du i løpet av det siste året gitt til veldedige formål?")
    party = forms.ChoiceField(choices=PARTIES, label="Hvilket parti stemte du på ved forrige valg?")

class QuestionsForm2(forms.Form):
    reason1 = forms.CharField(max_length=1000, widget=forms.widgets.Textarea(attrs={'rows': 4, 'cols': 40}), label="Beslutning 1:")
    reason2 = forms.CharField(max_length=1000, widget=forms.widgets.Textarea(attrs={'rows': 4, 'cols': 40}), label="Beslutning 2:")
    reason3 = forms.CharField(max_length=1000, widget=forms.widgets.Textarea(attrs={'rows': 4, 'cols': 40}), label="Beslutning 3:")

class AddressForm(forms.Form):
    name = forms.CharField(max_length=60, label="Ditt navn:", required=True)
    line1 = forms.CharField(max_length=60, label="Adresselinje 1:", min_length=5, required=True)
    line2 = forms.CharField(max_length=60, label="Adresselinje 2:", required=False)
    postnr = forms.IntegerField(min_value=0, max_value=9999, required=True)
    poststed = forms.CharField(max_length=40, label="Poststed:", required=True)
