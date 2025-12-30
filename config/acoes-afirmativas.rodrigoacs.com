server {
    listen 80;
    server_name acoes-afirmativas.rodrigoacs.com www.acoes-afirmativas.rodrigoacs.com;

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
    server_name acoes-afirmativas.rodrigoacs.com www.acoes-afirmativas.rodrigoacs.com;

    ssl_certificate /etc/letsencrypt/live/acoes-afirmativas.rodrigoacs.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/acoes-afirmativas.rodrigoacs.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
	ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

	location /.well-known/acme-challenge/ {
        alias /var/www/certbot/;
    }

   location / {
	set $url http://afirmativas:8501;
	proxy_pass $url;
	proxy_set_header Host $host;
	proxy_set_header X-Real-IP $remote_addr;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_set_header X-Forwarded-Proto $scheme;
	
	proxy_http_version 1.1;
	proxy_set_header Upgrade $http_upgrade;
	proxy_set_header Connection "Upgrade";
   }
}
