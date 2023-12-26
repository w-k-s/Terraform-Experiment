FROM --platform=linux/amd64 openjdk:17-alpine
RUN apk add --update curl \
    && rm -rf /var/cache/apk/*
HEALTHCHECK --interval=30s --timeout=4s CMD curl -f http://localhost:8080/actuator/health || exit 1

WORKDIR /opt/shopping
COPY target/order-service-*-SNAPSHOT.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]