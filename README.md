REST-Resizer
============

API to resize images. Proportions are maintained, which is a very good thing.

Usage
-----

Issue a HTTP GET request to the endpoint `/api/v1/resize?url=&w=&h=`. For example:
```
curl -v http://127.0.0.1:3000/api/v1/resize?url=http%3A%2F%2Fplacehold.it%2F350x150.jpg?w=175&h=75
```
#### Query Parameter Notes

* The URL to the image must be URL encoded.
* `w` is the new width, in pixles; must be either a whole number or decimal.
* `h` is the new height, in pixels; must be either a whole number or decimal.

## Returned Content

The HTTP response body is binary image data. The image format is specified by
the Mime type in the Content-Type response header.

#### Errors

Errors are returned as a JSON string.

HTTP Code: 500.
```json
{"error":"Image could not be read: ..."}
```
Deployment
----------

### Prerequisites

You **must** have installed libraries for building the Imager CPAN module.

#### Tested

* **Ubuntu:**
    Tested under Perl 5.14.2 on Ubuntu 12.04 LTS, in VirtualBox. Installation
    requires having a C compiler. To install:
    ```
    sudo apt-get build-essential
    ```

    ```
    sudo apt-get libpng12-dev libgif-dev libjpeg8-dev libtiff4-dev libfreetype6-dev
    ```

#### Untested

* **CentOS/RHEL/Fedora:**
    ```
    yum groupinstall "Development Tools"
    ```
    ```
    yum install libpng-devel libtiff-devel giflib-devel, libjepg-devel freetype-devel
    ```
* **FreeBSD:**
    `pkg_add -r `, etc.
* **OpenBSD:**
    `pkg_add `, etc.
* **Windows:**
    Imager comes bundled with Strawberry Perl. It can also be upgraded from
    CPAN with no issues found by this author when doing so.
* **OSX:**
    Please see the Imager Docs (there seems to be much to do):
    https://metacpan.org/module/TONYC/Imager-0.97/lib/Imager/Install.pod

### Get Source Code

```
git clone https://github.com/mgatto/REST-Resizer.git
cd REST-Resizer
```
Next, install the dependencies.

### Install Dependencies

cpanm will automatically use the [`cpanfile`](https://github.com/mgatto/REST-Resizer/blob/master/cpanfile)
in the source code to install dependencies.

The modules are pinned to their latest releases, simply on principle and to match
my testing environment. Earlier releases of these distributions may well work.
Feel free to modify the cpanfile; it may break however, and if it does, please
file an issue on this GitHub project.

You may wish to install the required modules into your local::lib, and possibly
a separate install using Perlbrew.

In any case, go ahead and install the dependencies:
```
cpanm --installdeps .
```
After this, you are ready to start the (test) server!

### Start the Server

For demonstration purposes, we use the Morbo HTTP server, built-in to Mojolicious.
Make sure you're in the same directory as `resizer.pl` and then run:
```
./resizer.pl daemon
```
You may also run
```
morbo resizer.pl
```
But the daemon flag reloads updated code, which is good for shortening the dev cycle.

Design Decisions
----------------

Specifying the image's url in a query string rather than as part of the endpoint
was necessary because many HTTP servers disallow %2f (= encoded "/") in URLs.
It can be part of the querystring, however.

### Library Choices

##### Image Library

Perl developers have several fine choices, but mine are ranked below:

1. Imager (plenty of good ratings on cpanratings!)
2. GraphicsMagick (forked and faster than ImageMagick)
3. ImageMagick (PerlMagick)
4. GD
5. Imlib

I chose Imager because,

* Its API is clean and fits my expectations.
* Very sensible handlings of non-proportional x,y pixels for transforms.
* Actively maintained, with very recent releases.
* Highly rated by other CPAN users.

##### HTTP Microframework

Mojolicious has plenty of built-in support

has no required CPAN dependencies. Some have critiqued this, but
I'm fine with it since its fast. Also, a Mojolicious::Lite application can be
easily upgraded to a full Mojo application as it grows.

Future Directions/Issues
------------------------

* Retrieve and Stream the image with chunked encoding, to speed it up.

### Internal Refactorings

* Structured exceptions, probably based on Exception::Class and Try::Tiny.
* Store images to process in /tmp for user privacy and auto-ish cleanup of old files. Currently, Mojo dislikes this even when its configured to serve static files from a specific path aside from its default of `public/`
* Explore benefits of dealing only in filehandles, rather than paths.
* Explore benefits of in-memory processing, rather than disk I/O.

    This could speed things up and reduce disk usage, but it would also swell
    RAM requirements as it scales.
