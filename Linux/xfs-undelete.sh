#!/usr/bin/tclsh
##
## Copyright (c) 2019 Jan Kandziora <jjj@gmx.de>
##
## This source code is licensed under the GNU General Public License,
## Version 3. See the file COPYING for more details.
##

## Load packages.
package require cmdline

## Parse command line options.
if {[catch {set parameters [cmdline::getoptions argv {
        {o.arg xfs_undeleted "target directory for recovered files"}
        {s.arg 0 "start block"}
} {[options] -- options are:}]} result]} {
        puts stderr $result
        exit 127
}

## Get filesystem to scan from command line.
set fs [lindex $argv 0]

## Remount the target filesystem read-only if mounted.
catch {exec -ignorestderr -- mount 2>/dev/null -oremount,ro $fs}

## Create lost+found directory if nonexistent.
file mkdir [dict get $::parameters o]

## Defaults.
set blocksize 4096
set inodesize  512
set agblocks  1024
set agblklog    10
set dblocks   4096

## Get real xfs configuration from filesytem.
if {[catch {exec -ignorestderr -- xfs_db -r -c "sb 0" -c "p" $fs} config]} {
        exit 1
}
foreach line [split $config \n] {
        lassign $line key dummy value
        if {$key in {blocksize inodesize agblocks agblklog dblocks}} {
                set $key $value
        }
}

## Open filesystem image for binary reading.
set fd [open $fs r]
fconfigure $fd -translation binary

## Seek to start block.
seek $fd [expr {$blocksize*[dict get $::parameters s]}]

## Get message format.
set m1format "Checking block %[string length $dblocks]d/%[string length $dblocks]d  (%5.1f%%)\r"

## Run through whole filesystem.
for {set block [dict get $::parameters s]} {$block<$dblocks} {incr block} {
        ## Log each visited block.
        puts -nonewline stderr [format $m1format $block $dblocks [expr {100*$block/double($dblocks)}]]

        ## Read the block.
        set data [read $fd $blocksize]

        ## Run through all potential inodes in a block.
        for {set boffset 0} {$boffset<$blocksize} {incr boffset $inodesize} {
                ## Check for the magic string of an unused/deleted inode.
                if {[string range $data $boffset $boffset+7] eq "IN\0\0\3\2\0\0"} {
                        ## Found. Get inode number.
                        binary scan [string range $data $boffset+152 $boffset+159] W inode

                        ## Get output filename.
                        set of [file join [dict get $::parameters o] $inode]

                        ## Recover any extents found.
                        set recovered 0
                        for {set ioffset 176} {$ioffset<$inodesize} {incr ioffset 16} {
                                ## Get extent.
                                set extent [string range $data $boffset+$ioffset [expr {$boffset+$ioffset+15}]]

                                ## Ignore unused extents.
                                if {$extent eq "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"} continue

                                ## Get data blocks from extent.
                                binary scan $extent B* extbits
                                set flag    [expr 0b[string index $extbits 0]]
                                set loffset [expr 0b[string range $extbits 1 54]]
                                set ag      [expr 0b[string range $extbits 55 106-$agblklog]]
                                set ablock  [expr 0b[string range $extbits 107-$agblklog 106]]
                                set count   [expr 0b[string range $extbits 107 127]]
                                set skip    [expr {$ag*$agblocks+$ablock}]

                                ## Ignore preallocated, unwritten extents.
                                if {$flag} continue

                                ## Ignore extents beyond the filesystem.
                                if {($skip+$count)>=$dblocks} continue

                                ## Recover the data from this extent.
                                exec -ignorestderr -- dd 2>/dev/null if=$fs of=$of bs=$blocksize skip=$skip seek=$loffset count=$count

                                ## Remember there was at least one recovered extent.
                                set recovered 1
                        }

                        ## Log if we had at least one recovered extent.
                        if {$recovered} {
                                puts stderr "\nRecovered deleted inode $inode."
                        }
                }
        }
}

## Done.
puts stderr "\nDone."
