Prodemos Design System [PDS]
=============================

# Browse

You can view the design system in action at https://pds.prodemos.nl/

# Install


## git submodule
To install, you can pull this repo into your project
as a __git submodule__ 

https://git-scm.com/book/en/v2/Git-Tools-Submodules

```
git submodule add https://github.com/prodemos/pds
git submodule init
```

## npm
Since this is a Github Package, you will need to [authenticate with GitHub Packages](https://docs.github.com/en/packages/using-github-packages-with-your-projects-ecosystem/configuring-npm-for-use-with-github-packages#authenticating-to-github-packages), to install the module. Start by [creating a personal access token](https://github.com/settings/tokens). It needs only `read:packages` permissions.

Now copy your personal access token, and store it in your npm config:   

```
npm config set "@prodemos:registry" https://npm.pkg.github.com/
npm config set "//npm.pkg.github.com/:_authToken" [your GitHub access token from step 1]
```

These values are probably stored in your ~/.npmrc.

Now you can install the package:

```
npm install @prodemos/pds
```

Your co-developers will need to get the same instructions before they can install your project.

## Composer

Add the repository in your composer.json file 

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

## Download
or just fetch it as a zip 

https://github.com/ProDemos/pds/archive/master.zip

# Usage

If you just pulled this repo into your own project,
you can use the assets folder to implement the PDS
design. 
```
<link rel="stylesheet" href="pds/assets/css/reset.css">
<link rel="stylesheet" href="pds/assets/css/main.css">
```
The reset.css is optional.

The assets folder contains

 - assets/css : the minified css files
 - assets/images : some images referred to by those css files
 - assets/fonts : some fonts referred to by those css files
 
The rest is optional and depends on your project:

 - assets/sass : the source sass files you can include in your own project
 - assets/twig : some twig templates you can reuse in your own project
 - assets/javascript: used for more complex widgets created by twig 

 If you plan to include the sass in your own project, 
 you probably want to override 
 ```
 $pds-assets-path
 ```
 in your own sass, and point it to the assets folder
 (relative to the output of the css you are compiling)

 
# Demo / Styleguide

You can view the PDS in action in demo/html. This html uses
the assets from the assets folder, and was generated using 
the twig files defined in the assets folder.

# Making changes

Package [releases](https://github.com/ProDemos/pds/releases) are automated
using [semantic-release](https://github.com/semantic-release/semantic-release).

The semantic version number increments are based on the commit messages that we use,
so follow [Conventional Commits](https://www.conventionalcommits.org/):

* `fix: Fix some bug` bumps the patch version;
* `feat: Add some new feature` bumps the minor version;
* to bump the major version:
  ```
  feat: Add some backwards-incompatible feature

  BREAKING CHANGE: call new() instead of old().
  ```
 
## Build / compile

If you want to make changes, check the demo/build directory. 
You'll need Composer and Node. You should first run

```
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

#### Scales

The variables are defined by scales, which helps in consistency for sizings and layout. A scale can be accessed like an array, so when the font-size scale contains multiple value's, you can access one by:
```
$pds-font-sizes: 56px 44px 32px 24px 22px 18px 16px 14px 12px;<br>
.class {
    font-size: nth($pds-font-sizes, 2); // second in the array, gives 44px
}
```

Similar methods should be used for the `pds-spacings`, `$pds-line-heights`, 
`$pds-lighten-scale` and `$pds-darken-scale`.

#### Colors
Colors are defined in `$pds-colors` as a map, but you can use the mixin `@pds-color` and `@pds-theme-color` to find the right color.
Themes are defined in `$pds-themes`.`

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

