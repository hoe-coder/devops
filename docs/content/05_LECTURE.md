# Lecture 5 – Code Analysis with SonarQube

### Goals
- Add automated code quality and test coverage analysis to CI pipeline
- Generate coverage reports with JaCoCo
- Analyze code with SonarQube

### Setup

**Gradle Configuration:**
- Added `jacoco` plugin to `build.gradle.kts`
- Tests automatically generate XML coverage reports at `build/reports/jacoco/test/jacocoTestReport.xml`

**SonarQube Integration:**
1. Create project "Team9" on SonarQube server (`http://10.0.40.193:9000`)
2. Generate project token (no expiration)
3. Pipeline runs SonarQube analysis via Docker container

### Pipeline Addition
Analysis step added after build:
- Runs `sonarsource/sonar-scanner-cli` Docker container
- Uploads code metrics and JaCoCo coverage report
- Results visible in SonarQube dashboard

### Reports Generated
- **HTML**: `build/jacocoHtml/index.html` (local viewing)
- **XML**: `build/reports/jacoco/test/jacocoTestReport.xml` (SonarQube upload)

### SonarQube Dashboard
Displays:
- **Quality Gates**: Maintainability, Reliability, Security grades
- **Coverage**: Percentage of code covered by tests
- **Issues**: Bugs, Code Smells, Vulnerabilities, Duplications

---

## Results
**Lecture 5**: Code quality analysis integrated - every commit triggers automated testing and quality checks with results in SonarQube