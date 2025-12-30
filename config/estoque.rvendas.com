server {
	listen 80;
	server_name estoque.rvendas.com www.estoque.rvendas.com;

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
	server_name estoque.rvendas.com www.estoque.rvendas.com;

	ssl_certificate /etc/letsencrypt/live/estoque.rvendas.com/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/estoque.rvendas.com/privkey.pem;
	include /etc/letsencrypt/options-ssl-nginx.conf;
	ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

	location /.well-known/acme-challenge/ {
		alias /var/www/certbot/;
	}
	
	location / {
		set $service_url http://restoque-backend:3020;
		proxy_pass $service_url;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $scheme;

		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "Upgrade";
		proxy_set_header Host $host;
	}
}

