server {
    listen 80;
    server_name mrtsolarcongonhas.com www.mrtsolarcongonhas.com;

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
    server_name mrtsolarcongonhas.com www.mrtsolarcongonhas.com;
	
    ssl_certificate /etc/letsencrypt/live/mrtsolarcongonhas.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mrtsolarcongonhas.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
	ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location /.well-known/acme-challenge/ {
        alias /var/www/certbot/;
    }

    location / {
	set $url http://mrtsolarcongonhas-frontend:80;
	proxy_pass $url;
    }

    location /api {
	set $url http://mrtsolarcongonhas-backend:3040;
	proxy_pass $url;
    }

}
