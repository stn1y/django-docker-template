echo "Installing Playwright dependencies..."
gosu "$USER" playwright install

#!/bin/sh
# vim:sw=4:ts=4:et
echo "Running as user: $USER"
gosu "$USER" python manage.py collectstatic --noinput

# Creating the first user in the system
USER_EXISTS="from django.contrib.auth import get_user_model; User = get_user_model(); exit(User.objects.exists())"
gosu "$USER" python manage.py shell -c "$USER_EXISTS" && gosu "$USER" python manage.py createsuperuser --noinput


if [ "$1" = "--debug" ]; then
  # Django development server
  exec gosu "$USER" python manage.py runserver "0.0.0.0:$DJANGO_DEV_SERVER_PORT"
else
  # Gunicorn
  exec gosu "$USER" gunicorn "$PROJECT_NAME.wsgi:application" \
    --bind "0.0.0.0:$GUNICORN_PORT" \
    --workers "$GUNICORN_WORKERS" \
    --timeout "$GUNICORN_TIMEOUT" \
    --log-level "$GUNICORN_LOG_LEVEL"
fi
