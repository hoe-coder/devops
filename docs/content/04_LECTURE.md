## Lecture 4 – Deployment & Integration Tests

### Goals
- Deploy application automatically on the VM via GitHub Actions Runner
- Stop and replace old container by name
- Run **integration test** against the live container
- Push Docker image to **team registry** only if tests pass

### Workflow (`.github/workflows/ci-deploy.yml`)
```yaml
name: CI + Deploy + Integration Test

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

      - name: Build with Gradle (incl. bootJar)
        run: ./gradlew clean bootJar

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

### Integration Test (`ci/integration-test.sh`)
```bash
#!/usr/bin/env bash
set -euo pipefail

URL="http://localhost:8080/api/hello"
EXPECTED="Hello from DevOps App!"

for i in {1..30}; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$URL" || echo "000")
  if [ "$code" = "200" ]; then
    echo "Service responds with 200"
    break
  fi
  echo "Waiting... ($i/30), current code: $code"
  sleep 2
done

if [ "$code" != "200" ]; then
  echo "Error: Service did not return 200 (got $code)"
  docker logs --tail 100 devops-app-team9 || true
  exit 1
fi

actual=$(curl -s "$URL")
if [ "$actual" = "$EXPECTED" ]; then
  echo "Integration test passed: content matches"
  exit 0
else
  echo "Integration test failed"
  echo "Expected: $EXPECTED"
  echo "Actual:   $actual"
  exit 2
fi
```

### Registry
- Registry: `10.0.40.193:5000`
- Images pushed only if integration test passes
- Tags:
    - `devops-app-team9:latest`
    - `devops-app-team9:<commit-sha>`

Check registry:
```bash
curl http://10.0.40.193:5000/v2/_catalog
curl http://10.0.40.193:5000/v2/devops-app-team9/tags/list
```

---

## Results
- **Lecture 3**: Application builds with Gradle, runs as Docker container (JRE base).
- **Lecture 4**: Full CI/CD pipeline implemented:
    - Build → Dockerize → Deploy → Integration Test → Registry Push
- Only tested & working images are stored in the central FH registry.