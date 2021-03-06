if exists('g:loaded_rogue')
  finish
endif
let g:loaded_rogue = v:true

command! -nargs=* Rogue call rogue#rogue#main(<q-args>)
command! -nargs=0 RogueScores call rogue#rogue#main('-s')
command! -nargs=? RogueRestore call rogue#rogue#main(<q-args> == '' ? '-r' : <q-args>)
command! -nargs=0 RogueResume call rogue#rogue#main('--resume')
