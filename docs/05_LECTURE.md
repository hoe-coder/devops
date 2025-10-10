# Lecture 5 – Code Analysis with SonarQube

### Goals
- Add **code quality and coverage analysis** to the CI pipeline
- Integrate **JaCoCo** plugin for test coverage reporting
- Generate **XML & HTML reports** during the Gradle build
- Run **SonarQube analysis** via Docker (`sonarsource/sonar-scanner-cli`)
- View quality metrics (Bugs, Code Smells, Coverage, Duplications) in SonarQube Dashboard

---

### Gradle Setup (`build.gradle.kts`)
```kotlin
plugins {
    java
    id("org.springframework.boot") version "4.0.0-SNAPSHOT"
    id("io.spring.dependency-management") version "1.1.7"
    id("jacoco")
}

group = "com.example"
version = "0.0.1-SNAPSHOT"
description = "DevOps Lecture 5 – Code Analysis with SonarQube"

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

repositories {
    mavenCentral()
    maven { url = uri("https://repo.spring.io/snapshot") }
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-web")
    runtimeOnly("com.h2database:h2")
    developmentOnly("org.springframework.boot:spring-boot-devtools")
    developmentOnly("org.springframework.boot:spring-boot-docker-compose")
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.withType<Test> {
    useJUnitPlatform()
    finalizedBy("jacocoTestReport")
}

tasks.named<JacocoReport>("jacocoTestReport") {
    dependsOn(tasks.test)
    reports {
        xml.required.set(true)   // needed for SonarQube integration
        csv.required.set(false)
        html.outputLocation.set(layout.buildDirectory.dir("jacocoHtml"))
    }
}

jacoco {
    toolVersion = "0.8.12"
}
```

---

### Generated Reports
After running
```bash
./gradlew clean test jacocoTestReport
```
Reports are generated at:

| Type | Path | Purpose |
|------|------|----------|
| HTML | `build/jacocoHtml/index.html` | Local visualization of coverage |
| XML  | `build/reports/jacoco/test/jacocoTestReport.xml` | Used by SonarQube |

---

### Workflow (`.github/workflows/ci-deploy.yml`)
```yaml
name: CI + Deploy + Integration Test + SonarQube

on:
  push:
    branches: ["main"]

jobs:
  build-and-deploy:
    runs-on: self-hosted

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up JDK
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 21

      # Build & run tests (generate coverage)
      - name: Build with Gradle (incl. JaCoCo)
        run: ./gradlew clean test jacocoTestReport bootJar

      # SonarQube code analysis
      - name: Run SonarQube analysis
        run: |
          docker run --rm             -e SONAR_HOST_URL="http://10.0.40.193:9000"             -e SONAR_TOKEN="${{ secrets.SONAR_TOKEN }}"             -v "$(pwd):/usr/src"             sonarsource/sonar-scanner-cli             -Dsonar.projectKey=Team9             -Dsonar.sources=.             -Dsonar.java.binaries=build/classes/java/main             -Dsonar.coverage.jacoco.xmlReportPaths=build/reports/jacoco/test/jacocoTestReport.xml

      - name: Build Docker image (tag with commit SHA, plus latest)
        run: |
          IMAGE_TAG="devops-app-team9:${{ github.sha }}"
          docker build -t "$IMAGE_TAG" .
          docker tag "$IMAGE_TAG" devops-app-team9:latest

      - name: Stop and remove old container (ignore errors)
        run: |
          docker stop devops-app-team9 || true
          docker rm devops-app-team9 || true

      - name: Run container
        run: |
          docker run -d --name devops-app-team9 --restart unless-stopped -p 8080:8080 devops-app-team9:latest

      - name: Wait & Run integration tests
        run: |
          chmod +x ci/integration-test.sh
          ./ci/integration-test.sh

      - name: Tag and push to registry (only if tests passed)
        run: |
          REG="10.0.40.193:5000"
          IMAGE_TAG="devops-app-team9:${{ github.sha }}"
          REG_IMAGE="$REG/devops-app-team9:${{ github.sha }}"
          docker tag "$IMAGE_TAG" "$REG_IMAGE"
          docker push "$REG_IMAGE"
          docker tag devops-app-team9:latest "$REG/devops-app-team9:latest"
          docker push "$REG/devops-app-team9:latest"
```

---

### SonarQube Setup
1. Go to [SonarQube Server](http://10.0.40.193:9000)
2. Create a new project named **Team9**
3. Choose *“Other (locally)”* and generate a project token  
   (set expiration to *No expiration*)
4. Add the token in GitHub → **Settings → Secrets → Actions**  
   Name: `SONAR_TOKEN`
5. Re-run the pipeline → results will appear automatically in SonarQube

---

### Results
- CI/CD pipeline now includes **code quality and test coverage analysis**
- SonarQube automatically displays:
    - **Maintainability, Reliability, Security Grades**
    - **Coverage** via JaCoCo XML
    - **Code Smells, Duplications, and Security Hotspots**
- Dashboard example (Team9):
    - Security: A | Reliability: A | Maintainability: A
    - Coverage: 0.0% (increases with more tests)
    - Duplications: 0.0%

---

    
### Notes
- `sonarsource/sonar-scanner-cli` container runs analysis against the remote SonarQube instance.
- Token-based authentication ensures secure upload of code metrics.
- Reports are generated automatically in `build/` and uploaded after each commit to `main`.
