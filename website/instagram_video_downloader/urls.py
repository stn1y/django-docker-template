from django.urls import path, include
from . import views

urlpatterns = [
  path('', views.index, name='index'),
  path('process', views.process, name='process'),
  path('decode', views.decode, name='decode'),
  path('create_download_link', views.create_download_link, name='create_download_link'),
  path('igvd/<uuid:uniqueid>/', views.igvd, name='igvd'),
  # path('<str:catch>', views.ig_vd_index, name='catch')
]