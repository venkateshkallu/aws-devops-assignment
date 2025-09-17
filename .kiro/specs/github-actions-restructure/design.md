# Design Document

## Overview

This design addresses the challenge of organizing GitHub Actions workflows within the desired `pipeline` directory structure while maintaining GitHub's requirement that workflows must be located in `.github/workflows/`. The solution implements a hybrid approach that satisfies both the organizational requirements and GitHub's technical constraints.

## Architecture

The design uses a **symbolic link and reference architecture** that maintains GitHub Actions functionality while organizing workflow files logically within the pipeline directory structure.

### Key Design Principles

1. **GitHub Compatibility**: Maintain `.github/workflows/` for GitHub Actions discovery
2. **Logical Organization**: Use `pipeline/workflows/` for source workflow files
3. **Single Source of Truth**: Workflow definitions live in `pipeline/workflows/`
4. **Automated Synchronization**: Ensure changes propagate correctly

## Components and Interfaces

### 1. Directory Structure

```
# Symlink or copy of actual workflow
├── pipeline/               # GitHub Actions workflows (source)
│   ├── ci-cd.yml          # Master workflow definition
│   ├── sync-workflows.sh  # Utility script for synchronization
│   └── trust-policy.json  # Existing pipeline files
├── app/                   # Node.js demo app + Dockerfile
├── iac/                   # Terraform code for AWS resources
└── README.md              # Documentation
```

### 2. Workflow Management System

#### Component: Workflow Synchronization
- **Purpose**: Ensure `.github/workflows/` stays in sync with `pipeline/workflows/`
- **Implementation**: Shell script or GitHub Action that copies/links files
- **Trigger**: Pre-commit hooks or automated workflow

#### Component: Workflow Validation
- **Purpose**: Validate workflow syntax before synchronization
- **Implementation**: GitHub Actions workflow linting
- **Integration**: Part of the synchronization process

### 3. Implementation Approaches

#### Approach A: Symbolic Links (Recommended)
- Create symbolic links from `.github/workflows/` to `pipeline/workflows/`
- Pros: Real-time synchronization, single source of truth
- Cons: May not work on all systems (Windows compatibility)

#### Approach B: Automated Copy with Git Hooks
- Use pre-commit hooks to copy files from `pipeline/workflows/` to `.github/workflows/`
- Pros: Universal compatibility, explicit control
- Cons: Requires developer discipline, potential for drift

#### Approach C: Workflow Generator
- Generate `.github/workflows/` files from templates in `pipeline/workflows/`
- Pros: Flexible, supports templating and environment-specific configs
- Cons: More complex, requires build step

## Data Models

### Workflow Configuration Schema

```yaml
# pipeline/ci-cd.yml
name: CI/CD Pipeline - ECS Fargate
metadata:
  description: "Main deployment workflow"
  maintainer: "DevOps Team"
  sync_target: ".github/workflows/ci-cd.yml"

on:
  push:
    branches: [main]

# ... rest of workflow definition
```

### Synchronization Manifest

```json
{
  "workflows": [
    {
      "source": "pipeline/ci-cd.yml",
      "target": ".github/workflows/ci-cd.yml",
      "type": "symlink"
    }
  ],
  "last_sync": "2025-09-17T10:35:00Z",
  "sync_method": "symlink"
}
```

## Error Handling

### Synchronization Failures
- **Detection**: Compare file timestamps and checksums
- **Recovery**: Automatic re-sync with fallback to manual intervention
- **Notification**: GitHub Actions status checks and PR comments

### Workflow Validation Errors
- **Pre-sync Validation**: Lint YAML syntax and GitHub Actions schema
- **Rollback Strategy**: Maintain backup of last known good configuration
- **Error Reporting**: Clear error messages with line numbers and suggestions

### Cross-Platform Compatibility
- **Symlink Fallback**: Detect OS and fall back to file copying on Windows
- **Path Handling**: Use cross-platform path utilities
- **Permission Management**: Handle file permissions appropriately

## Testing Strategy

### Unit Tests
- Workflow YAML syntax validation
- Synchronization script functionality
- Path resolution and file operations

### Integration Tests
- End-to-end workflow execution
- Synchronization process validation
- Cross-platform compatibility testing

### Automated Testing
- Pre-commit hooks for workflow validation
- GitHub Actions workflow to test the sync process
- Periodic validation of workflow integrity

### Test Scenarios
1. **New Workflow Addition**: Add workflow to `pipeline/` directory and verify sync
2. **Workflow Modification**: Update existing workflow and verify propagation
3. **Sync Failure Recovery**: Simulate sync failure and test recovery
4. **Cross-Platform**: Test on Linux, macOS, and Windows environments

## Implementation Phases

### Phase 1: Basic Structure Setup
- Move existing workflow from `.github/workflows/` to `pipeline/` directory
- Implement basic synchronization mechanism
- Ensure GitHub Actions continues to work

### Phase 2: Automation and Validation
- Add pre-commit hooks or automated sync
- Implement workflow validation
- Add error handling and recovery

### Phase 3: Documentation and Optimization
- Update README.md with new structure
- Add developer guidelines
- Optimize sync performance and reliability

## Security Considerations

- Ensure synchronization process doesn't expose sensitive information
- Validate workflow content to prevent injection attacks
- Maintain proper file permissions and access controls
- Use secure methods for any automated synchronization processes