server {
    listen 80;
    server_name biblioplexo.com www.biblioplexo.com;

    location /.well-known/acme-challenge/ {
	root /var/www/certbot;
    }

    location / {
	return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    http2 on;
    server_name biblioplexo.com www.biblioplexo.com;
	
    ssl_certificate /etc/letsencrypt/live/biblioplexo.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/biblioplexo.com/privkey.pem;

    location /.well-known/acme-challenge/ {
        alias /var/www/certbot/;
    }

    location / {
        root /var/www/biblioplexo;
        index index.html;
	    try_files $uri $uri/ /index.html;
    }
}
