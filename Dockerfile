FROM gradle:9.1.0-jdk-21-and-24 AS build

WORKDIR /app
COPY . .

RUN gradle clean test --no-deamon

RUN gradle bootJar --no-deamon

FROM eclipse-temurin:21-jdk

WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]

