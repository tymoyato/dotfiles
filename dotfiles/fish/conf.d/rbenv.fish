type -q rbenv || return

set -l rbenv_root (test -n "$RBENV_ROOT" && echo $RBENV_ROOT || echo $HOME/.rbenv)
set -gx RBENV_ROOT $rbenv_root
set -gxp PATH $rbenv_root/shims
set -gx RBENV_SHELL fish

# Create dirs only if missing (avoids mkdir fork on every startup)
test -d $rbenv_root/shims || command mkdir -p $rbenv_root/shims
test -d $rbenv_root/versions || command mkdir -p $rbenv_root/versions
