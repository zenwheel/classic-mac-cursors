
Requirements: ImageMagick, x11-apps, ruby, xcursorgen

1) find/generate file with 'CURS' resources (ResEdit)
2) use MPW's DeRez to decompile the resources
3) use render-curs.rb on the DeRez output to generate PNG images

Examples:

![default](examples/default.png)
![progress](examples/progress-01.png)
![wait](examples/wait-01.png)

