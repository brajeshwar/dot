# Device Setup

This guide covers getting the dotfiles running on a work or client machine where you need a separate GitHub identity and SSH key.

## 1. Clone and bootstrap

```sh
git clone git@github.com:<your-handle>/dot.git ~/dot
cd ~/dot
chmod +x bootstrap.sh
./bootstrap.sh
```

## 2. Generate a device-specific SSH key

Work and job devices use a codename scheme to avoid identifying the employer in public configs. Pick a codename for this job identity (e.g., `job94776`).

```sh
ssh-keygen -t ed25519 -C "you@work.com" -f ~/.ssh/id_ed25519_job94776
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_job94776
```

Add the public key to the relevant GitHub account in **two places**:
- Settings → SSH and GPG keys → **Authentication keys** (for push/pull)
- Settings → SSH and GPG keys → **Signing keys** (for commit verification)

Both entries point to the same `~/.ssh/id_ed25519_job94776.pub` — it's one key serving two purposes.

## 3. Create ~/.ssh/config.local

This file holds device-specific SSH host entries and is never committed. Create it:

```sh
cp ~/dot/ssh/config.local.example ~/.ssh/config.local
```

Edit `~/.ssh/config.local` and add the work identity block:

```sshconfig
Host github-job94776
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_job94776
  IdentitiesOnly yes
```

Also add your personal device block here if this machine serves both purposes (see `ssh/config.local.example` for the personal pattern).

## 4. Create ~/.gitconfig.local

This sets your work identity and enables SSH commit signing — no GPG setup needed.

```sh
cp ~/dot/git/gitconfig.local.example ~/.gitconfig.local
```

Edit `~/.gitconfig.local`:

```ini
[user]
    name  = Your Name
    email = you@work.com
    signingkey = ~/.ssh/id_ed25519_job94776.pub

[gpg]
    format = ssh

[gpg "ssh"]
    allowedSignersFile = ~/.ssh/allowed_signers
```

Then create the allowed signers file so git can verify your own commits locally:

```sh
echo "you@work.com namespaces=\"git\" $(cat ~/.ssh/id_ed25519_job94776.pub)" \
  >> ~/.ssh/allowed_signers
```

Git will apply this identity automatically for all repos under `~/work/` via the `[includeIf]` already wired in `git/gitconfig`.

## 5. Create ~/.zshrc.local (optional)

For any work-specific environment variables, aliases, or tool completions:

```sh
touch ~/.zshrc.local
# edit as needed — it's sourced at the end of .zshrc if present
```

## 6. Test

```sh
sh ~/dot/test.sh
```

All checks should pass. If SSH assertions fail, verify `~/.ssh/config.local` is in place and the key file exists.

## 7. Clone work repos using the job alias

```sh
git clone git@github-job94776:<org>/<repo>.git ~/work/<repo>
```

This routes through the job-specific SSH key automatically.
