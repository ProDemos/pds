Prodemos Design System [PDS]
=============================

# Install

To install, you can pull this repo into your project
as a git submodule 

https://git-scm.com/book/en/v2/Git-Tools-Submodules

```
git submodule add https://github.com/prodemos/pds
git submodule init
```

or install it as a node submodule using npm

(link)

or a composer package

(link)

or just fetch it as a zip 

https://github.com/ProDemos/pds/archive/master.zip

# Usage

If you just pulled this repo into your own project,
you can use the assets folder to implement the PDS
design. It contains

 - assets/css : the minified css files
 - assets/images : some images referred to by those css files
 - assets/fonts : some fonts referred to by those css files
 
The rest is optional and depends on your project:

 - assets/sass : the source sass files you can include in your own project
 - assets/twig : some twig templates you can reuse in your own project
 - assets/javascript: used for more complex widgets created by twig 
 
# Demo / Styleguide

You can view the PDS in action in demo/html. This html uses
the assets from the assets folder, and was generated using 
the twig files defined there. 

# Build / compile

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

To create new elements, 
  - write your sass in assets/sass
  - write a demo twig template in assets/twig/*
  - add a demo config for that twig template to assets/twig/*/_styleguide.yml
and compile the sass and twig using composer.
Your element should now appear in the styleguide in demo/html

Create a pull request of your changes in your own branch.

