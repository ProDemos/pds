
# Including examples

Below are some more detailed examples of how to include PDS
into your own project.

## Plain css

```html
<html>
    <head>
        <link rel="stylesheet" type="text/css" href="pds/assets/css/reset.css"><!--optional-->
        <link rel="stylesheet" type="text/css" href="pds/assets/css/main.css">
    </head>
    <body class="pds-t-orange01">
        <button class="psd-c-button large">click</button>
    </body>
</html>
```

## Sass ( from cli )

Make sure to copy the assets (images, fonts etc) to a public 
folder and configure `$assets-path` to point to that folder first.

Use a sass `load-path` for the PDS scss so you don't have to type 
full paths in your `@use` statements:

```bash
sass --load-path path-to/pds-assets/sass input.scss output.css
```

Write the config in a **global stylesheet**

```scss
@use "pds/settings" with (
  $assets-path: "path-to/pds-assets",
  $custom-breakpoints: (
    phablet: 560px,
  )
  // etcetera
);
@use "pds/reset"; // optional
@use "pds/main";
```

To access sass variables, methods and mixins, 
include the pds namespace in any child sccs file:

```scss
@use "pds/pds";
@debug pds.$assets-path;
@include pds.media(phablet,max) {
    color:red;
}
```

## Sass ( in Vue )

- The PDS assets folder will be bundled during the build process. Use a compiler `alias` to resolve its path using javascript.
- Add a css `loadPath` for PDS so you don't have to type full paths in your `@use` statements
- Since you want to reuse the configuration in every Vue component, you can use `additionalData` to prepend a file with the `pds.settings` only. This way, pds is available (and configured) in every component.
- In another global file, you want to use `pds.reset` and `pds.main`. If you would do this in 'additionalData', the reset css may overwrite css added by other modules.

prepare the setup in **vite.config.ts**
```JS
export default defineConfig(({ mode }) => {
  return {
    resolve: {
      alias: {
        "@pds-assets": path.resolve(
          import.meta.dirname,
          "node_modules/@prodemos/pds-source/assets",
        )
      },
    },
    css: {
      preprocessorOptions: {
        scss: {
          loadPaths: ["node_modules/@prodemos/pds-source/assets/sass"],
          additionalData: `@use "@/shared/sass/prepend.scss";`,
        },
      },
    },
    
    ...
```

add the pds/settings in a **prepend.scss**
```scss
@use "pds/settings" with (
  $assets-path: "@pds-assets",
  $custom-breakpoints: (
    phablet: 560px,
  )
  // etcetera
);
```

add pds/reset and pds/main in a **global stylesheet**
```scss
@use "pds/reset"; // optional
@use "pds/main";
```

use pds/pds in a **Vue component**
```scss
<style lang="scss" scoped>
@use "pds/pds";
@debug pds.$font-serif;
@include pds.media(phablet,max) {
    background-image:url(#{pds.$assets-path}/images/icons/plus.svg);
}
</style>
```
