<h1 align="center">
  <br>
  <img src="https://github.com/tymoyato/Kitay-Gorod/blob/314106ce655e48dcd0d0b1432d7c972aeb07d46f/kitay-gorod.jpg" alt="logo" width="300">
  <br>
  Kitay Gorod
  <br>
  <br>
</h1>

A repository for automating software installation with apt and brew package managers, along with setting up personalized dotfiles for streamlined development environments.
Supported on linux (ubuntu, debian)

## Installation

This will clone the repo to the current path

```bash
bash -i <(wget -qO- https://raw.githubusercontent.com/tymoyato/tmp/main/run.sh)
```

Password will be asked for (packages manager, default shell setup)

It will logout from session next create symlinks 

```bash
bash -i .Kitay-Gorod/symlink.sh
```

Setup fish shell (run in fish shell)

```bash
fish .Kitay-Gorod/setup.fish
```

## Git setup

Add git remote, edit `./.devtools/git.yml`

```yml
  git:
  user:
    name: NAME
    email: EMAIL
```
Run
```bash
bash .Kitay-Gorod/.devtools/git.sh
```
## Screenshots

![](https://github.com/tymoyato/Kitay-Gorod/blob/main/dotfiles/awesome/themes/kitay/screenshots/iceland-desktop.png)
---

![](https://github.com/tymoyato/Kitay-Gorod/blob/main/dotfiles/awesome/themes/kitay/screenshots/iceland-nvim.png)
---

## Awesome WM v4.3

## Build Information

- **Compiled against Lua**: 5.3.6
- **Running with Lua**: 5.3
- **D-Bus support**: ✔
- **execinfo support**: ✔
- **xcb-randr version**: 1.6
- **LGI version**: 0.9.2
