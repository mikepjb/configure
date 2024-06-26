" Editor Configuration for both Vim (pref. 9.1+) & Neovim (pref. 0.10+)

autocmd! | setglobal nocp enc=UTF-8 tgc path=.,,** clipboard=unnamedplus
syntax on | filetype plugin indent on | runtime macros/matchit.vim
set sb spr vb aw so=3 wmnu wig=*.class,*.jpg,*.png,*.gif,*.pdf
set hid mouse=a bs=indent,eol,start nobk noswapfile gd is hls scs ic
set wrap tw=79 cc=80 sw=4 ts=4 sts=4 sta ai " -- indentation/line width settings
set spell smd sc history=1000 undodir=~/.vim/backup undofile ur=10000
set sm cul nu ls=2 stal=2 statusline=%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)
let g:omni_sql_no_default_maps = 1 | let g:sh_noisk = 1 " prevent remaps
let g:netrw_banner = 0 | let g:netrw_liststyle = 3 " netrw config

augroup Base " <CR> mappings + :make filetype configs
	autocmd!
	autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>
	autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
	autocmd QuickFixCmdPost [^l]* nested cwindow
	autocmd BufRead *.rs :setlocal tags=./rusty-tags.vi;/,$RUST_SRC/rusty-tags.vi
	autocmd FileType rust setlocal makeprg=cargo\ build
augroup END

nnoremap ge :E<CR>|nnoremap <space> :find<space>
nnoremap gc :!ctags -R .<space>
nnoremap gn :tabnew ~/.notes/src/SUMMARY.md<CR>
nnoremap gp :silent %!prettier --stdin-filepath %<CR>
nnoremap <C-j> <C-w><C-j>|nnoremap <C-k> <C-w><C-k>
nnoremap <C-h> <C-w><C-h>|nnoremap <C-l> <C-w><C-l>
nnoremap <Tab> <C-^>|nnoremap <C-g> :noh<CR><C-g>
inoremap <C-c> <Esc>|nnoremap <CR> :make<CR>|nnoremap Q @q
inoremap <C-l> <Space>=><Space>|inoremap <C-u> <Space>-><Space>

if v:version < 901 | finish | endif

set background=dark | colorscheme retrobox

let s:bashrc =<<EOD
export EDITOR=vim CDPATH=".:$HOME/src" PAGER='less -S' NPM_CONFIG_PREFIX=$HOME/.npm
export PATH=$HOME/.cargo/bin:$HOME/.npm/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin
export RUST_SRC=$(rustc --print sysroot)/lib/rustlib/src/rust/library/
alias vi='vim' gr='cd $(git rev-parse --shot-toplevel || echo \".\")'
PS1='\W($(git branch --show-current 2>/dev/null || echo "!")) \$ '
EOD

fun! Dots() abort " create basic dotfiles
	call writefile([". ~/.bashrc"], expand('$HOME/.bash_profile'))
	call writefile(s:bashrc, expand('$HOME/.bashrc'))
	let s:gPre = ";git config --global --replace-all " | let s:git = ""
	let s:f = " %C(cyan)%<(12)%cr %Cgreen%<(14,trunc)%aN%C(auto)%d %Creset%s"
	for s in ["core.editor 'vim'",
			\"core.autocrlf false",  "init.defaultBranch 'main'",
			\"alias.aa 'add --all'", "alias.br 'branch --sort=committerdate'",
			\"alias.st 'status'",    "alias.up 'pull --rebase'",
			\"alias.co 'checkout'",  "alias.ci 'commit --verbose'",
			\"alias.di 'diff'",      "alias.push-new 'push -u origin HEAD'",
			\"alias.ra \"log --pretty=format:'%C(yellow)%h" . s:f . "'\""]
		let s:git = s:git . s:gPre . s
	endfor | call system("command -v git && $(" . s:git[1:] . ")")
endfun | command! Dots :call Dots()

let s:css_reset =<<EOD
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0;}
body { line-height: 1.5; font-size: 100%; -webkit-font-smoothing: antialiased; }
img, picture, video, canvas, svg { display: block; max-width: 100%; }
input, button, textarea, select { font: inherit; }
p, h1, h2, h3, h4, h5, h6 { overflow-wrap: break-word; }
html { -moz-text-size-adjust: none; -webkit-text-size-adjust: none; text-size-adjust: none; }
EOD
call setreg("r", s:css_reset)

let s:html =<<EOD
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<link rel="stylesheet" href="/style.css" type="text/css" media="all" />  
	</head>
</html>
EOD
call setreg("h", s:html)

" install plugins if you need them in ~/.vim/pack/x/start
" For lsps, include dense-analysis/ale and install tsserver/rust_analyzer
let g:ale_completion_enabled = 1 " must be done before loading ale.
packloadall | silent! helptags ALL
if exists('g:loaded_ale')
	set omnifunc=ale#completion#OmniFunc
endif
