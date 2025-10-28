# Pull Request

## Description
Provide a clear and concise description of what this pull request does.

**Type of Change**
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring (no functional changes)
- [ ] Security improvement
- [ ] Dependency update

## Related Issues
Fixes #(issue_number)
Closes #(issue_number)
Related to #(issue_number)

## Changes Made
### Summary of Changes
- List the key changes made in this PR
- Be specific about what was added, modified, or removed
- Include any new dependencies or configuration changes

### Files Changed
- `file1.bicep` - Description of changes
- `file2.yaml` - Description of changes
- `docs/file3.md` - Description of changes

## Testing
### Test Environment
- [ ] Tested in development subscription
- [ ] Tested in staging subscription
- [ ] Tested with minimal configuration
- [ ] Tested with complex configuration

### Test Scenarios
Describe the test scenarios you ran:
1. Scenario 1: Description and results
2. Scenario 2: Description and results
3. Scenario 3: Description and results

### Validation Steps
- [ ] Bicep templates validate successfully (`azd provision --preview`)
- [ ] Deployment completes without errors
- [ ] All resources are created as expected
- [ ] Functionality works as intended
- [ ] No regression in existing features
- [ ] Documentation is accurate

### Test Configuration
```yaml
# Include test configuration used (remove sensitive data)
solutionName: "test-config"
# ... other test settings
```

## Breaking Changes
**Are there any breaking changes?** [Yes/No]

If yes, describe:
- What functionality is affected
- How users should migrate their configurations
- Timeline for deprecation (if applicable)

### Migration Guide
```yaml
# Old configuration
oldSetting: "value"

# New configuration
newSetting: "value"
```

## Screenshots/Diagrams
If applicable, add screenshots or diagrams to help explain your changes.

## Documentation
- [ ] README.md updated (if needed)
- [ ] Documentation updated in `/docs` (if needed)
- [ ] Inline code comments added for complex logic
- [ ] Parameter descriptions updated
- [ ] Examples updated
- [ ] CHANGELOG.md updated

## Security Considerations
- [ ] No sensitive data exposed
- [ ] Follows security best practices
- [ ] Uses managed identities where applicable
- [ ] Implements least-privilege access
- [ ] No hardcoded secrets or keys

## Performance Impact
- [ ] No negative performance impact
- [ ] Performance improvement quantified
- [ ] Resource efficiency considered
- [ ] Scalability implications assessed

## Checklist
### Code Quality
- [ ] Code follows the style guidelines of this project
- [ ] Self-review of code completed
- [ ] Code is properly documented
- [ ] No commented-out code left behind
- [ ] No debug statements or test code included

### Functionality  
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published

### Documentation
- [ ] I have made corresponding changes to the documentation
- [ ] I have updated the CHANGELOG.md file
- [ ] I have added inline documentation for complex logic
- [ ] Examples have been updated to reflect changes

## Deployment Instructions
**How to deploy/test these changes:**
1. Step 1
2. Step 2
3. Step 3

**Configuration requirements:**
- Any new parameters that need to be set
- Changes to existing parameter values
- New dependencies or prerequisites

## Additional Notes
**Implementation Details:**
Any additional context, design decisions, or implementation details that reviewers should know.

**Future Improvements:**
Suggestions for future enhancements or related work.

**Known Limitations:**
Any known limitations or edge cases with this implementation.

---

### For Reviewers
**Review Focus Areas:**
- Security implications
- Performance impact
- Breaking changes
- Documentation accuracy
- Test coverage

**Deployment Verification:**
- [ ] Reviewer has validated the deployment in their environment
- [ ] Configuration examples have been tested
- [ ] Documentation has been verified

### Post-Merge Actions
- [ ] Update project boards
- [ ] Create release notes entry
- [ ] Notify stakeholders
- [ ] Update related documentation