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
let s:vim_plug = expand('~/.vim/autoload/plug.vim')
if !filereadable(s:vim_plug)
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  let s:first_run = 1
endif

" プラグインのインストール
augroup InstallPlugins
  " vim-plug の初回インストール時 または 未インストールのプラグインがある場合
  autocmd!
  autocmd VimEnter * if exists('s:first_run') || len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) | PlugInstall --sync | source $MYVIMRC | endif
augroup END


" プラグインの追加
call plug#begin('~/.vim/plugged')
Plug 'dracula/vim', { 'as': 'dracula' }
call plug#end()

" プラグインの設定
silent! packadd! dracula
silent! colorscheme dracula


" ------------------------------------------------------------------------------
" Vim の設定
" ------------------------------------------------------------------------------

set syntax=on             " シンタックスハイライト
set cursorline            " カーソル行をハイライト
set cursorcolumn          " カーソル列をハイライト
set guicursor=a:blinkon0  " カーソルの点滅を無効化
set showmatch             " 対応する括弧をハイライト
set matchpairs+=<:>       " 対応する括弧の種類を追加
set hlsearch              " 検索結果をハイライト
set number                " 行番号の表示
set colorcolumn=80        " 目安線を表示
set scrolloff=5           " 上下スクロール時のオフセットを設定
set sidescrolloff=4       " 左右スクロール時のオフセットを設定
set sidescroll=1          " 左右スクロール時の移動量を設定
set showcmd               " コマンドを可視化
set visualbell            " ビープ音を可視化
set list                  " 不可視文字を可視化
set wildmode=list:longest " ファイル名の補完を有効化
set laststatus=2          " ステータスバーを表示
set listchars=tab:→\ ,trail:·,eol:↲,nbsp:%,extends:»,precedes:«
set statusline=%f\ %m\ %r%h%w%=Ln:%l\ Col:%c\ %{&fileencoding!=''?&fileencoding:&encoding}\ %{&fileformat}\ %{&filetype!=''?&filetype:'plain'}

" see: http://fugal.net/vim/rgbtxt.html
highlight NonText     guifg=grey50         " 改行文字の色
highlight SpecialKey  guifg=grey50         " タブ文字の色
highlight ColorColumn guibg=DimGrey        " 目安線の色
highlight Visual      guibg=LightSlateGrey " 選択範囲の色


" ------------------------------------------------------------------------------
" 挙動変更を伴う設定
" ------------------------------------------------------------------------------

set encoding=utf-8                  " システムの文字コードを指定
set fileencoding=utf-8              " 新規ファイルの文字コードを指定
set fileencodings=utf-8,sjis,euc-jp " 文字コードの識別候補と優先順位
set fileformats=unix,dos,mac        " 改行コードを指定
set clipboard=unnamed,unnamedplus   " Vim と OS のクリップボードを連携
set ttimeoutlen=10                  " インサートモードを抜けるまでの待機時間を削減

set nobackup                        " 保存時に永続バックアップを作成しない
set nowritebackup                   " 保存時に復旧用一時ファイルを作成しない
set noswapfile                      " 編集時に復旧用一時ファイルを作成しない
set noundofile                      " 変更履歴の永続バックアップを作成しない

set autoread                        " 未変更のファイルに対する Vim 外での更新を自動反映
set autochdir                       " 編集中ファイルに合わせ作業ディレクトリを変更
set incsearch                       " 検索語の入力時点で事前検索を実施
set autoindent                      " 改行時にインデント幅を継承
set smartindent                     " ブラケット内等で自動インデント
set whichwrap=b,s,h,l,<,>,[,],~     " 行頭行末での左右移動を許可
set virtualedit+=block              " 矩形選択時に行末を超えたカーソル移動を許可

" ----- 表示行単位での移動 -----
" インサートモード時に InsertLeave を発火させずにコマンドを実行したい
" see: https://github.com/vim-jp/issues/issues/1059
function! s:PerformMove(direction)
  if a:direction == "up"
    execute "normal! gk"
  elseif a:direction == "down"
    execute "normal! gj"
  endif
  " 空文字を返却する
  return ''
endfunction
nnoremap <Up>   gk
nnoremap <Down> gj
inoremap <Up>   <C-r>=<SID>PerformMove("up")<CR>
inoremap <Down> <C-r>=<SID>PerformMove("down")<CR>

" ----- IME 対応 -----
function! DisableIme()
  " if has("mac")
  "   call system('osascript -e "tell application \"System Events\" to key code 102"')
  " else
  " AppleScript は実行までラグがあるため、より高速な im-select で代用
  let g:command_im = '/opt/homebrew/bin/im-select'
  let g:default_im_macos = 'com.apple.keylayout.ABC'
  let current_im = trim(system(g:command_im))
  if current_im != g:default_im_macos
    call system(g:command_im . ' ' . g:default_im_macos)
  endif
  " endif
endfunction
" フォーカス取得時に英数入力を指定
augroup DisableImeOnFocusGained
  autocmd!
  autocmd FocusGained * if mode() == 'n' | call DisableIme() | endif
augroup END
" 挿入モード解除時に英数入力を指定
augroup DisableImeOnInsertLeave
  autocmd!
  autocmd InsertLeave * :call DisableIme()
augroup END

" ----- ESC によるクリア機能強化 -----
" ノーマルモードで ESC 押下時
" 1. 英数入力を指定
" 2. 検索ハイライトを解除
nnoremap <ESC> :call DisableIme()<CR>:noh<CR>
