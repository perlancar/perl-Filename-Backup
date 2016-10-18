package Filename::Backup;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(check_backup_filename);

our %SPEC;

our %SUFFIXES = (
    '~'     => 1,
    '.bak'  => 1,
    '.old'  => 1,
    '.orig' => 1, # patch
    '.rej'  => 1, # patch
    '.swp'  => 1,
    # XXX % (from /etc/mime.types)
    # XXX sik? (from /etc/mime.types)
    # XXX .dpkg*
    # XXX .rpm*
);

$SPEC{check_backup_filename} = {
    v => 1.1,
    summary => 'Check whether filename indicates being a backup file',
    description => <<'_',


_
    args => {
        filename => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
        # XXX recurse?
        ci => {
            summary => 'Whether to match case-insensitively',
            schema  => 'bool',
            default => 1,
        },
    },
    result_naked => 1,
    result => {
        schema => ['any*', of=>['bool*', 'hash*']],
        description => <<'_',

Return false if not detected as backup name. Otherwise return a hash, which may
contain these keys: `original_filename`. In the future there will be extra
information returned, e.g. editor name (if filename indicates backup from
certain backup program), date (if filename contains date information), and so
on.

_
    },
};
sub check_backup_filename {
    my %args = @_;

    my $filename = $args{filename};
    my $orig_filename;

    if ($filename =~ /\A#(.+)#\z/) {
        $orig_filename = $1;
        goto RETURN;
    }

    $filename =~ /(~|\.\w+)\z/ or return 0;
    my $ci = $args{ci} // 1;

    my $suffix = $1;

    my $spec;
    if ($ci) {
        my $suffix_lc = lc($suffix);
        for (keys %SUFFIXES) {
            if (lc($_) eq $suffix_lc) {
                $spec = $SUFFIXES{$_};
                last;
            }
        }
    } else {
        $spec = $SUFFIXES{$suffix};
    }
    return 0 unless $spec;

    ($orig_filename = $filename) =~ s/\Q$suffix\E\z//;

  RETURN:
    return {
        original_filename => $orig_filename,
    };
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use Filename::Backup qw(check_backup_filename);
 my $res = check_backup_filename(filename => "foo.txt~");
 if ($res) {
     printf "Filename indicates a backup, original name: %s\n",
         $res->{original_filename};
 } else {
     print "Filename does not indicate a backup\n";
 }

=head1 DESCRIPTION


=head1 SEE ALSO

L<Filename::Archive>

L<Filename::Compressed>

=cut
