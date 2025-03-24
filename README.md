Prodemos Design System [PDS]
=============================

The Prodemos Design System (PDS) attempts to normalize the design used for apps and sites within the Prodemos ecosystem. You can install and use it in your app. 

It does not by default change any of the design in your app; instead it offers tools and utilities to comply with ProDemos' standards. For example, it does not specify any default fonts, but it does provides the standard fonts used by ProDemos. It does not specify any colors, but it does provide methods to use Prodemos' default color sets - etcetera.


# Demo

You can view the design system in action at https://pds.prodemos.nl/

# How to include PDS in your own project

Each release comes with a number of packages and assets
you can use in your own project. Current packages are 
- **pds** \
  an assets folder containing everything
- **pds-compiled** \
  an assets folder containing the compiled sources (eg css)
- **pds-source** \
  an assets folder containing the raw sources (eg scss) 
- **pds-demo** \
  the website visible at https://pds.prodemos.nl/

## Download

You can download the packages as zip files at the releases page:
https://github.com/ProDemos/pds/releases

## Node / NPM

The packages are available as NPM packages too, see
https://github.com/orgs/ProDemos/packages?repo_name=pds

Since this is a Github NPM Package, you will need to [authenticate with GitHub Packages](https://docs.github.com/en/packages/using-github-packages-with-your-projects-ecosystem/configuring-npm-for-use-with-github-packages#authenticating-to-github-packages), to install the module. Start by [creating a personal access token](https://github.com/settings/tokens). It needs only `read:packages` permissions.

Now copy your personal access token, and store it in your npm config:   

```
npm config set "@prodemos:registry" https://npm.pkg.github.com/
npm config set "//npm.pkg.github.com/:_authToken" [your GitHub access token from step 1]
```

These values are probably stored in your ~/.npmrc.

Now you can install the package:

```
npm install @prodemos/(packagename)
```

Your co-developers will need to get the same instructions before they can install your project.

## PHP / Composer

You can add specific assets to your project by defining the package in your composer.json
```
"repositories":[
        {
            "type": "package",
            "package": {
                "name": "prodemos/pds",
                "version": "v5.0.1",
                "dist": {
                    "url": "https://github.com/ProDemos/pds/releases/download/v5.0.1/pds-compiled.tgz",
                    "type": "tar"
                }
            }
        }
]
```
and run `composer require prodemos/pds`. This will download and unzip the asset in `vendor/prodemos/pds/`



## GIT submodule

You can pull this full repository into your project
as a __git submodule__ 

https://git-scm.com/book/en/v2/Git-Tools-Submodules

```
git submodule add https://github.com/prodemos/pds
git submodule init
```


# How to use PDS in your own project

After installing, the package provides an `assets` folder somewhere
in your installation. 

Depending on the package you installed, the assets folder may contain any or all of these folders:

 - assets/images : some images referred to by those css files
 - assets/fonts : some fonts referred to by those css files
 - assets/css : the minified css files
 - assets/sass : the source sass files you can include in your own project
 - assets/twig : some twig templates you can reuse in your own project
 - assets/javascript: used for more complex widgets created by twig

## Plain css
If you installed a compiled package, you
can include the plain css/javascript into your project
```HTML
<link rel="stylesheet" href=".../pds/assets/css/reset.css">
<link rel="stylesheet" href=".../pds/assets/css/main.css">
```
The reset.css is optional.

## Source scss

 If you installed a package containing sass, you can use 
 the settings, reset and main scss files in your main scss [^1]. 
 Make sure to copy the assets (images, fonts etc) to a public 
 folder and configure `$assets-path` to point to that folder first.



```SCSS
@use "pds/settings" with (
  $assets-path: "../path-to/pds-assets"
);
@use "pds/reset"; // optional
@use "pds/main";

```

To access sass variables, methods and mixins 
defined in PDS, include the pds namespace
in any child sccs file:
```SCSS
@use "pds/pds";
h1 { font-size: pds.fontsize(l); }
```


There are more settings you can configure 
in the settings file, like breakpoints and fontsizes. 
Read the full documentation on https://pds.prodemos.nl/.

# Making changes, new releases

To install this repo locally and make changes to PDS, 
see [docs/Development.md](docs/Development.md). 

See [docs/Distribution.md](docs/Distribution.md)
on how to create a new release.

[^1]: If you configure `...path-to-pds/assets/sass` to be 
in your sass `load-path` (cli) or `loadPaths` (js), you can
use the shortcuts as shown. Otherwise, use full or
relative paths.