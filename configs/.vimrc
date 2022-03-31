" ******************************************************************************
" Vim 設定ファイル
" ------------------------------------------------------------------------------
" - 操作方法を一変させるような設定は行わない
" - 情報可視化、視認性向上、操作感改善程度に留める
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

set syntax=on              " シンタックスハイライト
set cursorline             " カーソル行をハイライト
set cursorcolumn           " カーソル列をハイライト
set guicursor=a:blinkon0   " カーソルの点滅を無効化
set showmatch              " 対応する括弧をハイライト
set matchpairs+=<:>        " 対応する括弧の種類を追加
set hlsearch               " 検索結果をハイライト
set number                 " 行番号の表示
set colorcolumn=80         " 目安線を表示
set scrolloff=5            " 上下スクロール時のオフセットを設定
set sidescrolloff=4        " 左右スクロール時のオフセットを設定
set sidescroll=1           " 左右スクロール時の移動量を設定
set showcmd                " コマンドを可視化
set visualbell             " ビープ音を可視化
set list                   " 不可視文字を可視化
set wildmode=list:longest  " ファイル名の補完を有効化
set laststatus=2           " ステータスバーを表示
set listchars=tab:→\ ,trail:·,eol:↲,nbsp:%,extends:»,precedes:«
set statusline=%f\ %m\ %r%h%w%=Ln:%l\ Col:%c\ %{&fileencoding!=''?&fileencoding:&encoding}\ %{&fileformat}\ %{&filetype!=''?&filetype:'plain'}

" see: http://fugal.net/vim/rgbtxt.html
highlight NonText     guifg=grey50          " 改行文字の色
highlight SpecialKey  guifg=grey50          " タブ文字の色
highlight ColorColumn guibg=DimGrey         " 目安線の色
highlight Visual      guibg=LightSlateGrey  " 選択範囲の色


" ------------------------------------------------------------------------------
" 挙動変更を伴う設定
" ------------------------------------------------------------------------------

set clipboard=unnamed,unnamedplus  " Vim と OS のクリップボードを連携
set ttimeoutlen=10                 " インサートモードを抜けるまでの待機時間を削減

set nobackup                       " 保存時に永続バックアップを作成しない
set nowritebackup                  " 保存時に復旧用一時ファイルを作成しない
set noswapfile                     " 編集時に復旧用一時ファイルを作成しない
set noundofile                     " 変更履歴の永続バックアップを作成しない

set autoread                       " 未変更のファイルに対する Vim 外での更新を自動反映
set autochdir                      " 編集中ファイルに合わせ作業ディレクトリを変更
set incsearch                      " 検索語の入力時点で事前検索を実施
set autoindent                     " 改行時にインデント幅を継承
set smartindent                    " ブラケット内等で自動インデント
set whichwrap=b,s,h,l,<,>,[,],~    " 行頭行末での左右移動を許可
set virtualedit+=block             " 矩形選択時に行末を超えたカーソル移動を許可

" ---------- 強制終了 ----------
" 一般的なアプリケーションと同様に ctrl+C で終了させる
nnoremap <C-c> :q<CR>
vnoremap <C-c> <Esc>:q<CR>
inoremap <C-c> <Esc>:q<CR>
" MSEdit にも合わせて ctrl+Q も
nnoremap <C-q> :q<CR>
vnoremap <C-q> <Esc>:q<CR>
inoremap <C-q> <Esc>:q<CR>

" ---------- 表示行単位での移動 ----------
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
vnoremap <Up>   gk
vnoremap <Down> gj
inoremap <Up>   <C-r>=<SID>PerformMove("up")<CR>
inoremap <Down> <C-r>=<SID>PerformMove("down")<CR>

" ---------- IME 対応 ----------
function! DisableIme()
  if has("mac")
    " 英数キーを送信
    silent call system("osascript -l JavaScript -e 'Application(`System Events`).keyCode(102)'")
  " else
    " let g:command_im = '/opt/homebrew/bin/im-select'
    " let g:default_im_macos = 'com.apple.keylayout.ABC'
    " let current_im = trim(system(g:command_im))
    " if current_im != g:default_im_macos
    "   call system(g:command_im . ' ' . g:default_im_macos)
    " endif
  endif
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

" ---------- ESC によるクリア機能強化 ----------
" ノーマルモードで ESC 押下時
" 1. 英数入力を指定
" 2. 検索ハイライトを解除
nnoremap <ESC> :call DisableIme()<CR>:noh<CR>

" ---------- チートシート表示 ----------
" 汎用コンテンツのバッファ表示
" @param bufname バッファ名
" @param content 表示する文字列
" @param ...     (可変長引数) オプション
function! ShowBuffer(bufname, content, ...)
  " オプション引数の取得
  let l:options = a:0 > 0 ? a:1 : {}
  let l:height = get(l:options, 'height', float2nr(&lines * 0.75))
  let l:filetype = get(l:options, 'filetype', 'markdown')
  let l:close_keys = get(l:options, 'close_keys', ['<ESC>'])

  " バッファがすでに存在する場合は削除
  let l:bufnr = bufnr(a:bufname)
  if l:bufnr != -1
    execute 'bwipeout! ' . l:bufnr
  endif

  " バッファを作成
  execute 'silent' l:height 'new'
  silent execute 'file' a:bufname

  " バッファ用の設定
  setlocal noswapfile        " バックアップファイルを作成しない
  setlocal nobuflisted       " バッファリストから除外
  setlocal bufhidden=wipe    " バッファを閉じた際にメモリもクリア
  setlocal buftype=nofile    " ファイルとの関連付けを無効化
  execute 'setlocal filetype=' . l:filetype

  " バッファに文字列を追加
  setlocal modifiable
  silent %delete _
  call setline(1, a:content)
  setlocal nomodifiable
  setlocal readonly

  " カーソルを先頭に移動
  silent normal! gg

  " このバッファ内でのみ指定のキーに閉じる処理を割り当てる
  for key in l:close_keys
    execute 'nnoremap <buffer> ' . key . ' :q<CR>'
  endfor

  " コマンドラインのメッセージをクリア
  echo ""
endfunction

" チートシートのバッファ表示
function! ShowCheatSheet()
  let l:content = [
    \ '## ----------------- コマンドライン -----------------',
    \ ':q⏎         閉じる',
    \ ':w⏎         上書き保存',
    \ ':e <PATH>⏎  ファイルを開く',
    \ ':se <OPT>⏎  Vim オプションを適用 (`:se nowrap`)',
    \ ':h <CMD>⏎   Vim コマンドのヘルプを表示 (`:h :w`)',
    \ ':!<SH>⏎     シェルコマンドを実行 (`:!ls`)',
    \ '',
    \ '## ---------------------- 検索 ----------------------',
    \ '/<WORD>⏎    指定の文字列を検索 (`/Hoge`)',
    \ '  └ n         次へ移動',
    \ '  └ N         前へ移動',
    \ 'f<CHAR>     現在の行で、指定の文字を検索 (`fH`)',
    \ '  └ ;         次へ移動',
    \ '  └ ,         前へ移動',
    \ '',
    \ '## ------------------- スクロール -------------------',
    \ 'ctrl+u      半ページ上に移動',
    \ 'ctrl+d      半ページ下に移動',
    \ 'ctrl+b      １ページ上に移動',
    \ 'ctrl+f      １ページ下に移動',
    \ '',
    \ '## ---------------- <POS> 位置(移動) ----------------',
    \ 'gg          ファイルの先頭に移動',
    \ 'G           ファイルの末尾に移動',
    \ '<LINE>gg    指定の行番号に移動 (`10gg`)',
    \ '<LINE>⏎     指定の行数だけ下に移動 (`10⏎`)',
    \ '^           行頭に移動',
    \ '$           行末に移動',
    \ 'w           次の単語の先頭に移動',
    \ 'e           単語の末尾に移動',
    \ 'b           単語の先頭に移動',
    \ '%           対応する括弧に移動',
    \ '',
    \ '## ---------------- <POS> 位置(範囲) ----------------',
    \ 'iw          単語の範囲',
    \ 'i"          ダブルクォートで囲われた範囲',
    \ '',
    \ '## ------------------- <SEL> 選択 -------------------',
    \ 'v           カーソル位置から選択開始',
    \ '  └ o         選択開始位置を移動開始',
    \ 'V           現在行から行選択開始',
    \ 'ctrl+v      カーソル位置から矩形選択開始',
    \ '  └ o         矩形入力開始',
    \ '',
    \ '## ---------------------- 入力 ----------------------',
    \ 'i           カーソル位置の左側から入力開始',
    \ 'a           カーソル位置の右側から入力開始',
    \ 'I           行頭から入力開始',
    \ 'A           行末から入力開始',
    \ 'c<POS>      指定の位置までカットして入力開始 (`cw`)',
    \ 'ciw         カーソル位置にある単語をカットして入力開始',
    \ '',
    \ '## ---------------------- 編集 ----------------------',
    \ 'u           元に戻す',
    \ 'ctrl+r      やり直し',
    \ 'P           貼り付け (カーソル位置の左または上)',
    \ 'gU<POS>     指定の位置まで大文字に変換 (`gUiw`)',
    \ ':sort⏎      テキストを昇順に並び替え',
    \ '',
    \ '## --------------------- コピー ---------------------',
    \ 'y<POS>      指定の位置までコピー (`y10`)',
    \ '<SEL>y      指定の選択範囲をコピー',
    \ 'yy          現在行をコピー',
    \ 'yiw         カーソル位置にある単語をコピー',
    \ '',
    \ '## --------------------- カット ---------------------',
    \ 'x           カーソル位置の文字をカット',
    \ 'X           カーソル位置の直前の１文字をカット',
    \ 'd<POS>      指定の位置までカット (`d$`)',
    \ '<SEL>d      指定の選択範囲をカット',
    \ 'dd          現在行をカット',
    \ 'diw         カーソル位置にある単語をカット',
    \ 'ctrl+w      ※挿入時 直前の単語の開始位置まで削除',
    \ '',
    \ '## ------------------- 応用(操作) -------------------',
    \ 'ggVG        全選択',
    \ 'gUiw        カーソル位置の単語を大文字に変換',
    \ 'cf<CHAR>    検索文字の手前まで削除して入力開始',
    \ 'aHoge.      再実行',
    \ '            「"Hoge" の入力」をもう一度実行',
    \ '10iHoge     連続実行',
    \ '            「"Hoge" の入力」10回繰り返す',
    \ '',
    \ '## ----------------- 応用(コマンド) -----------------',
    \ ':%s/OLD/NEW/g⏎   文字列を置換',
    \ '                 % 全行走査し, s 置換する, g 全箇所を',
    \ ':%g/^$/norm dd⏎  空行を削除',
    \ '                 % 全行走査し, g Grepする',
    \ ':r !ls⏎          シェルコマンドの結果を挿入',
    \ '                 ファイルの一覧を取得 (ls) し挿入 (:r)',
    \ ':!echo $((1+2))⏎ 数値を計算',
    \ '                 シェル (:!) で計算し表示 (echo)',
    \ ]
  call ShowBuffer('VimCheatSheet', l:content, {'close_keys': ['<Space>', '<ESC>']})
endfunction

" チートシート表示コマンド
nnoremap <Space> :call ShowCheatSheet()<CR>
