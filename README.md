# .

## Symlink

```
ln -s [source] [link]
ln -s README.md README
ln -s /Downloads ~/User/Downloads
```

// overwrite/force

`ln -sf [source] [link]`

## Stow

GNU [Stow](https://www.gnu.org/software/stow/) is a symlink farm manager which takes distinct packages of software and/or data located in separate directories on the filesystem, and makes them appear to be installed in the same place.

`stow -v -R -t ~ pkg`

- `-v (or --verbose)` makes stow run in verbose mode. When you use -v, stow will list the symlinks it creates or updates, making it easier to see the changes it’s making.
- `-R (or --restow)` tells stow to restow the packages. It’s useful when you’ve already stowed the packages previously, and want to reapply them. The -R flag ensures that stow re-symlinks files, even if they already exist. This makes each run idempotent and you won’t have to worry about polluting your workspace with straggler links.
- `-t <target> (or --target=<target>)` specifies the target directory where stow should create symlinks. The default target directory is the parent of $pwd. In the above command, -t ~ is used to set the home directory as the destination.
- `<pkg>` is the package name you want to stow.

#### References

- [Awesome Dotfiles](https://project-awesome.org/webpro/awesome-dotfiles)
- [dotfiles on GitHub](https://dotfiles.github.io), the Unofficial Guide
