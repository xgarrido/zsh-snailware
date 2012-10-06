zsh-snailware
=======================

**[SN@ilWare](https://nemo.lpc-caen.in2p3.fr) tools for [Zsh](http://www.zsh.org).**

*Requirements: zsh 4.3.9+.*


How to install
--------------

### In your ~/.zshrc

* Download the script or clone this repository:

        git clone git://github.com/xgarrido/zsh-snailware.git

* Add the cloned directory to `fpath` variable to make use of zsh completion:

        fpath=(/path/to/zsh-snailware $fpath)

* Source the script **at the end** of `~/.zshrc`:

        source /path/to/zsh-snailware/zsh-snailware.zsh

* Source `~/.zshrc`  to take changes into account:

        source ~/.zshrc


### With oh-my-zsh

* Download the script or clone this repository in [oh-my-zsh](http://github.com/robbyrussell/oh-my-zsh) plugins directory:

        cd ~/.oh-my-zsh/custom/plugins
        git clone git://github.com/xgarrido/zsh-snailware.git

* Activate the plugin in `~/.zshrc` (in **last** position):

        plugins=( [plugins...] zsh-snailware)

* Source `~/.zshrc`  to take changes into account:

        source ~/.zshrc

