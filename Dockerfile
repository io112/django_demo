FROM python:latest

WORKDIR /app

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY . .

CMD ["uvicorn", "django_demo_site.asgi:application", "--port", "8000", "--host", "0.0.0.0"]