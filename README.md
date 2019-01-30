
Requirements: ImageMagick, x11-apps, ruby, xcursorgen

1) find/generate file with 'CURS' resources (ResEdit)
2) use MPW's DeRez to decompile the resources
3) use render-curs.rb on the DeRez output to generate PNG images

Examples:

![default](examples/default.png)
![default](examples/progress-01.png)
![default](examples/wait-01.png)

