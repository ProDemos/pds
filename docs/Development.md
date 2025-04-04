PDS - Development
=============================

This document describes how to develop PDS itself.

See the general README.md for documentation on
how to include it in your own project.

See https://pds.prodemos.nl for documentation on
how to use it in your own project.

# Requirements 

This repo uses npm/node for `sass` and composer/php for `twig`.
It uses `make` as the workflow to combine these two. 
So installing it requires make, npm, and composer.

# Install 

```
git clone https://github.com/ProDemos/pds.git
make install
```

That's all.

# Workflow

 - Changes should be made in *feature* branches. 
 - PRs from these feature branches are made to the *develop* branch
   - These PRs should be squash-merged to the develop branch when approved
 - On every release, a PR is made to the *master* branch
   - That PR should not be squash-merged
 - From master, a new *release* can be created manually

To create a new release, read [Distribution.md](Distribution.md)


# Available make commands

- **make install**\
  calls composer install, npm install, etc

- **make compile** 
  - **make compile-css**\
    using node, compiles sass to css in `build/assets/css` and `build/demo/css`

  - **make compile-html**\
    using php, compiles twig to html in `build/demo/`

- **make packages** \
  copies files to various `/build/packages/(package)`

- **make release tag=$tag**\
  this target is called by a github action, see [Distribution.md](Distribution.md). You
  should not need to call this manually. 

- **make clean** \
  remove generated files in `/build/*`

- **make serve** \
  starts a webserver in `/build/demo` - requires python

# Making changes

To make changes
```
git checkout -b feature/barf

# make your changes here ..

make compile
make packages

# check if it works here, by starting a webserver 
# in the 'build/demo' folder (requires python)

make serve

# and checking http://localhost:8000/
# once you're done 

git push origin feature/barf

# now manually create a PR to the develop branch in github
```

## Compile & package

All source files are in `src/`.
The compiled versions appear in `build/`. 
The packages will appear in `build/packages`. 

The compiled files and packages are *not* included in the repo. When creating a 
new release from master, the workflow compiles these folders and
packages again and attaches them to the release.

# Expand - adding new elements

To create a new component, say pds-c-foo
  - write your sass in `src/assets/sass/components/_foo.scss`
  - add your stylesheet to `src/assets/components/_index.scss`
  - optionally write a demo twig template in `src/assets/twig/components/foo/foo.twig`
  - optionally add a config for that template to `src/demo/config/components/foo.yml`

and compile the sass and twig as described above.

If you added twig and a config, your component 
should now appear in the styleguide in `build/demo`.
Otherwise, manually edit a page in `src/demo/pages` 
to demo your new element.

## Conventions

### scss

Always prefix you classnames with pds-. Try to stay
within the definitions of pds-s(copes), pds-t(hemes),
pds-c(omponents) and pds-m(odifiers). Avoid BEM.
Use predefined colors, sizes and fonts.

If you want to write directly in the demo pages, 
check `src/demo/pages/*`

### icons

Icon components (`pds-c-icon`) are defined within a 20x20 frame,
but placed in a 24x24 viewbox, so with 2px space on all sides.
This leaves room for some icons to stick out a bit while still
being in scale.

To find new icons, try https://lucide.dev. It's open source
and aligns with ProDemos' design.

## Sass

A few notes on the use of the Sass-files when adding styles

> [!IMPORTANT]
> If you are defining a new element *inside PDS*, you can't include `pds/pds` itself, 
> because it would cause a feedback loop: `pds/pds` will provide your
> element for other users. Instead, use `../pds/settings` and `../helpers`
> directly as shown below

### Breakpoints

Breakpoints can be used inline in the class to target specific behaviour.

Just use:
```SCSS
@use "../helpers";
@include helpers.media(lg,min) {
    font-size: helpers.fontsize(l);
}
```
to set another style from breakpoint LG (LarGe, probably something around 1024px)


### Colors
Colors are defined in `settings.$colors` as a map, and themes are defined in `settings.$themes`. On preprocessing,
these are translated to css vars. You can use the helpers `helpers.color` and `helpers.theme-color` to find the right color,
but you should preferably use their css equivalents, eg the below classes are the same:

```SCSS
@use "../helpers";
.class1 {
    background-color: helpers.color(red-80);
    color: helpers.theme-color('blue01',stroke); 
}
.class2 {
    background-color: var(--pds-color-red-80);
    @include helpers.theme('blue01');
    color: var(--pds-color-stroke);
}
```

### Fonts

Font names, sizes and line-heights can be accessed from settings and helpers:
```SCSS
@use "../pds/settings";
@use "../helpers";
.class {
    font-family: settings.$font-sans;
    font-size: helpers.fontsize(l);
    line-height: helpers.lineheight(m);
}
```

### Scales

Some variables are defined by scales, which helps in consistency for sizings and layout. A scale can be accessed like
a map, and you can access one by:
```SCSS
@use "../helpers";
.class {
    margin-bottom: helpers.spacing(tiny); 
}
```




