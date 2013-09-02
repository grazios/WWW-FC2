package WWW::FC2;

use 5.006;
use strict;
#use warnings FATAL => 'all';

=head1 NAME

WWW::FC2 - The great new WWW::FC2!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';





=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use WWW::FC2;

    my $foo = WWW::FC2->new();
    ...

=head1 AUTHOR

Shun Takeyama, C<< <shun at takeshun.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-fc2 at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-FC2>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::FC2


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-FC2>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-FC2>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-FC2>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-FC2/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Shun Takeyama.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

#"

use Carp 'croak';
use WWW::Mechanize::Cached;
use Web::Scraper;
use utf8;
sub new {
    my $class = shift;


    my %passed_parms = @_;

    my $mod_parms = {
        autocheck   => ($class eq 'WWW::FC2' ? 1 : 0),
        email       =>  $passed_parms{'email'},
        pass        =>  $passed_parms{'pass'},
        mech        =>  WWW::Mechanize::Cached->new(),
    };
    
	$mod_parms->{mech}->agent_alias( 'Windows Mozilla' );
    return bless $mod_parms, $class;
}




sub login {
	my $self = shift;
    my %passed_parms = @_;
	my $loginUrl = "http://fc2.com/login.php";
	
	$self->{mech}->get($loginUrl);
	
	if(!$self->{mech}->success()){
	  croak "Can't access $loginUrl";
	}
	
	if(! $self->{mech}->is_html()){
	  croak "Can't access $loginUrl";
	}
	if(exists($passed_parms{email})){
		$self->{email} = $passed_parms{email};
	}elsif(! exists($self->{email})){
	  croak "Please set email";
	
	}
	
	if(exists($passed_parms{pass})){
		$self->{email} = $passed_parms{pass};
	}elsif(! exists($self->{pass})){
	  croak "Please set pass";
	
	}
	$self->{mech}->submit_form(
		form_name=>'form_login',
		fields => {
			email => $self->{email},
			pass => $self->{pass},
		},
	);
	
	
	

	
	if (! $self->{mech}->success()){
	  croak "Can't login";
	}
	
	$self->{mech}->get("http://id.fc2.com/?login=done");
	$self->{mech}->get("http://video.fc2.com/");
	$self->{mech}->get("https://secure.id.fc2.com/?done=video&switch_language=ja");
	$self->{mech}->get("http://id.fc2.com/?mode=redirect&login=done");
	
	
	print $self->{mech}->content;
	
	return $self;
}

sub get_movie{

	my $self = shift;
	my $target = shift;
	
	if(!defined($target)){
	  croak "Please set target";
	
	}

	#$self->{mech}->get("http://video.fc2.com/content/$target");

	$self->{mech}->get($target);


	if(!$self->{mech}->success()){
	  croak "Can't access $target";
	}
	
	if(! $self->{mech}->is_html()){
	  croak "Can't access $target";
	}
	
	my $scraper = scraper {
		process '/html/head/meta[@property="og:title"]', title => '@content';
		process '/html/head/meta[@property="og:url"]', url => '@content';
		process '/html/head/meta[@name="keywords"]', keywords => '@content';
		process '/html/head/meta[@name="description"]', description => '@content';
		process '/html/body//input[@name="thumbimg"]', 'thumbimg[]' => ['@onchange', sub {s/^changeThumbnail\(\'(.*)\',\'.*\',\'.*\'\).*$/$1/sg;}];#'
	};
	
	
	
	my $res = $scraper->scrape($self->{mech}->content);
	
	$res->{thumbnail}->{anim} = '<a href="' . $res->{url} . '" title="動画：'. $res->{title} .'" rel="nofollow"><img src="'. $res->{thumbimg}[0] . '" alt="動画：'. $res->{title} .'"></a>';
	$res->{thumbnail}->{digest} = '<a href="' . $res->{url} . '" title="動画：'. $res->{title} .'" rel="nofollow"><img src="'. $res->{thumbimg}[1] . '" alt="動画：'. $res->{title} .'"></a>';
	$res->{thumbnail}->{still} = '<a href="' . $res->{url} . '" title="動画：'. $res->{title} .'" rel="nofollow"><img src="'. $res->{thumbimg}[2] . '" alt="動画：'. $res->{title} .'"></a>';
	
	return $res;

}


1; # End of WWW::FC2
