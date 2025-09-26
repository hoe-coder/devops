FROM gradle:9.1.0-jdk21 AS build

WORKDIR /home/svcgithub/app
COPY . .

#RUN gradle clean test --no-daemon -Dspring.profiles.active=test
RUN gradle bootJar --no-daemon -x test

FROM eclipse-temurin:21-jdk

WORKDIR /home/svcgithub/app
COPY --from=build /home/svcgithub/app/build/libs/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]