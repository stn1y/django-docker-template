from django.shortcuts import render

def index(request):
  return render(request, 'instagram_video_downloader/index.html')