REST-Resizer
============

API to resize images


curl -v 127.0.0.1:3000/api/v1/resize/http%3A%2F%2Fplacehold.it%2F350x150.jpg?w=175&h=75

    "%2f (encoded "/") is not allowed in URL unless you explicitly allow it in webserver's configuration." -vartec; Stackoverflow.
    Me: make it part of thw querystring, instead!

pass percentage or either of width or height, but not both. This is to ensure the image's proportions are properly maintained.

* Imager (plenty of good ratings on cpanratings!)
* GraphicsMagick (forked and faster than ImageMagick)
* ImageMagick (PerlMagick)
* GD
* Imlib


Permissions Problems
--------------------
saving to /tmp work, but not reading from it for morbo?


Future Directions/Issues
------------------------

@TODO: save it as a file, rather than holding it in memory?
