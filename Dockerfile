FROM alpine:3.18.0
RUN apk add zola
COPY . .
RUN zola build

FROM nginx
COPY --from=0 public /usr/share/nginx/html
