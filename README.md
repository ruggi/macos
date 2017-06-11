# macOS setup

![](http://i.imgur.com/T1dHcie.jpg)

Scripts and utilities for setting up a macOS computer the way I use it.

## Disclaimer
This is and *always* will be a WIP repo, because I'm constantly adding new stuff and improving my workflow. Moreover, this script sets up everything the way *I* use and like it.
Therefore, I'm not responsible for thermonuclear wars, explosions, etc. etc. caused by this 😬

## Usage

```
$ ./setup.sh
```

## What it does

* Set up dotfiles and config files (mostly borrowed from [Iain's amazing repo](https://github.com/iain/dotfiles)
* Install Homebrew
* Install some homebrew packages (see `brew/install.list`)
* Install some gems (see `gems/install.list`)
* Install some utility apps from the Mac App Store (The Unarchiver, 1Password, Better, Shush)
* Sets up zsh
* Installs iTerm
* Provides configuration `plist` for iTerm with custom profiles
* Sets up vim the way I use it
* Tweaks the OS borrowing stuff from [this amazing script](https://github.com/mathiasbynens/dotfiles/blob/master/.macos)
