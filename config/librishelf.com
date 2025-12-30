server {
	listen 80;
	server_name librishelf.com www.librishelf.com;

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
	server_name librishelf.com www.librishelf.com;

	proxy_set_header Host $host;
	proxy_set_header X-Real-IP $remote_addr;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_set_header X-Forwarded-Proto $scheme;
	
	ssl_certificate /etc/letsencrypt/live/librishelf.com/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/librishelf.com/privkey.pem;
	include /etc/letsencrypt/options-ssl-nginx.conf;
	ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

	location /.well-known/acme-challenge/ {
		alias /var/www/certbot/;
	}
	
	location / {
		set $url http://librishelf-frontend:80;
		proxy_pass $url;
	}

	location /api/ {
		set $url http://librishelf-backend:3050;
		rewrite ^/api/(.*)$ /$1 break;
		proxy_pass $url;
	}
}

