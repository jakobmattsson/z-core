### Releasing a new version

1. Make sure your working environment is clean
2. Run the tests, to see that it's actually ok to release: `npm test`
3. Update the version number in `package.json`
4. Update the version number in `bower.json`
5. Run `make update-dist`
6. Run the tests again, to see that steps 1-5 weer done correctly: `npm test`
7. Commit these changes to git: `git commit -m "vX.X.X"`
8. Tag the commit with an annotated tag: `git tag -a vX.X.X -m vX.X.X`
9. Push to git, including tags: `git push --follow-tags`

TravisCI will take care of testing and deploying to npm.
