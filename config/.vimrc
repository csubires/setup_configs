autocmd VimEnter * startinsert
autocmd BufNewFile,BufRead * startinsert
filetype on
syntax on
set number
set cursorline
set nocompatible
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,latin1
set mouse=a
set ruler
set clipboard=unnamed
set nobackup
set nowritebackup
set noswapfile
set autoindent
set smarttab
set nowrap
set shiftwidth=4
set tabstop=4
set softtabstop=4
set scrolloff=8
set showmatch
set wildmenu
set nohlsearch
set hlsearch

:colorscheme sorbet

" Pares básicos (solo los que NO tienen conflicto)
inoremap <silent> ( ()<Left>
inoremap <silent> [ []<Left>
inoremap <silent> { {}<Left>
inoremap <silent> ` ``<Left>

" Cierre inteligente
inoremap <expr> ) getline('.')[col('.')-1] == ')' ? "\<Right>" : ')'
inoremap <expr> ] getline('.')[col('.')-1] == ']' ? "\<Right>" : ']'
inoremap <expr> } getline('.')[col('.')-1] == '}' ? "\<Right>" : '}'
inoremap <expr> ` getline('.')[col('.')-1] == '`' ? "\<Right>" : '`'

" Para comillas - versión que SÍ funciona
inoremap <expr> ' SmartQuote("'")
inoremap <expr> " SmartQuote('"')

function! SmartQuote(quote)
    let line = getline('.')
    let col_pos = col('.') - 1

    " Si el siguiente carácter es la misma comilla, saltar sobre ella
    if line[col_pos] == a:quote
        return "\<Right>"
    endif

    " Si no, insertar par de comillas
    return a:quote . a:quote . "\<Left>"
endfunction

" Auto-cierre con Enter para bloques
inoremap {<CR> {<CR>}<Esc>O
inoremap [<CR> [<CR>]<Esc>O
inoremap (<CR> (<CR>)<Esc>O

" Envolver selección con pares
vnoremap ( "zc()<Esc>"zp
vnoremap [ "zc[]<Esc>"zp
vnoremap { "zc{}<Esc>"zp
vnoremap ' "zc''<Esc>"zp
vnoremap " "zc""<Esc>"zp
vnoremap ` "zc``<Esc>"zp

" Para HTML/XML
inoremap < <><Left>
inoremap ><Space> ><Space>
inoremap ><CR> ><CR></<C-X><C-O><Esc>?<<CR>a

" MOREEEEEEE 

" Buscar visualmente seleccionado
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Reemplazar en todo el proyecto
nnoremap <Leader>r :%s///g<Left><Left><Left>

" Buscar archivos rápidamente
nnoremap <Leader>f :find<Space>

" Deshacer/Rehacer más fácil
nnoremap U <C-r>

" Duplicar línea (como Ctrl+D en otros editores)
nnoremap <C-d> yyp

" Mover líneas arriba/abajo
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Línea de estado informativa
set laststatus=2
set statusline=
set statusline+=%#PmenuSel#
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c

" Explorador de archivos con netrw mejorado
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25

" Abrir explorador actual
nnoremap <Leader>e :Lexplore<CR>

" Resaltar línea actual
set cursorline

" Navegar por líneas largas visualmente
nnoremap j gj
nnoremap k gk

" Buscar y centrar pantalla
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz

" Guardar con Ctrl+s (como en otros editores)
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a

" Salir fácil
nnoremap <Leader>q :q<CR>
nnoremap <Leader>w :wq<CR>

" Toggle números
nnoremap <Leader>n :set number!<CR>

" Limpiar búsqueda
nnoremap <silent> <Leader>/ :nohlsearch<CR>
