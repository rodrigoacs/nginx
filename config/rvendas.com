#server {
#	listen 443 ssl;
#	http2 on;
#	server_name rvendas.com www.rvendas.com;
#
#	ssl_certificate /cert/rvendas/fullchain.pem;
#	ssl_certificate_key /cert/rvendas/privkey.pem;
#
#	proxy_set_header Host $host;
#	proxy_set_header X-Real-IP $remote_addr;
#	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#	proxy_set_header X-Forwarded-Proto $scheme;
#}
