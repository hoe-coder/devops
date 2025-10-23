# Lecture 6 – Documentation with MkDocs

### Goals
- Generate technical documentation automatically
- Deploy documentation as containerized web service
- Integrate documentation build into CI/CD pipeline

### Setup

**MkDocs Configuration (`docs/mkdocs.yml`):**
- Uses Material theme
- Documentation source files in `docs/content/`
- Generates static HTML site

**Dockerfile (`Dockerfile.nginx`):**
```dockerfile
FROM nginx
COPY docs/build/site /usr/share/nginx/html
```

### Pipeline Integration
Documentation steps added after registry push:

1. **Build Documentation**: Run MkDocs via Docker container to generate static site
2. **Create Image**: Build nginx container with generated HTML
3. **Deploy**: Run documentation container on port 8081
4. **Test**: Verify documentation is accessible

### Deployment
- **Container name**: `mydoc`
- **Port**: 8081
- **Restart policy**: always
- **Access**: `http://10.0.40.189:8081`

### Integration Test
Script verifies documentation container responds with HTTP 200, confirming successful deployment.

---

## Results
**Lecture 6**: Automated documentation generation and deployment - every commit updates both application and documentation, accessible at dedicated port