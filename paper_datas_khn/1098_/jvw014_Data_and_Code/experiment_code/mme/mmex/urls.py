from django.conf.urls.defaults import *
from django.contrib import admin
from django.contrib.auth.views import login, logout
admin.autodiscover()

urlpatterns = patterns('mme.mmex.views',
                       (r'^index/$', 'index'),
                       (r'^new_user/$', 'new_user'),
                       (r'^adminindex/$', 'adminindex'),
                       (r'^showsecretcodes/$', 'showsecretcodes'),
                       (r'^logintoexperiment/$', 'logintoexperiment'),
                       (r'^welcome/$','welcome'),
                       (r'^deletemachine/$','deletemachine'),
                       (r'^pickup/$', 'pickup'),
                       (r'^status/$', 'status'),
                       (r'^statuslogon/$', 'statuslogon'),
                       (r'^create_session/$', 'create_session'),
                       (r'^close_session/$', 'close_session'),
                       (r'^showletter/(?P<lettern>\d+)/(?P<letter>\w+.\w*.[a-z]{3})/$', 'showletter'),
                       (r'^backfromletter/$', 'backfromletter'),
                       (r'^production/$', 'production'),
                       (r'^noproduction/$', 'noproduction'),
                       (r'^wait20/$', 'wait20'),
                       (r'^level30/$', 'level30'),
                       (r'^questions1/$', 'questions1'),
                       (r'^questions2/$', 'questions2'),
                       (r'^address/$', 'address'),
                       (r'^waitforend/$', 'waitforend'),
                       (r'^admin/', include(admin.site.urls)),
                       )
