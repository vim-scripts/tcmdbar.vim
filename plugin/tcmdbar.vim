" Vim script for use with Total Commander's button bar.  It creates an
" argument list from all selected files and edits them.
"
" File:	    	tcmdbar.vim
" Last Change:	2007 Jan 28
" Author:	Andy Wokula <anwoku@yahoo.de>
" Version:	5
" Vim Version:	gVim 6.4 (only tested on gVim 7.0)
" OS:		Win32 only (maybe Win16)
"
" Thanks To:	Florian Trippel for reporting bugs.

" Installation:
" 1. Put this file in any directory (example: ~\vimfiles)
"    Note: This is not a plugin.
"
" 2. Create a new button for GVim in Total Commander's button bar.
"    (Example) Dialog for this:
"
"    Change button bar
"    Command:	 <path>\gvim.exe -S ~\vimfiles\tcmdbar.vim
"    Parameters: %L dummy
"    Start Path:
"    ...
"    Tooltip:	 Click to edit selected files or drag&drop a file
"
"    The "dummy" argument is a required dummy file name, its name is fixed.
"    You should not run into problems if this is an existing file.
"
"    From Totalcmd's help (in my words):
"     %L creates a list file in the TEMP-directory containing the names of
"        all selected files and folders.  The name of the list file is added
"        to the command line.  The list file is deleted after exiting the
"        program.  The created list contains long file names including full
"        path.
"
" Usage:
" The button can be used in the following ways:
"
" (1) Select one or more files and click the GVim-Button:
"     GVim starts up, loads the argument temp file (created by TC) and
"     sources this script to create an argument list.  Directories (ending
"     in a backslash) are silently removed from the list.  The temp file is
"     removed from the buffer list and the first argument is shown in a
"     buffer.  If only directories were selected an empty buffer is created.
"     Added: Will work with a flattened filelist (Totalcmd: Ctrl-B),
"     therefore the %P argument is needed.
"
" (2) Drag&Drop a file onto the GVim-Button:
"     GVim loads the file argument the usual way.  If it is a directory, the
"     file explorer (GVim6) or the netrw plugin (GVim7) starts up
"     automatically (if plugins are not disabled).
"
" (3) To not load any file, first select the ".." directory and click the
"     GVim button.
" --------------------------------------------------------------------------

" We must know whether a file argument is a Total Commander file list or
" not.  In fact this is easy (?!): use the number of arguments for decision.

" zero arguments: only ".." is selected in TC
" one argument: drag&drop - always one file
if argc() < 2
    finish
endif

let s:cpo_save = &cpo
set cpo&vim
let s:spat_save = @/
let s:lz_save = &lazyredraw
set lazyredraw
let s:gd_save = &gdefault
set nogdefault

" two arguments:
" delete the second (dummy) argument
2argdelete

" delete the dummy buffer (maybe not number 2 in the buffer list):
bwipeout! ^dummy$

" the one remaining argument is the file list created by Total Commander

" remove directories from the list:
silent global/[\\/]\s*$/delete

if getline(1)!=""
    " at least one selected file

    " use Vim's current working dir to later remove the leading paths in the
    " file list (somewhat critical, but I see no reason why they shouldn't
    " match)
    let s:cdl = strlen(substitute(getcwd(),'[\\/]\s*$','','')) + 1
    " in the root dir, getcwd() adds a backslash (e.g. 'C:\')

    " remove the path name from all buffer lines:
    silent global/./call setline(line("."), strpart(getline("."), s:cdl))

    unlet s:cdl

    " end of shortening the arglist

    " escape spaces in the filename ('gd' must be off)
    silent %s/ /\\ /ge

    " create pre-arglist
    %join
    let s:arglist = getline(1)

    setlocal nomodified

    " define new argument list:
    execute "args" s:arglist

    " quit from file list buffer:
    bwipeout! #
    " wiping afterwards avoids creation of another empty buffer

    " save memory:
    unlet s:arglist
else
    " no files selected, only directories
    bwipeout!
    " ?: howto clear the command line?
    exe "norm! \<c-g>"
endif

let @/ = s:spat_save
unlet s:spat_save
nohlsearch
let &cpo = s:cpo_save
unlet s:cpo_save
let &lazyredraw = s:lz_save
unlet s:lz_save
let &gdefault = s:gd_save
unlet s:gd_save

if exists("Tcmdbar_OpenInTabs")
    argdelete *
    tab sball
    tabnext 1
endif

" vim:set ts=8:
