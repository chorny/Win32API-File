@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S "%0" %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
goto endofperl
@rem ';
#!/usr/bin/perl
#line 14
    eval 'exec perl -x -S "$0" ${1+"$@"}'
	if 0;	# In case running under some shell

use strict;
use ExtUtils::Install qw( install_default );;

exit main();

sub main
{
    install_default( "Win32API/File" )
      or die "Can't install package Win32API/File: $!\n";
    # install_default() should append to perl/lib/perllocal.pod but doesn't
    # as of Perl5.004_04 so use "make install" if this is important to you.
    # Should check for perl.dll vs. perlcore.dll so binary distribution
    # isn't installed with seriously wrong version of Perl.
    0;
}

__END__
:endofperl
