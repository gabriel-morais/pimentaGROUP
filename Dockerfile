FROM pivotalpa/angular-cli

WORKDIR /build
COPY . /build

RUN apk update \
    && apk add nginx

RUN adduser -D -g 'www' www \
    && mkdir /www \
    && chown -R www:www /www \
    && chown -R www:www /var/lib/nginx \
    && cp -v nginx.conf /etc/nginx/nginx.conf

RUN npm install \
    && ng build -prod

RUN cp -r ./dist/* /www \
    && rm -rf ./*

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
