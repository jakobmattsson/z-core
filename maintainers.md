### Releasing a new version

- Make sure your working environment is clean
- Update the version number in `package.json`
- Update the version number in `bower.json`
- Run `make update-dist`
- Commit these changes to git. Include the version number in the message.
- Tag the commit with an annotated tag, `git tag -a vX.X.X -m vX.X.X`
