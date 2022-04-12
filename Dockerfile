# syntax=docker/dockerfile:1

FROM nginx

COPY build /usr/share/nginx/html

