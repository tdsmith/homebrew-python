# Homebrew Python

This [Homebrew](http://brew.sh) tap provides formulæ to install Python libraries with external dependencies that `pip` doesn't know how to handle, including the scientific Python stack (numpy, scipy, and matplotlib).
We aim to provide precompiled bottles where we can.
Please send us a pull request if you don't see your favorite!

<div style="height: 320px; overflow:hidden;">
<a href="https://xkcd.com/353/"><img src="http://imgs.xkcd.com/comics/python.png" alt="'You're flying! How?' 'Python!'"></a>
</div>

## How do I install these formulæ?
`brew install homebrew/python/<formula>`

Or `brew tap homebrew/python` and then `brew install <formula>`.

## Troubleshooting
Please check the main [Homebrew troubleshooting guide](https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Troubleshooting.md#troubleshooting) and then [open an issue in this tap](https://github.com/Homebrew/homebrew-python/issues/new).

## Python
Homebrew Python modules install to whichever Python is first in the `PATH`. Our formulæ are tested against Homebrew Python as well as the Python that came with your Mac.

Formulæ are installed with Python 2 support by default. For simultaneous Python 3 support, use `brew install <formula> --with-python3`. If you don't need Python 2.x support at all, you can pass `--with-python3 --without-python`.

## How to submit a new formula
* Fork this repository on GitHub.
* Clone to your Mac.
* Read [Python for Formula Authors](https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Python-for-Formula-Authors.md) and look at the other formulæ here.
* In your locally cloned `homebrew-python` repo, create a new branch: `git checkout --branch my_new_formula`
* Write/edit your formula (ruby file). Check [Homebrew's documentation](https://github.com/Homebrew/brew/tree/master/share/doc/homebrew#readme) for details.
* Test it locally! `brew install ./my-new-formula.rb`. Does it install? Note, `./<formula>.rb` will target the local file.
* `git push --set-upstream origin my-new-formula` to get it into your GitHub fork as a new branch.
* If you have to change something, add a commit and `git push`.
* On GitHub, select your new branch and then click the "Pull Request" button.
