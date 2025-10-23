## Lecture 3 – Build & Dockerize

### Goals
- Build the Spring Boot application with Gradle
- Generate a **FatJar** including all dependencies
- Create a Docker image using JRE base image
- Run the application in a container

### Steps
1. **Build Application**
   ```bash
   ./gradlew clean bootJar
   ```
   → Generates `build/libs/devops-0.0.1-SNAPSHOT.jar`

2. **Dockerfile**
   ```dockerfile
   FROM eclipse-temurin:21-jre
   WORKDIR /app
   COPY build/libs/devops-0.0.1-SNAPSHOT.jar app.jar
   EXPOSE 8080
   ENTRYPOINT ["java", "-jar", "app.jar"]
   ```

3. **Build & Run**
   ```bash
   docker build -t devops-app-team9:latest .
   docker run -p 8080:8080 devops-app-team9:latest
   ```
---