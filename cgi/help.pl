#!/usr/bin/env perl

use strict;
use HTML::Template::Pro;

use C4::Output;    # contains gettemplate
# use C4::Auth;
use Koha;
use C4::Context;
use CGI;

our $query = CGI->new();

# find the script that called the online help using the CGI referer()
our $refer = $query->referer();

# workaround for popup not functioning correctly in IE
my $referurl = $query->param('url');
if ($referurl) {
    $refer = $query->param('url');
}

$refer =~ s{/\.\.}{}g; # untaint
$refer =~ /.*koha\/(.*)\.pl.*/;
my $from = "modules/help/$1.tmpl";

our $template = gethelptemplate( $from, "intranet" );

# my $template
output_html_with_http_headers $query, "", $template->output;

sub gethelptemplate {
    my ($tmplbase) = @_;

    my $htdocs;
    $htdocs = C4::Context->config('intrahtdocs');
    my ( $theme, $lang ) = themelanguage( $htdocs, $tmplbase, "intranet", $query );
    unless ( -e "$htdocs/$theme/$lang/$tmplbase" ) {
        $tmplbase = "modules/help/nohelp.tmpl";
        ( $theme, $lang ) = themelanguage( $htdocs, $tmplbase, "intranet", $query );
    }
    my $template = HTML::Template::Pro->new(
        filename          => "$htdocs/$theme/$lang/$tmplbase",
        die_on_bad_params => 0,
        global_vars       => 1,
        path              => ["$htdocs/$theme/$lang/includes"]
    );

    # XXX temporary patch for Bug 182 for themelang
    $template->param(
        themelang => '/intranet-tmpl' . "/$theme/$lang",
        interface => '/intranet-tmpl',
        theme     => $theme,
        lang      => $lang,
        intranetcolorstylesheet =>
          C4::Context->preference("intranetcolorstylesheet"),
        intranetstylesheet => C4::Context->preference("intranetstylesheet"),
        IntranetNav        => C4::Context->preference("IntranetNav"),
		yuipath => (C4::Context->preference("yuipath") eq "local"?"/intranet-tmpl/$theme/$lang/lib/yui":C4::Context->preference("yuipath")),
        referer            => $refer,
    );
    return $template;
}
