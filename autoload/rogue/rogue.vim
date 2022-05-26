let s:FILE_DIR = fnamemodify(expand('<sfile>'), ':h:h:h') .. '/lua/rogue/'
let s:FILE_DIR = substitute(s:FILE_DIR, '\\', '/', 'g')
function! rogue#rogue#main(args)
  let resume = 0
  if luaeval('type(Rogue)') ==# 'table' &&
        \ luaeval('tostring(Rogue.suspended)') ==# 'true'
    if a:args ==# '--resume'
      let resume = 1
    else
      let c = confirm(luaeval('require("rogue.mesg")[544]'),
            \ "&Yes\n&No\n&Cancel", 1)
      if c == 1
        let resume = 1
      elseif c == 2
        let resume = 0
      else
        echo luaeval('require("rogue.mesg")[12]')
        return
      endif
    endif
  endif
  if !resume
    for file in ['main', 'const', 'curses', 'debug', 'hit',
          \ 'init', 'invent', 'level', 'message', 'monster',
          \ 'move', 'object', 'pack', 'play', 'ring', 'room',
          \ 'save', 'score', 'spechit', 'throw', 'trap', 'use',
          \ 'util/init', 'zap']
      execute 'luafile' printf('%s/%s.lua', s:FILE_DIR, file)
    endfor
  endif

  silent edit `='Rogue-clone II'`
  silent only
  nohlsearch
  setlocal tabstop=8 expandtab
  setlocal nonumber norelativenumber
  setlocal buftype=nofile noswapfile bufhidden=wipe
  setlocal nowrap nolist
  setlocal nocursorline nocursorcolumn
  setlocal foldcolumn=0
  setlocal conceallevel=3 concealcursor=n
  setlocal filetype=rogue
  let s:save_encoding = &encoding
  if &encoding ==? 'utf-8'
    let s:needs_iconv = 0
  else
    let s:needs_iconv = 1
  endif

  let s:args = a:args
  doautocmd <nomodeline> User RoguePre
  execute 'lua Rogue.main()'
  doautocmd <nomodeline> User RoguePost

  let &encoding   = s:save_encoding
  bdelete
endfunction
