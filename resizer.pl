#!/usr/bin/env perl
use Modern::Perl '2012';
use Mojolicious::Lite;
use Mojo::URL;
use Mojo::UserAgent;
use Mojo::Util qw/ url_escape url_unescape /;
use File::Basename; # core; no install...
use Imager;
use Regexp::Common qw/ number /;


# Documentation browser under "/perldoc"
plugin 'PODRenderer';


=head1 GET Index

This displays a help page, since we are really an API server.
=cut
get '/' => sub {
    my $self = shift;

    $self->render('help');
};


=head1 GET '/api/v1/resize?url=http%3A%2F%2Fwww.example.com%2Fexample.jpg&w=200&h=200'

Resize an image.

Width and height are passed as query params since its more appropriate than
being part of the URL path itself; the path describes a resource and query params
describe desired attributes.

Proportions are maintained, which is a very good thing.

=cut
get '/api/v1/resize' => sub {
    # an instance of Mojolicious::Controller
    my $self = shift;

    my $image_url = Mojo::URL->new(url_unescape $self->param('url'));
    my $image_name = basename($image_url->path);

    my $new_width = $self->param('w');
    my $new_height = $self->param('h');

    ## Validate width & height
    return $self->render(
        json => {error => sprintf("Bad Parameter: Width was %s; must be whole number or decimal", $new_width)}, status => 500
    ) unless $RE{num}{decimal}->matches($new_width);

    return $self->render(
        json => {error => sprintf("Bad Parameter: Height was %s; must be whole number or decimal", $new_height)}, status => 500
    ) unless $RE{num}{decimal}->matches($new_height);


    ## Get the resource; better to use a real UA string so servers in the wild
    # don't panic and refuse the request.
    my $grabber = Mojo::UserAgent->new()
        ->name('"Mozilla/5.0 (Windows NT 5.1; rv:22.0) Gecko/20100101 Firefox/22.0"')
        ->request_timeout(5);

    # Docs say: "When downloading large files with Mojo::UserAgent you
    # don't have to worry about memory usage at all, because it will
    # automatically stream everything above 250KB into a temporary file."
    #
    # Set the accept header for mime types which Imager can process
    my $tx = $grabber->get($image_url->to_string, {'Accept' => 'image/jpeg, image/gif, image/png'});
    return $self->render(
        json => {error => "Cannot get image: " .  $tx->error}, status => 500
    ) if $tx->error;

    # Move it to somewhere from which we can serve it later.
    #
    # `res` is an instance of Mojo::Message::Response
    my $downloaded_img = $tx->res->content->asset->move_to('public/' . $image_name);   #->body();
    return $self->render(
        json => {error => "Cannot move image: " .  $tx->error}, status => 500
    ) if $tx->error;

    ## Resize it!
    my $img = Imager->new();
    $img->read(file => 'public/' . $image_name);
    return $self->render(json => {error => "Cannot read image: " . $img->errstr}, status => 500) if $img->errstr;

    # non-proportional x or y pixels don't matter; Imager handles it according to the `type` arg
    my $resized_img = $img->scale(
        xpixels => $new_width,
        ypixels => $new_height,
        type    => 'max',   # default = use the max size if x,y are not proportional
        qtype   => 'normal' # default
    );

    $resized_img->write(
        file => 'public/' . $image_name,
    );
    return $self->render(json => {error => "Cannot write image: " . $img->errstr()}, status => 500) if $img->errstr();

    ## Return directly to client
    $self->render_static($image_name); # default is to serve from ./public
};


app->start;

__DATA__

@@ help.html.ep
% layout 'default';
% title 'Help';
This application is only meant to be accessed a an API.

@@ exception.html.ep
Error!

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
    <head>
        <title><%= title %></title>
    </head>
    <body>
        <%= content %>
    </body>
</html>

