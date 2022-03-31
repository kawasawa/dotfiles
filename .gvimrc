" ******************************************************************************
" Vim 設定ファイル (GUI 用)
" ******************************************************************************


" ------------------------------------------------------------------------------
" Vim の設定
" ------------------------------------------------------------------------------

set guifont=Cascadia\ Code:h14 " フォントを指定
set lines=35                   " 画面サイズを指定 (縦)
set columns=60                 " 画面サイズを指定 (横)
set transparency=10            " 画面の透明度を指定
set showtabline=2              " タブバーを常時表示 ※複数タブ時のみだとタブバー表示時にウィンドウ位置がずれるため
set titlestring=Vim\ %{v:version/100}.%{v:version%100} " タイトルバーの表示文字列を指定 ※ファイル名はあちこち表示されてくどいので除去


" ------------------------------------------------------------------------------
" netrw の設定
" ------------------------------------------------------------------------------

let g:netrw_keepdir=0      " 作業ディレクトリをエクスプローラに追従
let g:netrw_winsize=80     " エクスプローラウィンドウのサイズを指定
let g:netrw_banner=0       " バナー非表示
let g:netrw_liststyle=3    " ツリー表示
let g:netrw_browse_split=1 " ファイルを水平分割で開く
let g:netrw_alto=1         " ファイルを水平分割で開く場合は下部に配置


" ------------------------------------------------------------------------------
" term の設定
" ------------------------------------------------------------------------------

set termwinsize=10x0 " ターミナルウィンドウのサイズを指定


" ------------------------------------------------------------------------------
" 挙動変更を伴う設定
" ------------------------------------------------------------------------------

" ----- 現在の画面でファイルを開く -----
" - Cmd-o: 新しい画面でファイルを開く
" - Ctrl-o: 現在の画面でファイルを開く
map <C-o> :browse tabnew<CR>
imap <C-o> <Esc> :browse tabnew<CR>
command! -nargs=0 Open browse tabnew

" ----- フォーカス移動 -----
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
