PDS - Development
=============================

# Install 

This repo uses npm/node for `sass` and composer/php for `twig`,
so it contains both a `package.json` and a `composer.json`.
It uses `make` for the workflow to combine these two. 
So it requires make, npm, and composer.

```
git clone https://github.com/ProDemos/pds.git
make install
```

To make changes
```
git checkout -b feature/barf

# edit stuff ..

make compile
make packages

# check stuff ..

git push origin feature/barf

# now manually create a PR in github
```

To create a new release, read [Distribution.md](Distribution.md)


## make commands

- **make install**\
  calls composer install, npm install, etc

- **make compile** 
  - **make compile-css**\
    using node, compiles sass to css in `build/assets/css`

  - **make compile-html**\
    using php, compiles twig to html in `build/demo/`

- **make packages** \
  copies files to various `/build/packages/(package)`

- **make release tag=$tag**\
  this target is called by a github action, see [Distribution.md](Distribution.md). You
  should not need to call this manually. It either calls `npm version $tag && npm publish` to github for each package 
  and/or calls `hub release edit -a *tgz` for each zipped package.

- **make clean** \
  remove generated files in `/build/*`

# Making changes

## Build / compile / package

You can edit the files in `src/assets` and `src/demo`.
To compile them, use `make compile`. The compiled versions
appear in `build/assets` and `build/demo`. If needed, you
can call `make packages`, too. The packages will appear
in `build/packages`. 

These are *not* included in the repo. When creating a 
new release, the workflow compiles these folders and
packages again and attaches them to the release.

## Expand - adding new elements

To create a new element, say pds-c-foo
  - write your sass in assets/sass/pds/components/_foo.scss
  - add your stylesheet to assets/sass/main.scss
  - write a demo twig template in assets/twig/components/foo/foo.twig
  - add a config for template to assets/twig/pds/components/foo/_styleguide.yml
and compile the sass and twig as described above.

Your element should now appear in the styleguide in `build/demo`

Always prefix you classnames with pds-. Try to stay
within the definitions of pds-s(copes), pds-t(hemes),
pds-c(omponents) and pds-m(odifiers). Avoid BEM.
Use predefined colors, sizes and fonts.

If you want to write directly in the demo pages, 
check demo/build/pages/*

## Sass

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



