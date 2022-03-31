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


" ----- チートシート表示 -----
" 汎用コンテンツのバッファ表示
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
    \ '# Vim チートシート',
    \ '',
    \ '## ----------------- コマンドライン -----------------',
    \ ':q!⏎        閉じる',
    \ ':wq⏎        上書き保存して閉じる',
    \ ':w <path>⏎  名前を付けて保存 (`:w path/to/file.txt`)',
    \ ':w <path>⏎  名前を付けて保存 (`:w path/to/file.txt`)',
    \ ':e <path>⏎  ファイルを開く (`:e path/to/file.txt`)',
    \ ':se <opt>⏎  Vim オプションを適用 (`:se nowrap`)',
    \ ':h <cmd>⏎   Vim コマンドのヘルプを表示 (`:h :w`)',
    \ ':!<sh>⏎     シェルコマンドを実行 (`:!ls`)',
    \ ':r !<sh>⏎   シェルコマンドの実行結果を挿入 (`:r !ls`)',
    \ 'q:          Vim コマンドの実行履歴を表示',
    \ '',
    \ '## ---------------------- 検索 ----------------------',
    \ '/<word>⏎    指定の文字列を検索 (`/Hoge`)',
    \ '  n           次へ移動',
    \ '  N           前へ移動',
    \ 'f<char>     現在の行で、指定の文字を検索 (`fH`)',
    \ '  ;           次へ移動',
    \ '  ,           前へ移動',
    \ '',
    \ '## ------------------- スクロール -------------------',
    \ 'ctrl+u      半ページ上に移動',
    \ 'ctrl+d      半ページ下に移動',
    \ 'ctrl+b      １ページ上に移動',
    \ 'ctrl+f      １ページ下に移動',
    \ '',
    \ '## ---------------- <pos> 位置(移動) ----------------',
    \ 'gg          ファイルの先頭に移動',
    \ 'G           ファイルの末尾に移動',
    \ '<line>gg    指定の行番号に移動 (`10gg`)',
    \ '<line>⏎     指定の行数だけ下に移動 (`10⏎`)',
    \ '0           行頭に移動',
    \ '$           行末に移動',
    \ 'w           次の単語の先頭に移動',
    \ 'e           単語の末尾に移動',
    \ 'b           単語の先頭に移動',
    \ '%           対応する括弧に移動',
    \ '',
    \ '## ---------------- <pos> 位置(範囲) ----------------',
    \ 'iw          単語の範囲',
    \ 'i"          ダブルクォートで囲われた範囲',
    \ '',
    \ '## ------------------- <sel> 選択 -------------------',
    \ 'v           カーソル位置から選択開始',
    \ '  o           選択開始位置を移動開始',
    \ 'V           現在行から行選択開始',
    \ 'ctrl+v      カーソル位置から矩形選択開始',
    \ '  o           矩形入力開始',
    \ '',
    \ '## ---------------------- 入力 ----------------------',
    \ 'i           カーソル位置の直後から入力開始',
    \ 'a           カーソル位置の直前から入力開始',
    \ 'I           行頭から入力開始',
    \ 'A           行末から入力開始',
    \ 'c<pos>      指定の位置まで削除して入力開始 (`ciw`)',
    \ '  ctrl+w    直前の単語の開始位置まで削除',
    \ '',
    \ '## ---------------------- 編集 ----------------------',
    \ 'u           元に戻す',
    \ 'ctrl+r      やり直し',
    \ 'P           貼り付け (カーソル位置の左または上)',
    \ 'gU<pos>     指定の位置まで大文字に変換 (`gUiw`)',
    \ ':sort⏎      テキストを昇順に並び替え',
    \ '',
    \ '## --------------------- コピー ---------------------',
    \ 'y<pos>      指定の位置までコピー (`y10`)',
    \ '<sel>y      指定の選択範囲をコピー',
    \ 'yy          現在行をコピー',
    \ 'yiw         カーソル位置にある単語をコピー',
    \ '',
    \ '## --------------------- カット ---------------------',
    \ 'd<pos>      指定の位置までカット (`d$`)',
    \ '<sel>d      指定の選択範囲をカット',
    \ 'dd          現在行をカット',
    \ 'diw         カーソル位置にある単語をカット',
    \ '',
    \ '## ------------------- 応用(操作) -------------------',
    \ 'ggVG        全選択',
    \ 'gUiw        カーソル位置の単語を大文字に変換',
    \ 'cf<char>    検索文字の手前まで削除して入力開始',
    \ 'aHoge.      再実行',
    \ '            「"Hoge" の入力」をもう一度実行',
    \ '10iHoge     連続実行',
    \ '            「"Hoge" の入力」10回繰り返す',
    \ '',
    \ '## ----------------- 応用(コマンド) -----------------',
    \ ':%s/<old>/<new>/g  置換',
    \ '                   % 全行を走査, s 置換, g 全出現箇所を',
    \ ':%g/^$/normal dd   空行削除',
    \ '                   % 全行を走査, g Grep',
    \ ':!echo $((1+1))    簡易計算機',
    \ '                   シェル (:!) で計算し表示 (echo)',
    \ '',
    \ ]
  call ShowBuffer('VimCheatSheet', l:content, {'close_keys': ['<Space>', '<ESC>']})
endfunction

" チートシート表示コマンド
nnoremap <Space> :call ShowCheatSheet()<CR>
