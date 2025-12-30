server {
	listen 80;
	server_name rodrigoacs.com www.rodrigoacs.com;

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
    server_name rodrigoacs.com www.rodrigoacs.com;
	
    ssl_certificate /etc/letsencrypt/live/rodrigoacs.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rodrigoacs.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location /.well-known/acme-challenge/ {
        alias /var/www/certbot/;
    }

    location / {
	set $service_url http://rodrigoacs-frontend:80;
	proxy_pass $service_url;
    }
}
