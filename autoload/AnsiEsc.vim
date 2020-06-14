" AnsiEsc.vim: Uses vim 7.0 syntax highlighting
" Language:		Text with ansi escape sequences
" Maintainer:	Charles E. Campbell <NdrOchipS@PcampbellAfamily.Mbiz>
" Version:		13s	ASTRO-ONLY
" Date:		May 01, 2019
"
" Usage: :AnsiEsc  (toggles)
" Note:   This plugin requires +conceal
"
" GetLatestVimScripts: 302 1 :AutoInstall: AnsiEsc.vim
"redraw!|call DechoSep()|call inputsave()|call input("Press <cr> to continue")|call inputrestore()
" ---------------------------------------------------------------------
"DechoRemOn
"  Load Once: {{{1
if exists("g:loaded_AnsiEsc")
 finish
endif
let g:loaded_AnsiEsc = "v13s"
if v:version < 700
 echohl WarningMsg
 echo "***warning*** this version of AnsiEsc needs vim 7.0"
 echohl Normal
 finish
endif
"DechoTabOn
let s:keepcpo= &cpo
set cpo&vim

" ---------------------------------------------------------------------
" AnsiEsc#AnsiEsc: toggles ansi-escape code visualization {{{2
fun! AnsiEsc#AnsiEsc(rebuild)
"  call Dfunc("AnsiEsc#AnsiEsc(rebuild=".a:rebuild.")")
  if a:rebuild
"   call Decho("rebuilding AnsiEsc tables")
   call AnsiEsc#AnsiEsc(0)   " toggle AnsiEsc off
   call AnsiEsc#AnsiEsc(0)   " toggle AnsiEsc back on
"   call Dret("AnsiEsc#AnsiEsc")
   return
  endif
  let bn= bufnr("%")
  if !exists("s:AnsiEsc_enabled_{bn}")
   let s:AnsiEsc_enabled_{bn}= 0
  endif
  if s:AnsiEsc_enabled_{bn}
   " disable AnsiEsc highlighting
"   call Decho("disable AnsiEsc highlighting: s:AnsiEsc_ft_".bn."<".s:AnsiEsc_ft_{bn}."> bn#".bn)
   if exists("g:colors_name")|let colorname= g:colors_name|endif
   if exists("s:conckeep_{bufnr('%')}")|let &l:conc= s:conckeep_{bufnr('%')}|unlet s:conckeep_{bufnr('%')}|endif
   if exists("s:colekeep_{bufnr('%')}")|let &l:cole= s:colekeep_{bufnr('%')}|unlet s:colekeep_{bufnr('%')}|endif
   if exists("s:cocukeep_{bufnr('%')}")|let &l:cocu= s:cocukeep_{bufnr('%')}|unlet s:cocukeep_{bufnr('%')}|endif
   hi! link ansiStop NONE
   syn clear
   hi  clear
   syn reset
   exe "set ft=".s:AnsiEsc_ft_{bn}
   if exists("colorname")|exe "colors ".colorname|endif
   let s:AnsiEsc_enabled_{bn}= 0
   if has("gui_running") && has("menu") && &go =~# 'm'
    " menu support
    exe 'silent! unmenu '.g:DrChipTopLvlMenu.'AnsiEsc'
    exe 'menu '.g:DrChipTopLvlMenu.'AnsiEsc.Start<tab>:AnsiEsc		:AnsiEsc<cr>'
   endif
   if !has('conceal')
    let &l:hl= s:hlkeep_{bufnr("%")}
   endif
"   call Dret("AnsiEsc#AnsiEsc")
   return
  else
   let s:AnsiEsc_ft_{bn}      = &ft
   let s:AnsiEsc_enabled_{bn} = 1
"   call Decho("enable AnsiEsc highlighting: s:AnsiEsc_ft_".bn."<".s:AnsiEsc_ft_{bn}."> bn#".bn)
   if has("gui_running") && has("menu") && &go =~# 'm'
    " menu support
    exe 'sil! unmenu '.g:DrChipTopLvlMenu.'AnsiEsc'
    exe 'menu '.g:DrChipTopLvlMenu.'AnsiEsc.Stop<tab>:AnsiEsc		:AnsiEsc<cr>'
   endif

   " -----------------
   "  Conceal Support: {{{2
   " -----------------
   if has("conceal")
    if v:version < 703
     if &l:conc != 3
      let s:conckeep_{bufnr('%')}= &cole
      setl conc=3
"      call Decho("setl l:conc=".&l:conc)
     endif
    else
     if &l:cole != 3 || &l:cocu != "nv"
      let s:colekeep_{bufnr('%')}= &l:cole
      let s:cocukeep_{bufnr('%')}= &l:cocu
      setl cole=3 cocu=nv
"      call Decho("setl l:cole=".&l:cole." l:cocu=".&l:cocu)
     endif
    endif
   endif
  endif

  " syn clear

  " suppress escaped sequences that don't involve colors (which may or may not be ansi-compliant)
  if has("conceal")
   syn match ansiSuppress	conceal	'\e\[[0-9;]*[^m]' containedin=TOP contained
   syn match ansiSuppress	conceal	'\e\[?\d*[^m]' containedin=TOP contained
   syn match ansiSuppress	conceal	'\b' containedin=TOP contained
   syn match ansiSuppress	conceal	'\e\[2[234]m' containedin=TOP contained
  else
   syn match ansiSuppress		'\e\[[0-9;]*[^m]' containedin=TOP contained
   syn match ansiSuppress		'\e\[?\d*[^m]' containedin=TOP contained
   syn match ansiSuppress		'\b' containedin=TOP contained
   syn match ansiSuppress		'\e\[2[234]m' containedin=TOP contained
  endif

  " ------------------------------
  " Ansi Escape Sequence Handling: {{{2
  " ------------------------------
  if has("conceal")
   syn match ansiConceal		conceal	"\e\[\(\d*;\)*\d*m\|\e\[K" containedin=TOP contained
  else
   syn match ansiConceal		"\e\[\(\d*;\)*\d*m\|\e\[K" containedin=TOP contained
  endif

  syn region ansiNone		start="\e\[[01;]m"           skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiNone		start="\e\[m"                skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiNone		start="\e\[\%(0;\)\=39;49m"  skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiNone		start="\e\[\%(0;\)\=49;39m"  skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiNone		start="\e\[\%(0;\)\=39m"     skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiNone		start="\e\[\%(0;\)\=49m"     skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiNone		start="\e\[\%(0;\)\=22m"     skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiBold		start="\e\[;\=0\{0,2};\=1m"  skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiBoldGroup
  syn region ansiItalic		start="\e\[;\=0\{0,2};\=3m"  skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiItalicGroup
  syn region ansiUnderline	start="\e\[;\=0\{0,2};\=4m"  skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiUnderlineGroup

  syn region ansiBlack		start="\e\[;\=0\{0,2};\=30m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRed		start="\e\[;\=0\{0,2};\=31m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiGreen		start="\e\[;\=0\{0,2};\=32m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiYellow		start="\e\[;\=0\{0,2};\=33m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlue		start="\e\[;\=0\{0,2};\=34m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiMagenta	start="\e\[;\=0\{0,2};\=35m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiCyan		start="\e\[;\=0\{0,2};\=36m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiWhite		start="\e\[;\=0\{0,2};\=37m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiGray		start="\e\[;\=0\{0,2};\=90m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiRed		start="\e\[;\=0\{0,2};\=91m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiGreen		start="\e\[;\=0\{0,2};\=92m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiYellow		start="\e\[;\=0\{0,2};\=93m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlue		start="\e\[;\=0\{0,2};\=94m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiMagenta	start="\e\[;\=0\{0,2};\=95m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiCyan		start="\e\[;\=0\{0,2};\=96m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiWhite		start="\e\[;\=0\{0,2};\=97m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiBoldBlack	start="\e\[;\=0\{0,2};\=\%(1;30\|30;0*1\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBoldRed	start="\e\[;\=0\{0,2};\=\%(1;31\|31;0*1\)m" skip="\e\[K" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBoldGreen	start="\e\[;\=0\{0,2};\=\%(1;32\|32;0*1\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBoldYellow	start="\e\[;\=0\{0,2};\=\%(1;33\|33;0*1\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBoldBlue	start="\e\[;\=0\{0,2};\=\%(1;34\|34;0*1\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBoldMagenta	start="\e\[;\=0\{0,2};\=\%(1;35\|35;0*1\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBoldCyan	start="\e\[;\=0\{0,2};\=\%(1;36\|36;0*1\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBoldWhite	start="\e\[;\=0\{0,2};\=\%(1;37\|37;0*1\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBoldGray	start="\e\[;\=0\{0,2};\=\%(1;90\|90;0*1\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiStandoutBlack	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;30\|30;0*3\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiStandoutRed	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;31\|31;0*3\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiStandoutGreen	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;32\|32;0*3\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiStandoutYellow	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;33\|33;0*3\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiStandoutBlue	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;34\|34;0*3\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiStandoutMagenta	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;35\|35;0*3\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiStandoutCyan	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;36\|36;0*3\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiStandoutWhite	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;37\|37;0*3\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiStandoutGray	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(3;90\|90;0*3\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiItalicBlack	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;30\|30;0*2\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiItalicRed	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;31\|31;0*2\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiItalicGreen	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;32\|32;0*2\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiItalicYellow	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;33\|33;0*2\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiItalicBlue	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;34\|34;0*2\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiItalicMagenta	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;35\|35;0*2\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiItalicCyan	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;36\|36;0*2\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiItalicWhite	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;37\|37;0*2\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiItalicGray	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(2;90\|90;0*2\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiUnderlineBlack	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;30\|30;0*4\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiUnderlineRed	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;31\|31;0*4\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiUnderlineGreen	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;32\|32;0*4\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiUnderlineYellow	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;33\|33;0*4\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiUnderlineBlue	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;34\|34;0*4\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiUnderlineMagenta	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;35\|35;0*4\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiUnderlineCyan	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;36\|36;0*4\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiUnderlineWhite	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;37\|37;0*4\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiUnderlineGray	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(4;90\|90;0*4\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiBlinkBlack	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;30\|30;0*5\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlinkRed	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;31\|31;0*5\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlinkGreen	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;32\|32;0*5\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlinkYellow	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;33\|33;0*5\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlinkBlue	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;34\|34;0*5\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlinkMagenta	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;35\|35;0*5\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlinkCyan	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;36\|36;0*5\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlinkWhite	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;37\|37;0*5\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlinkGray	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(5;90\|90;0*5\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiRapidBlinkBlack	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;30\|30;0*6\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRapidBlinkRed	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;31\|31;0*6\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRapidBlinkGreen	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;32\|32;0*6\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRapidBlinkYellow	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;33\|33;0*6\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRapidBlinkBlue	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;34\|34;0*6\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRapidBlinkMagenta	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;35\|35;0*6\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRapidBlinkCyan	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;36\|36;0*6\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRapidBlinkWhite	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;37\|37;0*6\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRapidBlinkGray	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(6;90\|90;0*6\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiRV	 	start="\e\[;\=0\{0,2};\=\%(1;\)\=7m"	     skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRVBlack	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;30\|30;0*7\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRVRed		start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;31\|31;0*7\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRVGreen	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;32\|32;0*7\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRVYellow	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;33\|33;0*7\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRVBlue		start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;34\|34;0*7\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRVMagenta	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;35\|35;0*7\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRVCyan		start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;36\|36;0*7\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRVWhite	start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;37\|37;0*7\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRVGray		start="\e\[;\=0\{0,2};\=\%(1;\)\=\%(7;90\|90;0*7\)m" skip='\e\[K' end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  if v:version >= 703
"   "-----------------------------------------
"   " handles implicit background highlighting
"   "-----------------------------------------
"   call Decho("installing implicit background highlighting")

   syn cluster AnsiBoldGroup    contains=ansiInheritBoldBlack,ansiInheritBoldRed,ansiInheritBoldGreen,ansiInheritBoldYellow,ansiInheritBoldBlue,ansiInheritBoldMagenta,ansiInheritBoldCyan,ansiInheritBoldWhite
   syn region ansiInheritBoldBlack		contained	start="\e\[30m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiBoldGroup
   syn region ansiInheritBoldRed		contained	start="\e\[31m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiBoldGroup
   syn region ansiInheritBoldGreen		contained	start="\e\[32m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiBoldGroup
   syn region ansiInheritBoldYellow		contained	start="\e\[33m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiBoldGroup
   syn region ansiInheritBoldBlue		contained	start="\e\[34m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiBoldGroup
   syn region ansiInheritBoldMagenta	contained	start="\e\[35m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiBoldGroup
   syn region ansiInheritBoldCyan		contained	start="\e\[36m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiBoldGroup
   syn region ansiInheritBoldWhite		contained	start="\e\[37m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiBoldGroup
   hi default link ansiInheritBoldBlack		ansiBoldBlack
   hi default link ansiInheritBoldRed		ansiBoldRed
   hi default link ansiInheritBoldGreen		ansiBoldGreen
   hi default link ansiInheritBoldYellow		ansiBoldYellow
   hi default link ansiInheritBoldBlue		ansiBoldBlue
   hi default link ansiInheritBoldMagenta		ansiBoldMagenta
   hi default link ansiInheritBoldCyan		ansiBoldCyan
   hi default link ansiInheritBoldWhite		ansiBoldWhite

   syn cluster AnsiItalicGroup    contains=ansiInheritItalicBlack,ansiInheritItalicRed,ansiInheritItalicGreen,ansiInheritItalicYellow,ansiInheritItalicBlue,ansiInheritItalicMagenta,ansiInheritItalicCyan,ansiInheritItalicWhite
   syn region ansiInheritItalicBlack	contained	start="\e\[30m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiItalicGroup
   syn region ansiInheritItalicRed		contained	start="\e\[31m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiItalicGroup
   syn region ansiInheritItalicGreen	contained	start="\e\[32m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiItalicGroup
   syn region ansiInheritItalicYellow	contained	start="\e\[33m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiItalicGroup
   syn region ansiInheritItalicBlue		contained	start="\e\[34m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiItalicGroup
   syn region ansiInheritItalicMagenta	contained	start="\e\[35m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiItalicGroup
   syn region ansiInheritItalicCyan		contained	start="\e\[36m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiItalicGroup
   syn region ansiInheritItalicWhite	contained	start="\e\[37m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiItalicGroup
   hi default link ansiInheritItalicBlack		ansiItalicBlack
   hi default link ansiInheritItalicRed		ansiItalicRed
   hi default link ansiInheritItalicGreen		ansiItalicGreen
   hi default link ansiInheritItalicYellow		ansiItalicYellow
   hi default link ansiInheritItalicBlue		ansiItalicBlue
   hi default link ansiInheritItalicMagenta		ansiItalicMagenta
   hi default link ansiInheritItalicCyan		ansiItalicCyan
   hi default link ansiInheritItalicWhite		ansiItalicWhite

   syn cluster AnsiUnderlineGroup    contains=ansiInheritUnderlineBlack,ansiInheritUnderlineRed,ansiInheritUnderlineGreen,ansiInheritUnderlineYellow,ansiInheritUnderlineBlue,ansiInheritUnderlineMagenta,ansiInheritUnderlineCyan,ansiInheritUnderlineWhite
   syn region ansiInheritUnderlineBlack	contained	start="\e\[30m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiUnderlineGroup
   syn region ansiInheritUnderlineRed	contained	start="\e\[31m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiUnderlineGroup
   syn region ansiInheritUnderlineGreen	contained	start="\e\[32m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiUnderlineGroup
   syn region ansiInheritUnderlineYellow	contained	start="\e\[33m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiUnderlineGroup
   syn region ansiInheritUnderlineBlue	contained	start="\e\[34m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiUnderlineGroup
   syn region ansiInheritUnderlineMagenta	contained	start="\e\[35m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiUnderlineGroup
   syn region ansiInheritUnderlineCyan	contained	start="\e\[36m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiUnderlineGroup
   syn region ansiInheritUnderlineWhite	contained	start="\e\[37m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal	nextgroup=@AnsiUnderlineGroup
   hi default link ansiInheritUnderlineBlack	ansiUnderlineBlack
   hi default link ansiInheritUnderlineRed		ansiUnderlineRed
   hi default link ansiInheritUnderlineGreen	ansiUnderlineGreen
   hi default link ansiInheritUnderlineYellow	ansiUnderlineYellow
   hi default link ansiInheritUnderlineBlue		ansiUnderlineBlue
   hi default link ansiInheritUnderlineMagenta	ansiUnderlineMagenta
   hi default link ansiInheritUnderlineCyan		ansiUnderlineCyan
   hi default link ansiInheritUnderlineWhite	ansiUnderlineWhite

   syn cluster AnsiBlackBgGroup contains=ansiBgBlackBlack,ansiBgRedBlack,ansiBgGreenBlack,ansiBgYellowBlack,ansiBgBlueBlack,ansiBgMagentaBlack,ansiBgCyanBlack,ansiBgWhiteBlack
   syn region ansiBlackBg	concealends	matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=40\%(;1\)\=m" skip='\e\[K' end="\ze\e\[;\=[04m]"  containedin=TOP contained contains=@AnsiBlackBgGroup,ansiConceal
   syn region ansiBgBlackBlack	contained	start="\e\[30m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiBgRedBlack	contained	start="\e\[31m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiBgGreenBlack	contained	start="\e\[32m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiBgYellowBlack	contained	start="\e\[33m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiBgBlueBlack	contained	start="\e\[34m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiBgMagentaBlack	contained	start="\e\[35m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiBgCyanBlack	contained	start="\e\[36m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiBgWhiteBlack	contained	start="\e\[37m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=ansiConceal
   hi default link ansiBgBlackBlack	ansiBlackBlack
   hi default link ansiBgRedBlack	ansiRedBlack
   hi default link ansiBgGreenBlack	ansiGreenBlack
   hi default link ansiBgYellowBlack	ansiYellowBlack
   hi default link ansiBgBlueBlack	ansiBlueBlack
   hi default link ansiBgMagentaBlack	ansiMagentaBlack
   hi default link ansiBgCyanBlack	ansiCyanBlack
   hi default link ansiBgWhiteBlack	ansiWhiteBlack

   syn cluster AnsiRedBgGroup contains=ansiBgBlackRed,ansiBgRedRed,ansiBgGreenRed,ansiBgYellowRed,ansiBgBlueRed,ansiBgMagentaRed,ansiBgCyanRed,ansiBgWhiteRed
   syn region ansiRedBg		concealends matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=41\%(;1\)\=m" skip='\e\[K' end="\ze\e\[;\=[04m]"  containedin=TOP contained contains=@AnsiRedBgGroup,ansiConceal
   syn region ansiBgBlackRed	contained	start="\e\[30m" skip='\e\[K' end="\ze\e\[;\=[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgRedRed	contained	start="\e\[31m" skip='\e\[K' end="\ze\e\[;\=[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgGreenRed	contained	start="\e\[32m" skip='\e\[K' end="\ze\e\[;\=[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgYellowRed	contained	start="\e\[33m" skip='\e\[K' end="\ze\e\[;\=[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgBlueRed	contained	start="\e\[34m" skip='\e\[K' end="\ze\e\[;\=[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgMagentaRed	contained	start="\e\[35m" skip='\e\[K' end="\ze\e\[;\=[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgCyanRed	contained	start="\e\[36m" skip='\e\[K' end="\ze\e\[;\=[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgWhiteRed	contained	start="\e\[37m" skip='\e\[K' end="\ze\e\[;\=[03m]" containedin=TOP contained contains=ansiConceal
   hi default link ansiBgBlackRed	ansiBlackRed
   hi default link ansiBgRedRed		ansiRedRed
   hi default link ansiBgGreenRed	ansiGreenRed
   hi default link ansiBgYellowRed	ansiYellowRed
   hi default link ansiBgBlueRed	ansiBlueRed
   hi default link ansiBgMagentaRed	ansiMagentaRed
   hi default link ansiBgCyanRed	ansiCyanRed
   hi default link ansiBgWhiteRed	ansiWhiteRed

   syn cluster AnsiGreenBgGroup contains=ansiBgBlackGreen,ansiBgRedGreen,ansiBgGreenGreen,ansiBgYellowGreen,ansiBgBlueGreen,ansiBgMagentaGreen,ansiBgCyanGreen,ansiBgWhiteGreen
   syn region ansiGreenBg	concealends matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=42\%(;1\)\=m" skip='\e\[K' end="\ze\e\[;\=[04m]"  containedin=TOP contained contains=@AnsiGreenBgGroup,ansiConceal
   syn region ansiBgBlackGreen	contained	start="\e\[30m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgRedGreen	contained	start="\e\[31m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgGreenGreen	contained	start="\e\[32m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgYellowGreen	contained	start="\e\[33m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgBlueGreen	contained	start="\e\[34m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgMagentaGreen	contained	start="\e\[35m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgCyanGreen	contained	start="\e\[36m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgWhiteGreen	contained	start="\e\[37m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   hi default link ansiBgBlackGreen	ansiBlackGreen
   hi default link ansiBgGreenGreen	ansiGreenGreen
   hi default link ansiBgRedGreen	ansiRedGreen
   hi default link ansiBgYellowGreen	ansiYellowGreen
   hi default link ansiBgBlueGreen	ansiBlueGreen
   hi default link ansiBgMagentaGreen	ansiMagentaGreen
   hi default link ansiBgCyanGreen	ansiCyanGreen
   hi default link ansiBgWhiteGreen	ansiWhiteGreen

   syn cluster AnsiYellowBgGroup contains=ansiBgBlackYellow,ansiBgRedYellow,ansiBgGreenYellow,ansiBgYellowYellow,ansiBgBlueYellow,ansiBgMagentaYellow,ansiBgCyanYellow,ansiBgWhiteYellow
   syn region ansiYellowBg	concealends matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=43\%(;1\)\=m" skip='\e\[K' end="\ze\e\[;\=[04m]"  containedin=TOP contained contains=@AnsiYellowBgGroup,ansiConceal
   syn region ansiBgBlackYellow	contained	start="\e\[30m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgRedYellow	contained	start="\e\[31m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgGreenYellow	contained	start="\e\[32m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgYellowYellow	contained	start="\e\[33m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgBlueYellow	contained	start="\e\[34m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgMagentaYellow	contained	start="\e\[35m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgCyanYellow	contained	start="\e\[36m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgWhiteYellow	contained	start="\e\[37m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   hi default link ansiBgBlackYellow	ansiBlackYellow
   hi default link ansiBgRedYellow	ansiRedYellow
   hi default link ansiBgGreenYellow	ansiGreenYellow
   hi default link ansiBgYellowYellow	ansiYellowYellow
   hi default link ansiBgBlueYellow	ansiBlueYellow
   hi default link ansiBgMagentaYellow	ansiMagentaYellow
   hi default link ansiBgCyanYellow	ansiCyanYellow
   hi default link ansiBgWhiteYellow	ansiWhiteYellow

   syn cluster AnsiBlueBgGroup contains=ansiBgBlackBlue,ansiBgRedBlue,ansiBgGreenBlue,ansiBgYellowBlue,ansiBgBlueBlue,ansiBgMagentaBlue,ansiBgCyanBlue,ansiBgWhiteBlue
   syn region ansiBlueBg	concealends matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=44\%(;1\)\=m" skip='\e\[K' end="\ze\e\[;\=[04m]"  containedin=TOP contained contains=@AnsiBlueBgGroup,ansiConceal
   syn region ansiBgBlackBlue	contained	start="\e\[30m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgRedBlue	contained	start="\e\[31m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgGreenBlue	contained	start="\e\[32m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgYellowBlue	contained	start="\e\[33m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgBlueBlue	contained	start="\e\[34m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgMagentaBlue	contained	start="\e\[35m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgCyanBlue	contained	start="\e\[36m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgWhiteBlue	contained	start="\e\[37m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   hi default link ansiBgBlackBlue	ansiBlackBlue
   hi default link ansiBgRedBlue	ansiRedBlue
   hi default link ansiBgGreenBlue	ansiGreenBlue
   hi default link ansiBgYellowBlue	ansiYellowBlue
   hi default link ansiBgBlueBlue	ansiBlueBlue
   hi default link ansiBgMagentaBlue	ansiMagentaBlue
   hi default link ansiBgCyanBlue	ansiCyanBlue
   hi default link ansiBgWhiteBlue	ansiWhiteBlue

   syn cluster AnsiMagentaBgGroup contains=ansiBgBlackMagenta,ansiBgRedMagenta,ansiBgGreenMagenta,ansiBgYellowMagenta,ansiBgBlueMagenta,ansiBgMagentaMagenta,ansiBgCyanMagenta,ansiBgWhiteMagenta
   syn region ansiMagentaBg	concealends matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=45\%(;1\)\=m" skip='\e\[K' end="\ze\e\[;\=[04m]"  containedin=TOP contained contains=@AnsiMagentaBgGroup,ansiConceal
   syn region ansiBgBlackMagenta	contained	start="\e\[30m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgRedMagenta	contained	start="\e\[31m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgGreenMagenta	contained	start="\e\[32m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgYellowMagenta	contained	start="\e\[33m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgBlueMagenta	contained	start="\e\[34m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgMagentaMagenta	contained	start="\e\[35m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgCyanMagenta	contained	start="\e\[36m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgWhiteMagenta	contained	start="\e\[37m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   hi default link ansiBgBlackMagenta	ansiBlackMagenta
   hi default link ansiBgRedMagenta	ansiRedMagenta
   hi default link ansiBgGreenMagenta	ansiGreenMagenta
   hi default link ansiBgYellowMagenta	ansiYellowMagenta
   hi default link ansiBgBlueMagenta	ansiBlueMagenta
   hi default link ansiBgMagentaMagenta	ansiMagentaMagenta
   hi default link ansiBgCyanMagenta	ansiCyanMagenta
   hi default link ansiBgWhiteMagenta	ansiWhiteMagenta

   syn cluster AnsiCyanBgGroup contains=ansiBgBlackCyan,ansiBgRedCyan,ansiBgGreenCyan,ansiBgYellowCyan,ansiBgBlueCyan,ansiBgMagentaCyan,ansiBgCyanCyan,ansiBgWhiteCyan
   syn region ansiCyanBg	concealends matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=46\%(;1\)\=m" skip='\e\[K' end="\ze\e\[;\=[04m]"  containedin=TOP contained contains=@AnsiCyanBgGroup,ansiConceal
   syn region ansiBgBlackCyan	contained	start="\e\[30m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgRedCyan	contained	start="\e\[31m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgGreenCyan	contained	start="\e\[32m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgYellowCyan	contained	start="\e\[33m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgBlueCyan	contained	start="\e\[34m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgMagentaCyan	contained	start="\e\[35m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgCyanCyan	contained	start="\e\[36m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgWhiteCyan	contained	start="\e\[37m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   hi default link ansiBgBlackCyan	ansiBlackCyan
   hi default link ansiBgRedCyan	ansiRedCyan
   hi default link ansiBgGreenCyan	ansiGreenCyan
   hi default link ansiBgYellowCyan	ansiYellowCyan
   hi default link ansiBgBlueCyan	ansiBlueCyan
   hi default link ansiBgMagentaCyan	ansiMagentaCyan
   hi default link ansiBgCyanCyan	ansiCyanCyan
   hi default link ansiBgWhiteCyan	ansiWhiteCyan

   syn cluster AnsiWhiteBgGroup contains=ansiBgBlackWhite,ansiBgRedWhite,ansiBgGreenWhite,ansiBgYellowWhite,ansiBgBlueWhite,ansiBgMagentaWhite,ansiBgCyanWhite,ansiBgWhiteWhite
   syn region ansiWhiteBg	concealends matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=47\%(;1\)\=m" skip='\e\[K' end="\ze\e\[;\=[04m]"  containedin=TOP contained contains=@AnsiWhiteBgGroup,ansiConceal
   syn region ansiBgBlackWhite	contained	start="\e\[30m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgRedWhite	contained	start="\e\[31m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgGreenWhite	contained	start="\e\[32m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgYellowWhite	contained	start="\e\[33m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgBlueWhite	contained	start="\e\[34m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgMagentaWhite	contained	start="\e\[35m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgCyanWhite	contained	start="\e\[36m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   syn region ansiBgWhiteWhite	contained	start="\e\[37m" skip='\e\[K' end="\ze\e\[[03m]" containedin=TOP contained contains=ansiConceal
   hi default link ansiBgBlackWhite	ansiBlackWhite
   hi default link ansiBgRedWhite	ansiRedWhite
   hi default link ansiBgGreenWhite	ansiGreenWhite
   hi default link ansiBgYellowWhite	ansiYellowWhite
   hi default link ansiBgBlueWhite	ansiBlueWhite
   hi default link ansiBgMagentaWhite	ansiMagentaWhite
   hi default link ansiBgCyanWhite	ansiCyanWhite
   hi default link ansiBgWhiteWhite	ansiWhiteWhite

   "-----------------------------------------
   " handles implicit foreground highlighting
   "-----------------------------------------
"   call Decho("installing implicit foreground highlighting")

   syn cluster AnsiBlackFgGroup contains=ansiFgBlackBlack,ansiFgBlackRed,ansiFgBlackGreen,ansiFgBlackYellow,ansiFgBlackBlue,ansiFgBlackMagenta,ansiFgBlackCyan,ansiFgBlackWhite
   syn region ansiBlackFg	concealends	matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=30\%(;1\)\=m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=@AnsiBlackFgGroup,ansiConceal
   syn region ansiFgBlackBlack	contained	start="\e\[40m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackRed	contained	start="\e\[41m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackGreen	contained	start="\e\[42m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackYellow	contained	start="\e\[43m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackBlue	contained	start="\e\[44m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackMagenta	contained	start="\e\[45m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackCyan	contained	start="\e\[46m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackWhite	contained	start="\e\[47m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackBlack	contained	start="\e\[\d;40m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackRed	contained	start="\e\[\d;41m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackGreen	contained	start="\e\[\d;42m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackYellow	contained	start="\e\[\d;43m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackBlue	contained	start="\e\[\d;44m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackMagenta	contained	start="\e\[\d;45m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackCyan	contained	start="\e\[\d;46m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlackWhite	contained	start="\e\[\d;47m" skip='\e\[K' end="\ze\e\[[04m]"  containedin=TOP contained contains=ansiConceal
   hi default link ansiFgBlackBlack	ansiBlackBlack
   hi default link ansiFgBlackRed	ansiBlackRed
   hi default link ansiFgBlackGreen	ansiBlackGreen
   hi default link ansiFgBlackYellow	ansiBlackYellow
   hi default link ansiFgBlackBlue	ansiBlackBlue
   hi default link ansiFgBlackMagenta	ansiBlackMagenta
   hi default link ansiFgBlackCyan	ansiBlackCyan
   hi default link ansiFgBlackWhite	ansiBlackWhite

   syn cluster AnsiRedFgGroup contains=ansiFgRedBlack,ansiFgRedRed,ansiFgRedGreen,ansiFgRedYellow,ansiFgRedBlue,ansiFgRedMagenta,ansiFgRedCyan,ansiFgRedWhite
   syn region ansiRedFg		concealends matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=31\%(;1\)\=m" skip='\e\[K' end="\ze\e\[;\=[03m]"  containedin=TOP contained contains=@AnsiRedFgGroup,ansiConceal
   syn region ansiFgRedBlack	contained	start="\e\[40m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedRed	contained	start="\e\[41m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedGreen	contained	start="\e\[42m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedYellow	contained	start="\e\[43m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedBlue	contained	start="\e\[44m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedMagenta	contained	start="\e\[45m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedCyan	contained	start="\e\[46m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedWhite	contained	start="\e\[47m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedBlack	contained	start="\e\[\d;40m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedRed	contained	start="\e\[\d;41m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedGreen	contained	start="\e\[\d;42m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedYellow	contained	start="\e\[\d;43m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedBlue	contained	start="\e\[\d;44m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedMagenta	contained	start="\e\[\d;45m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedCyan	contained	start="\e\[\d;46m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgRedWhite	contained	start="\e\[\d;47m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   hi default link ansiFgRedBlack	ansiRedBlack
   hi default link ansiFgRedRed		ansiRedRed
   hi default link ansiFgRedGreen	ansiRedGreen
   hi default link ansiFgRedYellow	ansiRedYellow
   hi default link ansiFgRedBlue	ansiRedBlue
   hi default link ansiFgRedMagenta	ansiRedMagenta
   hi default link ansiFgRedCyan	ansiRedCyan
   hi default link ansiFgRedWhite	ansiRedWhite

   syn cluster AnsiGreenFgGroup contains=ansiFgGreenBlack,ansiFgGreenRed,ansiFgGreenGreen,ansiFgGreenYellow,ansiFgGreenBlue,ansiFgGreenMagenta,ansiFgGreenCyan,ansiFgGreenWhite
   syn region ansiGreenFg	concealends matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=32\%(;1\)\=m" skip='\e\[K' end="\ze\e\[\([1-7]\=;\)\=[03]\dm"  containedin=TOP contained contains=@AnsiGreenFgGroup,ansiConceal
   syn region ansiFgGreenBlack	contained	start="\e\[40m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenRed	contained	start="\e\[41m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenGreen	contained	start="\e\[42m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenYellow	contained	start="\e\[43m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenBlue	contained	start="\e\[44m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenMagenta	contained	start="\e\[45m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenCyan	contained	start="\e\[46m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenWhite	contained	start="\e\[47m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenBlack	contained	start="\e\[\d;40m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenRed	contained	start="\e\[\d;41m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenGreen	contained	start="\e\[\d;42m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenYellow	contained	start="\e\[\d;43m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenBlue	contained	start="\e\[\d;44m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenMagenta	contained	start="\e\[\d;45m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenCyan	contained	start="\e\[\d;46m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgGreenWhite	contained	start="\e\[\d;47m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   hi default link ansiFgGreenBlack	ansiGreenBlack
   hi default link ansiFgGreenGreen	ansiGreenGreen
   hi default link ansiFgGreenRed	ansiGreenRed
   hi default link ansiFgGreenYellow	ansiGreenYellow
   hi default link ansiFgGreenBlue	ansiGreenBlue
   hi default link ansiFgGreenMagenta	ansiGreenMagenta
   hi default link ansiFgGreenCyan	ansiGreenCyan
   hi default link ansiFgGreenWhite	ansiGreenWhite

   syn cluster AnsiYellowFgGroup contains=ansiFgYellowBlack,ansiFgYellowRed,ansiFgYellowGreen,ansiFgYellowYellow,ansiFgYellowBlue,ansiFgYellowMagenta,ansiFgYellowCyan,ansiFgYellowWhite,cecJUNK
   syn region ansiYellowFg	concealends matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=33\%(;1\)\=m" skip='\e\[K' end="\ze\e\[\([1-7]\=;\)\=[03]\dm"  containedin=TOP contained contains=@AnsiYellowFgGroup,ansiConceal
   syn region ansiFgYellowBlack	contained	start="\e\[40m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowRed	contained	start="\e\[41m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowGreen	contained	start="\e\[42m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowYellow	contained	start="\e\[43m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowBlue	contained	start="\e\[44m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowMagenta	contained	start="\e\[45m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowCyan	contained	start="\e\[46m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowWhite	contained	start="\e\[47m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowBlack	contained	start="\e\[\d;40m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowRed	contained	start="\e\[\d;41m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowGreen	contained	start="\e\[\d;42m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowYellow	contained	start="\e\[\d;43m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowBlue	contained	start="\e\[\d;44m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowMagenta	contained	start="\e\[\d;45m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowCyan	contained	start="\e\[\d;46m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgYellowWhite	contained	start="\e\[\d;47m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   hi default link ansiFgYellowBlack	ansiYellowBlack
   hi default link ansiFgYellowRed	ansiYellowRed
   hi default link ansiFgYellowGreen	ansiYellowGreen
   hi default link ansiFgYellowYellow	ansiYellowYellow
   hi default link ansiFgYellowBlue	ansiYellowBlue
   hi default link ansiFgYellowMagenta	ansiYellowMagenta
   hi default link ansiFgYellowCyan	ansiYellowCyan
   hi default link ansiFgYellowWhite	ansiYellowWhite

   syn cluster AnsiBlueFgGroup contains=ansiFgBlueBlack,ansiFgBlueRed,ansiFgBlueGreen,ansiFgBlueYellow,ansiFgBlueBlue,ansiFgBlueMagenta,ansiFgBlueCyan,ansiFgBlueWhite
   syn region ansiBlueFg	concealends matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=34\%(;1\)\=m" skip='\e\[K' end="\ze\e\[\([1-7]\=;\)\=[03]\dm"  containedin=TOP contained contains=@AnsiBlueFgGroup,ansiConceal
   syn region ansiFgBlueBlack	contained	start="\e\[40m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueRed	contained	start="\e\[41m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueGreen	contained	start="\e\[42m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueYellow	contained	start="\e\[43m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueBlue	contained	start="\e\[44m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueMagenta	contained	start="\e\[45m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueCyan	contained	start="\e\[46m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueWhite	contained	start="\e\[47m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueBlack	contained	start="\e\[\d;40m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueRed	contained	start="\e\[\d;41m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueGreen	contained	start="\e\[\d;42m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueYellow	contained	start="\e\[\d;43m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueBlue	contained	start="\e\[\d;44m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueMagenta	contained	start="\e\[\d;45m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueCyan	contained	start="\e\[\d;46m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgBlueWhite	contained	start="\e\[\d;47m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   hi default link ansiFgBlueBlack	ansiBlueBlack
   hi default link ansiFgBlueRed	ansiBlueRed
   hi default link ansiFgBlueGreen	ansiBlueGreen
   hi default link ansiFgBlueYellow	ansiBlueYellow
   hi default link ansiFgBlueBlue	ansiBlueBlue
   hi default link ansiFgBlueMagenta	ansiBlueMagenta
   hi default link ansiFgBlueCyan	ansiBlueCyan
   hi default link ansiFgBlueWhite	ansiBlueWhite

   syn cluster AnsiMagentaFgGroup contains=ansiFgMagentaBlack,ansiFgMagentaRed,ansiFgMagentaGreen,ansiFgMagentaYellow,ansiFgMagentaBlue,ansiFgMagentaMagenta,ansiFgMagentaCyan,ansiFgMagentaWhite
   syn region ansiMagentaFg	concealends matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=35\%(;1\)\=m" skip='\e\[K' end="\ze\e\[\([1-7]\=;\)\=[03]\dm"  containedin=TOP contained contains=@AnsiMagentaFgGroup,ansiConceal
   syn region ansiFgMagentaBlack	contained	start="\e\[40m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaRed	contained	start="\e\[41m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaGreen	contained	start="\e\[42m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaYellow	contained	start="\e\[43m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaBlue	contained	start="\e\[44m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaMagenta	contained	start="\e\[45m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaCyan	contained	start="\e\[46m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaWhite	contained	start="\e\[47m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaBlack	contained	start="\e\[\d;40m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaRed	contained	start="\e\[\d;41m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaGreen	contained	start="\e\[\d;42m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaYellow	contained	start="\e\[\d;43m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaBlue	contained	start="\e\[\d;44m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaMagenta	contained	start="\e\[\d;45m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaCyan	contained	start="\e\[\d;46m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgMagentaWhite	contained	start="\e\[\d;47m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   hi default link ansiFgMagentaBlack	ansiMagentaBlack
   hi default link ansiFgMagentaRed	ansiMagentaRed
   hi default link ansiFgMagentaGreen	ansiMagentaGreen
   hi default link ansiFgMagentaYellow	ansiMagentaYellow
   hi default link ansiFgMagentaBlue	ansiMagentaBlue
   hi default link ansiFgMagentaMagenta	ansiMagentaMagenta
   hi default link ansiFgMagentaCyan	ansiMagentaCyan
   hi default link ansiFgMagentaWhite	ansiMagentaWhite

   syn cluster AnsiCyanFgGroup contains=ansiFgCyanBlack,ansiFgCyanRed,ansiFgCyanGreen,ansiFgCyanYellow,ansiFgCyanBlue,ansiFgCyanMagenta,ansiFgCyanCyan,ansiFgCyanWhite
   syn region ansiCyanFg	concealends matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=36\%(;1\)\=m" skip='\e\[K' end="\ze\e\[\([1-7]\=;\)\=[03]\dm"  containedin=TOP contained contains=@AnsiCyanFgGroup,ansiConceal
   syn region ansiFgCyanBlack	contained	start="\e\[40m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanRed	contained	start="\e\[41m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanGreen	contained	start="\e\[42m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanYellow	contained	start="\e\[43m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanBlue	contained	start="\e\[44m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanMagenta	contained	start="\e\[45m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanCyan	contained	start="\e\[46m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanWhite	contained	start="\e\[47m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanBlack	contained	start="\e\[\d;40m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanRed	contained	start="\e\[\d;41m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanGreen	contained	start="\e\[\d;42m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanYellow	contained	start="\e\[\d;43m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanBlue	contained	start="\e\[\d;44m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanMagenta	contained	start="\e\[\d;45m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanCyan	contained	start="\e\[\d;46m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgCyanWhite	contained	start="\e\[\d;47m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   hi default link ansiFgCyanBlack	ansiCyanBlack
   hi default link ansiFgCyanRed	ansiCyanRed
   hi default link ansiFgCyanGreen	ansiCyanGreen
   hi default link ansiFgCyanYellow	ansiCyanYellow
   hi default link ansiFgCyanBlue	ansiCyanBlue
   hi default link ansiFgCyanMagenta	ansiCyanMagenta
   hi default link ansiFgCyanCyan	ansiCyanCyan
   hi default link ansiFgCyanWhite	ansiCyanWhite

   syn cluster AnsiWhiteFgGroup contains=ansiFgWhiteBlack,ansiFgWhiteRed,ansiFgWhiteGreen,ansiFgWhiteYellow,ansiFgWhiteBlue,ansiFgWhiteMagenta,ansiFgWhiteCyan,ansiFgWhiteWhite
   syn region ansiWhiteFg	concealends matchgroup=ansiNone start="\e\[;\=0\{0,2};\=\%(1;\)\=37\%(;1\)\=m" skip='\e\[K' end="\ze\e\[\([1-7]\=;\)\=[03]\dm"  containedin=TOP contained contains=@AnsiWhiteFgGroup,ansiConceal
   syn region ansiFgWhiteBlack	contained	start="\e\[40m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteRed	contained	start="\e\[41m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteGreen	contained	start="\e\[42m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteYellow	contained	start="\e\[43m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteBlue	contained	start="\e\[44m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteMagenta	contained	start="\e\[45m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteCyan	contained	start="\e\[46m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteWhite	contained	start="\e\[47m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteBlack	contained	start="\e\[\d;40m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteRed	contained	start="\e\[\d;41m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteGreen	contained	start="\e\[\d;42m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteYellow	contained	start="\e\[\d;43m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteBlue	contained	start="\e\[\d;44m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteMagenta	contained	start="\e\[\d;45m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteCyan	contained	start="\e\[\d;46m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   syn region ansiFgWhiteWhite	contained	start="\e\[\d;47m" skip='\e\[K' end="\ze\e\[[04m]" containedin=TOP contained contains=ansiConceal
   hi default link ansiFgWhiteBlack	ansiWhiteBlack
   hi default link ansiFgWhiteRed	ansiWhiteRed
   hi default link ansiFgWhiteGreen	ansiWhiteGreen
   hi default link ansiFgWhiteYellow	ansiWhiteYellow
   hi default link ansiFgWhiteBlue	ansiWhiteBlue
   hi default link ansiFgWhiteMagenta	ansiWhiteMagenta
   hi default link ansiFgWhiteCyan	ansiWhiteCyan
   hi default link ansiFgWhiteWhite	ansiWhiteWhite
  endif

  if has("conceal")
   syn match ansiStop		conceal "\e\[;\=0\{1,2}m" containedin=TOP contained
   syn match ansiStop		conceal "\e\[K" containedin=TOP contained
   syn match ansiStop		conceal "\e\[H" containedin=TOP contained
   syn match ansiStop		conceal "\e\[2J" containedin=TOP contained
  else
   syn match ansiStop		"\e\[;\=0\{0,2}m" containedin=TOP contained
   syn match ansiStop		"\e\[K" containedin=TOP contained
   syn match ansiStop		"\e\[H" containedin=TOP contained
   syn match ansiStop		"\e\[2J" containedin=TOP contained
  endif

  " ---------------------------------------------------------------------
  " Some Color Combinations: - can't do 'em all, the qty of highlighting groups is limited! {{{2
  " ---------------------------------------------------------------------
  syn region ansiBlackBlack	start="\e\[0\{0,2};\=\(30;40\|40;30\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRedBlack	start="\e\[0\{0,2};\=\(31;40\|40;31\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiGreenBlack	start="\e\[0\{0,2};\=\(32;40\|40;32\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiYellowBlack	start="\e\[0\{0,2};\=\(33;40\|40;33\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlueBlack	start="\e\[0\{0,2};\=\(34;40\|40;34\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiMagentaBlack	start="\e\[0\{0,2};\=\(35;40\|40;35\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiCyanBlack	start="\e\[0\{0,2};\=\(36;40\|40;36\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiWhiteBlack	start="\e\[0\{0,2};\=\(37;40\|40;37\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiBlackRed	start="\e\[0\{0,2};\=\(30;41\|41;30\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRedRed		start="\e\[0\{0,2};\=\(31;41\|41;31\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiGreenRed	start="\e\[0\{0,2};\=\(32;41\|41;32\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiYellowRed	start="\e\[0\{0,2};\=\(33;41\|41;33\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlueRed	start="\e\[0\{0,2};\=\(34;41\|41;34\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiMagentaRed	start="\e\[0\{0,2};\=\(35;41\|41;35\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiCyanRed	start="\e\[0\{0,2};\=\(36;41\|41;36\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiWhiteRed	start="\e\[0\{0,2};\=\(37;41\|41;37\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiBlackGreen	start="\e\[0\{0,2};\=\(30;42\|42;30\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRedGreen	start="\e\[0\{0,2};\=\(31;42\|42;31\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiGreenGreen	start="\e\[0\{0,2};\=\(32;42\|42;32\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiYellowGreen	start="\e\[0\{0,2};\=\(33;42\|42;33\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlueGreen	start="\e\[0\{0,2};\=\(34;42\|42;34\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiMagentaGreen	start="\e\[0\{0,2};\=\(35;42\|42;35\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiCyanGreen	start="\e\[0\{0,2};\=\(36;42\|42;36\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiWhiteGreen	start="\e\[0\{0,2};\=\(37;42\|42;37\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiBlackYellow	start="\e\[0\{0,2};\=\(30;43\|43;30\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRedYellow	start="\e\[0\{0,2};\=\(31;43\|43;31\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiGreenYellow	start="\e\[0\{0,2};\=\(32;43\|43;32\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiYellowYellow	start="\e\[0\{0,2};\=\(33;43\|43;33\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlueYellow	start="\e\[0\{0,2};\=\(34;43\|43;34\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiMagentaYellow	start="\e\[0\{0,2};\=\(35;43\|43;35\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiCyanYellow	start="\e\[0\{0,2};\=\(36;43\|43;36\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiWhiteYellow	start="\e\[0\{0,2};\=\(37;43\|43;37\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiBlackBlue	start="\e\[0\{0,2};\=\(30;44\|44;30\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRedBlue	start="\e\[0\{0,2};\=\(31;44\|44;31\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiGreenBlue	start="\e\[0\{0,2};\=\(32;44\|44;32\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiYellowBlue	start="\e\[0\{0,2};\=\(33;44\|44;33\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlueBlue	start="\e\[0\{0,2};\=\(34;44\|44;34\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiMagentaBlue	start="\e\[0\{0,2};\=\(35;44\|44;35\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiCyanBlue	start="\e\[0\{0,2};\=\(36;44\|44;36\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiWhiteBlue	start="\e\[0\{0,2};\=\(37;44\|44;37\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiBlackMagenta	start="\e\[0\{0,2};\=\(30;45\|45;30\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRedMagenta	start="\e\[0\{0,2};\=\(31;45\|45;31\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiGreenMagenta	start="\e\[0\{0,2};\=\(32;45\|45;32\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiYellowMagenta	start="\e\[0\{0,2};\=\(33;45\|45;33\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlueMagenta	start="\e\[0\{0,2};\=\(34;45\|45;34\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiMagentaMagenta	start="\e\[0\{0,2};\=\(35;45\|45;35\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiCyanMagenta	start="\e\[0\{0,2};\=\(36;45\|45;36\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiWhiteMagenta	start="\e\[0\{0,2};\=\(37;45\|45;37\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiBlackCyan	start="\e\[0\{0,2};\=\(30;46\|46;30\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRedCyan	start="\e\[0\{0,2};\=\(31;46\|46;31\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiGreenCyan	start="\e\[0\{0,2};\=\(32;46\|46;32\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiYellowCyan	start="\e\[0\{0,2};\=\(33;46\|46;33\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlueCyan	start="\e\[0\{0,2};\=\(34;46\|46;34\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiMagentaCyan	start="\e\[0\{0,2};\=\(35;46\|46;35\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiCyanCyan	start="\e\[0\{0,2};\=\(36;46\|46;36\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiWhiteCyan	start="\e\[0\{0,2};\=\(37;46\|46;37\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn region ansiBlackWhite	start="\e\[0\{0,2};\=\(30;47\|47;30\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiRedWhite	start="\e\[0\{0,2};\=\(31;47\|47;31\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiGreenWhite	start="\e\[0\{0,2};\=\(32;47\|47;32\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiYellowWhite	start="\e\[0\{0,2};\=\(33;47\|47;33\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiBlueWhite	start="\e\[0\{0,2};\=\(34;47\|47;34\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiMagentaWhite	start="\e\[0\{0,2};\=\(35;47\|47;35\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiCyanWhite	start="\e\[0\{0,2};\=\(36;47\|47;36\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal
  syn region ansiWhiteWhite	start="\e\[0\{0,2};\=\(37;47\|47;37\)m" end="\ze\e\[" containedin=TOP contained contains=ansiConceal

  syn match ansiExtended	"\e\[;\=\(0;\)\=[34]8;\(\d*;\)*\d*m"   containedin=TOP contained contains=ansiConceal

  " -------------
  " Highlighting: {{{2
  " -------------
  if !has("conceal")
   " --------------
   " ansiesc_ignore: {{{3
   " --------------
   hi def link ansiConceal	Ignore
   hi def link ansiSuppress	Ignore
   hi def link ansiIgnore	ansiStop
   hi def link ansiStop		Ignore
   hi def link ansiExtended	Ignore
   let s:hlkeep_{bufnr("%")}= &l:hl
"   call Decho("setl hl=".substitute(&hl,'8:[^,]\{-},','8:Ignore,',""))
   exe "setl hl=".substitute(&hl,'8:[^,]\{-},','8:Ignore,',"")
  endif

  " handle 3 or more element ansi escape sequences by building syntax and highlighting rules
  " specific to the current file
  call s:MultiElementHandler()

  if exists("g:ansiNone")
   exe g:ansiNone
  else
   hi ansiNone	cterm=NONE       gui=NONE
  endif
  if exists("g:ansiBold")
   exe g:ansiBold
  else
   hi ansiBold           cterm=bold       gui=bold
  endif
  if exists("g:ansiItalic")
   exe g:ansiItalic
  else
   hi ansiItalic         cterm=italic     gui=italic
  endif
  if exists("g:ansiUnderline")
   exe ansiUnderline
  else
   hi ansiUnderline      cterm=underline  gui=underline
  endif

  if &t_Co == 8 || &t_Co == 256
   " ---------------------
   " eight-color handling: {{{3
   " ---------------------
"   call Decho("set up 8-color highlighting groups")
   hi ansiBlack             ctermfg=black      guifg=black                                        cterm=none         gui=none
   hi ansiRed               ctermfg=red        guifg=red                                          cterm=none         gui=none
   hi ansiGreen             ctermfg=green      guifg=green                                        cterm=none         gui=none
   hi ansiYellow            ctermfg=yellow     guifg=yellow                                       cterm=none         gui=none
   hi ansiBlue              ctermfg=blue       guifg=blue                                         cterm=none         gui=none
   hi ansiMagenta           ctermfg=magenta    guifg=magenta                                      cterm=none         gui=none
   hi ansiCyan              ctermfg=cyan       guifg=cyan                                         cterm=none         gui=none
   hi ansiWhite             ctermfg=white      guifg=white                                        cterm=none         gui=none
   hi ansiGray              ctermfg=gray       guifg=gray                                         cterm=none         gui=none

   hi ansiBlackBg           ctermbg=black      guibg=black                                        cterm=none         gui=none
   hi ansiRedBg             ctermbg=red        guibg=red                                          cterm=none         gui=none
   hi ansiGreenBg           ctermbg=green      guibg=green                                        cterm=none         gui=none
   hi ansiYellowBg          ctermbg=yellow     guibg=yellow                                       cterm=none         gui=none
   hi ansiBlueBg            ctermbg=blue       guibg=blue                                         cterm=none         gui=none
   hi ansiMagentaBg         ctermbg=magenta    guibg=magenta                                      cterm=none         gui=none
   hi ansiCyanBg            ctermbg=cyan       guibg=cyan                                         cterm=none         gui=none
   hi ansiWhiteBg           ctermbg=white      guibg=white                                        cterm=none         gui=none
   hi ansiGrayBg            ctermbg=gray       guibg=gray                                         cterm=none         gui=none

   hi ansiBlackFg           ctermfg=black      guifg=black                                        cterm=none         gui=none
   hi ansiRedFg             ctermfg=red        guifg=red                                          cterm=none         gui=none
   hi ansiGreenFg           ctermfg=green      guifg=green                                        cterm=none         gui=none
   hi ansiYellowFg          ctermfg=yellow     guifg=yellow                                       cterm=none         gui=none
   hi ansiBlueFg            ctermfg=blue       guifg=blue                                         cterm=none         gui=none
   hi ansiMagentaFg         ctermfg=magenta    guifg=magenta                                      cterm=none         gui=none
   hi ansiCyanFg            ctermfg=cyan       guifg=cyan                                         cterm=none         gui=none
   hi ansiWhiteFg           ctermfg=white      guifg=white                                        cterm=none         gui=none
   hi ansiGrayFg            ctermfg=gray       guifg=gray                                         cterm=none         gui=none

   hi ansiBoldBlack         ctermfg=black      guifg=black                                        cterm=bold         gui=bold
   hi ansiBoldRed           ctermfg=red        guifg=red                                          cterm=bold         gui=bold
   hi ansiBoldGreen         ctermfg=green      guifg=green                                        cterm=bold         gui=bold
   hi ansiBoldYellow        ctermfg=yellow     guifg=yellow                                       cterm=bold         gui=bold
   hi ansiBoldBlue          ctermfg=blue       guifg=blue                                         cterm=bold         gui=bold
   hi ansiBoldMagenta       ctermfg=magenta    guifg=magenta                                      cterm=bold         gui=bold
   hi ansiBoldCyan          ctermfg=cyan       guifg=cyan                                         cterm=bold         gui=bold
   hi ansiBoldWhite         ctermfg=white      guifg=white                                        cterm=bold         gui=bold
   hi ansiBoldGray          ctermbg=gray       guibg=gray                                         cterm=bold         gui=bold

   hi ansiStandoutBlack     ctermfg=black      guifg=black                                        cterm=standout     gui=standout
   hi ansiStandoutRed       ctermfg=red        guifg=red                                          cterm=standout     gui=standout
   hi ansiStandoutGreen     ctermfg=green      guifg=green                                        cterm=standout     gui=standout
   hi ansiStandoutYellow    ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=standout
   hi ansiStandoutBlue      ctermfg=blue       guifg=blue                                         cterm=standout     gui=standout
   hi ansiStandoutMagenta   ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=standout
   hi ansiStandoutCyan      ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=standout
   hi ansiStandoutWhite     ctermfg=white      guifg=white                                        cterm=standout     gui=standout
   hi ansiStandoutGray      ctermfg=gray       guifg=gray                                         cterm=standout     gui=standout

   hi ansiItalicBlack       ctermfg=black      guifg=black                                        cterm=italic       gui=italic
   hi ansiItalicRed         ctermfg=red        guifg=red                                          cterm=italic       gui=italic
   hi ansiItalicGreen       ctermfg=green      guifg=green                                        cterm=italic       gui=italic
   hi ansiItalicYellow      ctermfg=yellow     guifg=yellow                                       cterm=italic       gui=italic
   hi ansiItalicBlue        ctermfg=blue       guifg=blue                                         cterm=italic       gui=italic
   hi ansiItalicMagenta     ctermfg=magenta    guifg=magenta                                      cterm=italic       gui=italic
   hi ansiItalicCyan        ctermfg=cyan       guifg=cyan                                         cterm=italic       gui=italic
   hi ansiItalicWhite       ctermfg=white      guifg=white                                        cterm=italic       gui=italic
   hi ansiItalicGray        ctermfg=gray       guifg=gray                                         cterm=italic       gui=italic

   hi ansiUnderlineBlack    ctermfg=black      guifg=black                                        cterm=underline    gui=underline
   hi ansiUnderlineRed      ctermfg=red        guifg=red                                          cterm=underline    gui=underline
   hi ansiUnderlineGreen    ctermfg=green      guifg=green                                        cterm=underline    gui=underline
   hi ansiUnderlineYellow   ctermfg=yellow     guifg=yellow                                       cterm=underline    gui=underline
   hi ansiUnderlineBlue     ctermfg=blue       guifg=blue                                         cterm=underline    gui=underline
   hi ansiUnderlineMagenta  ctermfg=magenta    guifg=magenta                                      cterm=underline    gui=underline
   hi ansiUnderlineCyan     ctermfg=cyan       guifg=cyan                                         cterm=underline    gui=underline
   hi ansiUnderlineWhite    ctermfg=white      guifg=white                                        cterm=underline    gui=underline
   hi ansiUnderlineGray     ctermfg=gray       guifg=gray                                         cterm=underline    gui=underline

   hi ansiBlinkBlack        ctermfg=black      guifg=black                                        cterm=standout     gui=undercurl
   hi ansiBlinkRed          ctermfg=red        guifg=red                                          cterm=standout     gui=undercurl
   hi ansiBlinkGreen        ctermfg=green      guifg=green                                        cterm=standout     gui=undercurl
   hi ansiBlinkYellow       ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=undercurl
   hi ansiBlinkBlue         ctermfg=blue       guifg=blue                                         cterm=standout     gui=undercurl
   hi ansiBlinkMagenta      ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=undercurl
   hi ansiBlinkCyan         ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=undercurl
   hi ansiBlinkWhite        ctermfg=white      guifg=white                                        cterm=standout     gui=undercurl
   hi ansiBlinkGray         ctermfg=gray       guifg=gray                                         cterm=standout     gui=undercurl

   hi ansiRapidBlinkBlack   ctermfg=black      guifg=black                                        cterm=standout     gui=undercurl
   hi ansiRapidBlinkRed     ctermfg=red        guifg=red                                          cterm=standout     gui=undercurl
   hi ansiRapidBlinkGreen   ctermfg=green      guifg=green                                        cterm=standout     gui=undercurl
   hi ansiRapidBlinkYellow  ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=undercurl
   hi ansiRapidBlinkBlue    ctermfg=blue       guifg=blue                                         cterm=standout     gui=undercurl
   hi ansiRapidBlinkMagenta ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=undercurl
   hi ansiRapidBlinkCyan    ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=undercurl
   hi ansiRapidBlinkWhite   ctermfg=white      guifg=white                                        cterm=standout     gui=undercurl
   hi ansiRapidBlinkGray    ctermfg=gray       guifg=gray                                         cterm=standout     gui=undercurl

   hi ansiRV                                                                                      cterm=reverse      gui=reverse
   hi ansiRVBlack           ctermfg=black      guifg=black                                        cterm=reverse      gui=reverse
   hi ansiRVRed             ctermfg=red        guifg=red                                          cterm=reverse      gui=reverse
   hi ansiRVGreen           ctermfg=green      guifg=green                                        cterm=reverse      gui=reverse
   hi ansiRVYellow          ctermfg=yellow     guifg=yellow                                       cterm=reverse      gui=reverse
   hi ansiRVBlue            ctermfg=blue       guifg=blue                                         cterm=reverse      gui=reverse
   hi ansiRVMagenta         ctermfg=magenta    guifg=magenta                                      cterm=reverse      gui=reverse
   hi ansiRVCyan            ctermfg=cyan       guifg=cyan                                         cterm=reverse      gui=reverse
   hi ansiRVWhite           ctermfg=white      guifg=white                                        cterm=reverse      gui=reverse
   hi ansiRVGray            ctermfg=gray       guifg=gray                                         cterm=reverse      gui=reverse

   hi ansiBlackBlack        ctermfg=black      ctermbg=black      guifg=Black      guibg=Black    cterm=none         gui=none
   hi ansiRedBlack          ctermfg=red        ctermbg=black      guifg=Red        guibg=Black    cterm=none         gui=none
   hi ansiGreenBlack        ctermfg=green      ctermbg=black      guifg=Green      guibg=Black    cterm=none         gui=none
   hi ansiYellowBlack       ctermfg=yellow     ctermbg=black      guifg=Yellow     guibg=Black    cterm=none         gui=none
   hi ansiBlueBlack         ctermfg=blue       ctermbg=black      guifg=Blue       guibg=Black    cterm=none         gui=none
   hi ansiMagentaBlack      ctermfg=magenta    ctermbg=black      guifg=Magenta    guibg=Black    cterm=none         gui=none
   hi ansiCyanBlack         ctermfg=cyan       ctermbg=black      guifg=Cyan       guibg=Black    cterm=none         gui=none
   hi ansiWhiteBlack        ctermfg=white      ctermbg=black      guifg=White      guibg=Black    cterm=none         gui=none
   hi ansiGrayBlack         ctermfg=gray       ctermbg=black      guifg=Gray       guibg=Black    cterm=none         gui=none

   hi ansiBlackRed          ctermfg=black      ctermbg=red        guifg=Black      guibg=Red      cterm=none         gui=none
   hi ansiRedRed            ctermfg=red        ctermbg=red        guifg=Red        guibg=Red      cterm=none         gui=none
   hi ansiGreenRed          ctermfg=green      ctermbg=red        guifg=Green      guibg=Red      cterm=none         gui=none
   hi ansiYellowRed         ctermfg=yellow     ctermbg=red        guifg=Yellow     guibg=Red      cterm=none         gui=none
   hi ansiBlueRed           ctermfg=blue       ctermbg=red        guifg=Blue       guibg=Red      cterm=none         gui=none
   hi ansiMagentaRed        ctermfg=magenta    ctermbg=red        guifg=Magenta    guibg=Red      cterm=none         gui=none
   hi ansiCyanRed           ctermfg=cyan       ctermbg=red        guifg=Cyan       guibg=Red      cterm=none         gui=none
   hi ansiWhiteRed          ctermfg=white      ctermbg=red        guifg=White      guibg=Red      cterm=none         gui=none
   hi ansiGrayRed           ctermfg=gray       ctermbg=red        guifg=Gray       guibg=Red      cterm=none         gui=none

   hi ansiBlackGreen        ctermfg=black      ctermbg=green      guifg=Black      guibg=Green    cterm=none         gui=none
   hi ansiRedGreen          ctermfg=red        ctermbg=green      guifg=Red        guibg=Green    cterm=none         gui=none
   hi ansiGreenGreen        ctermfg=green      ctermbg=green      guifg=Green      guibg=Green    cterm=none         gui=none
   hi ansiYellowGreen       ctermfg=yellow     ctermbg=green      guifg=Yellow     guibg=Green    cterm=none         gui=none
   hi ansiBlueGreen         ctermfg=blue       ctermbg=green      guifg=Blue       guibg=Green    cterm=none         gui=none
   hi ansiMagentaGreen      ctermfg=magenta    ctermbg=green      guifg=Magenta    guibg=Green    cterm=none         gui=none
   hi ansiCyanGreen         ctermfg=cyan       ctermbg=green      guifg=Cyan       guibg=Green    cterm=none         gui=none
   hi ansiWhiteGreen        ctermfg=white      ctermbg=green      guifg=White      guibg=Green    cterm=none         gui=none
   hi ansiGrayGreen         ctermfg=gray       ctermbg=green      guifg=Gray       guibg=Green    cterm=none         gui=none

   hi ansiBlackYellow       ctermfg=black      ctermbg=yellow     guifg=Black      guibg=Yellow   cterm=none         gui=none
   hi ansiRedYellow         ctermfg=red        ctermbg=yellow     guifg=Red        guibg=Yellow   cterm=none         gui=none
   hi ansiGreenYellow       ctermfg=green      ctermbg=yellow     guifg=Green      guibg=Yellow   cterm=none         gui=none
   hi ansiYellowYellow      ctermfg=yellow     ctermbg=yellow     guifg=Yellow     guibg=Yellow   cterm=none         gui=none
   hi ansiBlueYellow        ctermfg=blue       ctermbg=yellow     guifg=Blue       guibg=Yellow   cterm=none         gui=none
   hi ansiMagentaYellow     ctermfg=magenta    ctermbg=yellow     guifg=Magenta    guibg=Yellow   cterm=none         gui=none
   hi ansiCyanYellow        ctermfg=cyan       ctermbg=yellow     guifg=Cyan       guibg=Yellow   cterm=none         gui=none
   hi ansiWhiteYellow       ctermfg=white      ctermbg=yellow     guifg=White      guibg=Yellow   cterm=none         gui=none
   hi ansiGrayYellow        ctermfg=gray       ctermbg=yellow     guifg=Gray       guibg=Yellow   cterm=none         gui=none

   hi ansiBlackBlue         ctermfg=black      ctermbg=blue       guifg=Black      guibg=Blue     cterm=none         gui=none
   hi ansiRedBlue           ctermfg=red        ctermbg=blue       guifg=Red        guibg=Blue     cterm=none         gui=none
   hi ansiGreenBlue         ctermfg=green      ctermbg=blue       guifg=Green      guibg=Blue     cterm=none         gui=none
   hi ansiYellowBlue        ctermfg=yellow     ctermbg=blue       guifg=Yellow     guibg=Blue     cterm=none         gui=none
   hi ansiBlueBlue          ctermfg=blue       ctermbg=blue       guifg=Blue       guibg=Blue     cterm=none         gui=none
   hi ansiMagentaBlue       ctermfg=magenta    ctermbg=blue       guifg=Magenta    guibg=Blue     cterm=none         gui=none
   hi ansiCyanBlue          ctermfg=cyan       ctermbg=blue       guifg=Cyan       guibg=Blue     cterm=none         gui=none
   hi ansiWhiteBlue         ctermfg=white      ctermbg=blue       guifg=White      guibg=Blue     cterm=none         gui=none
   hi ansiGrayBlue          ctermfg=gray       ctermbg=blue       guifg=Gray       guibg=Blue     cterm=none         gui=none

   hi ansiBlackMagenta      ctermfg=black      ctermbg=magenta    guifg=Black      guibg=Magenta  cterm=none         gui=none
   hi ansiRedMagenta        ctermfg=red        ctermbg=magenta    guifg=Red        guibg=Magenta  cterm=none         gui=none
   hi ansiGreenMagenta      ctermfg=green      ctermbg=magenta    guifg=Green      guibg=Magenta  cterm=none         gui=none
   hi ansiYellowMagenta     ctermfg=yellow     ctermbg=magenta    guifg=Yellow     guibg=Magenta  cterm=none         gui=none
   hi ansiBlueMagenta       ctermfg=blue       ctermbg=magenta    guifg=Blue       guibg=Magenta  cterm=none         gui=none
   hi ansiMagentaMagenta    ctermfg=magenta    ctermbg=magenta    guifg=Magenta    guibg=Magenta  cterm=none         gui=none
   hi ansiCyanMagenta       ctermfg=cyan       ctermbg=magenta    guifg=Cyan       guibg=Magenta  cterm=none         gui=none
   hi ansiWhiteMagenta      ctermfg=white      ctermbg=magenta    guifg=White      guibg=Magenta  cterm=none         gui=none
   hi ansiGrayMagenta       ctermfg=gray       ctermbg=magenta    guifg=Gray       guibg=Magenta  cterm=none         gui=none

   hi ansiBlackCyan         ctermfg=black      ctermbg=cyan       guifg=Black      guibg=Cyan     cterm=none         gui=none
   hi ansiRedCyan           ctermfg=red        ctermbg=cyan       guifg=Red        guibg=Cyan     cterm=none         gui=none
   hi ansiGreenCyan         ctermfg=green      ctermbg=cyan       guifg=Green      guibg=Cyan     cterm=none         gui=none
   hi ansiYellowCyan        ctermfg=yellow     ctermbg=cyan       guifg=Yellow     guibg=Cyan     cterm=none         gui=none
   hi ansiBlueCyan          ctermfg=blue       ctermbg=cyan       guifg=Blue       guibg=Cyan     cterm=none         gui=none
   hi ansiMagentaCyan       ctermfg=magenta    ctermbg=cyan       guifg=Magenta    guibg=Cyan     cterm=none         gui=none
   hi ansiCyanCyan          ctermfg=cyan       ctermbg=cyan       guifg=Cyan       guibg=Cyan     cterm=none         gui=none
   hi ansiWhiteCyan         ctermfg=white      ctermbg=cyan       guifg=White      guibg=Cyan     cterm=none         gui=none
   hi ansiGrayCyan          ctermfg=gray       ctermbg=cyan       guifg=Gray       guibg=Cyan     cterm=none         gui=none

   hi ansiBlackWhite        ctermfg=black      ctermbg=white      guifg=Black      guibg=White    cterm=none         gui=none
   hi ansiRedWhite          ctermfg=red        ctermbg=white      guifg=Red        guibg=White    cterm=none         gui=none
   hi ansiGreenWhite        ctermfg=green      ctermbg=white      guifg=Green      guibg=White    cterm=none         gui=none
   hi ansiYellowWhite       ctermfg=yellow     ctermbg=white      guifg=Yellow     guibg=White    cterm=none         gui=none
   hi ansiBlueWhite         ctermfg=blue       ctermbg=white      guifg=Blue       guibg=White    cterm=none         gui=none
   hi ansiMagentaWhite      ctermfg=magenta    ctermbg=white      guifg=Magenta    guibg=White    cterm=none         gui=none
   hi ansiCyanWhite         ctermfg=cyan       ctermbg=white      guifg=Cyan       guibg=White    cterm=none         gui=none
   hi ansiWhiteWhite        ctermfg=white      ctermbg=white      guifg=White      guibg=White    cterm=none         gui=none
   hi ansiGrayWhite         ctermfg=gray       ctermbg=white      guifg=gray       guibg=White    cterm=none         gui=none

   hi ansiBlackGray         ctermfg=black      ctermbg=gray       guifg=Black      guibg=gray     cterm=none         gui=none
   hi ansiRedGray           ctermfg=red        ctermbg=gray       guifg=Red        guibg=gray     cterm=none         gui=none
   hi ansiGreenGray         ctermfg=green      ctermbg=gray       guifg=Green      guibg=gray     cterm=none         gui=none
   hi ansiYellowGray        ctermfg=yellow     ctermbg=gray       guifg=Yellow     guibg=gray     cterm=none         gui=none
   hi ansiBlueGray          ctermfg=blue       ctermbg=gray       guifg=Blue       guibg=gray     cterm=none         gui=none
   hi ansiMagentaGray       ctermfg=magenta    ctermbg=gray       guifg=Magenta    guibg=gray     cterm=none         gui=none
   hi ansiCyanGray          ctermfg=cyan       ctermbg=gray       guifg=Cyan       guibg=gray     cterm=none         gui=none
   hi ansiWhiteGray         ctermfg=white      ctermbg=gray       guifg=White      guibg=gray     cterm=none         gui=none
   hi ansiGrayGray          ctermfg=gray       ctermbg=gray       guifg=Gray       guibg=gray     cterm=none         gui=none

   if v:version >= 700 && exists("+t_Co") && &t_Co == 256 && exists("g:ansiesc_256color")
    " ---------------------------
    " handle 256-color terminals: {{{3
    " ---------------------------
"    call Decho("set up 256-color highlighting groups")
    let icolor= 1
    while icolor < 256
     let jcolor= 1
     exe "hi ansiHL_".icolor."_0 ctermfg=".icolor
     exe "hi ansiHL_0_".icolor." ctermbg=".icolor
"     call Decho("exe hi ansiHL_".icolor." ctermfg=".icolor)
     while jcolor < 256
      exe "hi ansiHL_".icolor."_".jcolor." ctermfg=".icolor." ctermbg=".jcolor
"      call Decho("exe hi ansiHL_".icolor."_".jcolor." ctermfg=".icolor." ctermbg=".jcolor)
      let jcolor= jcolor + 1
     endwhile
     let icolor= icolor + 1
    endwhile
   endif

  else
   " ----------------------------------
   " not 8 or 256 color terminals (gui): {{{3
   " ----------------------------------
"   call Decho("set up gui highlighting groups")
   hi ansiBlack             ctermfg=black      guifg=black                                        cterm=none         gui=none
   hi ansiRed               ctermfg=red        guifg=red                                          cterm=none         gui=none
   hi ansiGreen             ctermfg=green      guifg=green                                        cterm=none         gui=none
   hi ansiYellow            ctermfg=yellow     guifg=yellow                                       cterm=none         gui=none
   hi ansiBlue              ctermfg=blue       guifg=blue                                         cterm=none         gui=none
   hi ansiMagenta           ctermfg=magenta    guifg=magenta                                      cterm=none         gui=none
   hi ansiCyan              ctermfg=cyan       guifg=cyan                                         cterm=none         gui=none
   hi ansiWhite             ctermfg=white      guifg=white                                        cterm=none         gui=none

   hi ansiBlackBg           ctermbg=black      guibg=black                                        cterm=none         gui=none
   hi ansiRedBg             ctermbg=red        guibg=red                                          cterm=none         gui=none
   hi ansiGreenBg           ctermbg=green      guibg=green                                        cterm=none         gui=none
   hi ansiYellowBg          ctermbg=yellow     guibg=yellow                                       cterm=none         gui=none
   hi ansiBlueBg            ctermbg=blue       guibg=blue                                         cterm=none         gui=none
   hi ansiMagentaBg         ctermbg=magenta    guibg=magenta                                      cterm=none         gui=none
   hi ansiCyanBg            ctermbg=cyan       guibg=cyan                                         cterm=none         gui=none
   hi ansiWhiteBg           ctermbg=white      guibg=white                                        cterm=none         gui=none

   hi ansiBlackFg           ctermfg=black      guifg=black                                        cterm=none         gui=none
   hi ansiRedFg             ctermfg=red        guifg=red                                          cterm=none         gui=none
   hi ansiGreenFg           ctermfg=green      guifg=green                                        cterm=none         gui=none
   hi ansiYellowFg          ctermfg=yellow     guifg=yellow                                       cterm=none         gui=none
   hi ansiBlueFg            ctermfg=blue       guifg=blue                                         cterm=none         gui=none
   hi ansiMagentaFg         ctermfg=magenta    guifg=magenta                                      cterm=none         gui=none
   hi ansiCyanFg            ctermfg=cyan       guifg=cyan                                         cterm=none         gui=none
   hi ansiWhiteFg           ctermfg=white      guifg=white                                        cterm=none         gui=none

   hi ansiBoldBlack         ctermfg=black      guifg=black                                        cterm=bold         gui=bold
   hi ansiBoldRed           ctermfg=red        guifg=red                                          cterm=bold         gui=bold
   hi ansiBoldGreen         ctermfg=green      guifg=green                                        cterm=bold         gui=bold
   hi ansiBoldYellow        ctermfg=yellow     guifg=yellow                                       cterm=bold         gui=bold
   hi ansiBoldBlue          ctermfg=blue       guifg=blue                                         cterm=bold         gui=bold
   hi ansiBoldMagenta       ctermfg=magenta    guifg=magenta                                      cterm=bold         gui=bold
   hi ansiBoldCyan          ctermfg=cyan       guifg=cyan                                         cterm=bold         gui=bold
   hi ansiBoldWhite         ctermfg=white      guifg=white                                        cterm=bold         gui=bold

   hi ansiStandoutBlack     ctermfg=black      guifg=black                                        cterm=standout     gui=standout
   hi ansiStandoutRed       ctermfg=red        guifg=red                                          cterm=standout     gui=standout
   hi ansiStandoutGreen     ctermfg=green      guifg=green                                        cterm=standout     gui=standout
   hi ansiStandoutYellow    ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=standout
   hi ansiStandoutBlue      ctermfg=blue       guifg=blue                                         cterm=standout     gui=standout
   hi ansiStandoutMagenta   ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=standout
   hi ansiStandoutCyan      ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=standout
   hi ansiStandoutWhite     ctermfg=white      guifg=white                                        cterm=standout     gui=standout

   hi ansiItalicBlack       ctermfg=black      guifg=black                                        cterm=italic       gui=italic
   hi ansiItalicRed         ctermfg=red        guifg=red                                          cterm=italic       gui=italic
   hi ansiItalicGreen       ctermfg=green      guifg=green                                        cterm=italic       gui=italic
   hi ansiItalicYellow      ctermfg=yellow     guifg=yellow                                       cterm=italic       gui=italic
   hi ansiItalicBlue        ctermfg=blue       guifg=blue                                         cterm=italic       gui=italic
   hi ansiItalicMagenta     ctermfg=magenta    guifg=magenta                                      cterm=italic       gui=italic
   hi ansiItalicCyan        ctermfg=cyan       guifg=cyan                                         cterm=italic       gui=italic
   hi ansiItalicWhite       ctermfg=white      guifg=white                                        cterm=italic       gui=italic

   hi ansiUnderlineBlack    ctermfg=black      guifg=black                                        cterm=underline    gui=underline
   hi ansiUnderlineRed      ctermfg=red        guifg=red                                          cterm=underline    gui=underline
   hi ansiUnderlineGreen    ctermfg=green      guifg=green                                        cterm=underline    gui=underline
   hi ansiUnderlineYellow   ctermfg=yellow     guifg=yellow                                       cterm=underline    gui=underline
   hi ansiUnderlineBlue     ctermfg=blue       guifg=blue                                         cterm=underline    gui=underline
   hi ansiUnderlineMagenta  ctermfg=magenta    guifg=magenta                                      cterm=underline    gui=underline
   hi ansiUnderlineCyan     ctermfg=cyan       guifg=cyan                                         cterm=underline    gui=underline
   hi ansiUnderlineWhite    ctermfg=white      guifg=white                                        cterm=underline    gui=underline

   hi ansiBlinkBlack        ctermfg=black      guifg=black                                        cterm=standout     gui=undercurl
   hi ansiBlinkRed          ctermfg=red        guifg=red                                          cterm=standout     gui=undercurl
   hi ansiBlinkGreen        ctermfg=green      guifg=green                                        cterm=standout     gui=undercurl
   hi ansiBlinkYellow       ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=undercurl
   hi ansiBlinkBlue         ctermfg=blue       guifg=blue                                         cterm=standout     gui=undercurl
   hi ansiBlinkMagenta      ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=undercurl
   hi ansiBlinkCyan         ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=undercurl
   hi ansiBlinkWhite        ctermfg=white      guifg=white                                        cterm=standout     gui=undercurl

   hi ansiRapidBlinkBlack   ctermfg=black      guifg=black                                        cterm=standout     gui=undercurl
   hi ansiRapidBlinkRed     ctermfg=red        guifg=red                                          cterm=standout     gui=undercurl
   hi ansiRapidBlinkGreen   ctermfg=green      guifg=green                                        cterm=standout     gui=undercurl
   hi ansiRapidBlinkYellow  ctermfg=yellow     guifg=yellow                                       cterm=standout     gui=undercurl
   hi ansiRapidBlinkBlue    ctermfg=blue       guifg=blue                                         cterm=standout     gui=undercurl
   hi ansiRapidBlinkMagenta ctermfg=magenta    guifg=magenta                                      cterm=standout     gui=undercurl
   hi ansiRapidBlinkCyan    ctermfg=cyan       guifg=cyan                                         cterm=standout     gui=undercurl
   hi ansiRapidBlinkWhite   ctermfg=white      guifg=white                                        cterm=standout     gui=undercurl

   hi ansiRV                                                                                      cterm=reverse      gui=reverse
   hi ansiRVBlack           ctermfg=black      guifg=black                                        cterm=reverse      gui=reverse
   hi ansiRVRed             ctermfg=red        guifg=red                                          cterm=reverse      gui=reverse
   hi ansiRVGreen           ctermfg=green      guifg=green                                        cterm=reverse      gui=reverse
   hi ansiRVYellow          ctermfg=yellow     guifg=yellow                                       cterm=reverse      gui=reverse
   hi ansiRVBlue            ctermfg=blue       guifg=blue                                         cterm=reverse      gui=reverse
   hi ansiRVMagenta         ctermfg=magenta    guifg=magenta                                      cterm=reverse      gui=reverse
   hi ansiRVCyan            ctermfg=cyan       guifg=cyan                                         cterm=reverse      gui=reverse
   hi ansiRVWhite           ctermfg=white      guifg=white                                        cterm=reverse      gui=reverse

   hi ansiBlackBlack        ctermfg=black      ctermbg=black      guifg=Black      guibg=Black    cterm=none         gui=none
   hi ansiRedBlack          ctermfg=black      ctermbg=black      guifg=Black      guibg=Black    cterm=none         gui=none
   hi ansiRedBlack          ctermfg=red        ctermbg=black      guifg=Red        guibg=Black    cterm=none         gui=none
   hi ansiGreenBlack        ctermfg=green      ctermbg=black      guifg=Green      guibg=Black    cterm=none         gui=none
   hi ansiYellowBlack       ctermfg=yellow     ctermbg=black      guifg=Yellow     guibg=Black    cterm=none         gui=none
   hi ansiBlueBlack         ctermfg=blue       ctermbg=black      guifg=Blue       guibg=Black    cterm=none         gui=none
   hi ansiMagentaBlack      ctermfg=magenta    ctermbg=black      guifg=Magenta    guibg=Black    cterm=none         gui=none
   hi ansiCyanBlack         ctermfg=cyan       ctermbg=black      guifg=Cyan       guibg=Black    cterm=none         gui=none
   hi ansiWhiteBlack        ctermfg=white      ctermbg=black      guifg=White      guibg=Black    cterm=none         gui=none

   hi ansiBlackRed          ctermfg=black      ctermbg=red        guifg=Black      guibg=Red      cterm=none         gui=none
   hi ansiRedRed            ctermfg=red        ctermbg=red        guifg=Red        guibg=Red      cterm=none         gui=none
   hi ansiGreenRed          ctermfg=green      ctermbg=red        guifg=Green      guibg=Red      cterm=none         gui=none
   hi ansiYellowRed         ctermfg=yellow     ctermbg=red        guifg=Yellow     guibg=Red      cterm=none         gui=none
   hi ansiBlueRed           ctermfg=blue       ctermbg=red        guifg=Blue       guibg=Red      cterm=none         gui=none
   hi ansiMagentaRed        ctermfg=magenta    ctermbg=red        guifg=Magenta    guibg=Red      cterm=none         gui=none
   hi ansiCyanRed           ctermfg=cyan       ctermbg=red        guifg=Cyan       guibg=Red      cterm=none         gui=none
   hi ansiWhiteRed          ctermfg=white      ctermbg=red        guifg=White      guibg=Red      cterm=none         gui=none

   hi ansiBlackGreen        ctermfg=black      ctermbg=green      guifg=Black      guibg=Green    cterm=none         gui=none
   hi ansiRedGreen          ctermfg=red        ctermbg=green      guifg=Red        guibg=Green    cterm=none         gui=none
   hi ansiGreenGreen        ctermfg=green      ctermbg=green      guifg=Green      guibg=Green    cterm=none         gui=none
   hi ansiYellowGreen       ctermfg=yellow     ctermbg=green      guifg=Yellow     guibg=Green    cterm=none         gui=none
   hi ansiBlueGreen         ctermfg=blue       ctermbg=green      guifg=Blue       guibg=Green    cterm=none         gui=none
   hi ansiMagentaGreen      ctermfg=magenta    ctermbg=green      guifg=Magenta    guibg=Green    cterm=none         gui=none
   hi ansiCyanGreen         ctermfg=cyan       ctermbg=green      guifg=Cyan       guibg=Green    cterm=none         gui=none
   hi ansiWhiteGreen        ctermfg=white      ctermbg=green      guifg=White      guibg=Green    cterm=none         gui=none

   hi ansiBlackYellow       ctermfg=black      ctermbg=yellow     guifg=Black      guibg=Yellow   cterm=none         gui=none
   hi ansiRedYellow         ctermfg=red        ctermbg=yellow     guifg=Red        guibg=Yellow   cterm=none         gui=none
   hi ansiGreenYellow       ctermfg=green      ctermbg=yellow     guifg=Green      guibg=Yellow   cterm=none         gui=none
   hi ansiYellowYellow      ctermfg=yellow     ctermbg=yellow     guifg=Yellow     guibg=Yellow   cterm=none         gui=none
   hi ansiBlueYellow        ctermfg=blue       ctermbg=yellow     guifg=Blue       guibg=Yellow   cterm=none         gui=none
   hi ansiMagentaYellow     ctermfg=magenta    ctermbg=yellow     guifg=Magenta    guibg=Yellow   cterm=none         gui=none
   hi ansiCyanYellow        ctermfg=cyan       ctermbg=yellow     guifg=Cyan       guibg=Yellow   cterm=none         gui=none
   hi ansiWhiteYellow       ctermfg=white      ctermbg=yellow     guifg=White      guibg=Yellow   cterm=none         gui=none

   hi ansiBlackBlue         ctermfg=black      ctermbg=blue       guifg=Black      guibg=Blue     cterm=none         gui=none
   hi ansiRedBlue           ctermfg=red        ctermbg=blue       guifg=Red        guibg=Blue     cterm=none         gui=none
   hi ansiGreenBlue         ctermfg=green      ctermbg=blue       guifg=Green      guibg=Blue     cterm=none         gui=none
   hi ansiYellowBlue        ctermfg=yellow     ctermbg=blue       guifg=Yellow     guibg=Blue     cterm=none         gui=none
   hi ansiBlueBlue          ctermfg=blue       ctermbg=blue       guifg=Blue       guibg=Blue     cterm=none         gui=none
   hi ansiMagentaBlue       ctermfg=magenta    ctermbg=blue       guifg=Magenta    guibg=Blue     cterm=none         gui=none
   hi ansiCyanBlue          ctermfg=cyan       ctermbg=blue       guifg=Cyan       guibg=Blue     cterm=none         gui=none
   hi ansiWhiteBlue         ctermfg=white      ctermbg=blue       guifg=White      guibg=Blue     cterm=none         gui=none

   hi ansiBlackMagenta      ctermfg=black      ctermbg=magenta    guifg=Black      guibg=Magenta  cterm=none         gui=none
   hi ansiRedMagenta        ctermfg=red        ctermbg=magenta    guifg=Red        guibg=Magenta  cterm=none         gui=none
   hi ansiGreenMagenta      ctermfg=green      ctermbg=magenta    guifg=Green      guibg=Magenta  cterm=none         gui=none
   hi ansiYellowMagenta     ctermfg=yellow     ctermbg=magenta    guifg=Yellow     guibg=Magenta  cterm=none         gui=none
   hi ansiBlueMagenta       ctermfg=blue       ctermbg=magenta    guifg=Blue       guibg=Magenta  cterm=none         gui=none
   hi ansiMagentaMagenta    ctermfg=magenta    ctermbg=magenta    guifg=Magenta    guibg=Magenta  cterm=none         gui=none
   hi ansiCyanMagenta       ctermfg=cyan       ctermbg=magenta    guifg=Cyan       guibg=Magenta  cterm=none         gui=none
   hi ansiWhiteMagenta      ctermfg=white      ctermbg=magenta    guifg=White      guibg=Magenta  cterm=none         gui=none

   hi ansiBlackCyan         ctermfg=black      ctermbg=cyan       guifg=Black      guibg=Cyan     cterm=none         gui=none
   hi ansiRedCyan           ctermfg=red        ctermbg=cyan       guifg=Red        guibg=Cyan     cterm=none         gui=none
   hi ansiGreenCyan         ctermfg=green      ctermbg=cyan       guifg=Green      guibg=Cyan     cterm=none         gui=none
   hi ansiYellowCyan        ctermfg=yellow     ctermbg=cyan       guifg=Yellow     guibg=Cyan     cterm=none         gui=none
   hi ansiBlueCyan          ctermfg=blue       ctermbg=cyan       guifg=Blue       guibg=Cyan     cterm=none         gui=none
   hi ansiMagentaCyan       ctermfg=magenta    ctermbg=cyan       guifg=Magenta    guibg=Cyan     cterm=none         gui=none
   hi ansiCyanCyan          ctermfg=cyan       ctermbg=cyan       guifg=Cyan       guibg=Cyan     cterm=none         gui=none
   hi ansiWhiteCyan         ctermfg=white      ctermbg=cyan       guifg=White      guibg=Cyan     cterm=none         gui=none

   hi ansiBlackWhite        ctermfg=black      ctermbg=white      guifg=Black      guibg=White    cterm=none         gui=none
   hi ansiRedWhite          ctermfg=red        ctermbg=white      guifg=Red        guibg=White    cterm=none         gui=none
   hi ansiGreenWhite        ctermfg=green      ctermbg=white      guifg=Green      guibg=White    cterm=none         gui=none
   hi ansiYellowWhite       ctermfg=yellow     ctermbg=white      guifg=Yellow     guibg=White    cterm=none         gui=none
   hi ansiBlueWhite         ctermfg=blue       ctermbg=white      guifg=Blue       guibg=White    cterm=none         gui=none
   hi ansiMagentaWhite      ctermfg=magenta    ctermbg=white      guifg=Magenta    guibg=White    cterm=none         gui=none
   hi ansiCyanWhite         ctermfg=cyan       ctermbg=white      guifg=Cyan       guibg=White    cterm=none         gui=none
   hi ansiWhiteWhite        ctermfg=white      ctermbg=white      guifg=White      guibg=White    cterm=none         gui=none
  endif
"  call Dret("AnsiEsc#AnsiEsc")
endfun

" ---------------------------------------------------------------------
" s:MultiElementHandler: builds custom syntax highlighting for three or more element ansi escape sequences {{{2
fun! s:MultiElementHandler()
"  call Dfunc("s:MultiElementHandler()")
  let curwp= SaveWinPosn(0)
  keepj 1
  keepj norm! 0
  let mehcnt = 0
  let mehrules     = []
  while search('\e\[;\=\d\+;\d\+;\d\+\(;\d\+\)*m','cW')
   let curcol  = col(".")+1
   call search('m','cW')
   let mcol    = col(".")
   let ansiesc = strpart(getline("."),curcol,mcol - curcol)
   let aecodes = split(ansiesc,'[;m]')
"   call Decho("ansiesc<".ansiesc."> aecodes=".string(aecodes))
   let skip         = 0
   let mod          = "NONE,"
   let fg           = ""
   let bg           = ""

   " if the ansiesc is
   if index(mehrules,ansiesc) == -1
    let mehrules+= [ansiesc]

    for code in aecodes

     " handle multi-code sequences (38;5;color  and 48;5;color)
     if skip == 38 && code == 5
      " handling <esc>[38;5
      let skip= 385
"      call Decho(" 1: building code=".code." skip=".skip.": mod<".mod."> fg<".fg."> bg<".bg.">")
      continue
     elseif skip == 385
      " handling <esc>[38;5;...
      if has("gui") && has("gui_running")
       let fg= s:Ansi2Gui(code)
      else
       let fg= code
      endif
      let skip= 0
"      call Decho(" 2: building code=".code." skip=".skip.": mod<".mod."> fg<".fg."> bg<".bg.">")
      continue

     elseif skip == 48 && code == 5
      " handling <esc>[48;5
      let skip= 485
"      call Decho(" 3: building code=".code." skip=".skip.": mod<".mod."> fg<".fg."> bg<".bg.">")
      continue
     elseif skip == 485
      " handling <esc>[48;5;...
      if has("gui") && has("gui_running")
       let bg= s:Ansi2Gui(code)
      else
       let bg= code
      endif
      let skip= 0
"      call Decho(" 4: building code=".code." skip=".skip.": mod<".mod."> fg<".fg."> bg<".bg.">")
      continue

     else
      let skip= 0
     endif

     " handle single-code sequences
     if code == 1
      let mod=mod."bold,"
     elseif code == 2
      let mod=mod."italic,"
     elseif code == 3
      let mod=mod."standout,"
     elseif code == 4
      let mod=mod."underline,"
     elseif code == 5 || code == 6
      let mod=mod."undercurl,"
     elseif code == 7
      let mod=mod."reverse,"

     elseif code == 30
      if has("gui") && has("gui_running") && mod =~ "bold"
        let fg= "gray18"
       else
        let fg= "black"
       endif
     elseif code == 31
      if has("gui") && has("gui_running") && mod =~ "bold"
       let fg= "red3"
      else
       let fg= "red"
      endif
     elseif code == 32
      if has("gui") && has("gui_running") && mod =~ "bold"
       let fg= "green3"
      else
       let fg= "green"
      endif
     elseif code == 33
      if has("gui") && has("gui_running") && mod =~ "bold"
       let fg= "yellow3"
      else
       let fg= "yellow"
      endif
     elseif code == 34
      if has("gui") && has("gui_running") && mod =~ "bold"
       let fg= "blue3"
      else
       let fg= "blue"
      endif
     elseif code == 35
      if has("gui") && has("gui_running") && mod =~ "bold"
       let fg= "magenta3"
      else
       let fg= "magenta"
      endif
     elseif code == 36
      if has("gui") && has("gui_running") && mod =~ "bold"
       let fg= "cyan3"
      else
       let fg= "cyan"
      endif
     elseif code == 37
      if has("gui") && has("gui_running") && mod =~ "bold"
       let fg= "gray81"
      else
       let fg= "white"
      endif

     elseif code == 40
      if has("gui") && has("gui_running") && mod =~ "bold"
       let bg= "gray9"
      else
       let bg= "black"
      endif
     elseif code == 41
      if has("gui") && has("gui_running") && mod =~ "bold"
       let bg= "red4"
      else
       let bg= "red"
      endif
     elseif code == 42
      if has("gui") && has("gui_running") && mod =~ "bold"
       let bg= "green4"
      else
       let bg= "green"
      endif
     elseif code == 43
      if has("gui") && has("gui_running") && mod =~ "bold"
       let bg= "yellow4"
      else
       let bg= "yellow"
      endif
     elseif code == 44
      if has("gui") && has("gui_running") && mod =~ "bold"
       let bg= "blue4"
      else
       let bg= "blue"
      endif
     elseif code == 45
      if has("gui") && has("gui_running") && mod =~ "bold"
       let bg= "magenta4"
      else
       let bg= "magenta"
      endif
     elseif code == 46
      if has("gui") && has("gui_running") && mod =~ "bold"
       let bg= "cyan4"
      else
       let bg= "cyan"
      endif
     elseif code == 47
      if has("gui") && has("gui_running") && mod =~ "bold"
       let bg= "gray50"
      else
       let bg= "white"
      endif

     elseif code == 38
      let skip= 38

     elseif code == 48
      let skip= 48
     endif

"     call Decho(" 5: building code=".code." skip=".skip.": mod<".mod."> fg<".fg."> bg<".bg.">")
    endfor

    " fixups
    let mod= substitute(mod,',$','','')

    " build syntax-recognition rule
    "   (ansi-escape multi-element handler rule)
    let mehcnt  = mehcnt + 1
    let synrule = "syn region ansiMEH".mehcnt
    let synrule = synrule.' start="\e\['.ansiesc.'"'
    let synrule = synrule.' end="\ze\e\["'
    let synrule = synrule." containedin=TOP contained contains=ansiConceal"
"    call Decho(" exe synrule: ".synrule)
    exe synrule

    " build highlighting rule
    let hirule= "hi ansiMEH".mehcnt
    if has("gui") && has("gui_running")
     let hirule=hirule." gui=".mod
     if fg != ""| let hirule=hirule." guifg=".fg| endif
     if bg != ""| let hirule=hirule." guibg=".bg| endif
    else
     let hirule=hirule." cterm=".mod
     if fg != ""| let hirule=hirule." ctermfg=".fg| endif
     if bg != ""| let hirule=hirule." ctermbg=".bg| endif
    endif
"    call Decho(" exe hirule: ".hirule)
    exe hirule
   endif

  endwhile

  call RestoreWinPosn(curwp)
"  call Dret("s:MultiElementHandler")
endfun

" ---------------------------------------------------------------------
" s:Ansi2Gui: converts an ansi-escape sequence (for 256-color xterms) {{{2
"           to an equivalent gui color
"           colors   0- 15:
"           colors  16-231:  6x6x6 color cube, code= 16+r*36+g*6+b  with r,g,b each in [0,5]
"           colors 232-255:  grayscale ramp,   code= 10*gray + 8    with gray in [0,23] (black,white left out)
fun! s:Ansi2Gui(code)
"  call Dfunc("s:Ansi2Gui(code=)".a:code)
  let guicolor= a:code
  if a:code < 16
   let code2rgb = [ "black", "red3", "green3", "yellow3", "blue3", "magenta3", "cyan3", "gray70", "gray40", "red", "green", "yellow", "royalblue3", "magenta", "cyan", "white"]
   let guicolor = code2rgb[a:code]
  elseif a:code >= 232
   let code     = a:code - 232
   let code     = 10*code + 8
   let guicolor = printf("#%02x%02x%02x",code,code,code)
  else
   let code     = a:code - 16
   let code2rgb = [43,85,128,170,213,255]
   let r        = code2rgb[code/36]
   let g        = code2rgb[(code%36)/6]
   let b        = code2rgb[code%6]
   let guicolor = printf("#%02x%02x%02x",r,g,b)
  endif
"  call Dret("s:Ansi2Gui ".guicolor)
  return guicolor
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim: ts=12 fdm=marker
