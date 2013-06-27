use Modern::Perl;
use LWP;
use JSON;

use File::Slurp;

# look into rewriting this in jquery and hosting it on github pages

my ($mode,$raw_json) = call_api(@ARGV);
my $kanji_list = process_response($mode,$raw_json);
my @xml = build_xml($mode,$kanji_list);
write_file('wanikani-'.$mode.'.xml', {binmode => ':utf8' }, @xml);

sub call_api {

    my ($mode,$key,$url) = ($_[0],$_[-1],'http://www.wanikani.com/api/user/');

    if ($key !~ /^[[:xdigit:]]{32}$/){
        die "$key doesn't look like a WaniKani API key."; #shouldn't die out of a function
    }
    $url .= $key;

    # K for standard kanji, V for vocab.
    if ($mode !~ s/^-?([vk]).*/uc $1/ie){
        $mode = 'K';
    }
    if ($mode eq 'V'){
        $url .= '/vocabulary/';
    } else {
        $url .= '/kanji/';
    }

    #grab/check the page
    my $req = LWP::UserAgent->new()->get($url);
    if (! $req->is_success){
        die $req->code.' '.$req->content_length;
    }

    return ($mode,$req->decoded_content);
}

sub process_response {
    my $json;
    eval { $json = JSON->new->utf8->decode($_[1]); };
    if ($@){ die $@; }

    if ($_[0] eq 'K'){
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
    } elsif ($_[0] eq 'V'){ #why the subtle API difference?
        my %vocab;
        my $i = $#{$json->{'requested_information'}{'general'}};
        while ($i >= 0){
            my $chr = $json->{'requested_information'}{'general'}[$i];
            for (split /,\s+/, $chr->{'meaning'}){
                push @{$vocab{$_}}, $chr->{'character'};
            }
            $i--;
        }
        return \%vocab;
    }
}

sub build_xml { #doing this manually b/c I don't know of an XML framework that's not worthless
    my @xml = (
        '<?xml version="1.0" encoding="utf-8"?>',
    );
    $_[0] eq 'V'
    ? push @xml, '<root title="WaniKani (Vocab)">'
    : push @xml, '<root title="WaniKani (Kanji)">';

    for (sort keys %{$_[1]}){
        push @xml, '<entry key="'.$_.'" kanji="'.(join ';', @{$_[1]{$_}}).'" />';
    }

    push @xml, '</root>';
    return @xml;
}
