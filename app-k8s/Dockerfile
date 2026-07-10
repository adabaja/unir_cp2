FROM docker.io/library/python:3.12-slim

# Logs sin buffer: sin esto, kubectl logs puede mostrarse vacío
ENV PYTHONUNBUFFERED=1

RUN pip install --no-cache-dir flask

COPY app.py /app/app.py

EXPOSE 8000
CMD ["python", "/app/app.py"]