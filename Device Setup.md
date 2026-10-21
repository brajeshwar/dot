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

Work and job devices use a codename scheme to avoid identifying the employer in public configs. Pick a codename for this identity (for example `job12345` or a client nickname) and use it for the key, the SSH host alias, and the identity file. The codename itself never goes into this repo. Keys are named `id_ed25519_<codename>_<YYYYMON>` — identity plus the month the key was made on this device — with the same string as the key comment, so the public key carries no email.

```sh
ssh-keygen -t ed25519 -C "<codename>_<YYYYMON>" -f ~/.ssh/id_ed25519_<codename>_<YYYYMON>
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_<codename>_<YYYYMON>
```

Add the public key to the relevant GitHub account in **two places**:
- Settings → SSH and GPG keys → **Authentication keys** (for push/pull)
- Settings → SSH and GPG keys → **Signing keys** (for commit verification)

Both entries use the same `~/.ssh/id_ed25519_<codename>_<YYYYMON>.pub` — one key, two purposes.

### 3A. Create ~/.ssh/config.local

```sh
cp ~/dot/ssh/config.local.example ~/.ssh/config.local
```

Add the work identity block:

```sshconfig
Host github-<codename>
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_<codename>_<YYYYMON>
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

Then add the routing block for the work identity at the end of the file (section 5 of the example):

```ini
[includeIf "gitdir:~/dev/"]
    path = ~/.config/git/identities/<codename>.gitconfig
```

### 5A. Create the work identity file

```sh
mkdir -p ~/.config/git/identities && chmod 700 ~/.config/git/identities
cp ~/dot/git/identity.gitconfig.example ~/.config/git/identities/<codename>.gitconfig
```

Fill in every `<…>`. The template is self-contained — name, email, signing key, `commit.gpgsign`, and credentials — so no value leaks in from another identity:

```ini
[user]
    name  = Your Name
    email = you@work.com
    signingkey = ~/.ssh/id_ed25519_<codename>_<YYYYMON>.pub

[gpg]
    format = ssh

[gpg "ssh"]
    allowedSignersFile = ~/.ssh/allowed_signers

[commit]
    gpgsign = true

[credential "https://github.com"]
    helper =
    helper = osxkeychain
    username = <work-github-username>
```

Create the allowed signers file so git can verify your own commits locally:

```sh
echo "you@work.com namespaces=\"git\" $(cat ~/.ssh/id_ed25519_<codename>_<YYYYMON>.pub)" \
  >> ~/.ssh/allowed_signers
```

### 6A. Clone work repos

```sh
git clone git@github-<codename>:<org>/<repo>.git ~/dev/<repo>
```

Repos under `~/dev/` automatically get the work identity through the routing table in `~/.gitconfig.local`.
Personal repos go anywhere outside `~/dev/`. For a client or second job, see [Add another identity](#add-another-identity).

---

## Track B — HTTPS only (SSH blocked)

SSH is blocked by the corporate firewall. All GitHub operations use HTTPS. You will have two accounts on github.com: your personal one and your work one.

### 2B. Generate a device-specific SSH key (for commit signing only)

SSH keys can still be used to *sign commits* locally — no network connection needed. Generate one even though it won't be used for transport.

```sh
ssh-keygen -t ed25519 -C "<codename>_<YYYYMON>" -f ~/.ssh/id_ed25519_<codename>_<YYYYMON>
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
# Work repos get SSH signing via their identity file instead.
[commit]
    gpgsign = false

[tag]
    gpgSign = false
```

Then add the routing block for the work identity at the end of the file, after everything above — later matches win, so the identity file overrides these defaults:

```ini
[includeIf "gitdir:~/dev/"]
    path = ~/.config/git/identities/<codename>.gitconfig
```

### 5B. Create the work identity file

```sh
mkdir -p ~/.config/git/identities && chmod 700 ~/.config/git/identities
cp ~/dot/git/identity.gitconfig.example ~/.config/git/identities/<codename>.gitconfig
```

Fill in your work identity, signing key, and work credentials:

```ini
[user]
    name  = Your Name
    email = you@work.com
    signingkey = ~/.ssh/id_ed25519_<codename>_<YYYYMON>.pub

[gpg]
    format = ssh

[gpg "ssh"]
    allowedSignersFile = ~/.ssh/allowed_signers

[commit]
    gpgsign = true

[tag]
    gpgSign = true

# Work account on a SAML-SSO org: use the gh CLI helper, NOT a Keychain PAT.
# A Keychain PAT must be SSO-authorized or pushes 403 ("write access not granted"),
# even though read/clone works. gh handles the SSO authorization for you.
[credential "https://github.com"]
    helper =
    helper = !gh auth git-credential
    username = <work-github-username>

[credential "https://gist.github.com"]
    helper =
    helper = !gh auth git-credential
    username = <work-github-username>
```

Create the allowed signers file:

```sh
echo "you@work.com namespaces=\"git\" $(cat ~/.ssh/id_ed25519_<codename>_<YYYYMON>.pub)" \
  >> ~/.ssh/allowed_signers
```

### 6B. Personal → Keychain PAT; work → gh CLI (handles SSO)

**Personal account** — store the PAT in the Keychain:

```sh
printf 'protocol=https\nhost=github.com\nusername=<personal-github-username>\npassword=<PERSONAL_PAT>\n' \
  | git credential approve
```

**Work account** — sign in with gh, which does the SAML SSO authorization a raw PAT doesn't:

```sh
gh auth login  --hostname github.com --git-protocol https   # choose the WORK account
gh auth refresh -h github.com -s repo                        # authorize the token for the work org's SSO
```

The work identity file points `~/dev/` repos at `!gh auth git-credential`, so work pushes
use this gh token automatically — no per-repo workaround. (Prefer a PAT for work too?
Store it like the personal one above, then authorize it: token page → Configure SSO → Authorize.)

> **Why not just a work PAT in the Keychain?** On SAML-SSO orgs a valid-looking PAT
> still 403s on push until it's SSO-authorized. The classic symptom: **clone/read works,
> push fails** with `Write access to repository not granted`. gh keeps this authorized
> for you, so it's the lower-maintenance default for work repos.

### 7B. Check for conflicting system gitconfig

Corporate machines sometimes have a pre-existing `~/.gitconfig` that sets `pushInsteadOf`, which conflicts with the HTTPS setup. Check:

```sh
git config --list --show-origin | grep insteadof
```

You should see only the `insteadOf` entry from your `~/.gitconfig.local`. If you see a `pushInsteadOf` from `~/.gitconfig`, the corporate file was there first and `bootstrap.sh` skipped it. Move it aside and re-run bootstrap so `~/.gitconfig` becomes the dotfiles symlink:

```sh
mv ~/.gitconfig ~/.gitconfig.corporate && ~/dot/bootstrap.sh
```

Once `~/.gitconfig` is the symlink, never run `git config --global` — it writes straight into this public repo. Write to `~/.gitconfig.local` or an identity file with `git config --file` instead. `gh auth setup-git` and `git lfs install` write global config too; run them with care and check `git -C ~/dot status` afterward.

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

## Add another identity

A client or a second job on the same machine. Nothing in this repo changes — every step writes to a private file. Example: a client on github.com with its own account, its repos kept in `~/dev/` alongside work.

1. **Pick a codename** — for the key, the identity file, and the SSH alias. Never the client's name.

   Each identity gets its **own** key, even on the same device. Signing keys are public on GitHub and every signature carries its key, so one key shared across accounts links them for anyone who compares. It also ties the client's key rotation to your work signing.

2. **Signing key**, added to the client account under Settings → SSH and GPG keys → **Signing keys** (and Authentication keys on SSH machines):

   ```sh
   ssh-keygen -t ed25519 -C "<codename>_<YYYYMON>" -f ~/.ssh/id_ed25519_<codename>_<YYYYMON>
   ssh-add --apple-use-keychain ~/.ssh/id_ed25519_<codename>_<YYYYMON>
   echo "<client-email> namespaces=\"git\" $(cat ~/.ssh/id_ed25519_<codename>_<YYYYMON>.pub)" >> ~/.ssh/allowed_signers
   ```

3. **Identity file** — copy the template and fill every `<…>`, using the Keychain PAT helper (option A):

   ```sh
   cp ~/dot/git/identity.gitconfig.example ~/.config/git/identities/<codename>.gitconfig
   ```

4. **Credential** — a personal access token (PAT) for the client account, stored against its username. If the client org enforces SAML SSO, authorize the token for it on GitHub.

   ```sh
   printf 'protocol=https\nhost=github.com\nusername=<client-github-username>\npassword=<CLIENT_PAT>\n' \
     | git credential approve
   ```

5. **Route it** — append to the end of `~/.gitconfig.local`, below the `~/dev/` rule:

   ```ini
   [includeIf "hasconfig:remote.*.url:https://github.com/<client-org>/**"]
       path = ~/.config/git/identities/<codename>.gitconfig
   ```

   The match is case-sensitive but GitHub org names are not — add a second block with the org in lowercase, so a repo cloned either way routes correctly.

   The identity follows the remote, so a repo with no remote yet commits as work. Clone client repos, or add the remote before the first commit. If the client's code is on another host (GitHub Enterprise, GitLab, Azure DevOps), match that host's URL instead; credentials then separate by host on their own.

6. **gh CLI, if needed.** `gh` serves its *active* account to git, so `gh auth switch` would change which account work pushes use. Give the client a separate gh config instead, scoped to its repos with mise:

   ```sh
   GH_CONFIG_DIR=~/.config/gh-<codename> gh auth login --hostname github.com --git-protocol https
   ```

   ```toml
   # <repo>/mise.local.toml — gitignored globally
   [env]
   GH_CONFIG_DIR = "{{env.HOME}}/.config/gh-<codename>"
   ```

7. **SSH machines only** — add a `Host github-<codename>` block to `~/.ssh/config.local` (see `ssh/config.local.example`), and an SSH URL match (`git@github.com:<client-org>/**`) to the routing rule.

8. **Verify** inside a client repo:

   ```sh
   git config --show-origin --get user.email      # the client email, from <codename>.gitconfig
   git push --dry-run origin <branch>             # authenticates, updates nothing
   ```

---

## Troubleshooting

**Push fails `403 Write access to repository not granted` (but clone/read works).**
The work token isn't SSO-authorized for the org — the single most common cause on
corporate machines.
- gh: `gh auth status`, then `gh auth refresh -h github.com -s repo` (re-authorize SSO).
- PAT in Keychain: GitHub → token → **Configure SSO → Authorize** for the org.

**Push uses the wrong account / prompts unexpectedly.** Check which credential a repo
resolves to:
```sh
cd <repo>
git config --get-all credential.https://github.com.helper   # work repos (~/dev/) should list: !gh auth git-credential
git config --get credential.https://github.com.username     # should be the work username under ~/dev/
```
See which identity a repo resolved to, and which file set it:
```sh
git config --show-origin --get user.email
```
Repos only get the work identity when cloned **under `~/dev/`**, and a client identity only once the repo has a remote in the client org (the `includeIf` triggers in `~/.gitconfig.local`).

**Verify a push works without changing anything:**
```sh
git push --dry-run origin <branch>   # authenticates against the remote, updates nothing
```

---

## 9. Test

```sh
sh ~/dot/test.sh
```

All checks should pass. If SSH assertions fail, verify `~/.ssh/config.local` is in place and the key file exists.
