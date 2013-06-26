use Modern::Perl;
use LWP;
use JSON;

use File::Slurp;

# look into rewriting this in jquery and hosting it on github pages

my $raw_json = call_api($ARGV[0]);
my $kanji_list = process_response($raw_json);
my @xml = build_xml($kanji_list);
write_file('wanikani.xml', {binmode => ':utf8' }, @xml);

sub call_api { # entirely functional
    #first, validate the api key
    if ($_[0] !~ /^[[:xdigit:]]{32}$/){
        die "$_[0] doesn't look like a WaniKani API key."; #don't die out of a function
    }

    #grab/check the page
    my $req = LWP::UserAgent->new()->get('http://www.wanikani.com/api/user/'.$_[0].'/kanji/');
    if (! $req->is_success){
        die $req->code.' '.$req->content_length;
    }

    return $req->decoded_content;
}

sub process_response {
    my $json;
    eval { $json = JSON->new->utf8->decode($_[0]); };
    if ($@){ die $@; }

    my %kanji;
    my $i = $#{$json->{'requested_information'}};
    while ($i >= 0){
        my $chr = $json->{'requested_information'}[$i];
        for (split /,\s+/, $chr->{'meaning'}){
            push @{$kanji{$_}}, $chr->{'character'};
        }
        $i--;
    }
    return \%kanji;
}

sub build_xml { #doing this manually b/c I don't know of an XML framework that's not worthless
    my @xml = ( #boilerplate
        '<?xml version="1.0" encoding="utf-8"?>',
        '<root title="WaniKani">'
    );

    for (sort keys %{$_[0]}){
        push @xml, '<entry key="'.$_.'" kanji="'.(join ',', @{$_[0]{$_}}).'" />';
    }

    push @xml, '</root>';
    return @xml;
}
