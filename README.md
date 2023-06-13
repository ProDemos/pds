Prodemos Design System [PDS]
=============================

# Demo

You can view the design system in action at https://pds.prodemos.nl/

# How to use PDS in your own project

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

 ## Soure scss

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
 
# Demo / Styleguide

You can view the PDS in action at https://pds.prodemos.nl/

Alternatively, you can clone this repo and build the 
demo yourself, see below.


# Making changes

XXX TODO
 
## Build / compile

If you want to make changes, check the demo/build directory. 

> The changes should be compiled before committed to the repo, so
> the end user can just use the compiled css from the repo
> if s/he wants to.

You'll need Composer and Node. You should first run

```
cd demo/build
composer install
```

to install a twig- and sass-compiler and a yaml parser. 
After that you can run

```
composer compile-sass
```
to compile assets/sass/main.scss to assets/css/main.css

and
```
composer compile-twig
```
to generate new demo files in demo/html

You can also just call
``composer compile``
to do both.

# Expand - adding new elements

To create a new element, say pds-c-foo
  - write your sass in assets/sass/pds/components/_foo.scss
  - add your stylesheet to assets/sass/main.scss
  - write a demo twig template in assets/twig/components/foo/foo.twig
  - add a config for template to assets/twig/pds/components/foo/_styleguide.yml
and compile the sass and twig as described above.

Your element should now appear in the styleguide in demo/html

Always prefix you classnames with pds-. Try to stay
within the definitions of pds-s(copes), pds-t(hemes),
pds-c(omponents) and pds-m(odifiers). Avoid BEM.
Use predefined colors, sizes and fonts.

If you want to write directly in the demo pages, 
check demo/build/pages/*

# Sass

A few notes on the use of the Sass-files when adding styles

#### Breakpoints

When breakpoints are defined, they can be used inline in the class to target specific behaviour.

Just use:
```
@include media-from(lg) {
    font-size: nth($pds-font-sizes, 2);
}
```
to set another style from breakpoint LG (LarGe, probably something around 1024px)


Three types can be used:
 - `@include media-from(lg){ ... }` \ Which means: 'Use this style up from Large screens'
 - `@include media-between(md, lg) { ... }`  \ Which means: 'use this style between Medium and Large screens'
 - `@include media-until(lg) { ... }` \ Which means: 'use this style until Large screens'

#### Colors
Colors are defined in `$pds-colors` as a map, but you can use the helpers `pds-color` and `pds-theme-color` to find the right color. Themes are defined in `$pds-themes`.`

```
.class {
    background-color: pds-color(red);
    color: pds-theme-color(stroke); 
}
```

#### Fonts

The fonts are defined by name, which helps in consistency. A scale can be accessed with a helper:
```
.class {
    font-size: pds-fontsize(l);
    line-height: pds-lineheight(m);
}
```

#### Scales

Some variables are defined by scales, which helps in consistency for sizings and layout. A scale can be accessed like an array, so when the font-size scale contains multiple value's, you can access one by:
```
.class {
    margin-bottom: nth($pds-spacings, 2); // second in the array
}
```

Similar methods should be used for the `$pds-lighten-scale` and `$pds-darken-scale`.




