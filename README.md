# macOS setup

![](http://i.imgur.com/ttgPyeU.png)

Scripts and utilities for setting up a macOS computer the way I use it.

## Disclaimer

This is and _always_ will be a WIP repo, because I'm constantly adding new stuff and improving my workflow. Moreover, this script sets up everything the way _I_ use and like it.

Therefore, I'm not responsible for thermonuclear wars, explosions, etc. etc. caused by this 😬

## Usage

```
$ ./setup.sh
```

## What it does

- Set up dotfiles and config files (mostly borrowed from [Iain's amazing repo](https://github.com/iain/dotfiles))
- Install Homebrew
- Install some homebrew packages (see `brew/install.list`)
- Install some gems (see `gems/install.list`)
- Install some utility apps from the Mac App Store ([The Unarchiver](https://itunes.apple.com/it/app/the-unarchiver/id425424353?mt=12), [1Password](https://1password.com), [Better](https://better.fyi), [Shush](https://itunes.apple.com/us/app/shush-microphone-manager/id496437906?mt=12))
- Set up zsh
- Install [iTerm](https://www.iterm2.com)
- Provide configuration `plist` for iTerm with custom profiles
- Set up vim the way I use it
- Tweak the OS (mostly from [this amazing script](https://github.com/mathiasbynens/dotfiles/blob/master/.macos))
