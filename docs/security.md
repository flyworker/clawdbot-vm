# Why Run OpenClaw in a VM?

Running AI assistants like OpenClaw directly on your local machine poses security risks. This document explains why VM isolation is the safer approach.

## The Problem with Local Installation

When you install OpenClaw (or any AI agent) locally, it runs with your user permissions. This means it can:

- Read your SSH keys (`~/.ssh/`)
- Access cloud credentials (`~/.aws/`, `~/.config/gcloud/`)
- Read browser cookies and saved passwords
- Access cryptocurrency wallets
- Read/modify any file you can access
- Monitor network traffic on your machine

AI agents are powerful precisely because they can take actions on your behalf. That same power becomes a liability if the agent is compromised, has bugs, or behaves unexpectedly.

## VM Isolation: A Security Sandbox

Running OpenClaw in a VM creates a security boundary:

```
┌─────────────────────────────────────────┐
│  Your Host Machine                      │
│  ├── SSH keys, credentials, files       │
│  ├── Browser data                       │
│  └── Everything you care about          │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  Multipass VM (openclaw)          │  │
│  │  ├── Isolated filesystem          │  │
│  │  ├── Separate network stack       │  │
│  │  ├── Only openclaw + deps         │  │
│  │  └── Disposable                   │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

The VM can only see its own filesystem. Your host machine's sensitive data is invisible to it.

## Risk Comparison

| Risk | Local Install | VM Install |
|------|---------------|------------|
| File system access | Full access to your files | Only sees VM's filesystem |
| Credentials exposure | Can access ~/.ssh, ~/.aws, browser cookies | Isolated - can't reach host |
| Malicious code | Runs with your user permissions | Contained in VM sandbox |
| Supply chain attack | Direct access to host | Limited to VM |
| Cleanup | Scattered files, hard to fully remove | `multipass delete && purge` |
| Network sniffing | Same network namespace as host | Separate network stack |

## Worst Case Scenarios

### Local Installation
A compromised or buggy openclaw could:
- Exfiltrate your SSH keys to an attacker
- Read browser session cookies and hijack accounts
- Access cryptocurrency wallet files
- Modify your code repositories
- Install persistent backdoors

### VM Installation
A compromised openclaw can only:
- Damage files inside the VM
- Use your Anthropic API credits

**Solution**: Delete the VM and create a new one. Your host is untouched.

```bash
multipass delete openclaw && multipass purge
./install.sh
```

## Additional Security Measures

This setup includes:

1. **UFW Firewall** - Denies all incoming connections except SSH
2. **fail2ban** - Blocks brute force attacks
3. **Minimal attack surface** - Only essential packages installed
4. **Non-root execution** - OpenClaw runs as unprivileged user

## Best Practices

1. **Use a dedicated API key** - Create a separate Anthropic API key for openclaw
2. **Set spending limits** - Configure usage limits in Anthropic console
3. **Keep the VM updated** - Run `sudo apt update && sudo apt upgrade` periodically
4. **Review permissions** - Understand what messaging platforms openclaw connects to
5. **Disposable mindset** - Treat the VM as ephemeral; rebuild if in doubt

## Trade-offs

VM isolation does have costs:

- **Resource overhead**: 4GB RAM, 20GB disk dedicated to VM
- **Slight latency**: VM adds minimal overhead
- **Extra step**: Must `multipass shell` to access

For most users, these trade-offs are worth the security benefits.

## Conclusion

Running AI agents in isolated VMs follows the principle of least privilege. The agent gets only what it needs (API access, messaging connections) without access to your sensitive local data.

When in doubt, delete and recreate. That's the power of disposable infrastructure.
