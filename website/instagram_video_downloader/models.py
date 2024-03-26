from django.db import models
import uuid

class Bind(models.Model):
  original_link = models.TextField()
  unique_id = models.UUIDField(
    null=True,
    unique=True
  )
  created_at = models.DateTimeField(
    auto_now_add=True
  )
  def __str__(self):
    return (f'original: {self.original_link} | uuid: {self.unique_id}')