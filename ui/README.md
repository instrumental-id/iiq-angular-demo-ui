# Angular plugin build readme

## tl;dr

The ng-build.sh script is used to build the Angular code for packaging into the IIQ plugin. The IIQ plugin page.xhtml expects the Javascript files to be in a particular location, which is not the same as what Angular produces. 

To handle this, the script builds the Angular application, then substitutes a section of `page-template.xhtml` (following the line containing `NG INSERT`) with the contents of the generated `index.html` file. The resulting file is saved as `page.xhtml`.

Unusually, `page.xhtml` is not stored in Git at all.