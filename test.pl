#!/usr/bin/perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $|= 1; print "1..245\n"; }
END {print "not ok 1\n" unless $loaded;}
use Win32API::File qw(:ALL);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

$Debug=  ( -t STDIN ) != ( -t STDOUT );
if(  $Debug  ) {
    warn "# Running tests in debug mode ",
      "since exactly one of STDIN/STDOUT is a tty.\n";
}
$test= 1;

use strict qw(subs);

$temp= $ENV{"TMP"};
$temp= $ENV{"TEMP"}	unless -d $temp;
$temp= "C:/Temp"	unless -d $temp;
$temp= "."		unless -d $temp;
$dir= "W32ApiF.tmp";

chdir( $temp )
  or  die "# Can't cd to temp directory, $temp: $!\n";

if(  -d $dir  ) {
    if(  glob( "$dir/*" )  ) {
	system( "attrib -r -h -s $dir\\*" );
	$Debug && warn "# echo y | del $temp\\$dir\\*\n";
	system( "echo y | del $dir\\*" );
    }
    system( "rd $dir" );
}
mkdir( $dir, 0777 )
  or  die "# Can't create temp dir, $temp/$dir: $!\n";
$Debug && warn "# chdir $temp\\$dir\n";
chdir( $dir )
  or  die "# Can't cd to my dir, $temp/$dir: $!\n";

$h1= createFile( "ReadOnly.txt", "r", { Attributes=>"r" } );
$ok=  ! $h1  &&  fileLastError() =~ /not find the file?/i;
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 2
if(  ! $ok  ) {   CloseHandle($h1);   unlink("ReadOnly.txt");   }

$ok= $h1= createFile( "ReadOnly.txt", "wcn", { Attributes=>"r" } );
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 3

$ok= WriteFile( $h1, "Original text\n", 0, [], [] );
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 4

$h2= createFile( "ReadOnly.txt", "rcn" );
$ok= ! $h2  &&  fileLastError() =~ /file exists?/i;
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 5
if(  ! $ok  ) {   CloseHandle($h2);   }

$h2= createFile( "ReadOnly.txt", "rwke" );
$ok= ! $h2  &&  fileLastError() =~ /access is denied?/i;
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 6
if(  ! $ok  ) {   CloseHandle($h2);   }

$ok= $h2= createFile( "ReadOnly.txt", "r" );
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 7

$ok= SetFilePointer( $h1, length("Original"), [], FILE_BEGIN );
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 8

$ok= WriteFile( $h1, "ly was other text\n", 0, $len, [] )
  &&  $len == length("ly was other text\n");
$Debug && !$ok && warn "# <$len> should be <",
  length("ly was other text\n"),">: ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 9

$ok= ReadFile( $h2, $text, 80, $len, [] )
 &&  $len == length($text);
$Debug && !$ok && warn "# <$len> should be <",length($text),
  ">: ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 10

$ok= $text eq "Originally was other text\n";
if(  $Debug  &&  ! $ok  ) {
    $text =~ s/\r/\\r/g;   $text =~ s/\n/\\n/g;
    warn "# <$text> should be <Originally was other text\\n>.\n";
}
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 11

$ok= CloseHandle($h2);
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 12

$ok= ! ReadFile( $h2, $text, 80, $len, [] )
 &&  fileLastError() =~ /handle is invalid?/i;
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 13

CloseHandle($h1);

$ok= $h1= createFile( "CanWrite.txt", "rw", FILE_SHARE_WRITE,
	      { Create=>CREATE_ALWAYS } );
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 14

$ok= WriteFile( $h1, "Just this and not this", 10, [], [] );
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 15

$ok= $h2= createFile( "CanWrite.txt", "wk", { Share=>"rw" } );
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 16

$ok= OsFHandleOpen( "APP", $h2, "wat" );
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 17

$ok=  $h2 == GetOsFHandle( "APP" );
$Debug && !$ok && warn "# $h2 != ",GetOsFHandle("APP"),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 18

{   my $save= select(APP);   $|= 1;  select($save);   }
$ok= print APP "is enough\n";
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 19

$ok= ReadFile( $h1, $text, 0, [], [] );
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 20

$ok=  $text eq "is enough\r\n";
if(  $Debug  &&  ! $ok  ) {
    $text =~ s/\r/\\r/g;
    $text =~ s/\n/\\n/g;
    warn "# <$text> should be <is enough\\r\\n>\n";
}
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 21

$ok= ! unlink( "CanWrite.txt" )
 &&  $! =~ /permission denied/i;
$Debug && !$ok && warn "# $!\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 22

close(APP);		# Also does C<CloseHandle($h2)>
## CloseHandle( $h2 );
CloseHandle( $h1 );

$ok= ! DeleteFile( "ReadOnly.txt" )
 &&  fileLastError() =~ /access is denied?/i;
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 23

$ok= ! CopyFile( "ReadOnly.txt", "CanWrite.txt", 1 )
 &&  fileLastError() =~ /file exists?/i;
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 24

$ok= ! CopyFile( "CanWrite.txt", "ReadOnly.txt", 0 )
 &&  fileLastError() =~ /access is denied?/i;
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 25

$ok= ! MoveFile( "NoSuchFile", "NoSuchDest" )
 &&  fileLastError() =~ /not find the file/i;
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 26

$ok= ! MoveFileEx( "NoSuchFile", "NoSuchDest", 0 )
 &&  fileLastError() =~ /not find the file/i;
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 27

$ok= ! MoveFile( "ReadOnly.txt", "CanWrite.txt" )
 &&  fileLastError() =~ /file already exists?/i;
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 28

$ok= ! MoveFileEx( "ReadOnly.txt", "CanWrite.txt", 0 )
 &&  fileLastError() =~ /file already exists?/i;
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 29

$ok= CopyFile( "ReadOnly.txt", "ReadOnly.cp", 1 )
 &&  CopyFile( "CanWrite.txt", "CanWrite.cp", 1 );
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 30

$ok= ! MoveFileEx( "CanWrite.txt", "ReadOnly.cp", MOVEFILE_REPLACE_EXISTING )
 &&  fileLastError() =~ /access is denied?/i;
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 31

$ok= MoveFileEx( "ReadOnly.cp", "CanWrite.cp", MOVEFILE_REPLACE_EXISTING );
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 32

$ok= MoveFile( "CanWrite.cp", "Moved.cp" );
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 33

$ok= ! unlink( "ReadOnly.cp" )
 &&  $! =~ /no such file/i
 &&  ! unlink( "CanWrite.cp" )
 &&  $! =~ /no such file/i;
$Debug && !$ok && warn "# $!\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 34

$ok= ! DeleteFile( "Moved.cp" )
 &&  fileLastError() =~ /access is denied?/i;
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 35

system( "attrib -r Moved.cp" );

$ok= DeleteFile( "Moved.cp" );
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 36

$new= SEM_FAILCRITICALERRORS|SEM_NOOPENFILEERRORBOX;
$old= SetErrorMode( $new );
$renew= SetErrorMode( $old );
$reold= SetErrorMode( $old );

$ok= $old == $reold;
$Debug && !$ok && warn "# $old != $reold: ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 37

$ok= ($renew&$new) == $new;
$Debug && !$ok && warn "# $new != $renew: ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 38

$ok= @drives= getLogicalDrives();
$Debug && $ok && warn "# @drives\n";
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 39

$ok=  $drives[0] !~ /^[ab]/  ||  DRIVE_REMOVABLE == GetDriveType($drives[0]);
$Debug && !$ok && warn "# ",DRIVE_REMOVABLE," != ",GetDriveType($drives[0]),
  ": ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 40

$drive= substr( $ENV{windir}, 0, 3 );

$ok= 1 == grep /^\Q$drive\E/i, @drives;
$Debug && !$ok && warn "# No $drive found in list of drives.\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 41

$ok= DRIVE_FIXED == GetDriveType( $drive );
$Debug && !$ok && warn
  "# ",DRIVE_FIXED," != ",GetDriveType($drive),": ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 42

$ok=  GetVolumeInformation( $drive, $vol, 64, $ser, $max, $flag, $fs, 16 );
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 43
$vol= $ser= $max= $flag= $fs= "";	# Prevent warnings.

chop($drive);
$ok= QueryDosDevice( $drive, $dev, 80 );
$Debug && !$ok && warn "# $drive: ",fileLastError(),"\n";
if(  $Debug  &&  $ok  ) {
    ( $text= $dev ) =~ s/\0/\\0/g;
    warn "# $drive => $text\n";
}
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 44

$bits= GetLogicalDrives();
$let= "Z";
$bit= 1<<25;
while(  $bit & $bits  ) {
    $let--;
    $bit >>= 1;
}
$let .= ":";

$ok= DefineDosDevice( 0, $let, $ENV{windir} );
$Debug && !$ok && warn "# $let,$ENV{windir}: ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 45

$ok=  -s $let."/Win.ini"  ==  -s $ENV{windir}."/Win.ini";
$Debug && !$ok && warn "# ", -s $let."/Win.ini", " vs. ",
  -s $ENV{windir}."/Win.ini", ": ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 46

$ok= DefineDosDevice( DDD_REMOVE_DEFINITION|DDD_EXACT_MATCH_ON_REMOVE,
		      $let, $ENV{windir} );
$Debug && !$ok && warn "# $let,$ENV{windir}: ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 47

$ok= ! -f $let."/Win.ini"
  &&  $! =~ /no such file/i;
$Debug && !$ok && warn "# $!\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 48

$ok= DefineDosDevice( DDD_RAW_TARGET_PATH, $let, $dev );
if(  $Debug  &&  !$ok  ) {
    ( $text= $dev ) =~ s/\0/\\0/g;
    warn "# $let,$text: ",fileLastError(),"\n";
}
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 49

$ok= -f $let.substr($ENV{windir},3)."/win.ini";
$Debug && !$ok && warn "# ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 50

$ok= DefineDosDevice( DDD_REMOVE_DEFINITION|DDD_EXACT_MATCH_ON_REMOVE
		     |DDD_RAW_TARGET_PATH, $let, $dev );
$Debug && !$ok && warn "# $let,$dev: ",fileLastError(),"\n";
print $ok ? "" : "not ", "ok ", ++$test, "\n";	# ok 51

#	DefineDosDevice
#	GetFileType
#	GetVolumeInformation
#	QueryDosDevice
#Add a drive letter that points to our temp directory
#Add a drive letter that points to the drive our directory is in

#winnt.t:
# get first drive letters and use to test disk and storage IOCTLs
# "//./PhysicalDrive0"
#	DeviceIoControl

my %consts;
my @consts= @Win32API::File::EXPORT_OK;
@consts{@consts}= @consts;

my( @noargs, %noargs )= qw(
  attrLetsToBits fileLastError getLogicalDrives GetLogicalDrives );
@noargs{@noargs}= @noargs;

foreach $func ( @{$Win32API::File::EXPORT_TAGS{Func}} ) {
    delete $consts{$func};
    if(  defined( $noargs{$func} )  ) {
	$ok=  ! eval("$func(0,0)")  &&  $@ =~ /(::|\s)_?${func}A?[(:\s]/;
    } else {
	$ok=  ! eval("$func()")  &&  $@ =~ /(::|\s)_?${func}A?[(:\s]/;
    }
    $Debug && !$ok && warn "# $func: $@\n";
    print $ok ? "" : "not ", "ok ", ++$test, "\n";
}

foreach $func ( @{$Win32API::File::EXPORT_TAGS{FuncA}},
                @{$Win32API::File::EXPORT_TAGS{FuncW}} ) {
    $ok=  ! eval("$func()")  &&  $@ =~ /::_?${func}\(/;
    delete $consts{$func};
    $Debug && !$ok && warn "# $func: $@\n";
    print $ok ? "" : "not ", "ok ", ++$test, "\n";
}

foreach $const ( keys(%consts) ) {
    $ok= eval("my \$x= $const(); 1");
    $Debug && !$ok && warn "# Constant $const: $@\n";
    print $ok ? "" : "not ", "ok ", ++$test, "\n";
}

chdir( $temp );
system( "attrib -r $dir\\ReadOnly.txt" );
unlink "$dir/CanWrite.txt", "$dir/ReadOnly.txt";
system( "rd $dir" );

__END__
