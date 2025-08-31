# Security Guidelines

## 🔒 Sensitive Data Protection

### Files that should NEVER be committed:
- `terraform.tfvars` - Contains sensitive configuration values
- `*.pem`, `*.key` - SSH keys and certificates
- `credentials*` - AWS/Cloud provider credentials
- `.env*` - Environment variables
- `*secret*`, `*password*` - Any files containing secrets

### Configuration Setup:
1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Fill in your specific values (ARNs, account IDs, etc.)
3. Verify `.gitignore` is working: `git check-ignore terraform.tfvars`

## 🛡️ AWS Security Best Practices

### IAM User Configuration:
- Use IAM users with minimal required permissions
- Enable MFA on all administrative accounts
- Rotate access keys regularly
- Never hardcode AWS credentials in code

### EKS Security:
- Worker nodes are in private subnets (✅ implemented)
- Access via EKS Access Entries only (✅ implemented)
- OIDC provider for service accounts (✅ implemented)
- Regular security patches and updates

## 🚨 Security Checklist

Before any commit:
- [ ] No `.tfvars` files in git
- [ ] No hardcoded secrets or credentials
- [ ] No private keys or certificates
- [ ] `.gitignore` is comprehensive
- [ ] Sensitive data is in external configuration

## 🔍 Verification Commands

```bash
# Check for sensitive files in git
git ls-files | grep -E '\.(tfvars|env|key|pem)$|secret'

# Verify gitignore is working
git check-ignore terraform.tfvars

# Check for exposed secrets in commit history
git log --grep="password\|secret\|key" --oneline
```

## 🆘 If Secrets Were Committed

1. **DO NOT** push to remote repository
2. Remove secrets from files immediately
3. Use `git filter-branch` or BFG Repo-Cleaner to remove from history
4. Rotate any exposed credentials immediately
5. Review all commits for sensitive data

## 📞 Security Incident Response

If sensitive data was accidentally committed:
1. Stop all operations immediately
2. Assess the scope of exposure
3. Rotate all potentially compromised credentials
4. Clean git history using appropriate tools
5. Document the incident and prevention measures with e-mail luan.dotto@premiersoft.net