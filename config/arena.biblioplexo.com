server {
	listen 80;
	server_name arena.biblioplexo.com www.arena.biblioplexo.com;

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
	server_name arena.biblioplexo.com www.arena.biblioplexo.com;

	ssl_certificate /etc/letsencrypt/live/arena.biblioplexo.com/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/arena.biblioplexo.com/privkey.pem;
	include /etc/letsencrypt/options-ssl-nginx.conf;
	ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

	location /.well-known/acme-challenge/ {
		alias /var/www/certbot/;
	}
	
	location / {
		proxy_pass http://arena-frontend:80;
	}
}

