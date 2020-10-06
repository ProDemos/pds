Prodemos Design System [PDS]
=============================

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
 
# Demo

You can view the PDS in action in demo/html. This html uses
the assets from the assets folder, and was generated using 
the twig files defined there. 

# Build 

If you want to make changes, check the demo/build directory. You should first run

``
composer install
``

to install a twig- and sass-compiler. After that you can run

``
composer run-script compile-sass
composer run-script compile-twig
``
to compile assets/sass/main.scss to assets/css/main.css
and generate new demo files in demo/html

Stash your changes into your own branch and push
that back to origin to create a pull-request.

