# Lecture 2 – CI/CD Setup & First Pipeline

### Goals
- Install and configure GitHub Actions Runner on team VM
- Create first CI pipeline
- Run Docker "Hello World" test

### Setup Process

**GitHub Actions Runner Installation:**
1. SSH access to VM as user `svcgithub`
2. Download and configure runner from repository settings
3. Runner registered as self-hosted agent
4. Configured as SystemD service for automatic startup

**First Pipeline:**
- Created `.github/workflows/` directory
- Basic workflow file to verify runner connectivity
- Extended to run Docker hello-world container

### VM Access
- **IP Address**: 10.0.40.189
- **User**: `svcgithub`
- **Connection**: `ssh svcgithub@10.0.40.189`

### Key Learnings
- Self-hosted runners execute workflows directly on team VM
- Runner must have Docker access for containerized builds
- Workflows trigger automatically on push to specified branches

---

## Results
**Lecture 2**: GitHub Actions infrastructure established - team VM configured as self-hosted runner, ready for CI/CD pipelines