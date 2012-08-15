"---------------------------------------------------------------------------
" .vimrc
"---------------------------------------------------------------------------
" Initialize:"{{{
"
set nocompatible

augroup MyVimrcCmd
    autocmd!
augroup END

let s:MSWindows = has('win95') + has('win16') + has('win32') + has('win64')
let s:Android = executable('uname') ? system('uname -m')=~'armv7' : 0

if s:MSWindows
    let $DOTVIM = expand($VIM . '/vimfiles')
else
    let $DOTVIM = expand('~/.vim')
endif

let $MYLOCALVIMRC = $DOTVIM.'/.local.vimrc'

nnoremap <silent> <Space>ev  :<C-u>edit $MYVIMRC<CR>
nnoremap <silent> <Space>eg  :<C-u>edit $MYGVIMRC<CR>
nnoremap <silent> <Space>el  :<C-u>edit $MYLOCALVIMRC<CR>

nnoremap <silent> <Space>tv  :<C-u>tabedit $MYVIMRC<CR>
nnoremap <silent> <Space>tg  :<C-u>tabedit $MYGVIMRC<CR>
nnoremap <silent> <Space>tl  :<C-u>tabedit $MYLOCALVIMRC<CR>

nnoremap <silent> <Space>rv :<C-u>source $MYVIMRC \| if has('gui_running') \| source $MYGVIMRC \| endif <CR>
nnoremap <silent> <Space>rg :<C-u>source $MYGVIMRC<CR>
nnoremap <silent> <Space>rl :<C-u>if 1 && filereadable($MYLOCALVIMRC) \| source $MYLOCALVIMRC \| endif <CR>

if has('win32') || has('win64')
    " set shellslash
    set visualbell t_vb=
endif
nnoremap <Space>o/ :<C-u>setlocal shellslash!\|setlocal shellslash?<CR>

set noautochdir
nnoremap <Space>oc :<C-u>setlocal autochdir!\|setlocal autochdir?<CR>

"---------------------------------------------------------------------------
" Encoding:"{{{
"
" based on encode.vim
" https://sites.google.com/site/fudist/Home/vim-nihongo-ban/vim-utf8
if !has('gui_macvim')
    if !has('gui_running') && s:MSWindows
        set termencoding=cp932
        set encoding=cp932
    elseif s:MSWindows
        set termencoding=cp932
        set encoding=utf-8
    else
        set encoding=utf-8
    endif

    "set default fileencodings
    if &encoding == 'utf-8'
        set fileencodings=ucs-bom,utf-8,default,latin1
    elseif &encoding == 'cp932'
        set fileencodings=ucs-bom
    endif

    " set fileencodings for character code automatic recognition
    if &encoding !=# 'utf-8'
        set encoding=japan
        set fileencoding=japan
    endif
    if has('iconv')
        let s:enc_euc = 'euc-jp'
        let s:enc_jis = 'iso-2022-jp'
        " check whether iconv supports eucJP-ms.
        if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
            let s:enc_euc = 'eucjp-ms'
            let s:enc_jis = 'iso-2022-jp-3'
            " check whether iconv supports JISX0213.
        elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
            let s:enc_euc = 'euc-jisx0213'
            let s:enc_jis = 'iso-2022-jp-3'
        endif
        " build fileencodings
        if &encoding ==# 'utf-8'
            let s:fileencodings_default = &fileencodings
            let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
            let &fileencodings = &fileencodings .','. s:fileencodings_default
            unlet s:fileencodings_default
        else
            let &fileencodings = &fileencodings .','. s:enc_jis
            set fileencodings+=utf-8,ucs-2le,ucs-2
            if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
                set fileencodings+=cp932
                set fileencodings-=euc-jp
                set fileencodings-=euc-jisx0213
                set fileencodings-=eucjp-ms
                let &encoding = s:enc_euc
                let &fileencoding = s:enc_euc
            else
                let &fileencodings = &fileencodings .','. s:enc_euc
            endif
        endif
        " give priority to utf-8
        if &encoding == 'utf-8'
            set fileencodings-=utf-8
            let &fileencodings = substitute(&fileencodings, s:enc_jis, s:enc_jis.',utf-8','')
        endif

        " clean up constant
        unlet s:enc_euc
        unlet s:enc_jis
    endif

    " set fileformats automatic recognition
    if s:MSWindows
        set fileformats=dos,unix,mac
    else
        set fileformats=unix,mac,dos
    endif

    " to use the encoding to fileencoding when not included the Japanese
    if has('autocmd')
        function! AU_ReCheck_FENC()
            if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
                let &fileencoding=&encoding
                if s:MSWindows
                    let &fileencoding='cp932'
                endif
            endif
        endfunction
        autocmd MyVimrcCmd BufReadPost * call AU_ReCheck_FENC()
    endif

    " When internal encoding is not cp932 in Windows,
    " and environment variable contains multi-byte character
    command! -nargs=+ Let call Let__EnvVar__(<q-args>)
    function! Let__EnvVar__(cmd)
        let cmd = 'let ' . a:cmd
        if has('win32') + has('win64') && has('iconv') && &enc != 'cp932'
            let cmd = iconv(cmd, &enc, 'cp932')
        endif
        exec cmd
    endfunction
endif
"}}}

"---------------------------------------------------------------------------
" Kaoriya:"{{{
"
if exists('g:no_vimrc_example') && g:no_vimrc_example == 1
    silent! source $VIMRUNTIME/vimrc_example.vim
endif
"}}}

"---------------------------------------------------------------------------
" MacVim:"{{{
"
if has('mac')
    set macmeta
endif
"}}}

"---------------------------------------------------------------------------
" MSWIN:"{{{
"
if (1 && filereadable($VIMRUNTIME . '/mswin.vim')) && !s:Android
    source $VIMRUNTIME/mswin.vim
endif

" some textobj plugins doesn't work on selection=exclusive
set selection=inclusive

" Redefinition <C-A>:increment and <C-X>:decrement
noremap <C-i> <C-A>
noremap <M-i> <C-X>
"}}}
"}}}

"---------------------------------------------------------------------------
" Load Plugins:"{{{
"
filetype off
filetype plugin indent off

"---------------------------------------------------------------------------
" neobundle.vim:"{{{
"
if has('vim_starting')
    set runtimepath+=$DOTVIM/Bundle/neobundle.vim/
endif

if s:Android
    let $GITHUB_COM = 'git://207.97.227.239/'
else
    let $GITHUB_COM = 'git://github.com/'
endif

let $BITBUCKET_ORG = 'https://bitbucket.org/'

command! -nargs=* MyNeoBundle call MyNeoBundle(<q-args>)
function! MyNeoBundle(args)
    let args = split(a:args)
    if len(args) < 1
        return
    endif

    if eval(args[0])
        execute 'NeoBundle ' . join(args[1:])
    endif
endfunction

try
    call neobundle#rc($DOTVIM . '/Bundle/')

    " plugin management
    NeoBundle $GITHUB_COM.'Shougo/neobundle.vim.git'

    " doc
    NeoBundle $GITHUB_COM.'vim-jp/vimdoc-ja.git'
    NeoBundleLazy $GITHUB_COM.'thinca/vim-ref.git'

    " completion
    NeoBundle $GITHUB_COM.'Shougo/neocomplcache.git'
    NeoBundle $GITHUB_COM.'Shougo/neocomplcache-snippets-complete.git'
    MyNeoBundle !s:Android $GITHUB_COM.'Rip-Rip/clang_complete.git'
    MyNeoBundle !s:Android $GITHUB_COM.'osyo-manga/neocomplcache-clang_complete.git'
    MyNeoBundle !s:Android $GITHUB_COM.'ujihisa/neco-ghc.git'
    NeoBundle $GITHUB_COM.'teramako/jscomplete-vim.git'

    " ctags
    NeoBundleLazy $GITHUB_COM.'vim-scripts/taglist.vim.git'
    if executable('hg')
        NeoBundleLazy $BITBUCKET_ORG.'abudden/taghighlight', {'type': 'hg'}
    endif

    " vcs
    NeoBundle $GITHUB_COM.'tpope/vim-fugitive.git'
    NeoBundle $GITHUB_COM.'gregsexton/gitv.git'
    NeoBundle $GITHUB_COM.'int3/vim-extradite.git'

    " unite
    NeoBundle $GITHUB_COM.'Shougo/unite.vim.git'
    MyNeoBundle !s:Android $GITHUB_COM.'Shougo/unite-build.git'
    NeoBundle $GITHUB_COM.'ujihisa/unite-colorscheme.git'
    NeoBundleLazy $GITHUB_COM.'ujihisa/quicklearn.git'
    NeoBundle $GITHUB_COM.'sgur/unite-qf.git'
    NeoBundle $GITHUB_COM.'h1mesuke/unite-outline.git'
    NeoBundle $GITHUB_COM.'h1mesuke/vim-alignta.git'
    NeoBundle $GITHUB_COM.'tsukkee/unite-help.git'
    MyNeoBundle !s:Android $GITHUB_COM.'tsukkee/unite-tag.git'
    NeoBundle $GITHUB_COM.'tacroe/unite-mark.git'
    MyNeoBundle !s:Android $GITHUB_COM.'sgur/unite-everything.git'
    NeoBundle $GITHUB_COM.'zhaocai/unite-scriptnames.git'
    NeoBundle $GITHUB_COM.'pasela/unite-webcolorname.git'
    NeoBundle $GITHUB_COM.'daisuzu/unite-grep_launcher.git'
    MyNeoBundle !s:Android $GITHUB_COM.'daisuzu/unite-gtags.git'

    " textobj
    NeoBundle $GITHUB_COM.'kana/vim-textobj-user.git'
    NeoBundle $GITHUB_COM.'kana/vim-textobj-indent.git'
    NeoBundle $GITHUB_COM.'kana/vim-textobj-syntax.git'
    NeoBundle $GITHUB_COM.'kana/vim-textobj-line.git'
    NeoBundle $GITHUB_COM.'kana/vim-textobj-fold.git'
    NeoBundle $GITHUB_COM.'kana/vim-textobj-entire.git'
    NeoBundle $GITHUB_COM.'thinca/vim-textobj-between.git'
    NeoBundle $GITHUB_COM.'thinca/vim-textobj-comment.git'
    NeoBundle $GITHUB_COM.'h1mesuke/textobj-wiw.git'
    NeoBundle $GITHUB_COM.'vimtaku/vim-textobj-sigil.git'

    " operator
    NeoBundle $GITHUB_COM.'kana/vim-operator-user.git'
    NeoBundle $GITHUB_COM.'kana/vim-operator-replace.git'
    NeoBundle $GITHUB_COM.'tyru/operator-camelize.vim.git'
    NeoBundle $GITHUB_COM.'tyru/operator-reverse.vim.git'
    NeoBundle $GITHUB_COM.'emonkak/vim-operator-sort.git'

    " quickfix
    NeoBundle $GITHUB_COM.'thinca/vim-qfreplace.git'
    NeoBundle $GITHUB_COM.'dannyob/quickfixstatus.git'
    NeoBundle $GITHUB_COM.'jceb/vim-hier.git'
    NeoBundle $GITHUB_COM.'fuenor/qfixhowm.git'

    " appearance
    MyNeoBundle !s:Android $GITHUB_COM.'thinca/vim-fontzoom.git'
    MyNeoBundle !s:Android $GITHUB_COM.'nathanaelkane/vim-indent-guides.git'
    NeoBundle $GITHUB_COM.'vim-scripts/MultipleSearch.git'

    " cursor movement
    NeoBundle $GITHUB_COM.'Lokaltog/vim-easymotion.git'
    NeoBundle $GITHUB_COM.'vim-scripts/matchparenpp.git'
    NeoBundle $GITHUB_COM.'vim-scripts/matchit.zip.git'

    " editing
    NeoBundle $GITHUB_COM.'tpope/vim-surround.git'
    NeoBundle $GITHUB_COM.'t9md/vim-textmanip.git'
    NeoBundle $GITHUB_COM.'tomtom/tcomment_vim.git'
    NeoBundle $GITHUB_COM.'vim-scripts/DrawIt.git'
    NeoBundle $GITHUB_COM.'vim-scripts/RST-Tables.git'
    NeoBundle $GITHUB_COM.'vim-scripts/sequence.git'

    " search
    NeoBundle $GITHUB_COM.'thinca/vim-visualstar.git'
    NeoBundle $GITHUB_COM.'othree/eregex.vim.git'
    NeoBundle $GITHUB_COM.'vim-scripts/occur.vim.git'

    " utility
    NeoBundle $GITHUB_COM.'mattn/ideone-vim.git'
    NeoBundle $GITHUB_COM.'vim-scripts/project.tar.gz.git'
    MyNeoBundle !s:Android $GITHUB_COM.'Shougo/vimproc.git'
    MyNeoBundle !s:Android $GITHUB_COM.'Shougo/vinarise.git'
    MyNeoBundle !s:Android $GITHUB_COM.'s-yukikaze/vinarise-plugin-peanalysis.git'
    NeoBundleLazy $GITHUB_COM.'Shougo/vimfiler.git'
    MyNeoBundle !s:Android $GITHUB_COM.'Shougo/vimshell.git'
    MyNeoBundle !s:Android $GITHUB_COM.'thinca/vim-logcat.git'
    NeoBundleLazy $GITHUB_COM.'thinca/vim-quickrun.git'
    NeoBundle $GITHUB_COM.'thinca/vim-prettyprint.git'
    NeoBundle $GITHUB_COM.'thinca/vim-editvar.git'
    NeoBundle $GITHUB_COM.'tyru/open-browser.vim.git'
    MyNeoBundle !s:Android $GITHUB_COM.'sjl/splice.vim.git'
    MyNeoBundle !s:Android $GITHUB_COM.'sjl/gundo.vim.git'
    NeoBundle $GITHUB_COM.'vim-scripts/copypath.vim.git'
    NeoBundle $GITHUB_COM.'vim-scripts/DirDiff.vim.git'
    NeoBundle $GITHUB_COM.'vim-scripts/ShowMultiBase.git'
    NeoBundle $GITHUB_COM.'vim-scripts/ttoc.git'
    NeoBundle $GITHUB_COM.'vim-scripts/wokmarks.vim.git'

    " command extension
    NeoBundle $GITHUB_COM.'thinca/vim-ambicmd.git'
    NeoBundle $GITHUB_COM.'tyru/vim-altercmd.git'
    NeoBundle $GITHUB_COM.'tomtom/tcommand_vim.git'
    NeoBundleLazy $GITHUB_COM.'mbadran/headlights.git'

    " C/C++
    NeoBundleLazy $GITHUB_COM.'vim-scripts/a.vim.git'
    NeoBundleLazy $GITHUB_COM.'vim-scripts/c.vim.git'
    NeoBundleLazy $GITHUB_COM.'vim-scripts/CCTree.git'
    NeoBundleLazy $GITHUB_COM.'vim-scripts/Source-Explorer-srcexpl.vim.git'
    NeoBundleLazy $GITHUB_COM.'vim-scripts/trinity.vim.git'
    NeoBundleLazy $GITHUB_COM.'vim-scripts/cscope-menu.git'
    NeoBundleLazy $GITHUB_COM.'vim-scripts/gtags.vim.git'
    NeoBundleLazy $GITHUB_COM.'vim-scripts/DoxygenToolkit.vim.git'

    " Python
    NeoBundleLazy $GITHUB_COM.'alfredodeza/pytest.vim.git'
    NeoBundleLazy $GITHUB_COM.'klen/python-mode.git'

    " Perl
    NeoBundleLazy $GITHUB_COM.'vim-scripts/perl-support.vim.git'

    " JavaScript
    NeoBundleLazy $GITHUB_COM.'pangloss/vim-javascript.git'
    NeoBundleLazy $GITHUB_COM.'basyura/jslint.vim.git'

    " Haskell
    NeoBundleLazy $GITHUB_COM.'kana/vim-filetype-haskell.git'
    NeoBundleLazy $GITHUB_COM.'lukerandall/haskellmode-vim.git'
    NeoBundleLazy $GITHUB_COM.'Twinside/vim-syntax-haskell-cabal.git'
    NeoBundleLazy $GITHUB_COM.'eagletmt/ghcmod-vim.git'

    " Clojure
    MyNeoBundle !s:Android $GITHUB_COM.'jondistad/vimclojure.git'

    " CSV
    NeoBundle $GITHUB_COM.'vim-scripts/csv.vim.git'

    " colorscheme
    NeoBundle $GITHUB_COM.'vim-scripts/Color-Sampler-Pack.git'

    " runtime
    NeoBundle $GITHUB_COM.'mattn/webapi-vim.git'
    NeoBundle $GITHUB_COM.'vim-scripts/cecutil.git'
    NeoBundle $GITHUB_COM.'vim-scripts/tlib.git'
catch /E117/

endtry
"}}}

filetype plugin indent on

"---------------------------------------------------------------------------
" CCTree.vim:"{{{
"
if 1 && filereadable($DOTVIM . '/Bundle/CCTree/ftplugin/cctree.vim')
    source $DOTVIM/Bundle/CCTree/ftplugin/cctree.vim
endif
"}}}
"}}}

"---------------------------------------------------------------------------
" Edit:"{{{
"
set nobackup
set clipboard+=unnamed
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smarttab
set expandtab
set backspace=indent,eol,start
set whichwrap=b,s,<,>,[,]
set wildmenu
set autoindent
" Smart indenting
set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
inoremap # X<C-H><C-V>#
" settings for Japanese folding
set formatoptions+=mM
" don't continue the comment line automatically
set formatoptions-=ro
" settings for Japanese formatting
let format_allow_over_tw = 1
" tags{{{
set tags=./tags
set tags+=tags;
set tags+=./**/tags
"}}}
" grep{{{
set grepprg=grep\ -nH
"set grepprg=ack.pl\ -a
" autocmd MyVimrcCmd QuickfixCmdPost make,grep,grepadd,vimgrep,helpgrep copen
"}}}
"}}}

"---------------------------------------------------------------------------
" View:"{{{
"
set number
set showmatch
set laststatus=2
set cmdheight=2
set showcmd
set title
set showtabline=2
set display=uhex

set nowrap
nnoremap <Space>ow :<C-u>setlocal wrap!\|setlocal wrap?<CR>

set nolist
nnoremap <Space>ol :<C-u>setlocal list!\|setlocal list?<CR>
set listchars=tab:>-,extends:<,precedes:>,trail:-,eol:$,nbsp:%

" Tabline settings "{{{
function! s:tabpage_label(n) "{{{
    let title = gettabvar(a:n, 'title')
    if title !=# ''
        return title
    endif

    let bufnrs = tabpagebuflist(a:n)

    let hi = a:n is tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'

    let no = len(bufnrs)
    if no is 1
        let no = ''
    endif

    let mod = len(filter(copy(bufnrs), 'getbufvar(v:val, "&modified")')) ? '+' : ''
    let sp = (no . mod) ==# '' ? '' : ' '

    let curbufnr = bufnrs[tabpagewinnr(a:n) - 1]
    let fname = pathshorten(bufname(curbufnr))

    let label = no . mod . sp . fname

    return '%' . a:n . 'T' . hi . label . '%T%#TabLineFill#'
endfunction "}}}
function! MakeTabLine() "{{{
    let titles =map(range(1, tabpagenr('$')), 's:tabpage_label(v:val)')
    let sep = ' | '
    let tabpages = join(titles, sep) . sep . '%#TabLineFill#%T'
    let info = fnamemodify(getcwd(),"~:") . ' '
    return tabpages . '%=' . info
endfunction "}}}
set guioptions-=e
set tabline=%!MakeTabLine()
"}}}

" Visualization of the full-width space and the blank at the end of the line{{{
if has("syntax")
    syntax on

    " for POD bug
    syn sync fromstart

    function! ActivateInvisibleIndicator()
        syntax match InvisibleJISX0208Space "　" display containedin=ALL
        highlight InvisibleJISX0208Space term=underline ctermbg=Blue guibg=darkgray gui=underline
        syntax match InvisibleTrailedSpace "[ \t]\+$" display containedin=ALL
        highlight InvisibleTrailedSpace term=underline ctermbg=Red guibg=NONE gui=undercurl guisp=darkorange
        syntax match InvisibleTab "\t" display containedin=ALL
        highlight InvisibleTab term=underline ctermbg=white gui=undercurl guisp=darkslategray
    endfunction
    augroup invisible
        autocmd! invisible
        autocmd BufNew,BufRead * call ActivateInvisibleIndicator()
    augroup END
endif
"}}}
" Highlight end of line whitespace.
highlight WhitespaceEOL ctermbg=lightgray guibg=lightgray
match WhitespaceEOL /\s\+$/

" XPstatusline + fugitive#statusline {{{
let g:statusline_max_path = 20
function! StatusLineGetPath() "{{{
    let p = expand('%:.:h')
    let p = substitute(p, expand('$HOME'), '~', '')
    if len(p) > g:statusline_max_path
        let p = simplify(p)
        let p = pathshorten(p)
    endif
    return p
endfunction "}}}

nmap <Plug>view:switch_status_path_length :let g:statusline_max_path = 200 - g:statusline_max_path<cr>
nmap ,t <Plug>view:switch_status_path_length

augroup Statusline
    autocmd! Statusline

    autocmd BufEnter * call <SID>SetFullStatusline()
    autocmd BufLeave,BufNew,BufRead,BufNewFile * call <SID>SetSimpleStatusline()
augroup END

function! StatusLineRealSyn()
    let synId = synID(line('.'),col('.'),1)
    let realSynId = synIDtrans(synId)
    if synId == realSynId
        return 'Normal'
    else
        return synIDattr( realSynId, 'name' )
    endif
endfunction

function! s:SetFullStatusline() "{{{
    setlocal statusline=
    setlocal statusline+=%#StatuslineBufNr#%-1.2n\                   " buffer number
    setlocal statusline+=%h%#StatuslineFlag#%m%r%w                 " flags
    setlocal statusline+=%#StatuslinePath#\ %-0.20{StatusLineGetPath()}%0* " path
    setlocal statusline+=%#StatuslineFileName#\/%t\                       " file name

    try
        call fugitive#statusline()
        setlocal statusline+=%{fugitive#statusline()}  " Git branch name
    catch /E117/

    endtry

    setlocal statusline+=%#StatuslineChar#\ \ 0x%-2B                 " current char
"    setlocal statusline+=%#StatuslineChar#\ \ 0x%-2B\ %0*                 " current char
    setlocal statusline+=%#StatuslineTermEnc#(%{&termencoding},\           " encoding
    setlocal statusline+=%#StatuslineFileEnc#%{&fileencoding},\         " file encoding
    setlocal statusline+=%#StatuslineFileType#%{&fileformat}\)\              " file format

    setlocal statusline+=%#StatuslineFileType#\ %{strlen(&ft)?&ft:'**'}\ . " filetype
    setlocal statusline+=%#StatuslineSyn#\ %{synIDattr(synID(line('.'),col('.'),1),'name')}\ %0*           "syntax name
    setlocal statusline+=%#StatuslineRealSyn#\ %{StatusLineRealSyn()}\ %0*           "real syntax name
    setlocal statusline+=%=

    setlocal statusline+=\ %-10.(%l/%L,%c-%v%)             "position
    setlocal statusline+=\ %P                             "position percentage
"    setlocal statusline+=\ %#StatuslineTime#%{strftime(\"%m-%d\ %H:%M\")} " current time

endfunction "}}}

function! s:SetSimpleStatusline() "{{{
    setlocal statusline=
    setlocal statusline+=%#StatuslineNC#%-0.20{StatusLineGetPath()}%0* " path
    setlocal statusline+=\/%t\                       " file name
endfunction "}}}
"}}}
"}}}

"---------------------------------------------------------------------------
" Search:"{{{
"
set nowrapscan
set incsearch

set ignorecase
nnoremap <Space>oi :<C-u>setlocal ignorecase!\|setlocal ignorecase?<CR>

set smartcase
nnoremap <Space>os :<C-u>setlocal smartcase!\|setlocal smartcase?<CR>

set hlsearch
nnoremap <ESC><ESC> :nohlsearch<CR>
"}}}

"---------------------------------------------------------------------------
"  Utilities:"{{{
"
try
    call altercmd#load()
catch /E117/

endtry

" TabpageCD"{{{
command! -bar -complete=dir -nargs=?
      \   CD
      \   TabpageCD <args>
command! -bar -complete=dir -nargs=?
      \   TabpageCD
      \   execute 'cd' fnameescape(expand(<q-args>))
      \   | let t:cwd = getcwd()

autocmd MyVimrcCmd TabEnter *
      \   if exists('t:cwd') && !isdirectory(t:cwd)
      \ |     unlet t:cwd
      \ | endif
      \ | if !exists('t:cwd')
      \ |   let t:cwd = getcwd()
      \ | endif
      \ | execute 'cd' fnameescape(expand(t:cwd))

" Exchange ':cd' to ':TabpageCD'.
try
    AlterCommand cd CD
catch /E492/

endtry
"}}}

" CD to the directory of open files{{{
command! -nargs=? -complete=dir -bang TCD  call s:ChangeCurrentDir('<args>', '<bang>')
function! s:ChangeCurrentDir(directory, bang)
    if a:directory == ''
        TabpageCD %:p:h
    else
        execute 'TabpageCD' . a:directory
    endif

    if a:bang == ''
        pwd
    endif
endfunction}}}
nnoremap <silent> <Space>cd :<C-u>TCD<CR>

" WinMerge keybind in vimdiff "{{{
function! DiffGet() "{{{
    try
        execute 'diffget'
    catch/E101/
        execute 'diffget //2'
    endtry
endfunction "}}}
function! DiffPut() "{{{
    try
        execute 'diffput'
    catch/E101/
        execute 'diffget //3'
    endtry
endfunction "}}}
function! SetDiffMap() "{{{
        nnoremap <buffer> <F5> :<C-u>diffupdate<CR>
        nnoremap <buffer> <A-Up> [c
        nnoremap <buffer> <A-Down> ]c
        nnoremap <buffer> <A-Right> :<C-u>call DiffGet()<CR>
        nnoremap <buffer> <A-Left> :<C-u>call DiffPut()<CR>
endfunction "}}}
autocmd MyVimrcCmd FilterWritePost * call SetDiffMap()
"}}}
" Command-line window{{{
autocmd MyVimrcCmd CmdwinEnter * call s:init_cmdwin()
function! s:init_cmdwin()
    nnoremap <buffer> q :<C-u>quit<CR>
    nnoremap <buffer> <TAB> :<C-u>quit<CR>

    inoremap <buffer><expr><C-h> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"
    inoremap <buffer><expr><BS> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"

    inoremap <buffer><expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

    startinsert!
endfunction
"}}}
" DiffClip() "{{{
" http://vimwiki.net/?tips%2F49
command! -nargs=0 -range DiffClip <line1>, <line2>:call DiffClip('0')
" get diff with register reg
function! DiffClip(reg) range
    exe "let @a=@" . a:reg
    exe a:firstline  . "," . a:lastline . "y b"
    tabnew "new
    " clear the buffer after close this window
    set buftype=nofile bufhidden=wipe
    put a
    diffthis
    lefta vnew "vnew
    set buftype=nofile bufhidden=wipe
    put b
    diffthis
endfunction
"}}}
" NextIndent() "{{{
" http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation
"
" Jump to the next or previous line that has the same level or a lower
" level of indentation than the current line.
"
" exclusive (bool):   true:  Motion is exclusive
"                     false: Motion is inclusive
" fwd (bool):         true:  Go to next line
"                     false: Go to previous line
" lowerlevel (bool):  true:  Go to line with lower indentation level
"                     false: Go to line with the same indentation level
" skipblanks (bool):  true:  Skip blank lines
"                     false: Don't skip blank lines
function! NextIndent(exclusive, fwd, lowerlevel, skipblanks)
    let line = line('.')
    let column = col('.')
    let lastline = line('$')
    let indent = indent(line)
    let stepvalue = a:fwd ? 1 : -1

    while (line > 0 && line <= lastline)
        let line = line + stepvalue
        if ( ! a:lowerlevel && indent(line) == indent ||
            \ a:lowerlevel && indent(line) < indent)
            if (! a:skipblanks || strlen(getline(line)) > 0)
                if (a:exclusive)
                    let line = line - stepvalue
                endif
                exe line
                exe "normal " column . "|"
                return
            endif
        endif
    endwhile
endfunc

" Moving back and forth between lines of same or lower indentation.
nnoremap <silent> [l :call NextIndent(0, 0, 0, 1)<cr>
nnoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<cr>
nnoremap <silent> [L :call NextIndent(0, 0, 1, 1)<cr>
nnoremap <silent> ]L :call NextIndent(0, 1, 1, 1)<cr>
vnoremap <silent> [l <esc>:call NextIndent(0, 0, 0, 1)<cr>m'gv''
vnoremap <silent> ]l <esc>:call NextIndent(0, 1, 0, 1)<cr>m'gv''
vnoremap <silent> [L <esc>:call NextIndent(0, 0, 1, 1)<cr>m'gv''
vnoremap <silent> ]L <esc>:call NextIndent(0, 1, 1, 1)<cr>m'gv''
onoremap <silent> [l :call NextIndent(0, 0, 0, 1)<cr>
onoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<cr>
onoremap <silent> [L :call NextIndent(1, 0, 1, 1)<cr>
onoremap <silent> ]L :call NextIndent(1, 1, 1, 1)<cr>
"}}}
" flymake for perl{{{
augroup FlyQuickfixMakeCmd
    autocmd!
    autocmd BufEnter *.pm,*.pl,*.t call FlyQuickfixEnable()
augroup END

function! SetErrorMarkers()
    :cclose
    :HierUpdate
    :QuickfixStatusEnable
endfunction

function! FlyquickfixPrgSet(mode)
    if a:mode == 'perl'
        """ setting for perl
        setlocal makeprg=vimparse.pl\ -c\ %
        setlocal errorformat=%f:%l:%m
"        setlocal shellpipe=2>&1\ >
        let g:flyquickfixmake_mode = 'perl'
"        echo "flymake prg: perl"
    endif
endfunction

function! FlyquickfixToggleSet()
    if g:enabled_flyquickfixmake == 1
        autocmd! FlyQuickfixMakeCmd
        echo "not-used flymake"
        let g:enabled_flyquickfixmake = 0
    else
        echo "used flymake"
        let g:enabled_flyquickfixmake = 1
        autocmd FlyQuickfixMakeCmd BufWritePost *.pm,*.pl,*.t make
        autocmd FlyQuickfixMakeCmd QuickFixCmdPost make call SetErrorMarkers()
    endif
endfunction

function! FlyQuickfixEnable()
    if !exists("g:enabled_flyquickfixmake")
        let g:enabled_flyquickfixmake = 1
        autocmd FlyQuickfixMakeCmd BufWritePost *.pm,*.pl,*.t make
        autocmd FlyQuickfixMakeCmd QuickFixCmdPost make call SetErrorMarkers()
    endif

    if g:enabled_flyquickfixmake
        call FlyquickfixPrgSet(g:flyquickfixmake_mode)
    endif
endfunction

if !exists("g:flyquickfixmake_mode")
    let g:flyquickfixmake_mode = 'perl'
endif

noremap pl :call FlyquickfixToggleSet()<CR>
"}}}
" cscope_maps.vim{{{
" http://cscope.sourceforge.net/cscope_vim_tutorial.html
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CSCOPE settings for vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" This file contains some boilerplate settings for vim's cscope interface,
" plus some keyboard mappings that I've found useful.
"
" USAGE:
" -- vim 6:     Stick this file in your ~/.vim/plugin directory (or in a
"               'plugin' directory in some other directory that is in your
"               'runtimepath'.
"
" -- vim 5:     Stick this file somewhere and 'source cscope.vim' it from
"               your ~/.vimrc file (or cut and paste it into your .vimrc).
"
" NOTE:
" These key maps use multiple keystrokes (2 or 3 keys).  If you find that vim
" keeps timing you out before you can complete them, try changing your timeout
" settings, as explained below.
"
" Happy cscoping,
"
" Jason Duell       jduell@alumni.princeton.edu     2002/3/7
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" This tests to see if vim was configured with the '--enable-cscope' option
" when it was compiled.  If it wasn't, time to recompile vim...
if has("cscope")

    """"""""""""" Standard cscope/vim boilerplate

    " use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetag

    " check cscope for definition of a symbol before checking ctags: set to 1
    " if you want the reverse search order.
    set csto=0

    " add any cscope database in current directory
    if filereadable("cscope.out")
        cs add cscope.out
    " else add the database pointed to by environment variable
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif

    " show msg when any other cscope db added
    set cscopeverbose


    """"""""""""" My cscope/vim key mappings
    "
    " The following maps all invoke one of the following cscope search types:
    "
    "   's'   symbol: find all references to the token under cursor
    "   'g'   global: find global definition(s) of the token under cursor
    "   'c'   calls:  find all calls to the function name under cursor
    "   't'   text:   find all instances of the text under cursor
    "   'e'   egrep:  egrep search for the word under cursor
    "   'f'   file:   open the filename under cursor
    "   'i'   includes: find files that include the filename under cursor
    "   'd'   called: find functions that function under cursor calls
    "
    " Below are three sets of the maps: one set that just jumps to your
    " search result, one that splits the existing vim window horizontally and
    " diplays your search result in the new window, and one that does the same
    " thing, but does a vertical split instead (vim 6 only).
    "
    " I've used CTRL-\ and CTRL-@ as the starting keys for these maps, as it's
    " unlikely that you need their default mappings (CTRL-\'s default use is
    " as part of CTRL-\ CTRL-N typemap, which basically just does the same
    " thing as hitting 'escape': CTRL-@ doesn't seem to have any default use).
    " If you don't like using 'CTRL-@' or CTRL-\, , you can change some or all
    " of these maps to use other keys.  One likely candidate is 'CTRL-_'
    " (which also maps to CTRL-/, which is easier to type).  By default it is
    " used to switch between Hebrew and English keyboard mode.
    "
    " All of the maps involving the <cfile> macro use '^<cfile>$': this is so
    " that searches over '#include <time.h>" return only references to
    " 'time.h', and not 'sys/time.h', etc. (by default cscope will return all
    " files that contain 'time.h' as part of their name).


    " To do the first type of search, hit 'CTRL-\', followed by one of the
    " cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
    " search will be displayed in the current window.  You can use CTRL-T to
    " go back to where you were before the search.
    "

    nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>


    " Using 'CTRL-spacebar' (intepreted as CTRL-@ by vim) then a search type
    " makes the vim window split horizontally, with search result displayed in
    " the new window.
    "
    " (Note: earlier versions of vim may not have the :scs command, but it
    " can be simulated roughly via:
    "    nmap <C-@>s <C-W><C-S> :cs find s <C-R>=expand("<cword>")<CR><CR>

    nmap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>


    " Hitting CTRL-space *twice* before the search type does a vertical
    " split instead of a horizontal one (vim 6 and up only)
    "
    " (Note: you may wish to put a 'set splitright' in your .vimrc
    " if you prefer the new window on the right instead of the left

    nmap <C-@><C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-@><C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-@><C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>


    """"""""""""" key map timeouts
    "
    " By default Vim will only wait 1 second for each keystroke in a mapping.
    " You may find that too short with the above typemaps.  If so, you should
    " either turn off mapping timeouts via 'notimeout'.
    "
    "set notimeout
    "
    " Or, you can keep timeouts, by uncommenting the timeoutlen line below,
    " with your own personal favorite value (in milliseconds):
    "
    "set timeoutlen=4000
    "
    " Either way, since mapping timeout settings by default also set the
    " timeouts for multicharacter 'keys codes' (like <F1>), you should also
    " set ttimeout and ttimeoutlen: otherwise, you will experience strange
    " delays as vim waits for a keystroke after you hit ESC (it will be
    " waiting to see if the ESC is actually part of a key code like <F1>).
    "
    "set ttimeout
    "
    " personally, I find a tenth of a second to work well for key code
    " timeouts. If you experience problems and have a slow terminal or network
    " connection, set it higher.  If you don't set ttimeoutlen, the value for
    " timeoutlent (default: 1000 = 1 second, which is sluggish) is used.
    "
    "set ttimeoutlen=100

endif
"}}}
" FullScreenToggle() "{{{
command! FullScreenToggle call FullScreenToggle()
function! FullScreenToggle()
    if s:is_full_screen
        call FullScreenOff()
    else
        call FullScreenOn()
    endif
endfunction

let s:is_full_screen = 0
function! FullScreenOn()
    let s:columns = &columns
    let s:lines = &lines
    set columns=9999
    set lines=999
    let s:is_full_screen = 1
endfunction
function! FullScreenOff()
    execute 'set columns=' . s:columns
    execute 'set lines=' . s:lines
    let s:is_full_screen = 0
endfunction
"}}}
"}}}

"---------------------------------------------------------------------------
" Plugins:"{{{
"
"---------------------------------------------------------------------------
" 2html.vim:"{{{
"
let g:html_number_lines = 0
let g:html_dynamic_folds = 1
"let g:html_hover_unfold = 1
"}}}
"---------------------------------------------------------------------------
" vim-ref:"{{{
"
autocmd MyVimrcCmd FileType vim,help setlocal keywordprg=:help

let g:ref_cache_dir = $DOTVIM.'/.vim_ref_cache'

" Python
let g:ref_pydoc_cmd = "python -m pydoc"

" webdict
let g:ref_source_webdict_sites = {
            \ 'wikipedia:ja': {
                \ 'url': 'http://ja.wikipedia.org/wiki/%s',
                \ 'keyword_encoding': 'utf-8',
                \ 'cache': '0',
                \ },
            \ 'wikipedia:en': {
                \ 'url': 'http://en.wikipedia.org/wiki/%s',
                \ 'keyword_encoding': 'utf-8',
                \ 'cache': '0',
                \ },
            \ 'wiktionary': {
                \ 'url': 'http://ja.wiktionary.org/wiki/%s',
                \ 'keyword_encoding': 'utf-8',
                \ 'cache': '0',
                \ },
            \ 'alc': {
                \ 'url': 'http://eow.alc.co.jp/%s',
                \ 'keyword_encoding': 'utf-8',
                \ 'cache': '0',
                \ },
            \ }

function! g:ref_source_webdict_sites.wiktionary.filter(output)
    return join(split(a:output, "\n")[18:], "\n")
endfunction

function! g:ref_source_webdict_sites.alc.filter(output)
    return join(split(a:output, "\n")[38:], "\n")
endfunction

let g:ref_source_webdict_sites.default = 'alc'
"}}}
"---------------------------------------------------------------------------
" neocomplcache:"{{{
"
function! Init_neocomplcache() "{{{
    NeoComplCacheEnable
    imap <C-k>     <Plug>(neocomplcache_snippets_expand)
    smap <C-k>     <Plug>(neocomplcache_snippets_expand)
    inoremap <expr><C-g>     neocomplcache#undo_completion()
    inoremap <expr><C-l>     neocomplcache#complete_common_string()
    imap <C-q>  <Plug>(neocomplcache_start_unite_quick_match)

    " SuperTab like snippets behavior.
    "imap <expr><TAB> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<C-n>" : "\<TAB>"

    " Recommended key-mappings.
	" <CR>: close popup and save indent.
	inoremap <expr><silent> <CR> <SID>my_cr_function()
	function! s:my_cr_function()
	  return pumvisible() ? neocomplcache#close_popup() . "\<CR>" : "\<CR>"
	endfunction
    " <TAB>: completion.
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y>  neocomplcache#close_popup()
    inoremap <expr><C-e>  neocomplcache#cancel_popup()

    " For cursor moving in insert mode(Not recommended)
    "inoremap <expr><Left> neocomplcache#close_popup() . "\<Left>"
    "inoremap <expr><Right> neocomplcache#close_popup() . "\<Right>"
    "inoremap <expr><Up> neocomplcache#close_popup() . "\<Up>"
    "inoremap <expr><Down> neocomplcache#close_popup() . "\<Down>"
    " Or set this.
    "let g:neocomplcache_enable_cursor_hold_i = 1

    " AutoComplPop like behavior.
    "let g:neocomplcache_enable_auto_select = 1

    " Shell like behavior(not recommended).
    "set completeopt&
    "set completeopt+=longest
    "let g:neocomplcache_enable_auto_select = 1
    "let g:neocomplcache_disable_auto_complete = 1
    "inoremap <expr><TAB> pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"
    "inoremap <expr><CR> neocomplcache#smart_close_popup() . "\<CR>"
endfunction"}}}
function! Term_neocomplcache() "{{{
    NeoComplCacheDisable
    iunmap <C-k>
    sunmap <C-k>
    iunmap <C-g>
    iunmap <C-l>
    iunmap <C-q>
    iunmap <CR>
    iunmap <TAB>
    iunmap <C-h>
    iunmap <BS>
    iunmap <C-y>
    iunmap <C-e>
endfunction"}}}
command! InitNeoComplCache call Init_neocomplcache()
command! TermNeoComplCache call Term_neocomplcache()

" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 0
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Disable caching buffer name
let g:neocomplcache_disable_caching_file_path_pattern = '\.ref\|\.txt'
let g:neocomplcache_temporary_dir = $DOTVIM.'/.neocon'

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
  \ 'default' : $DOTVIM.'/.neo_default',
  \ 'vimshell' : $DOTVIM.'/.vimshell_hist',
  \ 'scheme' : $DOTVIM.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

let g:neocomplcache_enable_prefetch = 1

" For snippet_complete marker.
if has('conceal')
    set conceallevel=2 concealcursor=i
endif

try
    if neocomplcache#is_enabled()
        " neocomplcache enable at startup
        InitNeoComplCache
    else
        " lazy loading for neocomplcache
        augroup MyInitNeocomplcache
            autocmd!
            autocmd InsertEnter * call Init_neocomplcache() | autocmd! MyInitNeocomplcache
        augroup END
    endif
catch /E117/

endtry

" Enable omni completion.
autocmd MyVimrcCmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd MyVimrcCmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd MyVimrcCmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd MyVimrcCmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd MyVimrcCmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
"autocmd MyVimrcCmd FileType ruby setlocal omnifunc=rubycomplete#Complete
let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'

if !exists('g:neocomplcache_include_paths')
    let g:neocomplcache_include_paths = {}
endif

if s:MSWindows
    let g:neocomplcache_include_paths.c = "C:/MinGW/lib/gcc/mingw32/4.5.2/include"
    let g:neocomplcache_include_paths.cpp = "C:/MinGW/lib/gcc/mingw32/4.5.2/include/c++,C:/boost_1_47_0"
endif

" For clang_complete
let g:neocomplcache_force_overwrite_completefunc=1

let g:neocomplcache_ignore_composite_filetype_lists = {
      \ 'python.unit': 'python',
      \ 'php.unit': 'php',
      \ }
"}}}
"---------------------------------------------------------------------------
" clang_complete:"{{{
"
let g:clang_complete_auto = 1
let g:clang_use_library = 0

" if s:MSWindows
"     let g:clang_exec = '"C:/GnuWin32/bin/clang.exe'
"     let g:clang_user_options =
"                 \ '-I C:/boost_1_47_0 '.
"                 \ '-fms-extensions -fmsc-version=1500 -fgnu-runtime '.
"                 \ '-D__MSVCRT_VERSION__=0x800 -D_WIN32_WINNT=0x0500 '.
"                 \ '2> NUL || exit 0"'
" endif
"}}}
"---------------------------------------------------------------------------
" taghighlight:"{{{
"
if exists('g:rt_cmd_registered')
    for ft in keys(g:rt_cmd_registered)
        execute 'autocmd MyVimrcCmd FileType ' . ft . ' silent! ReadTypes'
    endfor
else
    let g:rt_cmd_registered = {}
endif

function! s:registReadTypesCmd(ft)
    if !get(g:rt_cmd_registered, a:ft)
        execute 'autocmd MyVimrcCmd FileType ' . a:ft . ' silent! ReadTypes'
        let g:rt_cmd_registered[a:ft] = 1
    endif
endfunction
"}}}
"---------------------------------------------------------------------------
" vim-fugitive:"{{{
"
nnoremap <Space>gd :<C-u>Gdiff<CR>
nnoremap <Space>gs :<C-u>Gstatus<CR>
nnoremap <Space>gl :<C-u>Extradite<CR>
nnoremap <Space>ga :<C-u>Gwrite<CR>
nnoremap <Space>gc :<C-u>Gcommit<CR>
nnoremap <Space>gC :<C-u>Git commit --amend<CR>
nnoremap <Space>gb :<C-u>Gblame<CR>
nnoremap <Space>gv :<C-u>Gitv<CR>
nnoremap <Space>gV :<C-u>Gitv!<CR>
"}}}
"---------------------------------------------------------------------------
" unite.vim:"{{{
"
" The prefix key.
nnoremap    [unite]   <Nop>
nmap    f [unite]

nnoremap <silent> [unite]a  :<C-u>Unite -prompt=#\  buffer bookmark file_mru file<CR>
nnoremap <silent> [unite]b  :<C-u>UniteWithBufferDir -buffer-name=files -prompt=%\  buffer bookmark file_mru file<CR>
nnoremap <silent> [unite]c  :<C-u>UniteWithCurrentDir -buffer-name=files buffer bookmark file_mru file<CR>
nnoremap <silent> [unite]e  :<C-u>Unite -buffer-name=files everything<CR>
nnoremap <silent> [unite]f  :<C-u>Unite source<CR>
nnoremap <expr>   [unite]g  ':<C-u>Unite grep:*::' . expand("<cword>")
nnoremap <silent> [unite]h  :<C-u>UniteWithCursorWord help<CR>
nnoremap <silent> [unite]m  :<C-u>Unite mark -no-quit<CR>
nnoremap <silent> [unite]o  :<C-u>Unite outline<CR>
nnoremap <silent> [unite]pi :<C-u>Unite neobundle/install<CR>
nnoremap <silent> [unite]pu :<C-u>Unite neobundle/install:!<CR>
nnoremap <silent> [unite]pl :<C-u>Unite neobundle<CR>
nnoremap <silent> [unite]r  :<C-u>Unite -buffer-name=register register<CR>
nnoremap <silent> [unite]s  :<C-u>Unite scriptnames<CR>
nnoremap <silent> [unite]t  :<C-u>Unite buffer_tab tab buffer<CR>

let g:unite_kind_file_cd_command = 'TabpageCD'
let g:unite_kind_file_lcd_command = 'TabpageCD'

" Start insert.
let g:unite_enable_start_insert = 1

autocmd MyVimrcCmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings() "{{{
    " Overwrite settings.

    nmap <buffer> <ESC>      <Plug>(unite_exit)
    imap <buffer> jj      <Plug>(unite_insert_leave)
    imap <buffer> <C-w>     <Plug>(unite_delete_backward_path)
    inoremap <buffer> <expr> <C-y> unite#do_action('insert')

    " <C-l>: manual neocomplcache completion.
    inoremap <buffer> <C-l>  <C-x><C-u><C-p><Down>

endfunction"}}}

let g:unite_source_file_mru_limit = 200
let g:unite_source_grep_max_candidates = 50000

" For optimize.
let g:unite_source_file_mru_filename_format = ''

let g:unite_data_directory = $DOTVIM.'/.unite'
"}}}
"---------------------------------------------------------------------------
" textobj-comment:"{{{
"
let g:textobj_comment_no_default_key_mappings = 1
omap ao	<Plug>(textobj-comment-a)
xmap ao	<Plug>(textobj-comment-a)
omap io	<Plug>(textobj-comment-i)
xmap io	<Plug>(textobj-comment-i)
"}}}
"---------------------------------------------------------------------------
" operator-replace:"{{{
"
map _  <Plug>(operator-replace)
"}}}
"---------------------------------------------------------------------------
" operator-camelize:"{{{
"
map <Leader>c <Plug>(operator-camelize)
map <Leader>C <Plug>(operator-decamelize)
"}}}
"---------------------------------------------------------------------------
" operator-sort:"{{{
"
map <Leader>s <Plug>(operator-sort)
"}}}
"---------------------------------------------------------------------------
" qfixhown.vim:"{{{
"
let QFixHowm_Key = 'g'
let QFixHowm_KeyB = ','

let howm_dir             = $DOTVIM.'/howm'
let howm_filename        = '%Y/%m/%Y-%m-%d-%H%M%S.howm'
let howm_fileencoding    = 'utf-8'
let howm_fileformat      = 'dos'
"}}}
"---------------------------------------------------------------------------
" qfixmemo.vim:"{{{
"
let qfixmemo_dir           = $DOTVIM.'/qfixmemo'
let qfixmemo_filename      = '%Y/%m/%Y-%m-%d-%H%M%S.txt'
let qfixmemo_fileencoding  = 'cp932'
let qfixmemo_fileformat    = 'dos'
let qfixmemo_filetype      = 'qfix_memo'
"}}}
"---------------------------------------------------------------------------
" qfixmru.vim:"{{{
"
let QFixMRU_Filename     = $DOTVIM.'/.qfixmru'
let QFixMRU_IgnoreFile   = ''
let QFixMRU_RegisterFile = ''
let QFixMRU_IgnoreTitle  = ''
let g:QFixMRU_Entries    = 20
let QFixMRU_EntryMax     = 300
"}}}
"---------------------------------------------------------------------------
" qfixgrep.vim:"{{{
"
let QFix_PreviewEnable    = 0
let QFix_HighSpeedPreview = 0
let QFix_DefaultPreview   = 0
let QFix_PreviewExclude = '\.pdf$\|\.mp3$\|\.jpg$\|\.bmp$\|\.png$\|\.zip$\|\.rar$\|\.exe$\|\.dll$\|\.lnk$'

let QFix_CopenCmd = ''
let QFix_Height = 10
let QFix_Width = 0
set previewheight=12
let QFix_PreviewHeight = 12
set winwidth=20
let QFix_WindowHeightMin = 0
let QFix_PreviewOpenCmd = ''
let QFix_PreviewWidth  = 0

let QFix_HeightFixMode         = 0

let QFix_CloseOnJump           = 0
let QFix_Edit = 'tab'

let QFix_PreviewFtypeHighlight = 1
let QFix_CursorLine            = 1
let QFix_PreviewCursorLine     = 1
"hi CursorLine guifg=NONE guibg=NONE gui=underline

let QFix_Copen_winfixheight = 1
let QFix_Copen_winfixwidth  = 1
let QFix_Preview_winfixheight = 1
let QFix_Preview_winfixwidth  = 1

let MyGrep_ExcludeReg = '[~#]$\|\.bak$\|\.o$\|\.obj$\|\.exe$\|[/\\]tags$\|[/\\]svn[/\\]\|[/\\]\.git[/\\]\|[/\\]\.hg[/\\]'
let mygrepprg = 'grep'
let MyGrep_ShellEncoding      = 'cp932'
let MyGrep_Damemoji           = 2
let MyGrep_DamemojiReplaceReg = '(..)'
let MyGrep_DamemojiReplace    = '[]'
let MyGrep_yagrep_opt = 0

let MyGrepcmd_useropt = ''

"let MyGrep_Key  = 'g'
"let MyGrep_KeyB = ','

let MyGrep_DefaultSearchWord = 1

let MyGrep_MenuBar = 3

autocmd MyVimrcCmd QuickfixCmdPre make,grep,grepadd,vimgrep,helpgrep copen
"}}}
"---------------------------------------------------------------------------
" vim-indent-guides:"{{{
"
"let g:indent_guides_indent_levels = 30
let g:indent_guides_auto_colors = 1
"let g:indent_guides_color_change_percent = 10
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2
"let g:indent_guides_space_guides = 0
let g:indent_guides_enable_on_vim_startup = 0
"}}}
"---------------------------------------------------------------------------
" MultipleSearch:"{{{
"
let g:MultipleSearchMaxColors=13
let g:MultipleSearchColorSequence="red,yellow,blue,green,magenta,lightred,cyan,lightyellow,gray,brown,lightblue,darkmagenta,darkcyan"
let g:MultipleSearchTextColorSequence="white,black,white,black,white,black,black,black,black,white,black,white,white"
"}}}
"---------------------------------------------------------------------------
" vim-textmanip:"{{{
"
xmap <C-j> <Plug>(textmanip-move-down)
xmap <C-k> <Plug>(textmanip-move-up)
xmap <C-h> <Plug>(textmanip-move-left)
xmap <C-l> <Plug>(textmanip-move-right)

xmap <M-d> <Plug>(textmanip-duplicate-down)
nmap <M-d> <Plug>(textmanip-duplicate-down)
xmap <M-D> <Plug>(textmanip-duplicate-up)
nmap <M-D> <Plug>(textmanip-duplicate-up)
"}}}
"---------------------------------------------------------------------------
" tcomment_vim:"{{{
"
let g:tcommentMapLeaderOp1 = ',c'
let g:tcommentMapLeaderOp2 = ',C'
"}}}
"---------------------------------------------------------------------------
" eregex.vim:"{{{
"
nnoremap ,/ :<C-u>M/
nnoremap ,? :<C-u>M?
"}}}
"---------------------------------------------------------------------------
" ideone-vim:"{{{
"
let g:ideone_put_url_to_clipboard_after_post = 0
let g:ideone_open_buffer_after_post = 1
"}}}
"---------------------------------------------------------------------------
" project.tar.gz:"{{{
"
let g:proj_flags = "imstc"
nmap <silent> <Leader>P <Plug>ToggleProject
"}}}
"---------------------------------------------------------------------------
" vimproc:"{{{
"
nmap <S-F6> <ESC>:<C-u>call vimproc#system("ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q")<CR>
"}}}
"---------------------------------------------------------------------------
" vimfiler:"{{{
"
nnoremap    [vimfiler]   <Nop>
nmap    <Space>v [vimfiler]

nnoremap <silent> [vimfiler]b  :<C-u>VimFilerBufferDir<CR>
nnoremap <silent> [vimfiler]c  :<C-u>VimFilerCurrentDir<CR>
nnoremap <silent> [vimfiler]d  :<C-u>VimFilerDouble<CR>
nnoremap <silent> [vimfiler]f  :<C-u>VimFilerSimple -no-quit -winwidth=32<CR>
nnoremap <silent> [vimfiler]s  :<C-u>VimShell<CR>

" Edit file by tabedit.
let g:vimfiler_edit_action = 'open'
let g:vimfiler_split_action = 'tabopen'

let g:vimfiler_as_default_explorer = 1

if s:MSWindows
    let g:unite_kind_file_use_trashbox = 1
endif

" Enable file operation commands.
let g:vimfiler_safe_mode_by_default = 0

let g:vimfiler_data_directory = $DOTVIM.'/.vimfiler'

let g:vimfiler_execute_file_list={'txt': 'vim',
            \'vim': 'vim'}
"}}}
"---------------------------------------------------------------------------
" vimshell:"{{{
"
let g:vimshell_interactive_encodings = {'git': 'utf-8'}
let g:vimshell_temporary_directory = $DOTVIM.'/.vimshell'
let g:vimshell_vimshrc_path = $DOTVIM.'/.vimshell/.vimshrc'
let g:vimshell_cd_command = 'TabpageCD'
let g:vimshell_scrollback_limit = 50000

autocmd MyVimrcCmd FileType vimshell call s:vimshell_settings()
function! s:vimshell_settings()
    inoremap <silent><expr><buffer> <Up>  unite#sources#vimshell_history#start_complete(!0)
    inoremap <silent><expr><buffer> <Down>  unite#sources#vimshell_history#start_complete(!0)
endfunction
"}}}
"---------------------------------------------------------------------------
" vim-quickrun:"{{{
"
if !exists('g:quickrun_config')
    let g:quickrun_config = {}
endif
" flymake for C/C++{{{
function! Flymake_for_CPP_Setting()
    try
        "" To highlight with a undercurl in quickfix error
        "" The following two lines are written in the .gvimrc
        "execute "highlight qf_error_ucurl gui=undercurl guisp=Red"
        "let g:hier_highlight_group_qf  = "qf_error_ucurl"

        let s:silent_quickfix = quickrun#outputter#quickfix#new()
        function! s:silent_quickfix.finish(session)
            call call(quickrun#outputter#quickfix#new().finish, [a:session], self)
            :cclose
            :HierUpdate
            :QuickfixStatusEnable
        endfunction

        call quickrun#register_outputter("silent_quickfix", s:silent_quickfix)

        let g:quickrun_config["CppSyntaxCheck_gcc"] = {
            \ "type"  : "cpp",
            \ "exec"      : "%c %o %s:p ",
            \ "command"   : "g++",
            \ "cmdopt"    : "-fsyntax-only -std=gnu++0x ",
            \ "outputter" : "silent_quickfix",
            \ "runner"    : "vimproc"
        \ }

        let g:quickrun_config["CppSyntaxCheck_msvc"] = {
            \ "type"  : "cpp",
            \ "exec"      : "%c %o %s:p ",
            \ "command"   : "cl.exe",
            \ "cmdopt"    : "/Zs ",
            \ "outputter" : "silent_quickfix",
            \ "runner"    : "vimproc",
            \ "output_encode" : "sjis"
        \ }

        "autocmd MyVimrcCmd BufWritePost *.cpp,*.h,*.hpp :QuickRun CppSyntaxCheck_msvc
    catch /E117/

    endtry
endfunction
call Flymake_for_CPP_Setting()
"}}}
" settings for pandoc{{{
let g:quickrun_config['markdown'] = {
      \ 'type': 'markdown/pandoc',
      \ 'outputter': 'browser',
      \ 'cmdopt': '-s'
      \ }
"}}}
"}}}
"---------------------------------------------------------------------------
" vim-ambicmd:"{{{
"
if 1 && filereadable($DOTVIM.'/Bundle/vim-ambicmd/autoload/ambicmd.vim')
    cnoremap <expr> <Space> ambicmd#expand("\<Space>")
    cnoremap <expr> <CR> ambicmd#expand("\<CR>")
    cnoremap <expr> <C-f> ambicmd#expand("\<Right>")

    autocmd MyVimrcCmd CmdwinEnter * call s:init_cmdwin_ambicmd()
    function! s:init_cmdwin_ambicmd()
        inoremap <buffer> <expr> <Space> ambicmd#expand("\<Space>")
        inoremap <buffer> <expr> <CR> ambicmd#expand("\<CR>")
    endfunction
endif
"}}}
"---------------------------------------------------------------------------
" tcommand_vim:"{{{
"
noremap <Leader>: :TCommand<CR>
"}}}
"---------------------------------------------------------------------------
" Source-Explorer-srcexpl.vim:"{{{
"
" // The switch of the Source Explorer                                         "
" nmap <F8> :SrcExplToggle<CR>
"                                                                              "
" // Set the height of Source Explorer window                                  "
 let g:SrcExpl_winHeight = 8
"                                                                              "
" // Set 100 ms for refreshing the Source Explorer                             "
 let g:SrcExpl_refreshTime = 100
"                                                                              "
" // Set "Enter" key to jump into the exact definition context                 "
 let g:SrcExpl_jumpKey = "<ENTER>"
"                                                                              "
" // Set "Space" key for back from the definition context                      "
 let g:SrcExpl_gobackKey = "<SPACE>"
"                                                                              "
" // In order to Avoid conflicts, the Source Explorer should know what plugins "
" // are using buffers. And you need add their bufname into the list below     "
" // according to the command ":buffers!"                                      "
 let g:SrcExpl_pluginList = [
         \ "__Tag_List__",
         \ "_NERD_tree_",
         \ "Source_Explorer"
     \ ]
"                                                                              "
" // Enable/Disable the local definition searching, and note that this is not  "
" // guaranteed to work, the Source Explorer doesn't check the syntax for now. "
" // It only searches for a match with the keyword according to command 'gd'   "
 let g:SrcExpl_searchLocalDef = 1
"                                                                              "
" // Do not let the Source Explorer update the tags file when opening          "
 let g:SrcExpl_isUpdateTags = 0
"                                                                              "
" // Use 'Exuberant Ctags' with '--sort=foldcase -R .' or '-L cscope.files' to "
" //  create/update a tags file                                                "
 let g:SrcExpl_updateTagsCmd = "ctags --sort=foldcase -R ."
"                                                                              "
" // Set "<F12>" key for updating the tags file artificially                   "
" let g:SrcExpl_updateTagsKey = "<F12>"
"}}}
"---------------------------------------------------------------------------
" gtags.vim:"{{{
"
nmap <Leader>gs :<C-u>Gtags -s <C-R>=expand("<cword>")<CR><CR>
nmap <Leader>gg :<C-u>Gtags -g <C-R>=expand("<cword>")<CR><CR>
nmap <Leader>gf :<C-u>Gtags -f <C-R>=expand("<cfile>")<CR><CR>
nmap <Leader>gr :<C-u>Gtags -r <C-R>=expand("<cword>")<CR><CR>
nmap <Leader>gd :<C-u>Gtags -d <C-R>=expand("<cword>")<CR><CR>
"}}}
"---------------------------------------------------------------------------
" python-mode:"{{{
"
let g:pymode_lint_onfly = 1
let g:pymode_lint_write = 1
let g:pymode_lint_cwindow = 0
let g:pymode_lint_message = 1
let g:pydoc = "python -m pydoc"
let g:pymode_rope = 0
let g:pymode_folding = 0
"}}}
"---------------------------------------------------------------------------
" perl-support.vim:"{{{
"
let g:Perl_Debugger = "ptkdb"
"}}}
"---------------------------------------------------------------------------
" jslint.vim:"{{{
"
autocmd MyVimrcCmd FileType javascript call s:registJSLintCmd()

let s:jslint_enabled = filereadable($DOTVIM . '/Bundle/jslint.vim/plugin/jslint.vim') &&
            \ s:MSWindows ||
            \ exists("$JS_CMD") ||
            \ executable('/System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc') ||
            \ executable('node') ||
            \ executable('js')

let g:jslint_cmd_registered = []
function! s:registJSLintCmd()
    if s:jslint_enabled && index(g:jslint_cmd_registered, bufnr('%')) < 0
        call add(g:jslint_cmd_registered, bufnr('%'))
        autocmd MyVimrcCmd BufLeave     <buffer> call jslint#clear()
        autocmd MyVimrcCmd BufWritePost <buffer> call jslint#check()
        autocmd MyVimrcCmd InsertLeave <buffer> call jslint#check()
        autocmd MyVimrcCmd CursorMoved  <buffer> call jslint#message()
    endif
endfunction
"}}}
"---------------------------------------------------------------------------
" haskellmode-vim:"{{{
"
if s:MSWindows
    let g:haddock_browser="C:/Program\ Files/Mozilla\ Firefox/firefox.exe"
else
    let g:haddock_browser="/usr/bin/firefox"
endif
"}}}
"---------------------------------------------------------------------------
" vimclojure:"{{{
"
let g:clj_highlight_builtins = 1
let g:clj_paren_rainbow = 1
"}}}
"---------------------------------------------------------------------------
" neobundle.vim:"{{{
"
function! LazyLoading(ft)
    for plugin_name in g:ll_plugins[a:ft]
        execute "silent! NeoBundleSource " . plugin_name
    endfor
    execute "autocmd! NeoBundleSourceFor_" . a:ft

    if exists('g:ll_post_process[a:ft]')
        for post_process in g:ll_post_process[a:ft]
            execute post_process
        endfor
    endif
endfunction

let g:ll_plugins={}
let g:ll_plugins['c'] = [
            \ 'taglist.vim',
            \ 'taghighlight',
            \ 'a.vim',
            \ 'c.vim',
            \ 'Source-Explorer-srcexpl.vim',
            \ 'trinity.vim',
            \ 'cscope-menu',
            \ 'gtags.vim',
            \ 'DoxygenToolkit.vim',
            \ ]
let g:ll_plugins['cpp'] = [
            \ 'taglist.vim',
            \ 'taghighlight',
            \ 'a.vim',
            \ 'c.vim',
            \ 'Source-Explorer-srcexpl.vim',
            \ 'trinity.vim',
            \ 'cscope-menu',
            \ 'gtags.vim',
            \ 'DoxygenToolkit.vim',
            \ ]
let g:ll_plugins['python'] = [
            \ 'pytest.vim',
            \ 'python-mode',
            \ 'taglist.vim',
            \ 'taghighlight',
            \ ]
let g:ll_plugins['perl'] = [
            \ 'perl-support.vim',
            \ 'taglist.vim',
            \ 'taghighlight',
            \ ]
let g:ll_plugins['javascript'] = [
            \ 'vim-javascript',
            \ 'jslint.vim',
            \ 'taghighlight',
            \ ]
let g:ll_plugins['haskell'] = [
            \ 'vim-filetype-haskell',
            \ 'haskellmode-vim',
            \ 'vim-syntax-haskell-cabal',
            \ 'ghcmod-vim',
            \ ]
let g:ll_post_process={}
let g:ll_post_process['c'] = [
            \ 'call s:registReadTypesCmd("c")',
            \ 'silent! ReadTypes'
            \ ]
let g:ll_post_process['cpp'] = [
            \ 'call s:registReadTypesCmd("cpp")',
            \ 'silent! ReadTypes'
            \ ]
let g:ll_post_process['python'] = [
            \ 'call s:registReadTypesCmd("python")',
            \ 'silent! ReadTypes'
            \ ]
let g:ll_post_process['perl'] = [
            \ 'call s:registReadTypesCmd("perl")',
            \ 'silent! ReadTypes'
            \ ]
let g:ll_post_process['javascript'] = [
            \ 'call s:registReadTypesCmd("javascript")',
            \ 'silent! ReadTypes'
            \ ]

if has('vim_starting')
    " lazy loading of each filetype
    if exists("g:ll_plugins") && !s:Android
        for k in keys(g:ll_plugins)
            execute "augroup " . "NeoBundleSourceFor_" . k
            execute "autocmd!"
            execute "autocmd FileType " . k . " call LazyLoading('" . k . "')"
            execute "augroup END"
        endfor
    endif

    " lazy loading for vim-ref
    nnoremap <silent> K :<C-u>call LoadVimRef()<CR>K
    vnoremap <silent> K :<C-u>call LoadVimRef()<CR>K
    command! -nargs=+ Ref
                \ execute 'silent! NeoBundleSource vim-ref'
                \ | call ref#ref(<q-args>)
    function! LoadVimRef()
        nunmap K
        vunmap K
        silent! NeoBundleSource vim-ref
    endfunction

    " lazy loading for vimfiler
    nnoremap <silent> [vimfiler]b  :<C-u>call LoadVimFiler('VimFilerBufferDir')<CR>
    nnoremap <silent> [vimfiler]c  :<C-u>call LoadVimFiler('VimFilerCurrentDir')<CR>
    nnoremap <silent> [vimfiler]d  :<C-u>call LoadVimFiler('VimFilerDouble')<CR>
    nnoremap <silent> [vimfiler]f  :<C-u>call LoadVimFiler('VimFilerSimple -no-quit -winwidth=32')<CR>

    " for retry vimfiler command
    " vimfiler needs a few seconds to load with low-spec PC
    function! LoadVimFiler(vimfiler_cmd)
        silent! NeoBundleSource vimfiler
        let s:is_vimfiler_loading = 1
        while s:is_vimfiler_loading
            try
                silent! execute a:vimfiler_cmd
                let s:is_vimfiler_loading = 0
            catch /E127/
                sleep 1
            endtry
        endwhile
    endfunction

    " lazy loading for vim-quickrun
    function! LoadQuickRun()
        silent! NeoBundleSource vim-quickrun
        silent! NeoBundleSource quicklearn
        call Flymake_for_CPP_Setting()
    endfunction
    nnoremap <silent> <Leader>r :<C-u>call LoadQuickRun()<CR>:QuickRun<CR>
    command! -nargs=* -range=0 QuickRun
                \ call LoadQuickRun()
                \ | call quickrun#command(<q-args>, <count>, <line1>, <line2>)
endif
"}}}
"}}}

"---------------------------------------------------------------------------
" Key Mappings:"{{{
"
" leave insertmode
inoremap jj <ESC>

" insert blank in normal mode
nnoremap <C-Space> i <Esc><Right>
nnoremap <C-o> o<Esc><Up>
nnoremap <C-O> O<Esc><Down>

" Tabpage related mappings
nnoremap <Space>to :<C-u>tabnew<CR>
nnoremap <Space>tq :<C-u>tabclose<CR>

" Window related mappings
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-h> <C-w>h
nnoremap <M-l> <C-w>l
inoremap <M-j> <Esc><C-w>j
inoremap <M-k> <Esc><C-w>k
inoremap <M-h> <Esc><C-w>h
inoremap <M-l> <Esc><C-w>l

nnoremap <M-+> <C-w>+
nnoremap <M--> <C-w>-
nnoremap <M->> <C-w>>
nnoremap <M-<> <C-w><
inoremap <M-+> <Esc><C-w>+
inoremap <M--> <Esc><C-w>-
inoremap <M->> <Esc><C-w>>
inoremap <M-<> <Esc><C-w><

" Move to the position last edited
nnoremap gb '[
nnoremap gp ']

" 'Quote'
onoremap aq  a'
xnoremap aq  a'
onoremap iq  i'
xnoremap iq  i'

" "Double quote"
onoremap ad  a"
xnoremap ad  a"
onoremap id  i"
xnoremap id  i"

" (Round bracket)
onoremap ar  a)
xnoremap ar  a)
onoremap ir  i)
xnoremap ir  i)

" {Curly bracket}
onoremap ac  a}
xnoremap ac  a}
onoremap ic  i}
xnoremap ic  i}

" <Angle bracket>
onoremap aa  a>
xnoremap aa  a>
onoremap ia  i>
xnoremap ia  i>

" [sqUare bracket]
onoremap au  a]
xnoremap au  a]
onoremap iu  i]
xnoremap iu  i]

"}}}

"---------------------------------------------------------------------------
" External Settings:"{{{
"
if 1 && filereadable($MYLOCALVIMRC)
    source $MYLOCALVIMRC
endif
"}}}

" vim: foldmethod=marker
