FROM node:lts AS runtime
WORKDIR /app

COPY . .

RUN apt-get update && \
  apt-get install -y openssl && \
  openssl genrsa -des3 -passout pass:x -out server.pass.key 2048 && \
  openssl rsa -passin pass:x -in server.pass.key -out server.key && \
  rm server.pass.key && \
  openssl req -new -key server.key -out server.csr \
  -subj "/C=UK/ST=Ontario/L=Toronto/O=AtRiskMedia/OU=TractStack/CN=ZZZZZ.tractstack.com" && \
  openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

RUN corepack enable
RUN yarn set version stable
RUN yarn install
RUN yarn run build

ENV HOST=0.0.0.0
ENV PORT=ZZZZY
EXPOSE ZZZZY
CMD node ./dist/server/entry.mjs
