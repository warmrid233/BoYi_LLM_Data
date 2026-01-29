# Django wsgi configuration used at the time of the experiment.
import os
import sys

os.environ['DJANGO_SETTINGS_MODULE'] = 'mme.settings'

# This path must be localized:
sys.path.append('/home/sameos/Documents/mmexit/ekspkode/')
import django.core.handlers.wsgi

application = django.core.handlers.wsgi.WSGIHandler()
