FROM docker.io/library/nginx:1.27

# openssl (certificado) y apache2-utils (htpasswd), solo para el build
RUN apt-get update && \
    apt-get install -y --no-install-recommends openssl apache2-utils && \
    rm -rf /var/lib/apt/lists/*

# Certificado x.509 autofirmado generado DENTRO de la imagen (requisito: autocontenida)
RUN mkdir -p /etc/nginx/certs && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/nginx/certs/server.key \
      -out    /etc/nginx/certs/server.crt \
      -subj   "/C=ES/O=UNIR/CN=casopractico2"

# Credenciales de acceso web
RUN htpasswd -bc /etc/nginx/.htpasswd admin casopractico2

# Configuración del servidor y contenido
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80 443