# Flutter Gateway SDK

## Deployment

To deploy a new version of the package:

1. **Create a release branch**

   ```bash
   git checkout -b release/{scg | loans}/M.m.p
   ```

2. **Make changes**
   Update the package code as needed for the release.

3. **Make the chore(prod) commit with the correct version**
   Update the version in `pubspec.yaml` and commit:

   ```bash
   git add pubspec.yaml

   git commit -m "chore(prod): scg:M.m.p"
   # OR
   git commit -m "chore(prod): loans:M.m.p"
   ```

4. **Create a tag and push**
   Create a tag matching the pubspec version with the appropriate prefix:

   ```bash
   git tag scg-M.m.p
   # OR
   git tag scloans-M.m.p

   git push origin <tag-name>
   ```

5. **Run the publish workflow**
   Go to [GitHub Actions](https://github.com/smallcase/gw-mob-sdk-flutter/actions) and manually trigger the "🚀 Publish" workflow on the created tag. The workflow will not work on branches - it must be run on a tag.
