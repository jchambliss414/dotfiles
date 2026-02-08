#=======================================  __
#                                           |
# ~~~~~~ STANDARDS & PRACTICES ~~~~~~       |}-->(section header style)
#_______________________________________  __|

#---------------------------------------   _
# Variables: patterns and logic            _}-->(subsection header style)
#---------------------------------------

# **_trig = variable for multiple triggers for the same action
# UPR_CASE = Directory | lwr_case = file

#_______________________________________

#=======================================
#
# ~~~~~~~~~ ENVIRONMENT ~~~~~~~~~
#_______________________________________

#---------------------------------------
# Paths
#---------------------------------------

# Shared tools (fzf, etc.)
export PATH="/shared/bin:$PATH"

# Shared bun installation
export BUN_INSTALL="/shared/bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Shared npm installation
export PATH="/shared/npm-global/bin:$PATH"

#---------------------------------------
# Directory Exports
#---------------------------------------

# export ZL="/home/zhuli"
# export AREAS="/shared/Areas"
# export PROJ="/shared/Projects"
# #--
# config_trig="ZL_CONFIG PAI_DIR"
# for dir in $config_trig; do
#   export $dir="$ZL/.pai/.claude"
# done
#
# export ZL_SKILLS="$ZL_CONFIG/skills"
# export ZL_CORE_DIR="$ZL_SKILLS/CORE"
# export zl_core="$ZL_CORE_DIR/SKILL.md"
# export ZL_DIR="/shared/Areas/ZhuLi"
#--

#--
export CONF="/shared/dotfiles/config"
export CONF_NV="$CONF/nvim"
export CONF_TM="$CONF/tmux"
#--
#=======================================
#
# ~~~~~~~~~ ALIASES ~~~~~~~~~
#_______________________________________

#---------------------------------------
# Housekeeping
#---------------------------------------

# Open bashrc file
alias edbash="nvim ~/.bashrc"

# Refresh .bashrc
rf_trig="rf refresh"
for cmd in $rf_trig; do
   alias $cmd="source ~/.bashrc"
done

# Open this doc
alias aliases="nvim /shared/dotfiles/bash_aliases"

#---------------------------------------
# Tool Shortcuts
#---------------------------------------

# fd-find → fd (Ubuntu packages it as fdfind)
alias fd='fdfind'

#---------------------------------------
# User Switching
#---------------------------------------

# Switch to zhuli user
alias u_z="sudo su - zhuli"

# Switch to zhuli, cd to ZhuLi dir, invoke claude
zl_trig="zl zhuli Zhuli ZhuLi"
for cmd in $zl_trig; do
   alias $cmd="_zl_invoke"
done

function _zl_invoke() {
   sudo -iu zhuli bash -lc "cd /shared/Areas/ZhuLi && exec bash"
}

#---------------------------------------
# NAVIGATION
#---------------------------------------

# Smart nvim launcher with config shortcuts
nv() {
   case "$1" in
   -)
      echo "nv shortcuts:"
      printf "  %-12s - %s\n" "nv" "open nvim"
      # Dynamically extract shortcuts from this function
      declare -f nv | grep -E '^\s+[a-z]+\)' | grep -v '^\s+-)' | grep -v '^\s+"")' | grep -v '^\s+\*)' | while read -r line; do
         shortcut=$(echo "$line" | sed 's/)//' | xargs)
         # Get the file path from the next line
         filepath=$(declare -f nv | grep -A1 "^[[:space:]]*${shortcut})" | tail -1 | grep -oP 'nvim \K.*' | xargs)
         if [ -n "$filepath" ]; then
            # Expand variables in filepath
            filepath=$(eval echo "$filepath")
            # Get parent dir + filename
            parent_and_file=$(echo "$filepath" | awk -F'/' '{print $(NF-1)"/"$NF}')
            printf "  %-12s - %s\n" "nv $shortcut" "open $parent_and_file"
         fi
      done
      ;;
   conf)
      nvim $CONF_NV/init.lua
      ;;
   rend)
      nvim $CONF_NV/lua/plugins/render-markdown.lua
      ;;
   vw)
      nvim $CONF_NV/lua/plugins/vimwiki.lua
      ;;
   key)
      nvim $CONF_NV/lua/config/keymaps.lua
      ;;
   tmux)
      nvim $CONF_TM/tmux.conf
      ;;
   "")
      nvim
      ;;
   *)
      nvim "$@"
      ;;
   esac
}

# Open vimwiki index
wiki_trig="wiki vw vimwiki"
for cmd in $wiki_trig; do
   alias $cmd="nvim -c 'VimwikiIndex'"
done

#=======================================
#
# ~~~~~~~~~~ Yazi Setup ~~~~~~~~~
#
#=======================================

export EDITOR="nvim"

function y() {
   local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
   yazi "$@" --cwd-file="$tmp"
   IFS= read -r -d '' cwd <"$tmp"
   [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
   rm -f -- "$tmp"
}

#=======================================
#
# ~~~~~~~~~ FUNCTIONS ~~~~~~~~~
#_______________________________________


#---------------------------------------
# Git Sync Helpers (Cross-Device Sync - base)
#---------------------------------------

# Auto-commit tracked repos on shell exit
# Changes are captured locally; push manually or let scheduled task handle it
# _git-sync_auto_commit() {
#     local repos=(
#         "/shared"
#         "/home/zhuli/.pai"
#     )
#
#     for repo in "${repos[@]}"; do
#         [ -d "$repo/.git" ] || continue
#         cd "$repo" || continue
#
#         if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
#             git add -A
#             git commit -m "auto: $(whoami)@$(hostname) $(date +%Y-%m-%d_%H:%M)" --quiet
#         fi
#     done
# }

# Register exit trap (only for interactive shells)
if [[ $- == *i* ]]; then
   trap _git-sync_auto_commit EXIT
fi

# Prompt indicator: show total unpushed commits across repos
# Returns " [↑N]" for unpushed commits, " [?]" for branches without upstream
_git-sync_unpushed() {
   local repos=(
      "/shared"
      "/shared/dotfiles"
   )
   local total=0
   local has_untracked=false

   for repo in "${repos[@]}"; do
      [ -d "$repo/.git" ] || continue
      local ahead
      # Check if upstream exists
      if (cd "$repo" && git rev-parse --abbrev-ref "@{u}" >/dev/null 2>&1); then
         ahead=$(cd "$repo" && git rev-list --count @{u}..HEAD 2>/dev/null) || ahead=0
         total=$((total + ahead))
      else
         has_untracked=true
      fi
   done

   # Build output
   local output=""
   [ "$total" -gt 0 ] && output=" [↑$total]"
   [ "$has_untracked" = true ] && output="${output} [?]"
   echo "$output"
}

# Modify PS1 to include sync status
# Adjust to match your actual prompt style
PS1='\u@\h:\w$(_git-sync_unpushed)\$ '

# Push all repos (handles branches without upstream)
git-sync_push() {
   for repo in /shared /shared/dotfiles; do
      [ -d "$repo/.git" ] || continue
      echo "__________________________________________________________________________"
      echo "=========== Pushing $repo ==========="
      echo "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
      (
         cd "$repo" || exit 1
         local branch
         branch=$(git symbolic-ref --short HEAD 2>/dev/null)

         # Check if upstream exists
         if git rev-parse --abbrev-ref "@{u}" >/dev/null 2>&1; then
            git push
         else
            echo "No upstream for '$branch' - setting up tracking..."
            git push -u origin "$branch"
         fi
      )
   done
}

# Pull all repos
git-sync_pull() {
   for repo in /shared /shared/dotfiles; do
      [ -d "$repo/.git" ] || continue
      echo "________________________________________________________________________________"
      echo "=========== Pulling $repo... ==========="
      echo "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
      (cd "$repo" && git pull --rebase)
   done
}

# Full sync (pull then push)
git-sync_sync() {
   git-sync_pull
   git-sync_push
}

# Merge current branch into main/master and push
# Usage: zhuli_merge [repo]  (if no repo specified, uses current directory)
git-sync_merge() {
   local target_repo="${1:-$(pwd)}"

   if [ ! -d "$target_repo/.git" ]; then
      echo "Error: $target_repo is not a git repository"
      return 1
   fi

   (
      cd "$target_repo" || exit 1

      local current_branch
      current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

      # Detect default branch (main or master)
      local default_branch
      if git show-ref --verify --quiet refs/heads/main; then
         default_branch="main"
      elif git show-ref --verify --quiet refs/heads/master; then
         default_branch="master"
      else
         echo "Error: No main or master branch found"
         return 1
      fi

      if [ "$current_branch" = "$default_branch" ]; then
         echo "Already on $default_branch - nothing to merge"
         return 0
      fi

      echo "=== Merging '$current_branch' into '$default_branch' in $target_repo ==="
      echo "________________________________________________________________________________________"
      echo "=========== Merging '$current_branch' into '$default_branch' in $target_repo ==========="
      echo "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"

      # Ensure working tree is clean
      if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
         echo "Uncommitted changes detected. Auto-committing..."
         git add -A
         git commit -m "auto: pre-merge commit $(date +%Y-%m-%d_%H:%M)"
      fi

      # Switch to default branch, pull, merge, push
      echo "Switching to $default_branch..."
      git checkout "$default_branch" || return 1

      echo "Pulling latest $default_branch..."
      git pull --rebase || return 1

      echo "Merging $current_branch..."
      git merge "$current_branch" --no-edit || return 1

      echo "Pushing $default_branch..."
      git push || return 1

      echo "✓ Merged and pushed. Still on $default_branch."
      echo "  Run 'git checkout $current_branch' to return, or 'git branch -d $current_branch' to delete."
   )
}

# Check status of all repos
git-sync_status() {
   for repo in /shared /shared/dotfiles; do
      [ -d "$repo/.git" ] || continue
      echo "_______________________________________"
      echo "=== $repo ==="
      echo "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
      (cd "$repo" && git status -sb)
      echo ""
   done
}

#---------------------------------------
# Git Sync Helpers (Cross-Device Sync)
#---------------------------------------

# Auto-commit tracked repos on shell exit
# Changes are captured locally; push manually or let scheduled task handle it
# _zhuli_auto_commit() {
#     local repos=(
#         "/shared"
#         "/home/zhuli/.pai"
#     )
#
#     for repo in "${repos[@]}"; do
#         [ -d "$repo/.git" ] || continue
#         cd "$repo" || continue
#
#         if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
#             git add -A
#             git commit -m "auto: $(whoami)@$(hostname) $(date +%Y-%m-%d_%H:%M)" --quiet
#         fi
#     done
# }

# # Register exit trap (only for interactive shells)
# if [[ $- == *i* ]]; then
#    trap _zhuli_auto_commit EXIT
# fi
#
# # Prompt indicator: show total unpushed commits across repos
# # Returns " [↑N]" for unpushed commits, " [?]" for branches without upstream
# _zhuli_unpushed() {
#    local repos=(
#       "/shared"
#       "/home/zhuli/.pai"
#    )
#    local total=0
#    local has_untracked=false
#
#    for repo in "${repos[@]}"; do
#       [ -d "$repo/.git" ] || continue
#       local ahead
#       # Check if upstream exists
#       if (cd "$repo" && git rev-parse --abbrev-ref "@{u}" >/dev/null 2>&1); then
#          ahead=$(cd "$repo" && git rev-list --count @{u}..HEAD 2>/dev/null) || ahead=0
#          total=$((total + ahead))
#       else
#          has_untracked=true
#       fi
#    done
#
#    # Build output
#    local output=""
#    [ "$total" -gt 0 ] && output=" [↑$total]"
#    [ "$has_untracked" = true ] && output="${output} [?]"
#    echo "$output"
# }
#
# # Modify PS1 to include sync status
# # Adjust to match your actual prompt style
# PS1='\u@\h:\w$(_zhuli_unpushed)\$ '
#
# # Push all repos (handles branches without upstream)
# zhuli_push() {
#    for repo in /shared /home/zhuli/.pai; do
#       [ -d "$repo/.git" ] || continue
#       echo "__________________________________________________________________________"
#       echo "=========== Pushing $repo ==========="
#       echo "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
#       (
#          cd "$repo" || exit 1
#          local branch
#          branch=$(git symbolic-ref --short HEAD 2>/dev/null)
#
#          # Check if upstream exists
#          if git rev-parse --abbrev-ref "@{u}" >/dev/null 2>&1; then
#             git push
#          else
#             echo "No upstream for '$branch' - setting up tracking..."
#             git push -u origin "$branch"
#          fi
#       )
#    done
# }
#
# # Pull all repos
# zhuli_pull() {
#    for repo in /shared /home/zhuli/.pai; do
#       [ -d "$repo/.git" ] || continue
#       echo "________________________________________________________________________________"
#       echo "=========== Pulling $repo... ==========="
#       echo "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
#       (cd "$repo" && git pull --rebase)
#    done
# }
#
# # Full sync (pull then push)
# zhuli_sync() {
#    zhuli_pull
#    zhuli_push
# }
#
# # Merge current branch into main/master and push
# # Usage: zhuli_merge [repo]  (if no repo specified, uses current directory)
# zhuli_merge() {
#    local target_repo="${1:-$(pwd)}"
#
#    if [ ! -d "$target_repo/.git" ]; then
#       echo "Error: $target_repo is not a git repository"
#       return 1
#    fi
#
#    (
#       cd "$target_repo" || exit 1
#
#       local current_branch
#       current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
#
#       # Detect default branch (main or master)
#       local default_branch
#       if git show-ref --verify --quiet refs/heads/main; then
#          default_branch="main"
#       elif git show-ref --verify --quiet refs/heads/master; then
#          default_branch="master"
#       else
#          echo "Error: No main or master branch found"
#          return 1
#       fi
#
#       if [ "$current_branch" = "$default_branch" ]; then
#          echo "Already on $default_branch - nothing to merge"
#          return 0
#       fi
#
#       echo "=== Merging '$current_branch' into '$default_branch' in $target_repo ==="
#       echo "________________________________________________________________________________________"
#       echo "=========== Merging '$current_branch' into '$default_branch' in $target_repo ==========="
#       echo "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
#
#       # Ensure working tree is clean
#       if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
#          echo "Uncommitted changes detected. Auto-committing..."
#          git add -A
#          git commit -m "auto: pre-merge commit $(date +%Y-%m-%d_%H:%M)"
#       fi
#
#       # Switch to default branch, pull, merge, push
#       echo "Switching to $default_branch..."
#       git checkout "$default_branch" || return 1
#
#       echo "Pulling latest $default_branch..."
#       git pull --rebase || return 1
#
#       echo "Merging $current_branch..."
#       git merge "$current_branch" --no-edit || return 1
#
#       echo "Pushing $default_branch..."
#       git push || return 1
#
#       echo "✓ Merged and pushed. Still on $default_branch."
#       echo "  Run 'git checkout $current_branch' to return, or 'git branch -d $current_branch' to delete."
#    )
# }
#
# # Check status of all repos
# zhuli_status() {
#    for repo in /shared /home/zhuli/.pai; do
#       [ -d "$repo/.git" ] || continue
#       echo "_______________________________________"
#       echo "=== $repo ==="
#       echo "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
#       (cd "$repo" && git status -sb)
#       echo ""
#    done
# }

#---------------------------------------
# WSL Management
#---------------------------------------

# Clean exit + WSL shutdown
# Use instead of 'exit' when you're done with WSL for the day
bye() {
   echo "Shutting down WSL..."
   # Let the auto-commit trap run first (inherited from EXIT trap above)
   # Then trigger Windows-side WSL shutdown
   wsl.exe --shutdown
   # This shell will terminate as WSL shuts down
}

#---------------------------------------
# Package Management Guards
#---------------------------------------

# Force explicit choice for global installs
# Usage: install-shared [npm|bun] <package>
#        install-user [npm|bun] <package>

install-shared() {
   if [ -z "$1" ] || [ -z "$2" ]; then
      echo "Usage: install-shared [npm|bun] <package>"
      echo "  Installs to /shared/ (accessible to all users)"
      return 1
   fi

   case "$1" in
   npm)
      shift
      echo "Installing to /shared/npm-global/..."
      command npm install -g --prefix /shared/npm-global "$@"
      ;;
   bun)
      shift
      echo "Installing to /shared/bun/..."
      /shared/bun/bin/bun install -g "$@"
      ;;
   *)
      echo "Unknown package manager: $1"
      echo "Supported: npm, bun"
      return 1
      ;;
   esac
}

install-user() {
   if [ -z "$1" ] || [ -z "$2" ]; then
      echo "Usage: install-user [npm|bun] <package>"
      echo "  Installs to ~/. (current user only)"
      return 1
   fi

   case "$1" in
   npm)
      shift
      echo "Installing to $HOME/.npm-global/..."
      mkdir -p "$HOME/.npm-global"
      command npm install -g --prefix "$HOME/.npm-global" "$@"
      echo "Ensure $HOME/.npm-global/bin is in your PATH"
      ;;
   bun)
      shift
      echo "Installing to $HOME/.bun/..."
      BUN_INSTALL="$HOME/.bun" bun install -g "$@"
      echo "Ensure $HOME/.bun/bin is in your PATH"
      ;;
   *)
      echo "Unknown package manager: $1"
      echo "Supported: npm, bun"
      return 1
      ;;
   esac
}

#---------------------------------------
# Package Manager Wrappers
#---------------------------------------

# Intercept raw global installs with a warning
npm() {
   if [[ "$1" == "install" && "$*" == *"-g"* ]]; then
      echo "Direct global npm install blocked."
      echo ""
      echo "Use explicit install commands:"
      echo "  install-shared npm <package>  -> /shared/npm-global/ (all users)"
      echo "  install-user npm <package>    -> ~/.npm-global/ (current user only)"
      return 1
   else
      command npm "$@"
   fi
}

bun() {
   if [[ "$1" == "install" && "$*" == *"-g"* ]] || [[ "$1" == "add" && "$*" == *"-g"* ]]; then
      echo "Direct global bun install blocked."
      echo ""
      echo "Use explicit install commands:"
      echo "  install-shared bun <package>  -> /shared/bun/ (all users)"
      echo "  install-user bun <package>    -> ~/.bun/ (current user only)"
      return 1
   else
      command bun "$@"
   fi
}

#=======================================
#
# ~~~~~~~~~ INVOCATIONS ~~~~~~~~~
#_______________________________________

eval "$(zoxide init bash)"

#-----------------------------
# OBSERVABILITY DASHBOARD
#------------------------------

alias obsv-start="/home/zhuli/.claude/skills/Observability/manage.sh start"
alias obsv-stop="/home/zhuli/.claude/skills/Observability/manage.sh stop"
alias obsv-status="/home/zhuli/.claude/skills/Observability/manage.sh status"
alias obsv-restart="/home/zhuli/.claude/skills/Observability/manage.sh restart"

#-----------------------------
# Anansi TUI
#------------------------------

# Dashboard view (default)
anansi_trig="an ansi anansi Anansi"
for aTrig in $anansi_trig; do
   alias $aTrig="/home/zhuli/.pai/anansi/scripts/anansi-tui"
done

# Browser view (hierarchical tree)
alias ansi-browse="/home/zhuli/.pai/anansi/scripts/anansi-tui --view=browser"
# Daily review
alias ansi-review="/home/zhuli/.pai/anansi/scripts/anansi-tui --view=review"
# In tmux popup
alias ansi-pop="/home/zhuli/.pai/anansi/scripts/anansi-popup"
