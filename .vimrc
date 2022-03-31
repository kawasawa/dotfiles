" ******************************************************************************
" .vimrc
"
" ------------------------------------------------------------------------------
" - 操作方法を変えるような設定変更は行わない
" - 補助表示等の情報可視化、視認性向上程度にとどめる
" ******************************************************************************


" ------------------------------------------------------------------------------
" vim-plug の自動インストール
" ------------------------------------------------------------------------------

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" ------------------------------------------------------------------------------
" プラグインの自動インストール
" ------------------------------------------------------------------------------

autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) | PlugInstall --sync | source $MYVIMRC


" ------------------------------------------------------------------------------
" プラグインの指定
" ------------------------------------------------------------------------------

call plug#begin('~/.vim/plugged')
Plug 'dracula/vim', { 'as': 'dracula' }
call plug#end()


" ------------------------------------------------------------------------------
" Vim の設定
" ------------------------------------------------------------------------------

:silent! packadd! dracula         " プラグインをロード
:silent! colorscheme dracula      " カラースキームを指定
syntax on                         " シンタックスハイライト
set cursorline                    " カーソル行をハイライト
set cursorcolumn                  " カーソル列をハイライト
set hlsearch                      " 検索結果をハイライト
set showmatch                     " 対応する括弧をハイライト
set number                        " 行番号の表示
set wildmenu                      " 補完候補の表示
set laststatus=2                  " ステータスバーを表示
set statusline=%F\ %y%m\ %r%h%w%=[Ln:%02l,Col:%02c]\ [%{&fileencoding!=''?&fileencoding:&encoding},%{&ff}]
set scrolloff=1                   " スクロールオフセットを設定
set clipboard=unnamed,unnamedplus " クリップボードを連携
set nobackup                      " バックアップファイルを無効化
set noswapfile                    " スワップファイルを無効化
set noundofile                    " Undoファイルを無効化
