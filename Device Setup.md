# Device Setup

This guide covers getting the [dotfiles](https://github.com/brajeshwar/dot) running on a work or client machine where you need a separate GitHub identity alongside your personal one.

Two tracks depending on your network:

- **Track A — SSH available** (personal machines, offices without firewall restrictions)
- **Track B — HTTPS only** (corporate machines where SSH is blocked by the firewall)

---

## 1. Clone and bootstrap

```sh
git clone https://github.com/brajeshwar/dot.git ~/dot
cd ~/dot
chmod +x bootstrap.sh
./bootstrap.sh
```

---

## Track A — SSH available

### 2A. Generate a device-specific SSH key

Work and job devices use a codename scheme to avoid identifying the employer in public configs. Pick a codename for this job identity (e.g., `job94776`).

```sh
ssh-keygen -t ed25519 -C "you@work.com" -f ~/.ssh/id_ed25519_job94776
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_job94776
```

Add the public key to the relevant GitHub account in **two places**:
- Settings → SSH and GPG keys → **Authentication keys** (for push/pull)
- Settings → SSH and GPG keys → **Signing keys** (for commit verification)

Both entries use the same `~/.ssh/id_ed25519_job94776.pub` — one key, two purposes.

### 3A. Create ~/.ssh/config.local

```sh
cp ~/dot/ssh/config.local.example ~/.ssh/config.local
```

Add the work identity block:

```sshconfig
Host github-job94776
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_job94776
  IdentitiesOnly yes
```

### 4A. Create ~/.gitconfig.local

```sh
cp ~/dot/git/gitconfig.local.example ~/.gitconfig.local
```

Uncomment and fill in the personal machine block (SSH push rewrite):

```ini
[url "git@github.com:"]
    pushInsteadOf = https://github.com/
```

### 5A. Create ~/.gitconfig.work

```sh
cp ~/dot/git/gitconfig.work.example ~/.gitconfig.work
```

Fill in your work identity and credentials:

```ini
[user]
    name  = Your Name
    email = you@work.com
    signingkey = ~/.ssh/id_ed25519_job94776.pub

[gpg]
    format = ssh

[gpg "ssh"]
    allowedSignersFile = ~/.ssh/allowed_signers

[credential "https://github.com"]
    helper =
    helper = osxkeychain
    username = <work-github-username>
```

Create the allowed signers file so git can verify your own commits locally:

```sh
echo "you@work.com namespaces=\"git\" $(cat ~/.ssh/id_ed25519_job94776.pub)" \
  >> ~/.ssh/allowed_signers
```

### 6A. Clone work repos

```sh
git clone git@github-job94776:<org>/<repo>.git ~/dev/<repo>
```

Repos under `~/dev/` automatically get the work identity from `~/.gitconfig.work`.
Personal repos go anywhere outside `~/dev/`.

---

## Track B — HTTPS only (SSH blocked)

SSH is blocked by the corporate firewall. All GitHub operations use HTTPS. You will have two accounts on github.com: your personal one and your work one.

### 2B. Generate a device-specific SSH key (for commit signing only)

SSH keys can still be used to *sign commits* locally — no network connection needed. Generate one even though it won't be used for transport.

```sh
ssh-keygen -t ed25519 -C "you@work.com" -f ~/.ssh/id_ed25519_job94776
```

Add the public key to your **work** GitHub account under:
Settings → SSH and GPG keys → **Signing keys** (not Authentication keys — HTTPS handles auth).

### 3B. Generate Personal Access Tokens (PATs)

GitHub does not accept your login password for git operations over HTTPS. You need a PAT for each account — the PAT *is* the password git uses.

**Personal PAT** — log into github.com as your personal account:
Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token. Scope: `repo` (add `workflow` if you push GitHub Actions changes).

**Work PAT** — log into github.com as your work account, same path.

Save both tokens somewhere safe (e.g. 1Password) — they are shown only once.

### 4B. Create ~/.gitconfig.local

```sh
cp ~/dot/git/gitconfig.local.example ~/.gitconfig.local
```

Uncomment and fill in the office machine block:

```ini
# Rewrite any git@github.com: remote URLs to HTTPS.
# Handles repos previously cloned with SSH URLs.
[url "https://github.com/"]
    insteadOf = git@github.com:

# Personal GitHub credentials (default for repos outside ~/dev/).
# Empty helper = clears the gh auth git-credential chain from global config.
[credential "https://github.com"]
    helper =
    helper = osxkeychain
    username = <personal-github-username>

[credential "https://gist.github.com"]
    helper =
    helper = osxkeychain
    username = <personal-github-username>

# Disable GPG signing for personal repos on this machine.
# GPG is typically not set up on corporate machines.
# Work repos get SSH signing via ~/.gitconfig.work instead.
[commit]
    gpgsign = false

[tag]
    gpgSign = false
```

### 5B. Create ~/.gitconfig.work

```sh
cp ~/dot/git/gitconfig.work.example ~/.gitconfig.work
```

Fill in your work identity, signing key, and work credentials:

```ini
[user]
    name  = Your Name
    email = you@work.com
    signingkey = ~/.ssh/id_ed25519_job94776.pub

[gpg]
    format = ssh

[gpg "ssh"]
    allowedSignersFile = ~/.ssh/allowed_signers

[credential "https://github.com"]
    helper =
    helper = osxkeychain
    username = <work-github-username>

[credential "https://gist.github.com"]
    helper =
    helper = osxkeychain
    username = <work-github-username>
```

Create the allowed signers file:

```sh
echo "you@work.com namespaces=\"git\" $(cat ~/.ssh/id_ed25519_job94776.pub)" \
  >> ~/.ssh/allowed_signers
```

### 6B. Store both PATs in the macOS Keychain

macOS Keychain stores two separate entries for `github.com` — one per username. The `username =` hint in the gitconfig sections picks the right one automatically.

```sh
printf 'protocol=https\nhost=github.com\nusername=<personal-github-username>\npassword=<PERSONAL_PAT>\n' \
  | git credential approve

printf 'protocol=https\nhost=github.com\nusername=<work-github-username>\npassword=<WORK_PAT>\n' \
  | git credential approve
```

### 7B. Check for conflicting system gitconfig

Corporate machines sometimes have a pre-existing `~/.gitconfig` that sets `pushInsteadOf`, which conflicts with the HTTPS setup. Check:

```sh
git config --list --show-origin | grep insteadof
```

You should see only the `insteadOf` entry from your `~/.gitconfig.local`. If you see a `pushInsteadOf` from `~/.gitconfig`, remove it:

```sh
git config --global --unset 'url.git@github.com:.pushInsteadOf'
```

### 8B. Clone repos

Work repos — clone into `~/dev/` to automatically pick up work identity and credentials:

```sh
git clone https://github.com/<work-org>/<repo>.git ~/dev/<repo>
```

Personal repos — clone anywhere outside `~/dev/`:

```sh
git clone https://github.com/brajeshwar/<repo>.git ~/src/<repo>
```

If you have an existing repo cloned with an SSH remote URL, update it:

```sh
git remote set-url origin https://github.com/OWNER/REPO.git
```

---

## 9. Test

```sh
sh ~/dot/test.sh
```

All checks should pass. If SSH assertions fail, verify `~/.ssh/config.local` is in place and the key file exists.
