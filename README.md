Prodemos Design System [PDS]
=============================

# Demo

You can view the design system in action at https://pds.prodemos.nl/

# How to include PDS in your own project

Each release comes with a number of packages and assets
you can use in your own project. Current packages are 
- **pds-compiled** \
  an assets folder containing, amongst others, plain css
- **pds-source** \
  an assets folder containing, amongst others, scss sources
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

You can add this full repository in your composer.json file 

```
{
  ...,
  "repositories":[
    {
      "type": "git",
      "url": "https://github.com/prodemos/pds"
    }
  ],
  ...
}
```
and run `composer install`. Because it is a private repository, Composer may prompt you for credentials, but just follow the instructions there.


## GIT submodule

You can pull this full repository into your project
as a __git submodule__ 

https://git-scm.com/book/en/v2/Git-Tools-Submodules

```
git submodule add https://github.com/prodemos/pds
git submodule init
```


# Usage

After installing, the package provides an `assets` folder somewhere
in your installation. 

The assets folder contains

 - assets/images : some images referred to by those css files
 - assets/fonts : some fonts referred to by those css files

The compiled package also contains 

 - assets/css : the minified css files

The source package also contains

 - assets/sass : the source sass files you can include in your own project
 - assets/twig : some twig templates you can reuse in your own project
 - assets/javascript: used for more complex widgets created by twig

## Plain css
If you installed the compiled package, you
can include the plain css/javascript into your project
```
<link rel="stylesheet" href=".../pds/assets/css/reset.css">
<link rel="stylesheet" href=".../pds/assets/css/main.css">
```
The reset.css is optional.

## Source scss

 If you installed the source package, you can import 
 the reset and main scss files. Make sure to override
 `$pds-assets-path` to point to the right root folder

 ```
 // override the pds assets base
$pds-assets-path: "@pds";

// import pds
@import "@pds/sass/reset.scss"; // optional
@import "@pds/sass/main.scss";

 ```

There are more variables you can override 
before including the scss files, like 
breakpoints and fontsizes. YMMV.
 

# Making changes, new releases

To install this repo locally and make changes, 
see [docs/Development.md](docs/Development.md). 

See [docs/Distribution.md](docs/Distribution.md)
on how to create a new release.

