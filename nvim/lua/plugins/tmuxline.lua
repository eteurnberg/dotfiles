-- Stage 2 drops this plugin (nothing left to attach to once airline is
-- gone) but keeps .tmuxline_snapshot.conf itself as a static file --
-- .tmux.conf sources it independently of vim/airline at runtime.
return { 'edkolev/tmuxline.vim', lazy = false }
