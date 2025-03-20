FROM dart:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock* ./

RUN dart pub get

COPY . .

RUN dart compile exe bin/server.dart -o server

FROM alpine:latest

RUN apk add --no-cache ca-certificates libstdc++

WORKDIR /app

RUN mkdir -p /app/static

COPY --from=build /app/server /app/
COPY --from=build /app/static /app/static/

CMD ["/app/server"]
