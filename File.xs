/* Win32API/File.xs */

#ifdef __cplusplus
extern "C" {
#endif

//#ifdef WORD
//# undef WORD	/* Perl defines this but Win32 uses it as a typedef */
//#endif
#include <windows.h>
#include <winioctl.h>
#include <malloc.h>

#include "EXTERN.h"
#include "perl.h"
#include "patchlevel.h"
#include "XSUB.h"

#if PATCHLEVEL < 5
/* Perl 5.005 added win32_get_osfhandle/win32_open_osfhandle */
# define win32_get_osfhandle _get_osfhandle
# define win32_open_osfhandle _open_osfhandle
# ifdef _get_osfhandle
#  undef _get_osfhandle	/* stolen_get_osfhandle() isn't available here */
# endif
# ifdef _open_osfhandle
#  undef _open_osfhandle /* stolen_open_osfhandle() isn't available here */
# endif
#endif

#ifdef __cplusplus
}
#endif


#ifndef DEBUGGING
# define	Debug(list)	/*Nothing*/
#else
# define	Debug(list)	ErrPrintf list
# include <stdarg.h>
    static void
    ErrPrintf( const char *sFmt, ... )
    {
      va_list pAList;
      static char *sEnv= NULL;
      DWORD uErr= GetLastError();
	if(  NULL == sEnv  ) {
	    if(  NULL == ( sEnv= getenv("DEBUG_WIN32API_FILE") )  )
		sEnv= "";
	}
	if(  '\0' == *sEnv  )
	    return;
	va_start( pAList, sFmt );
	vfprintf( stderr, sFmt, pAList );
	va_end( pAList );
	SetLastError( uErr );
    }
#endif /* DEBUGGING */


DWORD
constant( char *sName, int ivArg )
{
    errno= 0;
    if(  '\0' == sName[0]  ||  '\0' == sName[1]
     ||  '\0' == sName[2]  ||  '\0' == sName[3]  ) {
	;
    } else switch(  sName[4]  ) {
	case 't':
	    if(  strEQ(sName,"constant")  )
		break;	/* Prevent infinite recursion for some typos */
	    break;

	case '0':
	    if(  strEQ(sName,"F3_20Pt8_512")  )
		return (DWORD)F3_20Pt8_512;
	    break;
	case '2':
	    if(  strEQ(sName,"F3_120M_512")  )
		return (DWORD)F3_120M_512;
	    if(  strEQ(sName,"F3_720_512")  )
		return (DWORD)F3_720_512;
	    if(  strEQ(sName,"F5_320_1024")  )
		return (DWORD)F5_320_1024;
	    if(  strEQ(sName,"F5_320_512")  )
		return (DWORD)F5_320_512;
	    break;
	case '6':
	    if(  strEQ(sName,"F5_360_512")  )
		return (DWORD)F5_360_512;
	    if(  strEQ(sName,"F5_160_512")  )
		return (DWORD)F5_160_512;
	    break;
	case '8':
	    if(  strEQ(sName,"F5_180_512")  )
		return (DWORD)F5_180_512;
	    break;
	case 'd':
	    if(  strEQ(sName,"FixedMedia")  )
		return (DWORD)FixedMedia;
	    break;
	case 'o':
	    if(  strEQ(sName,"Unknown")  )
		return (DWORD)Unknown;
	    break;
	case 'v':
	    if(  strEQ(sName,"RemovableMedia")  )
		return (DWORD)RemovableMedia;
	    break;

	case '_':
	    switch(  sName[5]  ) {
	    case 'A':
		if(  '\0' == sName[6]  ||  '\0' == sName[7]
		 ||  '\0' == sName[8]  ) {
		    ;
		} else switch(  sName[9]  ) {
		    case 'A':
			if(  strEQ(sName,"FILE_ALL_ACCESS")  )
#			    ifdef FILE_ALL_ACCESS
				return (DWORD)FILE_ALL_ACCESS;
#			    else
				goto not_there;
#			    endif
			break;
		    case 'F':
			if(  strEQ(sName,"FILE_ADD_FILE")  )
#				    ifdef FILE_ADD_FILE
				return (DWORD)FILE_ADD_FILE;
#				    else
				goto not_there;
#				    endif
			break;
		    case 'I':
			if(  '\0' == sName[10]  ||  '\0' == sName[11]
			 ||  '\0' == sName[12]  ||  '\0' == sName[13]
			 ||  '\0' == sName[14]  ) {
			    ;
			} else switch(  sName[15]  ) {
			    case 'A':
				if(  strEQ(sName,"FILE_ATTRIBUTE_ARCHIVE")  )
#				    ifdef FILE_ATTRIBUTE_ARCHIVE
					return (DWORD)FILE_ATTRIBUTE_ARCHIVE;
#				    else
					goto not_there;
#				    endif
				break;
			    case 'C':
				if(  strEQ(sName,"FILE_ATTRIBUTE_COMPRESSED")  )
#				    ifdef FILE_ATTRIBUTE_COMPRESSED
					return (DWORD)FILE_ATTRIBUTE_COMPRESSED;
#				    else
					goto not_there;
#				    endif
				break;
			    case 'H':
				if(  strEQ(sName,"FILE_ATTRIBUTE_HIDDEN")  )
#				    ifdef FILE_ATTRIBUTE_HIDDEN
					return (DWORD)FILE_ATTRIBUTE_HIDDEN;
#				    else
					goto not_there;
#				    endif
				break;
			    case 'N':
				if(  strEQ(sName,"FILE_ATTRIBUTE_NORMAL")  )
#				    ifdef FILE_ATTRIBUTE_NORMAL
					return (DWORD)FILE_ATTRIBUTE_NORMAL;
#				    else
					goto not_there;
#				    endif
				break;
			    case 'O':
				if(  strEQ(sName,"FILE_ATTRIBUTE_OFFLINE")  )
#				    ifdef FILE_ATTRIBUTE_OFFLINE
					return (DWORD)FILE_ATTRIBUTE_OFFLINE;
#				    else
					goto not_there;
#				    endif
				break;
			    case 'R':
				if(  strEQ(sName,"FILE_ATTRIBUTE_READONLY")  )
#				    ifdef FILE_ATTRIBUTE_READONLY
					return (DWORD)FILE_ATTRIBUTE_READONLY;
#				    else
					goto not_there;
#				    endif
				break;
			    case 'S':
				if(  strEQ(sName,"FILE_ATTRIBUTE_SYSTEM")  )
#				    ifdef FILE_ATTRIBUTE_SYSTEM
					return (DWORD)FILE_ATTRIBUTE_SYSTEM;
#				    else
					goto not_there;
#				    endif
				break;
			    case 'T':
				if(  strEQ(sName,"FILE_ATTRIBUTE_TEMPORARY")  )
#				    ifdef FILE_ATTRIBUTE_TEMPORARY
					return (DWORD)FILE_ATTRIBUTE_TEMPORARY;
#				    else
					goto not_there;
#				    endif
				break;
			}
			break;
		    case 'N':
			if(  strEQ(sName,"FILE_APPEND_DATA")  )
#			    ifdef FILE_APPEND_DATA
				return (DWORD)FILE_APPEND_DATA;
#			    else
				goto not_there;
#			    endif
			break;
		    case 'S':
			if(  strEQ(sName,"FILE_ADD_SUBDIRECTORY")  )
#			    ifdef FILE_ADD_SUBDIRECTORY
				return (DWORD)FILE_ADD_SUBDIRECTORY;
#			    else
				goto not_there;
#			    endif
			break;
		    case 'Y':
			if(  strEQ(sName,"OPEN_ALWAYS")  )
#			    ifdef OPEN_ALWAYS
				return (DWORD)OPEN_ALWAYS;
#			    else
				goto not_there;
#			    endif
			break;
		}
		break;
	    case 'B':
		if(  strEQ(sName,"FILE_BEGIN")  )
#		    ifdef FILE_BEGIN
			return (DWORD)FILE_BEGIN;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'C':
		if(  strEQ(sName,"FILE_CURRENT")  )
#		    ifdef FILE_CURRENT
			return (DWORD)FILE_CURRENT;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FILE_CREATE_PIPE_INSTANCE")  )
#		    ifdef FILE_CREATE_PIPE_INSTANCE
			return (DWORD)FILE_CREATE_PIPE_INSTANCE;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'D':
		if(  strEQ(sName,"FILE_DELETE_CHILD")  )
#		    ifdef FILE_DELETE_CHILD
			return (DWORD)FILE_DELETE_CHILD;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'E':
		if(  strEQ(sName,"FILE_EXECUTE")  )
#		    ifdef FILE_EXECUTE
			return (DWORD)FILE_EXECUTE;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FILE_END")  )
#		    ifdef FILE_END
			return (DWORD)FILE_END;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"OPEN_EXISTING")  )
#		    ifdef OPEN_EXISTING
			return (DWORD)OPEN_EXISTING;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'F':
		if(  '\0' == sName[6]  ||  '\0' == sName[7]
		 ||  '\0' == sName[8]  ||  '\0' == sName[9]  ) {
		    ;
		} else switch(  sName[10]  ) {
		    case 'B':
			if(  strEQ(sName,"FILE_FLAG_BACKUP_SEMANTICS")  )
#			    ifdef FILE_FLAG_BACKUP_SEMANTICS
				return (DWORD)FILE_FLAG_BACKUP_SEMANTICS;
#			    else
				goto not_there;
#			    endif
			break;
		    case 'D':
			if(  strEQ(sName,"FILE_FLAG_DELETE_ON_CLOSE")  )
#			    ifdef FILE_FLAG_DELETE_ON_CLOSE
				return (DWORD)FILE_FLAG_DELETE_ON_CLOSE;
#			    else
				goto not_there;
#			    endif
			break;
		    case 'N':
			if(  strEQ(sName,"FILE_FLAG_NO_BUFFERING")  )
#			    ifdef FILE_FLAG_NO_BUFFERING
				return (DWORD)FILE_FLAG_NO_BUFFERING;
#			    else
				goto not_there;
#			    endif
			break;
		    case 'O':
			if(  strEQ(sName,"FILE_FLAG_OVERLAPPED")  )
#			    ifdef FILE_FLAG_OVERLAPPED
				return (DWORD)FILE_FLAG_OVERLAPPED;
#			    else
				goto not_there;
#			    endif
			break;
		    case 'P':
			if(  strEQ(sName,"FILE_FLAG_POSIX_SEMANTICS")  )
#			    ifdef FILE_FLAG_POSIX_SEMANTICS
				return (DWORD)FILE_FLAG_POSIX_SEMANTICS;
#			    else
				goto not_there;
#			    endif
			break;
		    case 'R':
			if(  strEQ(sName,"FILE_FLAG_RANDOM_ACCESS")  )
#			    ifdef FILE_FLAG_RANDOM_ACCESS
				return (DWORD)FILE_FLAG_RANDOM_ACCESS;
#			    else
				goto not_there;
#			    endif
			break;
		    case 'S':
			if(  strEQ(sName,"FILE_FLAG_SEQUENTIAL_SCAN")  )
#			    ifdef FILE_FLAG_SEQUENTIAL_SCAN
				return (DWORD)FILE_FLAG_SEQUENTIAL_SCAN;
#			    else
				goto not_there;
#			    endif
			break;
		    case 'W':
			if(  strEQ(sName,"FILE_FLAG_WRITE_THROUGH")  )
#			    ifdef FILE_FLAG_WRITE_THROUGH
				return (DWORD)FILE_FLAG_WRITE_THROUGH;
#			    else
				goto not_there;
#			    endif
			break;
		}
		break;
	    case 'G':
		if(  strEQ(sName,"FILE_GENERIC_EXECUTE")  )
#		    ifdef FILE_GENERIC_EXECUTE
			return (DWORD)FILE_GENERIC_EXECUTE;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FILE_GENERIC_READ")  )
#		    ifdef FILE_GENERIC_READ
			return (DWORD)FILE_GENERIC_READ;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FILE_GENERIC_WRITE")  )
#		    ifdef FILE_GENERIC_WRITE
			return (DWORD)FILE_GENERIC_WRITE;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'L':
		if(  strEQ(sName,"FILE_LIST_DIRECTORY")  )
#		    ifdef FILE_LIST_DIRECTORY
			return (DWORD)FILE_LIST_DIRECTORY;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'R':
		if(  strEQ(sName,"FILE_READ_DATA")  )
#		    ifdef FILE_READ_DATA
			return (DWORD)FILE_READ_DATA;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FILE_READ_EA")  )
#		    ifdef FILE_READ_EA
			return (DWORD)FILE_READ_EA;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FILE_READ_ATTRIBUTES")  )
#		    ifdef FILE_READ_ATTRIBUTES
			return (DWORD)FILE_READ_ATTRIBUTES;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'S':
		if(  strEQ(sName,"FILE_SHARE_DELETE")  )
#		    ifdef FILE_SHARE_DELETE
			return (DWORD)FILE_SHARE_DELETE;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FILE_SHARE_READ")  )
#		    ifdef FILE_SHARE_READ
			return (DWORD)FILE_SHARE_READ;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FILE_SHARE_WRITE")  )
#		    ifdef FILE_SHARE_WRITE
			return (DWORD)FILE_SHARE_WRITE;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'T':
		if(  strEQ(sName,"FILE_TRAVERSE")  )
#		    ifdef FILE_TRAVERSE
			return (DWORD)FILE_TRAVERSE;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FILE_TYPE_CHAR")  )
#		    ifdef FILE_TYPE_CHAR
			return (DWORD)FILE_TYPE_CHAR;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FILE_TYPE_DISK")  )
#		    ifdef FILE_TYPE_DISK
			return (DWORD)FILE_TYPE_DISK;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FILE_TYPE_PIPE")  )
#		    ifdef FILE_TYPE_PIPE
			return (DWORD)FILE_TYPE_PIPE;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FILE_TYPE_UNKNOWN")  )
#		    ifdef FILE_TYPE_UNKNOWN
			return (DWORD)FILE_TYPE_UNKNOWN;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'W':
		if(  strEQ(sName,"FILE_WRITE_ATTRIBUTES")  )
#		    ifdef FILE_WRITE_ATTRIBUTES
			return (DWORD)FILE_WRITE_ATTRIBUTES;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FILE_WRITE_DATA")  )
#		    ifdef FILE_WRITE_DATA
			return (DWORD)FILE_WRITE_DATA;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FILE_WRITE_EA")  )
#		    ifdef FILE_WRITE_EA
			return (DWORD)FILE_WRITE_EA;
#		    else
			goto not_there;
#		    endif
		break;
	    }
	    break;

	case 'A':
	    if(  strEQ(sName,"FS_CASE_IS_PRESERVED")  )
#		ifdef FS_CASE_IS_PRESERVED
		    return (DWORD)FS_CASE_IS_PRESERVED;
#		else
		    goto not_there;
#		endif
	    if(  strEQ(sName,"FS_CASE_SENSITIVE")  )
#		ifdef FS_CASE_SENSITIVE
		    return (DWORD)FS_CASE_SENSITIVE;
#		else
		    goto not_there;
#		endif
	    break;

	case 'C':
	    if(  strEQ(sName,"TRUNCATE_EXISTING")  )
#		ifdef TRUNCATE_EXISTING
		    return (DWORD)TRUNCATE_EXISTING;
#		else
		    goto not_there;
#		endif
	    break;

	case 'D':
	    if(  strEQ(sName,"VALID_NTFT")  )
#		ifdef VALID_NTFT
		    return (DWORD)VALID_NTFT;
#		else
		    goto not_there;
#		endif
	    break;

	case 'E':
	    if(  '\0' == sName[5]  ||  '\0' == sName[6]  )
		break;
	    switch(  sName[7]  ) {
	    case 'A':
		if(  strEQ(sName,"DRIVE_RAMDISK")  )
#		    ifdef DRIVE_RAMDISK
			return (DWORD)DRIVE_RAMDISK;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'C':
		if(  strEQ(sName,"DDD_EXACT_MATCH_ON_REMOVE")  )
#		    ifdef DDD_EXACT_MATCH_ON_REMOVE
			return (DWORD)DDD_EXACT_MATCH_ON_REMOVE;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'D':
		if(  strEQ(sName,"DRIVE_CDROM")  )
#		    ifdef DRIVE_CDROM
			return (DWORD)DRIVE_CDROM;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'E':
		if(  strEQ(sName,"DRIVE_REMOVABLE")  )
#		    ifdef DRIVE_REMOVABLE
			return (DWORD)DRIVE_REMOVABLE;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"DRIVE_REMOTE")  )
#		    ifdef DRIVE_REMOTE
			return (DWORD)DRIVE_REMOTE;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'I':
		if(  strEQ(sName,"DRIVE_FIXED")  )
#		    ifdef DRIVE_FIXED
			return (DWORD)DRIVE_FIXED;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"FS_PERSISTENT_ACLS")  )
#		    ifdef FS_PERSISTENT_ACLS
			return (DWORD)FS_PERSISTENT_ACLS;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'N':
		if(  strEQ(sName,"DRIVE_UNKNOWN")  )
#		    ifdef DRIVE_UNKNOWN
			return (DWORD)DRIVE_UNKNOWN;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'O':
		if(  strEQ(sName,"DRIVE_NO_ROOT_DIR")  )
#		    ifdef DRIVE_NO_ROOT_DIR
			return (DWORD)DRIVE_NO_ROOT_DIR;
#		    else
			goto not_there;
#		    endif
		break;
	    }
	    break;

	case 'F':
	    if(  strEQ( sName, "MOVEFILE_COPY_ALLOWED" )  )
#		ifdef MOVEFILE_COPY_ALLOWED
		    return (DWORD)MOVEFILE_COPY_ALLOWED;
#		else
		    goto not_there;
#		endif
	    if(  strEQ( sName, "MOVEFILE_DELAY_UNTIL_REBOOT" )  )
#		ifdef MOVEFILE_DELAY_UNTIL_REBOOT
		    return (DWORD)MOVEFILE_DELAY_UNTIL_REBOOT;
#		else
		    goto not_there;
#		endif
	    if(  strEQ( sName, "MOVEFILE_REPLACE_EXISTING" )  )
#		ifdef MOVEFILE_REPLACE_EXISTING
		    return (DWORD)MOVEFILE_REPLACE_EXISTING;
#		else
		    goto not_there;
#		endif
	    if(  strEQ( sName, "MOVEFILE_WRITE_THROUGH" )  )
#		ifdef MOVEFILE_WRITE_THROUGH
		    return (DWORD)MOVEFILE_WRITE_THROUGH;
#		else
		    goto not_there;
#		endif
	    if(  strEQ( sName, "SEM_FAILCRITICALERRORS" )  )
#		ifdef SEM_FAILCRITICALERRORS
		    return (DWORD)SEM_FAILCRITICALERRORS;
#		else
		    goto not_there;
#		endif
	    break;

	case 'I':
	    if(  '\0' == sName[5]  ||  '\0' == sName[6]
	     ||  '\0' == sName[7]  ||  '\0' == sName[8]
	     ||  '\0' == sName[9]  ||  '\0' == sName[10]  )
		break;
	    switch(  sName[11]  ) {
	    case 'A':
		if(  strEQ( sName, "PARTITION_FAT_12" )  )
#		    ifdef PARTITION_FAT_12
			return (DWORD)PARTITION_FAT_12;
#		    else
			goto not_there;
#		    endif
		if(  strEQ( sName, "PARTITION_FAT_16" )  )
#		    ifdef PARTITION_FAT_16
			return (DWORD)PARTITION_FAT_16;
#		    else
			goto not_there;
#		    endif
		if(  strEQ( sName, "PARTITION_FAT32" )  )
#		    ifdef PARTITION_FAT32
			return (DWORD)PARTITION_FAT32;
#		    else
			goto not_there;
#		    endif
		if(  strEQ( sName, "PARTITION_FAT32_XINT13" )  )
#		    ifdef PARTITION_FAT32_XINT13
			return (DWORD)PARTITION_FAT32_XINT13;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'E':
		if(  strEQ( sName, "PARTITION_XENIX_1" )  )
#		    ifdef PARTITION_XENIX_1
			return (DWORD)PARTITION_XENIX_1;
#		    else
			goto not_there;
#		    endif
		if(  strEQ( sName, "PARTITION_XENIX_2" )  )
#		    ifdef PARTITION_XENIX_2
			return (DWORD)PARTITION_XENIX_2;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'F':
		if(  strEQ( sName, "PARTITION_IFS" )  )
#		    ifdef PARTITION_IFS
			return (DWORD)PARTITION_IFS;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'I':
		if(  strEQ( sName, "PARTITION_XINT13" )  )
#		    ifdef PARTITION_XINT13
			return (DWORD)PARTITION_XINT13;
#		    else
			goto not_there;
#		    endif
		if(  strEQ( sName, "PARTITION_XINT13_EXTENDED" )  )
#		    ifdef PARTITION_XINT13_EXTENDED
			return (DWORD)PARTITION_XINT13_EXTENDED;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'N':
		if(  strEQ( sName, "PARTITION_ENTRY_UNUSED" )  )
#		    ifdef PARTITION_ENTRY_UNUSED
			return (DWORD)PARTITION_ENTRY_UNUSED;
#		    else
			goto not_there;
#		    endif
		if(  strEQ( sName, "PARTITION_UNIX" )  )
#		    ifdef PARTITION_UNIX
			return (DWORD)PARTITION_UNIX;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'P':
		if(  strEQ( sName, "FS_FILE_COMPRESSION" )  )
#		    ifdef FS_FILE_COMPRESSION
			return (DWORD)FS_FILE_COMPRESSION;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'R':
		if(  strEQ( sName, "PARTITION_PREP" )  )
#		    ifdef PARTITION_PREP
			return (DWORD)PARTITION_PREP;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'T':
		if(  strEQ( sName, "PARTITION_NTFT" )  )
#		    ifdef PARTITION_NTFT
			return (DWORD)PARTITION_NTFT;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'U':
		if(  strEQ( sName, "PARTITION_HUGE" )  )
#		    ifdef PARTITION_HUGE
			return (DWORD)PARTITION_HUGE;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'X':
		if(  strEQ( sName, "PARTITION_EXTENDED" )  )
#		    ifdef PARTITION_EXTENDED
			return (DWORD)PARTITION_EXTENDED;
#		    else
			goto not_there;
#		    endif
		break;
	    }
	    break;

	case 'L':
	    if(  '\0' == sName[5]  ||  '\0' == sName[6]  ||  '\0' == sName[7]
	     ||  '\0' == sName[8]  ||  '\0' == sName[9]  ||  '\0' == sName[10]
	     ||  '\0' == sName[11] ||  '\0' == sName[12] ||  '\0' == sName[13]
	     ||  '\0' == sName[14]  )
		break;
	    switch(  sName[15]  ) {
	    case 'A':
		if(  strEQ(sName,"IOCTL_DISK_FORMAT_TRACKS")  )
#		    ifdef IOCTL_DISK_FORMAT_TRACKS
			return (DWORD)IOCTL_DISK_FORMAT_TRACKS;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"IOCTL_DISK_FORMAT_TRACKS_EX")  )
#		    ifdef IOCTL_DISK_FORMAT_TRACKS_EX
			return (DWORD)IOCTL_DISK_FORMAT_TRACKS_EX;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'D':
		if(  strEQ(sName,"IOCTL_DISK_GET_DRIVE_GEOMETRY")  )
#		    ifdef IOCTL_DISK_GET_DRIVE_GEOMETRY
			return (DWORD)IOCTL_DISK_GET_DRIVE_GEOMETRY;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"IOCTL_DISK_GET_DRIVE_LAYOUT")  )
#		    ifdef IOCTL_DISK_GET_DRIVE_LAYOUT
			return (DWORD)IOCTL_DISK_GET_DRIVE_LAYOUT;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"IOCTL_DISK_SET_DRIVE_LAYOUT")  )
#		    ifdef IOCTL_DISK_SET_DRIVE_LAYOUT
			return (DWORD)IOCTL_DISK_SET_DRIVE_LAYOUT;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'E':
		if(  strEQ(sName,"IOCTL_DISK_REQUEST_DATA")  )
#		    ifdef IOCTL_DISK_REQUEST_DATA
			return (DWORD)IOCTL_DISK_REQUEST_DATA;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"IOCTL_DISK_REQUEST_STRUCTURE")  )
#		    ifdef IOCTL_DISK_REQUEST_STRUCTURE
			return (DWORD)IOCTL_DISK_REQUEST_STRUCTURE;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"IOCTL_STORAGE_GET_MEDIA_TYPES")  )
#		    ifdef IOCTL_STORAGE_GET_MEDIA_TYPES
			return (DWORD)IOCTL_STORAGE_GET_MEDIA_TYPES;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"IOCTL_STORAGE_MEDIA_REMOVAL")  )
#		    ifdef IOCTL_STORAGE_MEDIA_REMOVAL
			return (DWORD)IOCTL_STORAGE_MEDIA_REMOVAL;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"IOCTL_STORAGE_RESERVE")  )
#		    ifdef IOCTL_STORAGE_RESERVE
			return (DWORD)IOCTL_STORAGE_RESERVE;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"IOCTL_STORAGE_RELEASE")  )
#		    ifdef IOCTL_STORAGE_RELEASE
			return (DWORD)IOCTL_STORAGE_RELEASE;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'F':
		if(  strEQ(sName,"IOCTL_DISK_VERIFY")  )
#		    ifdef IOCTL_DISK_VERIFY
			return (DWORD)IOCTL_DISK_VERIFY;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'H':
		if(  strEQ(sName,"IOCTL_STORAGE_CHECK_VERIFY")  )
#		    ifdef IOCTL_STORAGE_CHECK_VERIFY
			return (DWORD)IOCTL_STORAGE_CHECK_VERIFY;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'I':
		if(  strEQ(sName,"IOCTL_DISK_LOGGING")  )
#		    ifdef IOCTL_DISK_LOGGING
			return (DWORD)IOCTL_DISK_LOGGING;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"IOCTL_STORAGE_FIND_NEW_DEVICES")  )
#		    ifdef IOCTL_STORAGE_FIND_NEW_DEVICES
			return (DWORD)IOCTL_STORAGE_FIND_NEW_DEVICES;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'J':
		if(  strEQ(sName,"IOCTL_STORAGE_EJECT_MEDIA")  )
#		    ifdef IOCTL_STORAGE_EJECT_MEDIA
			return (DWORD)IOCTL_STORAGE_EJECT_MEDIA;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'O':
		if(  strEQ(sName,"IOCTL_DISK_HISTOGRAM_DATA")  )
#		    ifdef IOCTL_DISK_HISTOGRAM_DATA
			return (DWORD)IOCTL_DISK_HISTOGRAM_DATA;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"IOCTL_DISK_HISTOGRAM_RESET")  )
#		    ifdef IOCTL_DISK_HISTOGRAM_RESET
			return (DWORD)IOCTL_DISK_HISTOGRAM_RESET;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"IOCTL_DISK_HISTOGRAM_STRUCTURE")  )
#		    ifdef IOCTL_DISK_HISTOGRAM_STRUCTURE
			return (DWORD)IOCTL_DISK_HISTOGRAM_STRUCTURE;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"IOCTL_DISK_PERFORMANCE")  )
#		    ifdef IOCTL_DISK_PERFORMANCE
			return (DWORD)IOCTL_DISK_PERFORMANCE;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"IOCTL_STORAGE_LOAD_MEDIA")  )
#		    ifdef IOCTL_STORAGE_LOAD_MEDIA
			return (DWORD)IOCTL_STORAGE_LOAD_MEDIA;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'P':
		if(  strEQ(sName,"IOCTL_DISK_GET_PARTITION_INFO")  )
#		    ifdef IOCTL_DISK_GET_PARTITION_INFO
			return (DWORD)IOCTL_DISK_GET_PARTITION_INFO;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"IOCTL_DISK_SET_PARTITION_INFO")  )
#		    ifdef IOCTL_DISK_SET_PARTITION_INFO
			return (DWORD)IOCTL_DISK_SET_PARTITION_INFO;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'R':
		if(  strEQ(sName,"IOCTL_DISK_IS_WRITABLE")  )
#		    ifdef IOCTL_DISK_IS_WRITABLE
			return (DWORD)IOCTL_DISK_IS_WRITABLE;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'S':
		if(  strEQ(sName,"IOCTL_DISK_REASSIGN_BLOCKS")  )
#		    ifdef IOCTL_DISK_REASSIGN_BLOCKS
			return (DWORD)IOCTL_DISK_REASSIGN_BLOCKS;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'V':
		if(  strEQ(sName,"INVALID_HANDLE_VALUE")  )
#		    ifdef INVALID_HANDLE_VALUE
			return (DWORD)INVALID_HANDLE_VALUE;
#		    else
			goto not_there;
#		    endif
		break;
	    }
	    break;
	
	case 'N':
	    if(  strEQ(sName,"FS_UNICODE_STORED_ON_DISK")  )
#		ifdef FS_UNICODE_STORED_ON_DISK
		    return (DWORD)FS_UNICODE_STORED_ON_DISK;
#		else
		    goto not_there;
#		endif
	    if(  strEQ(sName,"SEM_NOGPFAULTERRORBOX")  )
#		ifdef SEM_NOGPFAULTERRORBOX
		    return (DWORD)SEM_NOGPFAULTERRORBOX;
#		else
		    goto not_there;
#		endif
	    if(  strEQ(sName,"SEM_NOALIGNMENTFAULTEXCEPT")  )
#		ifdef SEM_NOALIGNMENTFAULTEXCEPT
		    return (DWORD)SEM_NOALIGNMENTFAULTEXCEPT;
#		else
		    goto not_there;
#		endif
	    if(  strEQ(sName,"SEM_NOOPENFILEERRORBOX")  )
#		ifdef SEM_NOOPENFILEERRORBOX
		    return (DWORD)SEM_NOOPENFILEERRORBOX;
#		else
		    goto not_there;
#		endif
	    break;

	case 'O':
	    if(  strEQ(sName,"FS_VOL_IS_COMPRESSED")  )
#		ifdef FS_VOL_IS_COMPRESSED
		    return (DWORD)FS_VOL_IS_COMPRESSED;
#		else
		    goto not_there;
#		endif
	    break;

	case 'P':
	    if(  strEQ(sName,"F5_1Pt2_512")  )
		return (DWORD)F5_1Pt2_512;
	    if(  strEQ(sName,"F3_1Pt44_512")  )
		return (DWORD)F3_1Pt44_512;
	    if(  strEQ(sName,"F3_2Pt88_512")  )
		return (DWORD)F3_2Pt88_512;
	    break;

	case 'R':
	    switch( sName[0] ) {
	    case 'D':
		if(  strEQ(sName,"DDD_RAW_TARGET_PATH")  )
#		    ifdef DDD_RAW_TARGET_PATH
			return (DWORD)DDD_RAW_TARGET_PATH;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"DDD_REMOVE_DEFINITION")  )
#		    ifdef DDD_REMOVE_DEFINITION
			return (DWORD)DDD_REMOVE_DEFINITION;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'G':
		if(  strEQ(sName,"GENERIC_ALL")  )
#		    ifdef GENERIC_ALL
			return (DWORD)GENERIC_ALL;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"GENERIC_EXECUTE")  )
#		    ifdef GENERIC_EXECUTE
			return (DWORD)GENERIC_EXECUTE;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"GENERIC_READ")  )
#		    ifdef GENERIC_READ
			return (DWORD)GENERIC_READ;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"GENERIC_WRITE")  )
#		    ifdef GENERIC_WRITE
			return (DWORD)GENERIC_WRITE;
#		    else
			goto not_there;
#		    endif
		break;
	    case 'S':
		if(  strEQ(sName,"SECURITY_ANONYMOUS")  )
#		    ifdef SECURITY_ANONYMOUS
			return (DWORD)SECURITY_ANONYMOUS;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"SECURITY_IDENTIFICATION")  )
#		    ifdef SECURITY_IDENTIFICATION
			return (DWORD)SECURITY_IDENTIFICATION;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"SECURITY_IMPERSONATION")  )
#		    ifdef SECURITY_IMPERSONATION
			return (DWORD)SECURITY_IMPERSONATION;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"SECURITY_DELEGATION")  )
#		    ifdef SECURITY_DELEGATION
			return (DWORD)SECURITY_DELEGATION;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"SECURITY_CONTEXT_TRACKING")  )
#		    ifdef SECURITY_CONTEXT_TRACKING
			return (DWORD)SECURITY_CONTEXT_TRACKING;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"SECURITY_EFFECTIVE_ONLY")  )
#		    ifdef SECURITY_EFFECTIVE_ONLY
			return (DWORD)SECURITY_EFFECTIVE_ONLY;
#		    else
			goto not_there;
#		    endif
		if(  strEQ(sName,"SECURITY_SQOS_PRESENT")  )
#		    ifdef SECURITY_SQOS_PRESENT
			return (DWORD)SECURITY_SQOS_PRESENT;
#		    else
			goto not_there;
#		    endif
		break;
	    }
	    break;

	case 'T':
	    if(  strEQ(sName,"CREATE_NEW")  )
#		ifdef CREATE_NEW
		    return (DWORD)CREATE_NEW;
#		else
		    goto not_there;
#		endif
	    if(  strEQ(sName,"CREATE_ALWAYS")  )
#		ifdef CREATE_ALWAYS
		    return (DWORD)CREATE_ALWAYS;
#		else
		    goto not_there;
#		endif
	    break;

    }
    errno = EINVAL;
    return 0;
not_there:
    errno = ENOENT;
    return 0;
}

#include "buffers.h"

MODULE = Win32API::File		PACKAGE = Win32API::File

PROTOTYPES: DISABLE


DWORD
constant( sName, ivArg=0 )
	char *	sName
	int	ivArg


BOOL
CloseHandle( hObject )
	HANDLE	hObject


BOOL
CopyFileA( sOldFileName, sNewFileName, bFailIfExists )
	char *	sOldFileName
	char *	sNewFileName
	BOOL	bFailIfExists


BOOL
CopyFileW( swOldFileName, swNewFileName, bFailIfExists )
	WCHAR *	swOldFileName
	WCHAR *	swNewFileName
	BOOL	bFailIfExists


HANDLE
CreateFileA( sPath, uAccess, uShare, pSecAttr, uCreate, uFlags, hModel )
	char *	sPath
	DWORD	uAccess
	DWORD	uShare
	void *	pSecAttr
	DWORD	uCreate
	DWORD	uFlags
	HANDLE	hModel
    CODE:
	RETVAL= CreateFileA( sPath, uAccess, uShare,
	  pSecAttr, uCreate, uFlags, hModel );
	if(  INVALID_HANDLE_VALUE == RETVAL  )
	    XSRETURN_NO;
	if(  0 == RETVAL  )
	    XSRETURN_PV( "0 but true" );
	if(  (IV) RETVAL < 0  )
	    XSRETURN_NV( (double) (IV) RETVAL );
	XSRETURN_IV( (IV) RETVAL );


HANDLE
CreateFileW( swPath, uAccess, uShare, pSecAttr, uCreate, uFlags, hModel )
	WCHAR *	swPath
	DWORD	uAccess
	DWORD	uShare
	void *	pSecAttr
	DWORD	uCreate
	DWORD	uFlags
	HANDLE	hModel
    CODE:
	RETVAL= CreateFileW( swPath, uAccess, uShare,
	  pSecAttr, uCreate, uFlags, hModel );
	if(  INVALID_HANDLE_VALUE == RETVAL  )
	    XSRETURN_NO;
	if(  0 == RETVAL  )
	    XSRETURN_PV( "0 but true" );
	if(  (IV) RETVAL < 0  )
	    XSRETURN_NV( (double) (IV) RETVAL );
	XSRETURN_IV( (IV) RETVAL );


BOOL
DefineDosDeviceA( uFlags, sDosDeviceName, sTargetPath )
	DWORD	uFlags
	char *	sDosDeviceName
	char *	sTargetPath


BOOL
DefineDosDeviceW( uFlags, swDosDeviceName, swTargetPath )
	DWORD	uFlags
	WCHAR *	swDosDeviceName
	WCHAR *	swTargetPath


BOOL
DeleteFileA( sFileName )
	char *	sFileName


BOOL
DeleteFileW( swFileName )
	WCHAR *	swFileName


BOOL
DeviceIoControl( hDevice, uIoControlCode, pInBuf, lInBuf, opOutBuf, lOutBuf, olRetBytes, pOverlapped )
	HANDLE	hDevice
	DWORD	uIoControlCode
	char *	pInBuf
	DWORD	lInBuf		= init_buf_l($arg);
	char *	opOutBuf	= NULL;
	DWORD	lOutBuf		= init_buf_l($arg);
	DWORD	&olRetBytes	= optUV($arg);
	void *	pOverlapped
    INIT:
	if(  NULL != pInBuf  ) {
	    if(  0 == lInBuf  ) {
		lInBuf= SvCUR(ST(2));
	    } else if(  SvCUR(ST(2)) < lInBuf  ) {
		croak( "%s: pInBuf shorter than specified (%d < %d)",
		  "Win32API::File::DeviceIoControl", SvCUR(ST(2)), lInBuf );
	    }
	}
	grow_buf_l( opOutBuf,ST(4), lOutBuf,ST(5) );
    OUTPUT:
	RETVAL
	opOutBuf	trunc_buf_l( RETVAL, opOutBuf,ST(4), olRetBytes );
	olRetBytes


HANDLE
FdGetOsFHandle( ivFd )
	int	ivFd
    CODE:
	RETVAL= (HANDLE) win32_get_osfhandle( ivFd );
    OUTPUT:
	RETVAL


DWORD
GetDriveTypeA( sRootPath )
	char *	sRootPath


DWORD
GetDriveTypeW( swRootPath )
	WCHAR *	swRootPath


DWORD
GetFileType( hFile )
	HANDLE	hFile


DWORD
GetLogicalDrives()


DWORD
GetLogicalDriveStringsA( lBufSize, osBuffer )
	DWORD	lBufSize	= init_buf_l($arg);
	char *	osBuffer	= NULL;
    INIT:
	grow_buf_l( osBuffer,ST(1), lBufSize,ST(0) );
    OUTPUT:
	RETVAL
	osBuffer	trunc_buf_l( 1, osBuffer,ST(1), RETVAL );


DWORD
GetLogicalDriveStringsW( lwBufSize, oswBuffer )
	DWORD	lwBufSize	= init_buf_lw($arg);
	WCHAR *	oswBuffer	= NULL;
    INIT:
	grow_buf_lw( oswBuffer,ST(1), lwBufSize,ST(0) );
    OUTPUT:
	RETVAL
	oswBuffer	trunc_buf_lw( 1, oswBuffer,ST(1), RETVAL );


BOOL
GetVolumeInformationA( sRootPath, osVolName, lVolName, ouSerialNum, ouMaxNameLen, ouFsFlags, osFsType, lFsType )
	char *	sRootPath
	char *	osVolName	= NULL;
	DWORD	lVolName	= init_buf_l($arg);
	DWORD	&ouSerialNum	= optUV($arg);
	DWORD	&ouMaxNameLen	= optUV($arg);
	DWORD	&ouFsFlags	= optUV($arg);
	char *	osFsType	= NULL;
	DWORD	lFsType		= init_buf_l($arg);
    INIT:
	grow_buf_l( osVolName,ST(1), lVolName,ST(2) );
	grow_buf_l( osFsType,ST(6), lFsType,ST(7) );
    OUTPUT:
	RETVAL
	osVolName	trunc_buf_z( RETVAL, osVolName,ST(1) );
	osFsType	trunc_buf_z( RETVAL, osFsType,ST(6) );
	ouSerialNum
	ouMaxNameLen
	ouFsFlags


BOOL
GetVolumeInformationW( swRootPath, oswVolName, lwVolName, ouSerialNum, ouMaxNameLen, ouFsFlags, oswFsType, lwFsType )
	WCHAR *	swRootPath
	WCHAR *	oswVolName	= NULL;
	DWORD	lwVolName	= init_buf_lw($arg);
	DWORD	&ouSerialNum	= optUV($arg);
	DWORD	&ouMaxNameLen	= optUV($arg);
	DWORD	&ouFsFlags	= optUV($arg);
	WCHAR *	oswFsType	= NULL;
	DWORD	lwFsType	= init_buf_lw($arg);
    INIT:
	grow_buf_lw( oswVolName,ST(1), lwVolName,ST(2) );
	grow_buf_lw( oswFsType,ST(6), lwFsType,ST(7) );
    OUTPUT:
	RETVAL
	oswVolName	trunc_buf_zw( RETVAL, oswVolName,ST(1) );
	oswFsType	trunc_buf_zw( RETVAL, oswFsType,ST(6) );
	ouSerialNum
	ouMaxNameLen
	ouFsFlags


BOOL
IsRecognizedPartition( ivPartitionType )
	int	ivPartitionType


BOOL
IsContainerPartition( ivPartitionType )
	int	ivPartitionType


BOOL
MoveFileA( sOldName, sNewName )
	char *	sOldName
	char *	sNewName


BOOL
MoveFileW( swOldName, swNewName )
	WCHAR *	swOldName
	WCHAR *	swNewName


BOOL
MoveFileExA( sOldName, sNewName, uFlags )
	char *	sOldName
	char *	sNewName
	DWORD	uFlags


BOOL
MoveFileExW( swOldName, swNewName, uFlags )
	WCHAR *	swOldName
	WCHAR *	swNewName
	DWORD	uFlags


long
OsFHandleOpenFd( hOsFHandle, uMode )
	long	hOsFHandle
	DWORD	uMode
    CODE:
	RETVAL= win32_open_osfhandle( hOsFHandle, uMode );
	if(  RETVAL < 0  )
	    XSRETURN_NO;
	if(  0 == RETVAL  )
	    XSRETURN_PV( "0 but true" );
	XSRETURN_IV( (IV) RETVAL );


DWORD
QueryDosDeviceA( sDeviceName, osTargetPath, lTargetBuf )
	char *	sDeviceName
	char *	osTargetPath	= NULL;
	DWORD	lTargetBuf	= init_buf_l($arg);
    INIT:
	grow_buf_l( osTargetPath,ST(1), lTargetBuf,ST(2) );
    OUTPUT:
	RETVAL
	osTargetPath	trunc_buf_l( 1, osTargetPath,ST(1), RETVAL );


DWORD
QueryDosDeviceW( swDeviceName, oswTargetPath, lwTargetBuf )
	WCHAR *	swDeviceName
	WCHAR *	oswTargetPath	= NULL;
	DWORD	lwTargetBuf	= init_buf_lw($arg);
    INIT:
	grow_buf_lw( oswTargetPath,ST(1), lwTargetBuf,ST(2) );
    OUTPUT:
	RETVAL
	oswTargetPath	trunc_buf_lw( 1, oswTargetPath,ST(1), RETVAL );


BOOL
ReadFile( hFile, opBuffer, lBytes, olBytesRead, pOverlapped )
	HANDLE	hFile
	BYTE *	opBuffer	= NULL;
	DWORD	lBytes		= init_buf_l($arg);
	DWORD	&olBytesRead	= optUV($arg);
	void *	pOverlapped
    INIT:
	grow_buf_l( opBuffer,ST(1), lBytes,ST(2) );
	/* Don't read more bytes than asked for if buffer is already big: */
	if(  0 == ( lBytes= init_buf_l(ST(2)) )  &&  autosize(ST(2))  ) {
	    lBytes= SvLEN( ST(1) ) - 1;
	}
    OUTPUT:
	RETVAL
	opBuffer	trunc_buf_l( RETVAL, opBuffer,ST(1), olBytesRead );
	olBytesRead


UINT
SetErrorMode( uNewMode )
	UINT	uNewMode


LONG
SetFilePointer( hFile, ivOffset, ioivOffsetHigh, uFromWhere )
	HANDLE	hFile
	LONG	ivOffset
	LONG	&ioivOffsetHigh
	DWORD	uFromWhere
    CODE:
	RETVAL= SetFilePointer( hFile, ivOffset, &ioivOffsetHigh, uFromWhere );
	if(  ~0 == RETVAL  )
	    XST_mNO(0);
	else if(  0 == RETVAL  )
	    XST_mPV(0,"0 but true");
	else
	    XST_mIV(0,RETVAL);
    OUTPUT:
	ioivOffsetHigh


BOOL
WriteFile( hFile, pBuffer, lBytes, ouBytesWritten, pOverlapped )
	HANDLE	hFile
	BYTE *	pBuffer
	DWORD	lBytes		= init_buf_l($arg);
	DWORD	&ouBytesWritten	= optUV($arg);
	void *	pOverlapped
    INIT:
	if(  0 == lBytes  ) {
	    lBytes= SvCUR(ST(1));
	} else if(  SvCUR(ST(1)) < lBytes  ) {
	    croak( "%s: pBuffer value too short (%d < %d)",
	      "Win32API::File::WriteFile", SvCUR(ST(1)), lBytes );
	}
    OUTPUT:
	RETVAL
	ouBytesWritten
