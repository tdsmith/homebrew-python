# Homebrew Python
[Homebrew](http://brew.sh)-formulae to install **Python** 2.x and 3.x libraries, which are not yet well supported by `pip install` due to compiler and dependency issues.

## Why not pip?
*   **Numpy**
    -   optionally link against the *openBLAS* (--with-openblas)
*   **SciPy**
    -   optionally link against the *openBLAS* (--with-openblas)
*   **Matplotlib**
    -   Support all optional deps, installable by brew
        (e.g. PyGTK, cairo, ghostscript, tk, freetype and libpng)
*   **matplotlib-basemap** (library for plotting 2D data on maps)
    -   Deps installed by brew (numpy, matplotlib, pillow, geos)
*   **PIL** (`brew install pillow`)
    -   The *Python Image Library* in the newer distribution named "pillow"
    -   Support for zlib/PNG
    -   *Freetype2* support
    -   *Little-CMS* (for color management)
*   **PyGame** (Game development and provides bindings to SDL)
*   **ReText** (Markdown Editor)
    -   Supports enchant. (You first need to `brew install enchant`)
    -   Some deps have to be installed via pip (it will tell you so)
*   _Open an issue if your favorite is missing_

## How do I install these formulae?
`brew install homebrew/python/<formula>`

Or `brew tap homebrew/python` and then `brew install <formula>`.

Or install via URL (which will not receive updates):

```
brew install https://raw.githubusercontent.com/Homebrew/homebrew-python/master/<formula>.rb
```

## Troubleshooting
Check main [Homebrew Troubleshooting guide](https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Troubleshooting.md#troubleshooting) and then [open an issue in this tap](https://github.com/Homebrew/homebrew/issues/new).

## Python
Homebrew Python modules install to whichever Python is first in the `PATH`. Our formulas are tested against Homebrew Python as well as the Python that came with your Mac.

We support Python 2.x and 3.x. For simultaneous support, use the `brew install <formula> --with-python3`. And if you don't need Python 2.x support at all:

```sh
brew install <formula> --with-python3 --without-python
```

## How to add a new formulae here
* Fork this repository on GitHub.
* Clone to your Mac.
* Read [Homebrew and Python](https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Homebrew-and-Python.md#homebrew-and-python) and look at the other formulae here.
* In your locally cloned `homebrew-python` repo, create a new branch: `git checkout --branch my_new_formula`
* Write/edit your formula (ruby file). Check the [Homebrew's documentation](https://github.com/Homebrew/homebrew/tree/master/share/doc/homebrew#readme) for details.
* Test it locally! `brew install ./my-new-formula.rb`. Does it install? Note, how `./<formula>.rb` will target the local file.
* `git push --set-upstream origin my-new-formula` to get it into your GitHub fork as a new branch.
* If you have to change something, add a commit and `git push`.
* On GitHub, select your new branch and then click the "Pull Request" button.
