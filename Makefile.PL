use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Win32API::File',
    'VERSION_FROM' => 'File.pm', # finds $VERSION
    ($] < 5.005 ? () : ('CAPI' => 'TRUE')),
);
