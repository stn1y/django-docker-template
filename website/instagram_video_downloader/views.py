from django.shortcuts import render
from django.views.decorators.http import require_http_methods
from django.http import JsonResponse, HttpResponse
import json
import asyncio
from collections import Counter
from playwright.sync_api import sync_playwright, Playwright
import sys
from .utils import encode_data, decode_data
from .models import Bind
import uuid
import requests
from django.shortcuts import get_object_or_404
from urllib.parse import quote
from pyvirtualdisplay import Display

async def index(request):
  return render(request, 'instagram_video_downloader/index.html')

def check_url_exists(url):
  try:
    response = requests.head(url)
    return response.status_code == 200
  except requests.ConnectionError:
    return False

@require_http_methods(['POST'])
def process(request):
  try:
    data = json.loads(request.body)
    input_url = data.get('input_url')
  except Exception as e:
    return JsonResponse({'status': 'error', 'message': 'loading_json_fail'}, status=400)
  
  url_exists = check_url_exists(input_url)
  if url_exists == False:
    return JsonResponse({'status': 'error', 'message': 'url_doesnt_exist'}, status=400)

  encoded_download_link = run_process(input_url)
  if encoded_download_link == 'error':
    return JsonResponse({'status': 'error', 'message': 'run_process_fail'}, status=400)
  
  return JsonResponse({'status': 'success', 'encoded_download_link': encoded_download_link}, status=200)

# block pages by resource type. e.g. image, stylesheet
BLOCK_RESOURCE_TYPES = [
  'beacon',
  'csp_report',
  'font',
  'image',
  'imageset',
  'media',
  'object',
  'texttrack',
#  we can even block stylsheets and scripts though it's not recommended:
# 'stylesheet',
# 'script',  
# 'xhr',
]

# we can also block popular 3rd party resources like tracking:
BLOCK_RESOURCE_NAMES = [
  'adzerk',
  'analytics',
  'cdn.api.twitter',
  'doubleclick',
  'exelator',
  'facebook',
  'fontawesome',
  'google',
  'google-analytics',
  'googletagmanager',
]

def intercept_route(route):
    """intercept all requests and abort blocked ones"""
    if route.request.resource_type in BLOCK_RESOURCE_TYPES:
        print(f'blocking background resource {route.request} blocked type "{route.request.resource_type}"')
        return route.abort()
    if any(key in route.request.url for key in BLOCK_RESOURCE_NAMES):
        print(f"blocking background resource {route.request} blocked name {route.request.url}")
        return route.abort()
    return route.continue_()

def run_process(input_url):

  display = Display(visible=0, size=(1920, 1080))
  display.start()

  with sync_playwright() as p:
    browser = p.chromium.launch(headless=False)
    context = browser.new_context(viewport={"width": 1920, "height": 1080})
    page = context.new_page()
    
    try:
      page.route("**/*", intercept_route)
      page.goto('https://snapinsta.app/')
      page.fill('form[name="formurl"] input[id="url"]', input_url)
      page.click('form[name="formurl"] button[type="submit"]')
      page.wait_for_selector('div.download-bottom a', state='attached', timeout=10000)
      download_link = page.eval_on_selector('div.download-bottom a', 'a => a.href')
      encoded_download_link = encode_data(download_link)
      
    except Exception as e:
      print(f'error: {e}')
      return 'error'
    finally:
      browser.close()
      display.stop()

  return encoded_download_link

def decode(request):
  try:
    data = json.loads(request.body)
    encoded_download_link = data.get('encodedDownloadLink')
    decoded_download_link = decode_data(encoded_download_link)
    return JsonResponse({'status': 'success', 'decoded_download_link': decoded_download_link}, status=200)
  except Exception as e:
    return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
  
def create_download_link(request):
  try:
    data = json.loads(request.body)
    file_name = data.get('fileName')
    encoded_download_link = data.get('encodedDownloadLink')
    decoded_download_link = decode_data(encoded_download_link)
    unique_id = uuid.uuid4()
    if file_name == '':
      download_link = f'https://stanleygfu.com/instagram_video_downloader/igvd/{unique_id}/'
    else:
      download_link = f'https://stanleygfu.com/instagram_video_downloader/igvd/{unique_id}/?filename={file_name}'
    new_connection = Bind(
      original_link=decoded_download_link,
      unique_id=unique_id
    )
    new_connection.save()
    return JsonResponse({'status': 'success', 'download_link': download_link}, status=200)
  except Exception as e:
    return JsonResponse({'status': 'error', 'message': str(e)}, status=400)

def igvd(request, uniqueid):
  bind = get_object_or_404(Bind, unique_id=uniqueid)
  response = requests.get(bind.original_link, stream=True)
  filename = request.GET.get('filename', str(uuid.uuid4()))
  if not any(filename.lower().endswith(ext) for ext in ['.mp4', '.avi', '.mov']):
    filename += '.mp4'
  safe_filename = quote(filename.encode('utf-8'))
  if response.status_code == 200:
    django_response = HttpResponse(response.content, content_type=response.headers['Content-Type'])
    django_response['Content-Disposition'] = f'attachment; filename="{safe_filename}"'
    return django_response
  else:
    return HttpResponse("Error fetching original content", status=404)