# DevOps Lecture 6 – Code Analysis & Documentation

### Overview
This project demonstrates automated code quality analysis using **SonarQube**
and continuous documentation generation using **MkDocs Material**.

### Build Pipeline
- **Gradle** builds the Spring Boot application and runs tests.
- **SonarQube** analyzes the code and reports coverage and issues.
- **MkDocs** generates documentation as static HTML.
- **Nginx** serves the generated documentation as a container.

###  Components
- Spring Boot App (JRE Image)
- Documentation Site (Nginx Image)

