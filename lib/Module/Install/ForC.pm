package Module::Install::ForC;
use strict;
use warnings;
our $VERSION = '0.11';
use 5.008000;
use Module::Install::ForC::Env;
use Config;              # first released with perl 5.00307
use File::Basename ();   # first released with perl 5
use FindBin;             # first released with perl 5.00307

use Module::Install::Base;
our @ISA     = qw(Module::Install::Base);

our %OBJECTS;
our @CONFIG_H;

sub env_for_c {
    my $self = shift;
    $self->_forc_initialize();
    $self->admin->copy_package('Module::Install::ForC::Env');
    Module::Install::ForC::Env->new($self, @_)
}
sub is_linux () { $^O eq 'linux'  }
sub is_mac   () { $^O eq 'darwin' }
sub is_win32 () { $^O eq 'MSWin32' }

# (DEPRECATED)
sub WriteMakefileForC { shift->WriteMakefile(@_) }

sub WriteHeaderForC {
    my ($self, $fname) = @_;
    $fname or die "Usage: WriteHeaderForC('foo_config.h')";

    (my $guard = $fname) =~ tr{a-z./\055}{A-Z___};

    my $header = "#ifndef $guard\n"
               . "#define $guard\n\n";
    my $footer = "\n\n#endif  /* $guard */\n";
    if (my $version = $self->version) {
        (my $verkey = $self->name) =~ s/^Clib-//;
        $verkey =~ tr{a-z./\055}{A-Z___};
        $verkey .= "_VERSION";
        $header .= qq{#define $verkey "$version"\n\n};
    }

    open my $fh, '>', $fname or die "cannot open file($fname): $!";
    print $fh $header . join('', @CONFIG_H) . $footer;
    close $fh;
}

{
    my $initialized = 0;
    sub _forc_initialize {
        return if $initialized++;

        my $self = shift;
        $self->makemaker_args(
            # linking, compiling is job for ForC.
            C      => [],
            OBJECT => '',
        );
    }
}

1;
__END__

=head1 NAME

Module::Install::ForC - the power of M::I for C programs

=head1 SYNOPSIS

    # in your Makefile.PL
    use inc::Module::Install;

    my $env = env_for_c(CPPPATH => ['picoev/', 'picohttpparser/']);
    $env->program('testechoclient' => ["testechoclient.c"]);

    WriteMakefile();

    # then, you will get the Makefile:
    all: testechoclient

    clean:
        rm testechoclient testechoclient.o
        rm Makefile

    testechoclient: testechoclient.o
        cc   -fstack-protector -L/usr/local/lib -o testechoclient testechoclient.o

    testechoclient.o: testechoclient.c
        cc -DDEBUGGING -fno-strict-aliasing -pipe -fstack-protector -I/usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -I picoev/ -I picohttpparser/ -c -o testechoclient.o testechoclient.c


=head1 DESCRIPTION

Module::Install::ForC is a extension library for Module::Install.

This module provides some useful functions for writing C/C++ programs/libraries, doesn't depend to Perl.

M::Install is useful for Perl/XS programming, but this module provides M::I power for C/C++ programs!You can use this module as replacement of autoconf/automake for easy case.

=head1 NOTE

This is a early BETA release! API will change later.

=head1 FUNCTIONS

=over 4

=item is_linux()

=item is_mac()

=item is_win32()

Is this the OS or not?

=item WriteHeaderForC("config.h")

Write config.h, contains HAVE_* style definitions generated by $env->have_header, $env->have_library.

=item my $env = env_for_c(CPPPATH => ['picoev/', 'picohttpparser/']);

env() returns the instance of M::I::ForC::Env.

$env contains the build environment variables.The key name is a generic value for C.If you want to know about key names, see also L<Module::Install::ForC::Env>.

=back

=head1 FAQ

=over 4

=item What is supported platform?

Currently GNU/Linux, OpenSolaris, Mac OSX, and MSWin32.

=back

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom  slkjfd gmail.comE<gt>

mattn(win32 port)

=head1 SEE ALSO

This module is inspired by SCons(L<http://www.scons.org/>).

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
