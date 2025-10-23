## Lecture 4 – Deployment & Integration Tests

### Goals
- Automatically deploy application to VM using GitHub Actions
- Replace running container with new version
- Run integration tests against deployed application
- Push Docker image to registry only after successful tests

### Process
1. **Build:** Create Docker image tagged with commit SHA
2. **Deploy:** Stop old container, start new one on port 8080
3. **Test:** Run `ci/integration-test.sh` to verify `/api/hello` endpoint
4. **Push:** Upload image to team registry at `10.0.40.193:5000`

### Integration Test
Script waits up to 60 seconds for container to respond with HTTP 200, then validates response content matches expected output.

### Registry
Images stored with two tags:
- `devops-app-team9:latest` (current version)
- `devops-app-team9:<commit-sha>` (specific commit)

Check registry contents:
```bash
curl http://10.0.40.193:5000/v2/_catalog
curl http://10.0.40.193:5000/v2/devops-app-team9/tags/list
```

---

## Results
**Lecture 3**: Application containerized with JRE base image  
**Lecture 4**: Full CI/CD pipeline with automated testing and registry deployment