
# Embedding examples

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
sass \
  --load-path path-to-pds/assets/sass \
  --style=compressed \
  input.scss \
  output.css
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
@use "pds/reset";
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

- The PDS assets folder will be bundled during the build process. Use a compiler `alias` to resolve the assets path using javascript.
- Add a css `loadPath` for PDS so you don't have to type full paths in your `@use` statements
- Finally, since you want to reuse the configuration in every Vue component, you can use `additionalData` to prepend a file with the pds config.

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

add the config in **prepend.scss**
```scss
@use "pds/settings" with (
  $assets-path: "@pds-assets",
  $custom-breakpoints: (
    phablet: 560px,
  )
  // etcetera
);
@use "pds/reset"; // optional
@use "pds/main";
```

use pds/pds in your **Vue component**
```scss
<style lang="scss" scoped>
@use "pds/pds";
@debug pds.$font-serif;
@include pds.media(phablet,max) {
    background-image:red;
}
</style>
```
