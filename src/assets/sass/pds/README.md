# Main PDS sass folder 

If you host the source sass in your project, you
only need to look a these files. They are in a subfolder
'pds' here so that, if you use the right `--load-path` on
the sass command, or configure it in your webpack,
you can `@use "pds/bla"` in your own code.