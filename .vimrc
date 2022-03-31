" ******************************************************************************
" Vim 設定ファイル
"
" ------------------------------------------------------------------------------
" - 操作方法を一変させるような設定は行わない
" - 情報可視化、視認性向上、多少の操作感改善程度に留める
" ******************************************************************************


" ------------------------------------------------------------------------------
" プラグインの管理
" ------------------------------------------------------------------------------

" プラグインマネージャーのインストール
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  augroup InstallManager
    autocmd!
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  augroup END
endif

" プラグインのインストール
augroup InstallPlugins
  autocmd!
  autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) | PlugInstall --sync | source $MYVIMRC | endif
augroup END

" プラグインの設定
call plug#begin('~/.vim/plugged')
Plug 'dracula/vim', { 'as': 'dracula' }
call plug#end()


" ------------------------------------------------------------------------------
" Vim の設定
" ------------------------------------------------------------------------------

:silent! packadd! dracula                  " テーマをロード
:silent! colorscheme dracula               " カラースキームを指定
syntax on                                  " シンタックスハイライト
highlight NonText     guifg=grey50         " 改行文字の色
highlight SpecialKey  guifg=grey50         " タブ文字の色
highlight ColorColumn guibg=DimGrey        " 目安線の色
highlight Visual      guibg=LightSlateGrey " 選択範囲の色

set cursorline      " カーソル行をハイライト
set cursorcolumn    " カーソル列をハイライト
set showmatch       " 対応する括弧をハイライト
set matchpairs+=<:> " 対応する括弧の種類を追加
set hlsearch        " 検索結果をハイライト
set number          " 行番号の表示
set colorcolumn=80  " 目安線を表示
set nowrap          " 折り返し表示を無効化
set scrolloff=5     " 上下スクロール時のオフセットを設定
set sidescrolloff=4 " 左右スクロール時のオフセットを設定
set sidescroll=1    " 左右スクロール時の移動量を設定
set wildmode        " ファイル名の補完を有効化
set showcmd         " コマンドを可視化
set visualbell      " ビープ音を可視化
set list            " 不可視文字を表示
set laststatus=2    " ステータスバーを表示
set listchars=tab:→\ ,trail:·,eol:↲,nbsp:%,extends:»,precedes:«
set statusline=%f\ %m\ %r%h%w%=Ln:%l\ Col:%c\ %{&fileencoding!=''?&fileencoding:&encoding}\ %{&fileformat}\ %{&filetype!=''?&filetype:'plain'}


" ------------------------------------------------------------------------------
" 挙動変更を伴う設定
" ------------------------------------------------------------------------------

set encoding=utf-8                " 文字コードを指定
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8
set fileformats=unix,dos,mac      " 改行コードを指定
set clipboard=unnamed,unnamedplus " Vim と OS のクリップボードを連携

set nobackup                      " 保存時に元データを退避しない
set noswapfile                    " 復旧用ファイルを作成しない
set noundofile                    " 変更履歴を永続化しない

set autoread                      " 未変更のファイルに対する Vim 外での更新を自動反映
set autochdir                     " 編集中ファイルに合わせ作業ディレクトリを変更
set incsearch                     " 検索語の入力時点で事前検索を実施
set autoindent                    " 改行時にインデント幅を継承
set smartindent                   " ブラケット内等で自動インデント
set whichwrap=b,s,h,l,<,>,[,],~   " 行頭行末での左右移動を許可
set virtualedit+=block            " 矩形選択時に行末を超えたカーソル移動を許可

" ----- ハイライト解除 -----
" ESC 連打でハイライトを解除
nnoremap <ESC><ESC> :noh<CR>

" ----- 表示行単位での移動 -----
" インサートモード時、 InsertLeave を発火させずにコマンドを実行したい
" see: https://github.com/vim-jp/issues/issues/1059
function! s:PerformMove(direction)
  if a:direction == "up"
    execute "normal! gk"
  elseif a:direction == "down"
    execute "normal! gj"
  endif
  return ''
endfunction
nnoremap <Up>   gk
nnoremap <Down> gj
inoremap <Up>   <C-r>=<SID>PerformMove("up")<CR>
inoremap <Down> <C-r>=<SID>PerformMove("down")<CR>

" ----- IME 対応 -----
function! DisableIme()
  if has("mac")
    call system('osascript -e "tell application \"System Events\" to key code 102"')
  " else
  "   let g:command_im = '/opt/homebrew/bin/im-select'
  "   let g:default_im_macos = 'com.apple.keylayout.ABC'
  "   let current_im = trim(system(g:command_im))
  "   if current_im != g:default_im_macos
  "     call system(g:command_im . ' ' . g:default_im_macos)
  "   endif
  endif
endfunction
" フォーカス取得時に英数入力を指定
augroup DisableImeOnFocusGained
  autocmd!
  autocmd FocusGained * if mode() ==# 'n' | call DisableIme() | endif
augroup END
" 挿入モード解除時に英数入力を指定
augroup DisableImeOnInsertLeave
  autocmd!
  autocmd InsertLeave * :call DisableIme()
augroup END
" ノーマルモードで ESC 押下時に英数入力を指定
nnoremap <ESC> :call DisableIme()<CR>
" ノーマルモードで日本語入力をショートカットキーとして認識させる
nnoremap あ a
nnoremap い i
nnoremap お o
