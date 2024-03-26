import base64

def encode_data(data):
  if not data:
    return None
  encoded_bytes = base64.urlsafe_b64encode(data.encode('utf-8'))
  return encoded_bytes.decode('utf-8')

def decode_data(data):
  if not data:
    return None
  decoded_bytes = base64.urlsafe_b64decode(data.encode('utf-8'))
  return decoded_bytes.decode('utf-8')