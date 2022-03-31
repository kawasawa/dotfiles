" ******************************************************************************
" Vim 設定ファイル (GUI 用)
" ******************************************************************************

" ------------------------------------------------------------------------------
" Vim の設定
" ------------------------------------------------------------------------------

set guifont=Cascadia\ Code:h14  " フォントを指定
set lines=40                    " 画面サイズを指定 (縦)
set columns=80                  " 画面サイズを指定 (横)
set transparency=10             " 画面の透明度を指定
set showtabline=2               " タブバーを常時表示 ※複数タブ時のみだとタブバー表示時にウィンドウ位置がずれるため
set titlestring=Vim\ %{v:version/100}.%{v:version%100}  " タイトルバーの表示文字列を指定 ※ファイル名はあちこち表示されてくどいので除去


" ------------------------------------------------------------------------------
" netrw の設定
" ------------------------------------------------------------------------------

let g:netrw_keepdir=0       " 作業ディレクトリをエクスプローラに追従
let g:netrw_winsize=80      " エクスプローラウィンドウのサイズを指定
let g:netrw_banner=0        " バナー非表示
let g:netrw_liststyle=3     " ツリー表示
let g:netrw_browse_split=1  " ファイルを水平分割で開く
let g:netrw_alto=1          " ファイルを水平分割で開く場合は下部に配置


" ------------------------------------------------------------------------------
" term の設定
" ------------------------------------------------------------------------------

set termwinsize=10x0  " ターミナルウィンドウのサイズを指定


" ------------------------------------------------------------------------------
" 挙動変更を伴う設定
" ------------------------------------------------------------------------------

" ---------- 選択と削除 ----------
" 一般的なエディタの操作感を再現
nnoremap <S-Up>    vgk
nnoremap <S-Down>  vgj
nnoremap <S-Left>  v<Left>
nnoremap <S-Right> v<Right>
vnoremap <S-Up>    gk
vnoremap <S-Down>  gj
vnoremap <S-Left>  <Left>
vnoremap <S-Right> <Right>
inoremap <S-Up>    <Esc>vgk
inoremap <S-Down>  <Esc>vgj
inoremap <S-Left>  <Esc>v<Left>
inoremap <S-Right> <Esc>v<Right>
vnoremap <BS> "_d  " ビジュアルモードでは選択範囲を削除 (ブラックホールレジスタに送る)

" ---------- フォーカス移動 ----------
" VSCode のショートカットキーを再現
" - Cmd-1:       エディタにフォーカスを設定
" - Cmd-Shift-e: エクスプローラにフォーカスを設定
" - Cmd-@:       ターミナルにフォーカスを設定
function! FocusEditor()
  for win in range(1, winnr('$'))
    let ft = getbufvar(winbufnr(win), '&filetype')
    let bt = getbufvar(winbufnr(win), '&buftype')
    if ft != 'netrw' && bt != 'terminal'
      execute win . 'wincmd w'
      return
    endif
  endfor
  echo "editor window not found"
endfunction
function! FocusExplorer()
  for win in range(1, winnr('$'))
    let ft = getbufvar(winbufnr(win), '&filetype')
    if ft == 'netrw'
      execute win . 'wincmd w'
      return
    endif
  endfor
  " 無ければ生成
  Explore
endfunction
function! FocusTerminal()
  for win in range(1, winnr('$'))
    let bt = getbufvar(winbufnr(win), '&buftype')
    if bt == 'terminal'
      execute win . 'wincmd w'
      return
    endif
  endfor
  " 無ければ生成
  terminal
endfunction

nnoremap <D-1> :call FocusEditor()<CR>
nnoremap <D-E> :call FocusExplorer()<CR>
nnoremap <D-@> :call FocusTerminal()<CR>
tnoremap <D-1> <C-\><C-n>:call FocusEditor()<CR>
nnoremap <D-E> <C-\><C-n>:call FocusExplorer()<CR>
