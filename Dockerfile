# Java Runtime als Basis nehmen
FROM eclipse-temurin:21-jre

# Arbeitsverzeichnis im Container
WORKDIR /app

# JAR ins Image kopieren
COPY build/libs/devops-0.0.1-SNAPSHOT.jar app.jar

# Port, auf dem die App läuft
EXPOSE 8080

# Startbefehl
ENTRYPOINT ["java", "-jar", "app.jar"]
