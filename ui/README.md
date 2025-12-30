# Angular plugin build readme

## tl;dr

The `ng-build.sh` script is used to prepare the Angular code for packaging into the IIQ plugin.

To handle this, the script builds the Angular application, then substitutes a section of `page-template.xhtml` (following the line containing `NG INSERT`) with the contents of the generated `index.html` file. A variety of `sed` commands are used to adjust paths and other details to ensure the Angular application works correctly within the IIQ plugin environment.

The resulting file is output as `page.xhtml`.

Unusually, `page.xhtml` should not be stored in Git at all.

The Gradle build's `createPluginZip` task will copy files from the right locations within the `ui` subfolder to create the final plugin ZIP file.

## Build folders

The Angular application source code is in the `src` folder.

When built, Angular places its output in the `dist/(project name)` folder, per the `angular.json` configuration file. This project name is supplied to the ng-build.sh script via environment variable. If you're using the `gradlew` script, it will be set based on your `gradle.properties`.

The `ng-build.sh` script will copy the resulting files to `js/app` and `css/app`, which is where the remainder of the build expects to find them.