# zsh-snailware

**[SN@ilWare](https://nemo.lpc-caen.in2p3.fr) tools for [Zsh](http://www.zsh.org).**

How to install
--------------

### In your ~/.zshrc

* Download the script or clone this repository:

``` bash
$ git clone git://github.com/xgarrido/zsh-snailware.git
```

* Add the cloned directory to `fpath` variable to make use of zsh completion:

``` bash
$ fpath=(/path/to/zsh-snailware $fpath)
```

* Source the script **at the end** of `~/.zshrc`:

``` bash
$ source /path/to/zsh-snailware/zsh-snailware.zsh
```

* Source `~/.zshrc`  to take changes into account:

``` bash
$ source ~/.zshrc
```

### With oh-my-zsh

* Download the script or clone this repository in [oh-my-zsh](http://github.com/robbyrussell/oh-my-zsh) plugins directory:

``` bash
$ cd ~/.oh-my-zsh/custom/plugins
$ git clone git://github.com/xgarrido/zsh-snailware.git
```

* Activate the plugin in `~/.zshrc` (in **last** position):

``` bash
plugins=( [plugins...] zsh-snailware)
```

* Source `~/.zshrc`  to take changes into account:

``` bash
$ source ~/.zshrc
```

How to use
----------

Type `snailware` and press `TAB` key. You will be prompt to
something like this

```bash
➜  snailware
build         -- Build a component
configure     -- Configure a component
goto          -- Goto a component directory
rebuild       -- Rebuild component from scratch
reset         -- Reset component
setup         -- Source a component
status        -- Status of a component
svn-checkout  -- SVN checkout a component
svn-diff      -- SVN diff a component
svn-status    -- SVN status of a component
svn-update    -- SVN update a component
test          -- Run tests on a component
```

Pressing again `TAB` key will bring you to the different
options. Let's try `build` option and again try to complete by using `TAB`

```bash
➜  snailware build
CellularAutomatonTracker brio       genvtx     sng4
TrackerClusterPath       channel    geomtools  sngenbb
TrackerPreClustering     cuts       matacqana  sngenvertex
all                      datatools  materials  sngeometry
bayeux                   extra      mygsl      snreconstruction
bipoanalysis             falaise    snanalysis snvisualization
bipovisualization        genbb_help sncore     trackfit
```

You can select and build software agregators, component either build `all` the
components in one time.
