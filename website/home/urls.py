from django.urls import path, include
from . import views

urlpatterns = [
  path('', views.index, name='index'),
  path('instagram_video_downloader', include('instagram_video_downloader.urls'))
]
