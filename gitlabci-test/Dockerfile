FROM docker:latest
RUN apk --update --no-cache add nginx openssh rsync git curl
RUN rm /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf
WORKDIR /var/www
RUN echo Hello > /var/www/index.html

EXPOSE 80
