#!/usr/bin/env bats

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
  unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME
  unset NVM_DIR
}

@test "help prints usage" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"install"* ]]
}

@test "version reads VERSION file" {
  run ./bin/nvim-config --version
  [ "$status" -eq 0 ]
  [ "$output" = "$(cat VERSION)" ]
}

@test "install dry-run prints planned commands" {
  run ./bin/nvim-config --dry-run install
  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo apt update"* ]]
  [[ "$output" == *"sudo apt install -y git make gcc curl ripgrep fd-find xsel xclip wl-clipboard lolcat"* ]]
}

@test "install deps dry-run installs apt packages" {
  run ./bin/nvim-config --dry-run install deps
  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo apt update"* ]]
}

@test "install deps includes gnupg (required to verify the mise installer)" {
  run ./bin/nvim-config --dry-run install deps
  [ "$status" -eq 0 ]
  [[ "$output" == *"gnupg"* ]]
}

@test "install deps includes git (mandatory prerequisite for lazy.nvim bootstrap)" {
  run ./bin/nvim-config --dry-run install deps
  [ "$status" -eq 0 ]
  [[ "$output" == *"git"* ]]
}

@test "install deps includes make (required to build telescope-fzf-native.nvim)" {
  run ./bin/nvim-config --dry-run install deps
  [ "$status" -eq 0 ]
  [[ "$output" == *"make"* ]]
}

@test "install deps includes gcc (make alone is not enough — telescope-fzf-native.nvim's Makefile calls cc)" {
  run ./bin/nvim-config --dry-run install deps
  [ "$status" -eq 0 ]
  [[ "$output" == *"gcc"* ]]
}

@test "install deps includes wl-clipboard (Wayland) alongside xsel/xclip (X11) — Neovim picks the right one at runtime" {
  run ./bin/nvim-config --dry-run install deps
  [ "$status" -eq 0 ]
  [[ "$output" == *"wl-clipboard"* ]]
  [[ "$output" == *"xsel"* ]]
  [[ "$output" == *"xclip"* ]]
}

@test "doctor lists gcc as a required binary, not merely optional (telescope-fzf-native.nvim needs it by default)" {
  run grep -n "for bin in git make gcc rg fdfind node npm" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install config dry-run prints symlink command" {
  run ./bin/nvim-config --dry-run install config
  [ "$status" -eq 0 ]
  [[ "$output" == *"ln -s"* ]]
}

@test "install config links existing symlink without error" {
  local nvim_config_dir="${HOME}/.config/nvim"
  local project_dir
  project_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  mkdir -p "${HOME}/.config"
  ln -s "${project_dir}" "${nvim_config_dir}"
  run ./bin/nvim-config install config
  [ "$status" -eq 0 ]
  [[ "$output" == *"already linked"* ]]
}

@test "install config aborts if target exists and is not a symlink" {
  mkdir -p "${HOME}/.config/nvim"
  run ./bin/nvim-config install config
  [ "$status" -eq 1 ]
}

@test "log_message prints ERROR exactly once, not duplicated on stdout and stderr" {
  mkdir -p "${HOME}/.config/nvim"
  run ./bin/nvim-config install config
  [ "$status" -eq 1 ]
  local count
  count=$(printf '%s\n' "$output" | grep -c "exists and is not a symlink")
  [ "$count" -eq 1 ]
}

@test "completion includes install subcommands" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"deps"* ]]
  [[ "$output" == *"config"* ]]
  [[ "$output" == *"all"* ]]
}

@test "show-completion bash prints completion script" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"_nvim_config_completions"* ]]
  [[ "$output" == *"install"* ]]
}

@test "install-completion bash writes completion file for current shell" {
  export SHELL="/usr/bin/bash"
  run ./bin/nvim-config --install-completion bash
  [ "$status" -eq 0 ]
  [ -f "$HOME/.local/share/bash-completion/completions/nvim-config" ]
}

@test "install nvim dry-run exits successfully" {
  run ./bin/nvim-config --dry-run install nvim
  [ "$status" -eq 0 ]
}

@test "install nvim script uses snap install nvim --classic" {
  run grep -n "snap install nvim" bin/nvim-config
  [ "$status" -eq 0 ]
  [[ "$output" == *"classic"* ]]
}

@test "install nvim script supports --apt flag with apt install neovim" {
  run grep -n "apt install -y neovim" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "apt install commands run non-interactively (-y) since the user already confirmed" {
  run grep -c -- "apt install -y" bin/nvim-config
  [ "$status" -eq 0 ]
  [ "$output" -ge 4 ]
}

@test "run_install_mise resets its EXIT/INT/TERM trap before returning (no stale tmp_dir reference)" {
  run grep -n "trap - EXIT INT TERM" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "update plugins dry-run mentions Lazy sync" {
  run ./bin/nvim-config --dry-run update plugins
  [ "$status" -eq 0 ]
  [[ "$output" == *"Lazy"* ]]
}

@test "update nvim dry-run prints a refresh or upgrade command" {
  run ./bin/nvim-config --dry-run update nvim
  [ "$status" -eq 0 ]
  # snap path: "snap refresh nvim"; apt path: "apt install ... neovim"
  [[ "$output" == *"nvim"* ]] || [[ "$output" == *"neovim"* ]]
}

@test "update dry-run runs both nvim and plugins" {
  run ./bin/nvim-config --dry-run update
  [ "$status" -eq 0 ]
  [[ "$output" == *"nvim"* ]]
  [[ "$output" == *"Lazy"* ]]
}

@test "help documents install nvim subcommand" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"install nvim"* ]] || [[ "$output" == *"nvim"* ]]
}

@test "help documents update command" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"update"* ]]
}

@test "completion includes nvim after install" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"nvim"* ]]
}

@test "completion includes update command" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"update"* ]]
}

@test "install tmux dry-run prints source-file injection" {
  run ./bin/nvim-config --dry-run install tmux
  [ "$status" -eq 0 ]
  [[ "$output" == *"source-file"* ]]
}

@test "install tmux skips if source-file already present" {
  local project_dir
  project_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  mkdir -p "${HOME}"
  printf '\nsource-file %s/.tmux.conf\n' "${project_dir}" > "${HOME}/.tmux.conf"
  run ./bin/nvim-config install tmux
  [ "$status" -eq 0 ]
  [[ "$output" == *"already sources"* ]]
}

@test "help documents install tmux subcommand" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"tmux"* ]]
}

@test "completion includes tmux after install" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"tmux"* ]]
}

@test "show-completion zsh prints zsh completion script" {
  run ./bin/nvim-config --show-completion zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"#compdef"* ]]
  [[ "$output" == *"nvim-config"* ]]
}

@test "zsh completion script covers install subcommands" {
  run ./bin/nvim-config --show-completion zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"deps"* ]]
  [[ "$output" == *"config"* ]]
  [[ "$output" == *"tmux"* ]]
  [[ "$output" == *"--with-node"* ]]
}

@test "install-completion zsh writes completion file" {
  export SHELL="/usr/bin/zsh"
  run ./bin/nvim-config --install-completion zsh
  [ "$status" -eq 0 ]
  [ -f "$HOME/.local/share/zsh/completions/_nvim-config" ]
}

@test "help documents zsh in completion options" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"zsh"* ]]
}

@test "install deps dry-run does not mention nvm or node by default" {
  run ./bin/nvim-config --dry-run install deps
  [ "$status" -eq 0 ]
  [[ "$output" != *"nvm"* ]]
  [[ "$output" != *"node"* ]]
}

@test "install deps --with-node dry-run mentions nvm install" {
  run ./bin/nvim-config --dry-run install deps --with-node
  [ "$status" -eq 0 ]
  [[ "$output" == *"nvm"* ]]
}

@test "install all --with-node dry-run mentions nvm install" {
  run ./bin/nvim-config --dry-run install all --with-node
  [ "$status" -eq 0 ]
  [[ "$output" == *"nvm"* ]]
}

@test "help documents --with-node option" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--with-node"* ]]
}

@test "help documents ui command" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"ui"* ]]
}

@test "ui set classic dry-run mentions .nvim-ui file" {
  run ./bin/nvim-config --dry-run ui set classic
  [ "$status" -eq 0 ]
  [[ "$output" == *".nvim-ui"* ]]
}

@test "ui set modern dry-run mentions .nvim-ui file" {
  run ./bin/nvim-config --dry-run ui set modern
  [ "$status" -eq 0 ]
  [[ "$output" == *".nvim-ui"* ]]
}

@test "ui unset dry-run mentions .nvim-ui file" {
  run ./bin/nvim-config --dry-run ui unset
  [ "$status" -eq 0 ]
  [[ "$output" == *".nvim-ui"* ]]
}

@test "completion includes ui command" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"ui"* ]]
}

@test "zsh completion covers ui subcommands" {
  run ./bin/nvim-config --show-completion zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"ui"* ]]
  [[ "$output" == *"set"* ]]
  [[ "$output" == *"unset"* ]]
}

# ---------------------------------------------------------------------------
# Phase 12 — theme CLI subcommand
# ---------------------------------------------------------------------------

@test "help documents theme command" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"theme"* ]]
}

@test "theme set dry-run mentions .nvim-theme file" {
  run ./bin/nvim-config --dry-run theme set nightfox
  [ "$status" -eq 0 ]
  [[ "$output" == *".nvim-theme"* ]]
}

@test "theme unset dry-run mentions .nvim-theme file" {
  run ./bin/nvim-config --dry-run theme unset
  [ "$status" -eq 0 ]
  [[ "$output" == *".nvim-theme"* ]]
}

@test "theme set writes .nvim-theme with given name" {
  local config_dir
  config_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  run ./bin/nvim-config theme set nightfox
  [ "$status" -eq 0 ]
  [ -f "${config_dir}/.nvim-theme" ]
  run cat "${config_dir}/.nvim-theme"
  [[ "$output" == *"nightfox"* ]]
  rm -f "${config_dir}/.nvim-theme"
}

@test "theme unset removes .nvim-theme file" {
  local config_dir
  config_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  echo "nightfox" > "${config_dir}/.nvim-theme"
  run ./bin/nvim-config theme unset
  [ "$status" -eq 0 ]
  [ ! -f "${config_dir}/.nvim-theme" ]
}

@test "completion includes theme command" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"theme"* ]]
}

@test "zsh completion covers theme subcommands" {
  run ./bin/nvim-config --show-completion zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"theme"* ]]
  [[ "$output" == *"set"* ]]
  [[ "$output" == *"unset"* ]]
}

# ---------------------------------------------------------------------------
# Phase 7 — fish completion
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Phase 13 — install claude and codex CLI
# ---------------------------------------------------------------------------

@test "help documents install claude subcommand" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"claude"* ]]
}

@test "help documents install codex subcommand" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"codex"* ]]
}

@test "install claude script uses npm install @anthropic-ai/claude-code" {
  run grep -n "@anthropic-ai/claude-code" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install codex script uses npm install @openai/codex" {
  run grep -n "@openai/codex" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "bash completion includes claude and codex after install" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"claude"* ]]
  [[ "$output" == *"codex"* ]]
}

@test "zsh completion includes claude and codex after install" {
  run ./bin/nvim-config --show-completion zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"claude"* ]]
  [[ "$output" == *"codex"* ]]
}

@test "fish completion includes claude and codex after install" {
  run ./bin/nvim-config --show-completion fish
  [ "$status" -eq 0 ]
  [[ "$output" == *"claude"* ]]
  [[ "$output" == *"codex"* ]]
}

@test "show-completion fish prints fish completion script" {
  run ./bin/nvim-config --show-completion fish
  [ "$status" -eq 0 ]
  [[ "$output" == *"complete -c nvim-config"* ]]
}

@test "fish completion covers all top-level commands" {
  run ./bin/nvim-config --show-completion fish
  [ "$status" -eq 0 ]
  [[ "$output" == *"install"* ]]
  [[ "$output" == *"update"* ]]
  [[ "$output" == *"profile"* ]]
  [[ "$output" == *"ui"* ]]
  [[ "$output" == *"theme"* ]]
}

@test "fish completion covers install subcommands" {
  run ./bin/nvim-config --show-completion fish
  [ "$status" -eq 0 ]
  [[ "$output" == *"deps"* ]]
  [[ "$output" == *"config"* ]]
  [[ "$output" == *"tmux"* ]]
  [[ "$output" == *"nvim"* ]]
}

@test "fish completion covers ui set classic and modern" {
  run ./bin/nvim-config --show-completion fish
  [ "$status" -eq 0 ]
  [[ "$output" == *"classic"* ]]
  [[ "$output" == *"modern"* ]]
}

@test "fish completion covers theme set and unset" {
  run ./bin/nvim-config --show-completion fish
  [ "$status" -eq 0 ]
  [[ "$output" == *"set"* ]]
  [[ "$output" == *"unset"* ]]
}

@test "install-completion fish writes completion file" {
  export SHELL="/usr/bin/fish"
  mkdir -p "${HOME}/.config/fish/completions"
  run ./bin/nvim-config --install-completion fish
  [ "$status" -eq 0 ]
  [ -f "${HOME}/.config/fish/completions/nvim-config.fish" ]
}

@test "help documents fish in completion options" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"fish"* ]]
}

# ---------------------------------------------------------------------------
# Phase 13 — install gemini
# ---------------------------------------------------------------------------

@test "install gemini subcommand is documented in usage" {
  run grep -n "gemini" bin/nvim-config
  [ "$status" -eq 0 ]
  [[ "$output" == *"gemini"* ]]
}

@test "install gemini function checks for npm" {
  run grep -n "run_install_gemini" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install gemini uses @google/gemini-cli package" {
  run grep -n "@google/gemini-cli" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "bash completion includes gemini subcommand" {
  run grep -n "gemini" bin/nvim-config
  [ "$status" -eq 0 ]
  [[ "$output" == *"gemini"* ]]
}

# ---------------------------------------------------------------------------
# Phase 14 — CLI enhancements
# ---------------------------------------------------------------------------

@test "help documents status command" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"status"* ]]
}

@test "help documents doctor command" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"doctor"* ]]
}

@test "help documents keymaps command" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"keymaps"* ]]
}

@test "help documents theme info and list subcommands" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"info"* ]]
  [[ "$output" == *"list"* ]]
}

@test "help documents profile info subcommand" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"profile"* ]]
  [[ "$output" == *"info"* ]]
}

@test "help documents update dap-adapters subcommand" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"dap-adapters"* ]]
}

@test "status command exits successfully" {
  run ./bin/nvim-config status
  [ "$status" -eq 0 ]
}

@test "status command shows Neovim version or not installed" {
  run ./bin/nvim-config status
  [ "$status" -eq 0 ]
  [[ "$output" == *"Neovim"* ]] || [[ "$output" == *"nvim"* ]]
}

@test "status command shows UI variant" {
  run ./bin/nvim-config status
  [ "$status" -eq 0 ]
  [[ "$output" == *"UI"* ]]
}

@test "status command shows theme" {
  run ./bin/nvim-config status
  [ "$status" -eq 0 ]
  [[ "$output" == *"Theme"* ]]
}

@test "status command shows profile" {
  run ./bin/nvim-config status
  [ "$status" -eq 0 ]
  [[ "$output" == *"Profile"* ]]
}

@test "theme info command shows active theme" {
  run ./bin/nvim-config theme info
  [ "$status" -eq 0 ]
  [[ "$output" == *"theme"* ]] || [[ "$output" == *"Theme"* ]]
}

@test "theme list command lists available themes" {
  run ./bin/nvim-config theme list
  [ "$status" -eq 0 ]
  [[ "$output" == *"nightfox"* ]]
  [[ "$output" == *"catppuccin"* ]]
  [[ "$output" == *"tokyonight"* ]]
}

@test "theme list marks the active theme with asterisk" {
  local config_dir
  config_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  printf 'nightfox\n' > "${config_dir}/.nvim-theme"
  run ./bin/nvim-config theme list
  rm -f "${config_dir}/.nvim-theme"
  [ "$status" -eq 0 ]
  [[ "$output" == *"* nightfox"* ]]
}

@test "ui info command shows active ui variant" {
  run ./bin/nvim-config ui info
  [ "$status" -eq 0 ]
  [[ "$output" == *"classic"* ]] || [[ "$output" == *"modern"* ]]
}

@test "profile list marks active profile with asterisk when profile file exists" {
  local tmpdir; tmpdir="$BATS_TEST_TMPDIR/proj"
  mkdir -p "${tmpdir}"
  printf 'web\n' > "${tmpdir}/.nvim-profile"
  cd "${tmpdir}"
  run "$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/bin/nvim-config" profile list
  [ "$status" -eq 0 ]
  [[ "$output" == *"* web"* ]]
}

@test "profile info shows no active profile when no .nvim-profile file" {
  run ./bin/nvim-config profile info
  [ "$status" -eq 0 ]
  [[ "$output" == *"none"* ]] || [[ "$output" == *"(none)"* ]]
}

@test "update dap-adapters dry-run with no profile reports nothing to update" {
  run ./bin/nvim-config --dry-run update dap-adapters
  [ "$status" -eq 0 ]
}

@test "bash completion includes status command" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"status"* ]]
}

@test "bash completion includes doctor command" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"doctor"* ]]
}

@test "bash completion includes keymaps command" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"keymaps"* ]]
}

@test "bash completion includes dap-adapters in update subcommands" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"dap-adapters"* ]]
}

@test "zsh completion includes status doctor keymaps" {
  run ./bin/nvim-config --show-completion zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"status"* ]]
  [[ "$output" == *"doctor"* ]]
  [[ "$output" == *"keymaps"* ]]
}

@test "zsh completion includes dap-adapters for update" {
  run ./bin/nvim-config --show-completion zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"dap-adapters"* ]]
}

@test "fish completion includes status doctor keymaps" {
  run ./bin/nvim-config --show-completion fish
  [ "$status" -eq 0 ]
  [[ "$output" == *"status"* ]]
  [[ "$output" == *"doctor"* ]]
  [[ "$output" == *"keymaps"* ]]
}

@test "fish completion includes dap-adapters for update" {
  run ./bin/nvim-config --show-completion fish
  [ "$status" -eq 0 ]
  [[ "$output" == *"dap-adapters"* ]]
}

# Phase 17 — mise integration

@test "help documents install mise subcommand" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"mise"* ]]
}

@test "help documents --mise flag" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--mise"* ]]
}

@test "install mise dry-run exits successfully" {
  run ./bin/nvim-config --dry-run install mise
  [ "$status" -eq 0 ]
}

@test "install mise reports all missing prerequisites (curl and gnupg) together" {
  run grep -n "_mise_missing_deps" bin/nvim-config
  [ "$status" -eq 0 ]
  run grep -n "mise install requires" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install mise script imports the official mise release GPG key" {
  run grep -n "24853EC9F655CE80B48E6C3A8B81C9D17413A06D" bin/nvim-config
  [ "$status" -eq 0 ]
  run grep -n "recv-keys" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install mise script downloads the GPG-signed installer from mise.jdx.dev" {
  run grep -n "https://mise.jdx.dev/install.sh.sig" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install mise skips when mise is already installed" {
  local fake_bin="$BATS_TEST_TMPDIR/fake_bin"
  mkdir -p "$fake_bin"
  cat > "$fake_bin/mise" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$fake_bin/mise"

  PATH="$fake_bin:$PATH" run ./bin/nvim-config install mise
  [ "$status" -eq 0 ]
  [[ "$output" == *"already installed"* ]]
}

@test "install nvim auto mode checks for mise before falling back" {
  run grep -n "command -v mise" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install nvim auto mode prompts to install mise when absent" {
  run grep -n "_confirm" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install nvim auto mode prompts to install snapd when snap is absent" {
  run grep -n "Install snapd now" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "confirm prompt declines automatically outside a TTY (never hangs in CI)" {
  run grep -n -- '-t 0' bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "confirm prompt declines automatically under --dry-run" {
  run grep -n 'DRY_RUN.*-eq 1.*QUIET\|_confirm()' bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install nvim explicit --apt flag requires the apt command" {
  run grep -n "apt is required" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install nvim dry-run with --snap flag exits successfully" {
  run ./bin/nvim-config --dry-run install nvim --snap
  [ "$status" -eq 0 ]
}

@test "install nvim dry-run with --apt flag exits successfully" {
  run ./bin/nvim-config --dry-run install nvim --apt
  [ "$status" -eq 0 ]
}

@test "install nvim auto mode falls back to snap/apt when mise install fails" {
  run grep -n "falling back to snap/apt" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install nvim auto mode falls back to apt when snapd install fails" {
  run grep -n "falling back to apt" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install all continues with deps and config even if the nvim step fails" {
  run grep -n "run_install_nvim ||" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install all also fetches the tree-sitter CLI (needed by nvim-treesitter to build parsers on first launch)" {
  run grep -n "run_update_tree_sitter" bin/nvim-config
  [ "$status" -eq 0 ]
  # must appear inside run_install's all) case, not just the update command
  # (def + update's tree-sitter case + update's all case = 3 already; a 4th
  # occurrence means install's all) case also calls it)
  run grep -c "run_update_tree_sitter" bin/nvim-config
  [ "$status" -eq 0 ]
  [ "$output" -ge 4 ]
}

@test "install --dry-run all fetches tree-sitter" {
  run ./bin/nvim-config --dry-run install all
  [ "$status" -eq 0 ]
  [[ "$output" == *"tree-sitter"* ]]
}

@test "install nvim auto mode offers to install missing mise prerequisites via apt in the same prompt" {
  run grep -n -- "+ mise now" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install nvim auto mode reuses the mise prerequisite check (no duplicated logic)" {
  run grep -c "_mise_missing_deps" bin/nvim-config
  [ "$status" -eq 0 ]
  [ "$output" -ge 3 ]
}

@test "install nvim --mise auto-installs mise instead of erroring when absent" {
  run grep -n "installing it now (--mise was explicitly requested)" bin/nvim-config
  [ "$status" -eq 0 ]
  run grep -n "run_install_mise" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install nvim --snap auto-installs snapd instead of erroring when absent" {
  run grep -n "installing snapd now (--snap was explicitly requested)" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install mise offers to add shell activation after a successful install" {
  run grep -n "_offer_mise_activation" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "mise activation covers bash, zsh, and fish" {
  run grep -n "activate bash" bin/nvim-config
  [ "$status" -eq 0 ]
  run grep -n "activate zsh" bin/nvim-config
  [ "$status" -eq 0 ]
  run grep -n "activate fish" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "mise activation line uses the absolute mise binary path, not bare 'mise' (avoids the chicken-and-egg PATH problem: bash needs to find mise to run 'mise activate', but mise isn't on PATH until activation runs)" {
  run grep -n "_mise_activate_line" bin/nvim-config
  [ "$status" -eq 0 ]
  run grep -n 'mise_bin' bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "mise activation also ensures ~/.local/bin is exported to PATH in the rc file, not just the activate eval" {
  run grep -n 'export PATH=.*\.local/bin' bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "the PATH guard line written to the rc file is itself idempotent (checks PATH before exporting, so re-sourcing the rc file never duplicates it)" {
  run grep -n '_mise_path_guard_line' bin/nvim-config
  [ "$status" -eq 0 ]
  run grep -n 'case ":\$PATH:" in' bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "the PATH guard for fish uses fish_add_path (built-in, deduplicates automatically)" {
  run grep -n "fish_add_path" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "mise activation check is idempotent (skips if already present in rc file)" {
  run grep -n "mise activate" bin/nvim-config
  [ "$status" -eq 0 ]
  run grep -n -- "grep -qF" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "help documents --activate and --no-activate flags" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--activate"* ]]
  [[ "$output" == *"--no-activate"* ]]
}

@test "--activate and --no-activate flags are parsed into a tri-state mode" {
  run grep -n -- "--activate)" bin/nvim-config
  [ "$status" -eq 0 ]
  run grep -n -- "--no-activate)" bin/nvim-config
  [ "$status" -eq 0 ]
  run grep -n "ACTIVATE_MODE" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "--activate skips the confirm prompt and adds the line unattended" {
  run grep -n 'ACTIVATE_MODE.*=.*yes\|"yes")' bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install mise dry-run with --no-activate exits successfully" {
  run ./bin/nvim-config --dry-run --no-activate install mise
  [ "$status" -eq 0 ]
}

@test "install mise dry-run with --activate exits successfully" {
  run ./bin/nvim-config --dry-run --activate install mise
  [ "$status" -eq 0 ]
}

@test "install nvim --mise stops immediately if the mise install fails (errexit is suppressed inside install all's || guard, so this must be explicit)" {
  run grep -n "run_install_mise || return 1" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install nvim --snap stops immediately if snapd install fails" {
  run grep -n "apt install -y snapd || return 1" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install nvim --mise auto-installs missing prerequisites (curl/gnupg) without an extra prompt" {
  run grep -c "_mise_missing_deps" bin/nvim-config
  [ "$status" -eq 0 ]
  [ "$output" -ge 4 ]
}

@test "update nvim prefers mise when nvim was installed via mise" {
  run grep -n "mise which nvim" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install/update nvim via mise uses mise use -g neovim@latest" {
  run grep -n "mise use -g neovim@latest" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install nvim dry-run with --mise flag exits successfully" {
  run ./bin/nvim-config --dry-run install nvim --mise
  [ "$status" -eq 0 ]
}

@test "doctor lists mise as an optional tool" {
  run ./bin/nvim-config doctor
  [[ "$output" == *"mise"* ]]
}

@test "bash completion includes mise after install" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"mise"* ]]
}

@test "zsh completion includes mise after install" {
  run ./bin/nvim-config --show-completion zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"mise"* ]]
}

@test "fish completion includes mise after install" {
  run ./bin/nvim-config --show-completion fish
  [ "$status" -eq 0 ]
  [[ "$output" == *"mise"* ]]
}

@test "bash completion offers classic/modern after 'ui set', not profile subcommands (regression: previous_word 'set' is ambiguous between profile/ui/theme)" {
  run bash -c '
    source <(./bin/nvim-config --show-completion bash)
    COMP_WORDS=(nvim-config ui set "")
    COMP_CWORD=3
    _nvim_config_completions
    echo "${COMPREPLY[*]}"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "classic modern" ]
}

@test "bash completion offers theme names after 'theme set', not profile subcommands" {
  run bash -c '
    source <(./bin/nvim-config --show-completion bash)
    COMP_WORDS=(nvim-config theme set "")
    COMP_CWORD=3
    _nvim_config_completions
    echo "${COMPREPLY[*]}"
  '
  [ "$status" -eq 0 ]
  [[ "$output" == *"nightfox"* ]]
  [[ "$output" == *"catppuccin-mocha"* ]]
  [[ "$output" != *"detect"* ]]
}

@test "bash completion still offers list/detect/set/unset/create/info after bare 'profile'" {
  run bash -c '
    source <(./bin/nvim-config --show-completion bash)
    COMP_WORDS=(nvim-config profile "")
    COMP_CWORD=2
    _nvim_config_completions
    echo "${COMPREPLY[*]}"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "list detect set unset create info" ]
}

@test "bash completion still offers info/set/unset after bare 'ui'" {
  run bash -c '
    source <(./bin/nvim-config --show-completion bash)
    COMP_WORDS=(nvim-config ui "")
    COMP_CWORD=2
    _nvim_config_completions
    echo "${COMPREPLY[*]}"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "info set unset" ]
}

@test "bash completion still offers info/list/set/unset after bare 'theme'" {
  run bash -c '
    source <(./bin/nvim-config --show-completion bash)
    COMP_WORDS=(nvim-config theme "")
    COMP_CWORD=2
    _nvim_config_completions
    echo "${COMPREPLY[*]}"
  '
  [ "$status" -eq 0 ]
  [ "$output" = "info list set unset" ]
}

@test "zsh completion offers classic/modern specifically after 'ui set'" {
  run ./bin/nvim-config --show-completion zsh
  [ "$status" -eq 0 ]
  run grep -n "words\[3\].*set" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "zsh completion offers theme names specifically after 'theme set'" {
  run ./bin/nvim-config --show-completion zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"nightfox"* ]]
}

@test "fish completion offers theme names specifically after 'theme set' (parity with the existing ui/set/classic-modern completion)" {
  run ./bin/nvim-config --show-completion fish
  [ "$status" -eq 0 ]
  run grep -n "seen_subcommand_from theme; and __fish_seen_subcommand_from set" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "run_install_mise adds ~/.local/bin to PATH after a fresh install so mise is usable immediately" {
  run grep -n -- '\.local/bin' bin/nvim-config
  [ "$status" -eq 0 ]
  run grep -n "export PATH=" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "run_install_mise errors clearly if mise still isn't reachable right after installing it" {
  run grep -n "mise was installed but is not on PATH" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install all reminds to reload the shell at the end if mise activation was just added" {
  run grep -n "MISE_ACTIVATION_PENDING" bin/nvim-config
  [ "$status" -eq 0 ]
  run grep -n "Reminder: reload your shell" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "help documents uninstall command" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"uninstall"* ]]
}

@test "completion includes uninstall subcommands" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"uninstall"* ]]
  [[ "$output" == *"config nvim mise deps all"* ]]
}

@test "zsh completion includes uninstall subcommands" {
  run ./bin/nvim-config --show-completion zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"uninstall_subcmds"* ]]
}

@test "fish completion includes uninstall subcommands" {
  run ./bin/nvim-config --show-completion fish
  [ "$status" -eq 0 ]
  [[ "$output" == *"__fish_seen_subcommand_from uninstall"* ]]
}

@test "uninstall config dry-run prints rm command" {
  local nvim_config_dir="${HOME}/.config/nvim"
  local project_dir
  project_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  mkdir -p "${HOME}/.config"
  ln -s "${project_dir}" "${nvim_config_dir}"
  run ./bin/nvim-config --dry-run uninstall config
  [ "$status" -eq 0 ]
  [[ "$output" == *"rm"* ]]
}

@test "uninstall config removes the symlink when it points at this repository" {
  local nvim_config_dir="${HOME}/.config/nvim"
  local project_dir
  project_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  mkdir -p "${HOME}/.config"
  ln -s "${project_dir}" "${nvim_config_dir}"
  run ./bin/nvim-config uninstall config
  [ "$status" -eq 0 ]
  [ ! -e "${nvim_config_dir}" ]
}

@test "uninstall config refuses to remove a symlink pointing elsewhere" {
  local nvim_config_dir="${HOME}/.config/nvim"
  local other_dir="${BATS_TEST_TMPDIR}/other"
  mkdir -p "${HOME}/.config" "${other_dir}"
  ln -s "${other_dir}" "${nvim_config_dir}"
  run ./bin/nvim-config uninstall config
  [ "$status" -eq 1 ]
  [ -L "${nvim_config_dir}" ]
}

@test "uninstall config refuses to remove a real directory (not a symlink)" {
  mkdir -p "${HOME}/.config/nvim"
  run ./bin/nvim-config uninstall config
  [ "$status" -eq 1 ]
  [ -d "${HOME}/.config/nvim" ]
}

@test "uninstall config is a no-op when nothing is linked" {
  run ./bin/nvim-config uninstall config
  [ "$status" -eq 0 ]
  [[ "$output" == *"nothing to uninstall"* ]]
}

@test "uninstall deps never runs apt remove — prints manual instructions instead" {
  run ./bin/nvim-config uninstall deps
  [ "$status" -eq 0 ]
  [[ "$output" == *"never removes apt packages"* ]]
  [[ "$output" == *"sudo apt remove"* ]]
}

@test "uninstall deps behaves the same under --dry-run (nothing to simulate, it never acts)" {
  run ./bin/nvim-config --dry-run uninstall deps
  [ "$status" -eq 0 ]
  [[ "$output" == *"never removes apt packages"* ]]
}

@test "uninstall nvim is a no-op when nvim is not installed" {
  local clean_path="" dir path_dirs
  IFS=':' read -ra path_dirs <<< "$PATH"
  for dir in "${path_dirs[@]}"; do
    [ -x "${dir}/nvim" ] && continue
    clean_path="${clean_path:+${clean_path}:}${dir}"
  done
  PATH="${clean_path}" run ./bin/nvim-config uninstall nvim
  [ "$status" -eq 0 ]
  [[ "$output" == *"not installed"* ]]
}

@test "uninstall mise is a no-op when mise is not installed" {
  local clean_path="" dir path_dirs
  IFS=':' read -ra path_dirs <<< "$PATH"
  for dir in "${path_dirs[@]}"; do
    [ -x "${dir}/mise" ] && continue
    clean_path="${clean_path:+${clean_path}:}${dir}"
  done
  PATH="${clean_path}" run ./bin/nvim-config uninstall mise
  [ "$status" -eq 0 ]
  [[ "$output" == *"not installed"* ]]
}

@test "uninstall mise declines automatically outside a TTY, leaving mise installed" {
  local fake_bin="$BATS_TEST_TMPDIR/fake_bin"
  mkdir -p "$fake_bin"
  cat > "$fake_bin/mise" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$fake_bin/mise"

  PATH="$fake_bin:$PATH" run ./bin/nvim-config uninstall mise
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipped"* ]]
  [ -x "$fake_bin/mise" ]
}

@test "uninstall nvim declines automatically outside a TTY, leaving nvim installed" {
  local fake_bin="$BATS_TEST_TMPDIR/fake_bin"
  mkdir -p "$fake_bin"
  cat > "$fake_bin/nvim" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$fake_bin/nvim"

  PATH="$fake_bin:$PATH" run ./bin/nvim-config uninstall nvim
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipped"* ]]
  [ -x "$fake_bin/nvim" ]
}

@test "uninstall all never touches apt packages (deps step stays informational)" {
  run ./bin/nvim-config uninstall all
  [ "$status" -eq 0 ]
  [[ "$output" == *"never removes apt packages"* ]]
}

@test "uninstall rejects an unknown subcommand" {
  run ./bin/nvim-config uninstall bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown uninstall subcommand"* ]]
}

@test "uninstall mise's rc cleanup targets the exact marker _offer_mise_activation writes" {
  run grep -c "# Added by nvim-config install mise" bin/nvim-config
  [ "$status" -eq 0 ]
  [ "$output" -eq 3 ]
}

@test "uninstall mise delegates rc-file cleanup to a dedicated helper (independent of the confirm gate)" {
  run grep -n "_remove_mise_activation" bin/nvim-config
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# update tree-sitter: network failures must be reported, not swallowed
# ---------------------------------------------------------------------------

# Writes a fake `curl` into a private dir and prints that dir (prepend to PATH).
#   api-fails             every call fails (offline / API rate limit)
#   api-ok-download-fails the release API answers, the asset download fails
_fake_curl_dir() {
  local mode="$1" dir="$BATS_TEST_TMPDIR/fake_curl_bin"
  mkdir -p "$dir"
  case "$mode" in
    api-fails)
      printf '#!/usr/bin/env bash\nexit 22\n' > "$dir/curl"
      ;;
    api-ok-download-fails)
      cat > "$dir/curl" <<'CURLEOF'
#!/usr/bin/env bash
case "$*" in
  *api.github.com*) printf '{\n  "tag_name": "v9.9.9"\n}\n' ;;
  *) exit 22 ;;
esac
CURLEOF
      ;;
  esac
  chmod +x "$dir/curl"
  printf '%s' "$dir"
}

@test "update tree-sitter reports an error and exits 1 when the latest release cannot be fetched (it used to exit silently under set -e)" {
  PATH="$(_fake_curl_dir api-fails):$PATH" run ./bin/nvim-config update tree-sitter
  [ "$status" -eq 1 ]
  [[ "$output" == *"Could not fetch latest tree-sitter release tag"* ]]
}

@test "update tree-sitter --dry-run still succeeds when the GitHub API is unreachable (dry-run must not depend on the network)" {
  PATH="$(_fake_curl_dir api-fails):$PATH" run ./bin/nvim-config --dry-run update tree-sitter
  [ "$status" -eq 0 ]
  [[ "$output" == *"tree-sitter"* ]]
}

@test "update tree-sitter --dry-run shows the release it would download when the API answers" {
  PATH="$(_fake_curl_dir api-ok-download-fails):$PATH" run ./bin/nvim-config --dry-run update tree-sitter
  [ "$status" -eq 0 ]
  [[ "$output" == *"would download: https://github.com/tree-sitter/tree-sitter/releases/download/v9.9.9/"* ]]
}

@test "update tree-sitter reports a failed download and does not claim success" {
  PATH="$(_fake_curl_dir api-ok-download-fails):$PATH" run ./bin/nvim-config update tree-sitter
  [ "$status" -eq 1 ]
  [[ "$output" == *"Failed to download"* ]]
  [[ "$output" != *"tree-sitter updated to"* ]]
}

@test "update tree-sitter treats a vendored binary that cannot report its version as outdated (it used to exit silently under set -e)" {
  # Run a copy of the script from a throwaway project root so the "vendored"
  # binary lives in the temp dir instead of this repository's vendor/.
  local proj="$BATS_TEST_TMPDIR/proj"
  mkdir -p "$proj/bin" "$proj/vendor/tree-sitter"
  cp bin/nvim-config "$proj/bin/nvim-config"
  printf '0.0.0\n' > "$proj/VERSION"
  printf '#!/usr/bin/env bash\nexit 1\n' > "$proj/vendor/tree-sitter/tree-sitter"
  chmod +x "$proj/vendor/tree-sitter/tree-sitter"

  PATH="$(_fake_curl_dir api-ok-download-fails):$PATH" run "$proj/bin/nvim-config" --dry-run update tree-sitter
  [ "$status" -eq 0 ]
  [[ "$output" == *"Updating tree-sitter none → 9.9.9"* ]]
}

@test "uninstall nvim does not abort silently when 'mise current' fails (the failing pipeline sits in a plain assignment)" {
  run grep -n 'nvim_version="$(mise current neovim.*)" || nvim_version=""' bin/nvim-config
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# uninstall --dry-run shows the removal plan instead of "Skipped"
# ---------------------------------------------------------------------------

# Prints $PATH with every directory that holds an executable named $1 removed.
_path_without() {
  local name="$1" dir out="" path_dirs
  IFS=':' read -ra path_dirs <<< "$PATH"
  for dir in "${path_dirs[@]}"; do
    [ -x "${dir}/${name}" ] && continue
    out="${out:+${out}:}${dir}"
  done
  printf '%s' "$out"
}

# Fake tools in a private dir; prints the dir. Usage: _fake_uninstall_tools nvim mise snap-managed
_fake_uninstall_tools() {
  local dir="$BATS_TEST_TMPDIR/fake_uninstall_bin" tool
  mkdir -p "$dir"
  for tool in "$@"; do
    case "$tool" in
      nvim)
        printf '#!/usr/bin/env bash\nexit 0\n' > "$dir/nvim" ;;
      mise)
        cat > "$dir/mise" <<'FAKEEOF'
#!/usr/bin/env bash
case "$1" in
  current) echo "0.12.5" ;;
  *) ;;
esac
exit 0
FAKEEOF
        ;;
      snap-managed)
        printf '#!/usr/bin/env bash\nexit 0\n' > "$dir/snap" ;;
      snap-absent-package)
        printf '#!/usr/bin/env bash\nexit 1\n' > "$dir/snap" ;;
    esac
  done
  chmod +x "$dir"/*
  printf '%s' "$dir"
}

@test "uninstall nvim --dry-run shows the mise removal commands instead of skipping" {
  local fake; fake="$(_fake_uninstall_tools nvim mise)"
  PATH="$fake:$PATH" run ./bin/nvim-config --dry-run uninstall nvim
  [ "$status" -eq 0 ]
  [[ "$output" == *"mise unuse -g neovim"* ]]
  [[ "$output" == *"mise uninstall neovim@0.12.5"* ]]
  [[ "$output" != *"Skipped"* ]]
}

@test "uninstall nvim --dry-run shows the snap removal command when nvim comes from snap" {
  local fake; fake="$(_fake_uninstall_tools nvim snap-managed)"
  PATH="$fake:$(_path_without mise)" run ./bin/nvim-config --dry-run uninstall nvim
  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo snap remove nvim"* ]]
  [[ "$output" != *"Skipped"* ]]
}

@test "uninstall nvim --dry-run shows the apt removal command when nvim comes from neither mise nor snap" {
  local fake; fake="$(_fake_uninstall_tools nvim snap-absent-package)"
  PATH="$fake:$(_path_without mise)" run ./bin/nvim-config --dry-run uninstall nvim
  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo apt remove -y neovim"* ]]
  [[ "$output" != *"Skipped"* ]]
}

@test "uninstall mise --dry-run shows the binary and shell rc cleanup it would do, and changes nothing" {
  local fake; fake="$(_fake_uninstall_tools mise)"
  cat > "${HOME}/.bashrc" <<'RCEOF'
before

# Added by nvim-config install mise
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate bash)"
after
RCEOF
  local before; before="$(cat "${HOME}/.bashrc")"

  SHELL=/bin/bash PATH="$fake:$PATH" run ./bin/nvim-config --dry-run uninstall mise
  [ "$status" -eq 0 ]
  [[ "$output" == *"rm -f ${fake}/mise"* ]]
  [[ "$output" == *"Remove the activation block added by 'install mise'"* ]]
  [[ "$output" != *"Skipped"* ]]
  [ -x "${fake}/mise" ]
  [ "$(cat "${HOME}/.bashrc")" = "$before" ]
}

@test "uninstall all --dry-run prints the whole plan (config link, nvim, mise) and still leaves apt packages alone" {
  local fake project_dir
  fake="$(_fake_uninstall_tools nvim mise)"
  project_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  mkdir -p "${HOME}/.config"
  ln -s "${project_dir}" "${HOME}/.config/nvim"

  PATH="$fake:$PATH" run ./bin/nvim-config --dry-run uninstall all
  [ "$status" -eq 0 ]
  [[ "$output" == *"rm ${HOME}/.config/nvim"* ]]
  [[ "$output" == *"mise unuse -g neovim"* ]]
  [[ "$output" == *"rm -f ${fake}/mise"* ]]
  [[ "$output" == *"never removes apt packages"* ]]
  [ -L "${HOME}/.config/nvim" ]
}

@test "uninstall still declines without --dry-run when there is no TTY (the bypass is dry-run only)" {
  local fake; fake="$(_fake_uninstall_tools nvim mise)"
  PATH="$fake:$PATH" run ./bin/nvim-config uninstall nvim
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipped"* ]]
  [[ "$output" != *"mise unuse"* ]]
}

@test "doctor lists shellcheck and shfmt as optional shell tools" {
  run grep -n "for bin in shellcheck shfmt" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "doctor checks the devops tools in Neovim's Mason bin directory too (the shell PATH never contains it)" {
  mkdir -p "${HOME}/.local/share/nvim/mason/bin"
  printf '#!/usr/bin/env bash\nexit 0\n' > "${HOME}/.local/share/nvim/mason/bin/actionlint"
  chmod +x "${HOME}/.local/share/nvim/mason/bin/actionlint"
  XDG_DATA_HOME="${HOME}/.local/share" run ./bin/nvim-config --no-log doctor
  [[ "$output" == *"DevOps tools"* ]]
  [[ "$output" == *"[ok]  actionlint"* ]]
  [[ "$output" == *"[!!]  hadolint"* ]]
}

# ---------------------------------------------------------------------------
# test runner
# ---------------------------------------------------------------------------

# Builds a throwaway project holding a copy of the runner and a stand-in for
# `bats` that records the environment it receives. The real bats is not nested
# inside a test: that depended on the BATS_* variables of the outer run and
# failed on CI for a reason that could not be reproduced locally. The path of
# the record is written into the stand-in, because the runner no longer passes
# the caller's variables on to it.
_runner_with_recording_bats() {
  local proj="$1" fake="$2" record="$3"
  mkdir -p "$proj/tests" "$fake"
  cp tests/run "$proj/tests/run"
  : > "$proj/tests/stub.bats"
  printf '#!/usr/bin/env bash\nenv > %q\nprintf "1..1\\nok 1 stub\\n"\n' "$record" > "$fake/bats"
  chmod +x "$fake/bats"
}

@test "tests/run scrubs XDG_* so a local run behaves like CI (a developer machine often points XDG_CONFIG_HOME at the installed config)" {
  local proj="$BATS_TEST_TMPDIR/proj" fake="$BATS_TEST_TMPDIR/fake_bin" record="$BATS_TEST_TMPDIR/env_seen"
  _runner_with_recording_bats "$proj" "$fake" "$record"

  run env XDG_CONFIG_HOME=/leak XDG_DATA_HOME=/leak XDG_STATE_HOME=/leak XDG_CACHE_HOME=/leak \
    PATH="$fake:$PATH" bash "$proj/tests/run"

  [ "$status" -eq 0 ] || { printf '# runner exited %s\n' "$status" >&3; printf '# %s\n' "$output" >&3; return 1; }
  [ -e "$record" ] || { printf '# the stand-in bats never ran\n' >&3; printf '# %s\n' "$output" >&3; return 1; }
  # XDG_RUNTIME_DIR, XDG_DATA_DIRS... are system-wide and legitimately set: only the four user directories matter
  run grep -E '^XDG_(CONFIG_HOME|DATA_HOME|STATE_HOME|CACHE_HOME)=' "$record"
  [ "$status" -ne 0 ] || { printf '# XDG variables reached bats: %s\n' "$(tr '\n' ' ' <<< "$output")" >&3; return 1; }
}

@test "tests/run gives bats a minimal environment: what the caller exports reaches the tests only if it is on the list (GitHub runners export NVM_DIR, a developer shell exports VIMINIT, NO_COLOR, SHELL...)" {
  local proj="$BATS_TEST_TMPDIR/proj" fake="$BATS_TEST_TMPDIR/fake_bin" record="$BATS_TEST_TMPDIR/env_seen"
  _runner_with_recording_bats "$proj" "$fake" "$record"

  run env NVM_DIR=/leak VIMINIT=leak NO_COLOR=1 SHELL=/bin/zsh TERMUX_VERSION=1 ZDOTDIR=/leak \
    NVIM_CONFIG_LOG_DIR=/leak NVIM_CHEATSHEET_DIRS=/leak MISE_SHELL=leak GITHUB_TOKEN=leak CI=true \
    UNLISTED_SENTINEL=leak PATH="$fake:$PATH" bash "$proj/tests/run"

  [ "$status" -eq 0 ] || { printf '# runner exited %s\n' "$status" >&3; printf '# %s\n' "$output" >&3; return 1; }
  [ -e "$record" ] || { printf '# the stand-in bats never ran\n' >&3; printf '# %s\n' "$output" >&3; return 1; }
  # bash itself adds PWD, SHLVL, OLDPWD and _ to what it runs
  local unexpected
  unexpected="$(cut -d= -f1 "$record" | grep -vxE 'PATH|HOME|TERM|TMPDIR|LC_ALL|NVIM_HEADLESS_TESTS_SKIP|PWD|OLDPWD|SHLVL|_' || true)"
  [ -z "$unexpected" ] || { printf '# variables that reached bats: %s\n' "$(tr '\n' ' ' <<< "$unexpected")" >&3; return 1; }
}

@test "tests/run keeps what bats and Neovim need (PATH, HOME, TERM), TMPDIR and the documented NVIM_HEADLESS_TESTS_SKIP when set, and fixes the locale" {
  local proj="$BATS_TEST_TMPDIR/proj" fake="$BATS_TEST_TMPDIR/fake_bin" record="$BATS_TEST_TMPDIR/env_seen"
  _runner_with_recording_bats "$proj" "$fake" "$record"

  run env HOME=/kept/home TERM=xterm-kitty TMPDIR=/kept/tmp NVIM_HEADLESS_TESTS_SKIP=0 LC_ALL=fr_FR.UTF-8 LANG=fr_FR.UTF-8 \
    PATH="$fake:$PATH" bash "$proj/tests/run"
  [ "$status" -eq 0 ] || { printf '# %s\n' "$output" >&3; return 1; }
  grep -qx 'HOME=/kept/home' "$record"
  grep -qx 'TERM=xterm-kitty' "$record"
  grep -qx 'TMPDIR=/kept/tmp' "$record"
  grep -qx 'NVIM_HEADLESS_TESTS_SKIP=0' "$record"
  grep -qx "PATH=$fake:$PATH" "$record"
  grep -qx 'LC_ALL=C.UTF-8' "$record"
  run grep -E '^LANG=' "$record"
  [ "$status" -ne 0 ]

  # unset on the caller's side stays unset (TERM gets a default, the optional ones do not appear)
  run env -u TMPDIR -u NVIM_HEADLESS_TESTS_SKIP -u TERM PATH="$fake:$PATH" bash "$proj/tests/run"
  [ "$status" -eq 0 ]
  run grep -E '^(TMPDIR|NVIM_HEADLESS_TESTS_SKIP)=' "$record"
  [ "$status" -ne 0 ]
  grep -qx 'TERM=dumb' "$record"
}

@test "doctor lists yazi among the optional tools (it only enables the yazi.nvim integration)" {
  run grep -n "for bin in lazygit tmux mise yazi claude codex gemini" bin/nvim-config
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
}

# ---------------------------------------------------------------------------
# --dry-run must not claim it did something, nor do it
# ---------------------------------------------------------------------------

@test "install config --dry-run says it would link, and links nothing" {
  run ./bin/nvim-config --no-log --dry-run install config
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would link ${HOME}/.config/nvim"* ]]
  [[ "$output" != *"] Linked "* ]]
  [ ! -e "${HOME}/.config/nvim" ]
}

@test "install config really links and still says Linked" {
  run ./bin/nvim-config --no-log install config
  [ "$status" -eq 0 ]
  [[ "$output" == *"Linked ${HOME}/.config/nvim"* ]]
  [ -L "${HOME}/.config/nvim" ]
}

@test "uninstall config --dry-run says it would remove the link, and keeps it" {
  local project_dir
  project_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  mkdir -p "${HOME}/.config"; ln -s "${project_dir}" "${HOME}/.config/nvim"
  run ./bin/nvim-config --no-log --dry-run uninstall config
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would remove ${HOME}/.config/nvim"* ]]
  [[ "$output" != *"] Removed "* ]]
  [ -L "${HOME}/.config/nvim" ]
}

@test "uninstall config really removes the link and still says Removed" {
  local project_dir
  project_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  mkdir -p "${HOME}/.config"; ln -s "${project_dir}" "${HOME}/.config/nvim"
  run ./bin/nvim-config --no-log uninstall config
  [[ "$output" == *"] Removed ${HOME}/.config/nvim"* ]]
  [ ! -e "${HOME}/.config/nvim" ]
}

@test "uninstall mise --dry-run says it would remove the binary instead of claiming it did" {
  local fake="$BATS_TEST_TMPDIR/fake_mise_bin"
  mkdir -p "$fake"; printf '#!/usr/bin/env bash\nexit 0\n' > "$fake/mise"; chmod +x "$fake/mise"
  SHELL=/bin/bash PATH="$fake:$PATH" run ./bin/nvim-config --no-log --dry-run uninstall mise
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would remove the mise binary"* ]]
  [[ "$output" != *"mise binary removed"* ]]
  [ -x "$fake/mise" ]
}

@test "--install-completion --dry-run writes nothing and says it would install" {
  local sh
  for sh in bash zsh fish; do
    run ./bin/nvim-config --no-log --dry-run --install-completion "$sh"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Would install ${sh} completion to ${HOME}"* ]]
    [[ "$output" != *"] Installed "* ]]
  done
  run find "$HOME" -type f
  [ -z "$output" ]
  run find "$HOME" -mindepth 1 -type d
  [ -z "$output" ]
}

@test "--install-completion without --dry-run still writes the file and says Installed" {
  run ./bin/nvim-config --no-log --install-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"Installed bash completion to ${HOME}"* ]]
  [ -s "${HOME}/.local/share/bash-completion/completions/nvim-config" ]
}

@test "no mutating command claims a finished action under --dry-run, and none changes anything (sweep)" {
  # A throwaway copy of the project: if a dry-run ever writes, it writes there and
  # not into this repository (ui set, theme set and profile create write next to bin/).
  local proj="$BATS_TEST_TMPDIR/proj" fake="$BATS_TEST_TMPDIR/fake_mise_bin" cmd claimed=""
  mkdir -p "$proj/bin" "$proj/lua/profiles" "$fake" "${HOME}/.config"
  cp bin/nvim-config "$proj/bin/"; cp VERSION "$proj/"; cp lua/profiles/*.lua "$proj/lua/profiles/"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$fake/mise"; chmod +x "$fake/mise"
  : > "$proj/.nvim-ui"; printf 'nordfox\n' > "$proj/.nvim-theme"
  ln -s "$proj" "${HOME}/.config/nvim"
  local before; before="$(cd "$proj" && find . -type f | sort | xargs md5sum | md5sum)"
  while IFS= read -r cmd; do
    run env SHELL=/bin/bash PATH="$fake:$PATH" "$proj/bin/nvim-config" --no-log --dry-run $cmd
    if printf '%s\n' "$output" | grep -qE '\[INFO\] (Removed|Linked|Installed|Added|Created|Wrote|mise binary removed) '; then
      claimed="${claimed} [${cmd}]"
    fi
  done <<'LIST'
install config
install tmux
uninstall config
uninstall mise
ui set modern
ui unset
theme set nordfox
theme unset
profile set web
profile unset
profile create zz-dry-run-sweep
--install-completion bash
--install-completion zsh
--install-completion fish
LIST
  [ -z "$claimed" ] || { echo "past-tense claim under --dry-run:${claimed}"; return 1; }
  [ "$(cd "$proj" && find . -type f | sort | xargs md5sum | md5sum)" = "$before" ]
  [ -L "${HOME}/.config/nvim" ]
  [ ! -e "${HOME}/.tmux.conf" ] && [ ! -e "${HOME}/.local/share/bash-completion" ] && [ ! -e "${HOME}/.local/share/zsh" ]
}

# ---------------------------------------------------------------------------
# Consistency between what install all does and what is said about it
# ---------------------------------------------------------------------------

@test "help, zsh and fish describe install all as also fetching the tree-sitter CLI (the code runs update tree-sitter at the end)" {
  run bash -c './bin/nvim-config --help | grep "all    — nvim, deps"'
  [[ "$output" == *"tree-sitter"* ]]
  run bash -c "./bin/nvim-config --show-completion zsh | grep \"'all:Install nvim\""
  [[ "$output" == *"tree-sitter"* ]]
  run bash -c "./bin/nvim-config --show-completion fish | grep \"seen_subcommand_from install' -a all\""
  [[ "$output" == *"tree-sitter"* ]]
}

@test "every array the zsh completion assigns is declared local (otherwise it leaks into the user's shell)" {
  local script declared assigned missing="" name
  script="$(./bin/nvim-config --show-completion zsh)"
  declared="$(printf '%s\n' "$script" | grep 'local -a' | sed 's/.*local -a //' | tr '\n' ' ')"
  for name in $(printf '%s\n' "$script" | grep -oP '^  \K[a-z_]+(?==\()' | sort -u); do
    [[ " $declared " == *" $name "* ]] || missing="$missing $name"
  done
  [ -z "$missing" ] || { echo "assigned but not local:$missing"; return 1; }
}

@test "the zsh completion assigns its commands array once (an earlier assignment was dead code)" {
  run bash -c "./bin/nvim-config --show-completion zsh | grep -c '^  commands=('"
  [ "$output" = "1" ]
}

# ---------------------------------------------------------------------------
# The CLI follows the XDG base directories (compatibility.md), and logs by appending
# ---------------------------------------------------------------------------

_logfile_in() { ls "$1"/nvim-config-*.log 2> /dev/null | head -1; }

@test "the log directory follows XDG_STATE_HOME" {
  local state="$BATS_TEST_TMPDIR/state"
  XDG_STATE_HOME="$state" run ./bin/nvim-config --dry-run uninstall deps
  [ "$status" -eq 0 ]
  [ -n "$(_logfile_in "$state/nvim-config/logs")" ]
  [ ! -e "$HOME/.local/state" ]
}

@test "without XDG_STATE_HOME the log directory is ~/.local/state/nvim-config/logs" {
  run ./bin/nvim-config --dry-run uninstall deps
  [ -n "$(_logfile_in "$HOME/.local/state/nvim-config/logs")" ]
}

@test "NVIM_CONFIG_LOG_DIR and --log-dir take precedence over XDG_STATE_HOME" {
  local state="$BATS_TEST_TMPDIR/state" envdir="$BATS_TEST_TMPDIR/envlogs" flagdir="$BATS_TEST_TMPDIR/flaglogs"
  XDG_STATE_HOME="$state" NVIM_CONFIG_LOG_DIR="$envdir" run ./bin/nvim-config --dry-run uninstall deps
  [ -n "$(_logfile_in "$envdir")" ]
  [ ! -e "$state" ]
  XDG_STATE_HOME="$state" NVIM_CONFIG_LOG_DIR="$envdir" run ./bin/nvim-config --log-dir "$flagdir" --dry-run uninstall deps
  [ -n "$(_logfile_in "$flagdir")" ]
}

@test "the daily log is appended to, not overwritten, by the next run" {
  local dir="$BATS_TEST_TMPDIR/logs" file first
  NVIM_CONFIG_LOG_DIR="$dir" run ./bin/nvim-config --dry-run uninstall deps
  file="$(_logfile_in "$dir")"; first="$(wc -l < "$file")"
  [ "$first" -ge 2 ]
  NVIM_CONFIG_LOG_DIR="$dir" run ./bin/nvim-config --dry-run uninstall config
  [ "$(wc -l < "$file")" -gt "$first" ]
  [ "$(grep -c "uninstall deps" "$file")" -ge 1 ]
  [ "$(grep -c "uninstall config" "$file")" -ge 1 ]
}

@test "each run starts with a header line in the log file (version and arguments), which is not printed on the terminal" {
  local dir="$BATS_TEST_TMPDIR/logs" file
  NVIM_CONFIG_LOG_DIR="$dir" run ./bin/nvim-config --dry-run uninstall deps
  file="$(_logfile_in "$dir")"
  [[ "$output" != *"Run: "* ]]
  run head -1 "$file"
  [[ "$output" == *"[INFO] Run: nvim-config $(cat VERSION | tr -d '\n') --dry-run uninstall deps"* ]]
}

@test "install config links inside XDG_CONFIG_HOME, which is where Neovim reads its config" {
  local xdg="$BATS_TEST_TMPDIR/xdgconf"
  XDG_CONFIG_HOME="$xdg" run ./bin/nvim-config --no-log install config
  [ "$status" -eq 0 ]
  [ -L "$xdg/nvim" ]
  [ ! -e "$HOME/.config/nvim" ]
  [[ "$output" == *"Linked $xdg/nvim"* ]]
}

@test "uninstall config removes the link from XDG_CONFIG_HOME" {
  local xdg="$BATS_TEST_TMPDIR/xdgconf" project_dir
  project_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  mkdir -p "$xdg"; ln -s "$project_dir" "$xdg/nvim"
  XDG_CONFIG_HOME="$xdg" run ./bin/nvim-config --no-log uninstall config
  [ "$status" -eq 0 ]
  [ ! -e "$xdg/nvim" ]
}

@test "install config --dry-run names the XDG_CONFIG_HOME path" {
  local xdg="$BATS_TEST_TMPDIR/xdgconf"
  XDG_CONFIG_HOME="$xdg" run ./bin/nvim-config --no-log --dry-run install config
  [[ "$output" == *"Would link $xdg/nvim"* ]]
}

@test "bash completion goes to XDG_DATA_HOME/bash-completion/completions" {
  local xdg="$BATS_TEST_TMPDIR/xdgdata"
  XDG_DATA_HOME="$xdg" run ./bin/nvim-config --no-log --install-completion bash
  [ -s "$xdg/bash-completion/completions/nvim-config" ]
  [ ! -e "$HOME/.local/share" ]
}

@test "zsh completion goes to XDG_DATA_HOME/zsh/completions, the directory the dotfiles put on fpath" {
  local xdg="$BATS_TEST_TMPDIR/xdgdata"
  XDG_DATA_HOME="$xdg" run ./bin/nvim-config --no-log --install-completion zsh
  [ -s "$xdg/zsh/completions/_nvim-config" ]
  [ ! -e "$HOME/.zfunc" ]
}

@test "zsh completion warns about a leftover ~/.zfunc/_nvim-config, which nothing loads any more" {
  mkdir -p "$HOME/.zfunc"; : > "$HOME/.zfunc/_nvim-config"
  run ./bin/nvim-config --no-log --install-completion zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"$HOME/.zfunc/_nvim-config"* ]]
  [[ "$output" == *"remove"* ]]
}

@test "fish completion goes to XDG_CONFIG_HOME/fish/completions" {
  local xdg="$BATS_TEST_TMPDIR/xdgconf"
  XDG_CONFIG_HOME="$xdg" run ./bin/nvim-config --no-log --install-completion fish
  [ -s "$xdg/fish/completions/nvim-config.fish" ]
  [ ! -e "$HOME/.config" ]
}

@test "the fish rc file used for mise activation follows XDG_CONFIG_HOME (fish reads it from there)" {
  run grep -n 'fish) printf .%s. "${XDG_CONFIG_DIR}/fish/config.fish"' bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install deps --with-node hands the same NVM_DIR to the nvm installer and to the later nvm.sh (nvm installs under XDG_CONFIG_HOME/nvm when that is set, not ~/.nvm)" {
  local xdg="$BATS_TEST_TMPDIR/xdgconf"
  XDG_CONFIG_HOME="$xdg" run ./bin/nvim-config --no-log --dry-run install deps --with-node
  [[ "$output" == *"env NVM_DIR=$xdg/nvm bash -c"*"install.sh"* ]]
  [[ "$output" == *". $xdg/nvm/nvm.sh"* ]]
}

@test "an existing ~/.nvm is kept rather than installing a second nvm under XDG_CONFIG_HOME" {
  mkdir -p "$HOME/.nvm"
  XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/xdgconf" run ./bin/nvim-config --no-log --dry-run install deps --with-node
  [[ "$output" == *"nvm already installed at $HOME/.nvm"* ]]
}

@test "an exported NVM_DIR wins, and nvm falls back to ~/.nvm when XDG_CONFIG_HOME is unset" {
  NVM_DIR="$BATS_TEST_TMPDIR/mynvm" run ./bin/nvim-config --no-log --dry-run install deps --with-node
  [[ "$output" == *"env NVM_DIR=$BATS_TEST_TMPDIR/mynvm bash -c"* ]]
  run ./bin/nvim-config --no-log --dry-run install deps --with-node
  [[ "$output" == *"env NVM_DIR=$HOME/.nvm bash -c"* ]]
}

# ---- install tmux must not write through a symlink -------------------------

@test "install tmux refuses to write through a symlinked ~/.tmux.conf and leaves its target untouched" {
  local target="$BATS_TEST_TMPDIR/otherrepo/.tmux.conf"
  mkdir -p "$(dirname "$target")"; printf 'set -g mouse on\n' > "$target"
  ln -s "$target" "$HOME/.tmux.conf"
  run ./bin/nvim-config --no-log install tmux
  [ "$status" -eq 1 ]
  [[ "$output" == *"symlink"* ]]
  [[ "$output" == *"source-file "* ]]
  [ "$(cat "$target")" = "set -g mouse on" ]
}

@test "install tmux --dry-run reports the same refusal" {
  local target="$BATS_TEST_TMPDIR/otherrepo/.tmux.conf"
  mkdir -p "$(dirname "$target")"; : > "$target"
  ln -s "$target" "$HOME/.tmux.conf"
  run ./bin/nvim-config --no-log --dry-run install tmux
  [ "$status" -eq 1 ]
  [[ "$output" == *"symlink"* ]]
}

@test "install tmux still recognises a symlinked config that already sources this repository" {
  local target="$BATS_TEST_TMPDIR/otherrepo/.tmux.conf" project_dir
  project_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  mkdir -p "$(dirname "$target")"; printf 'source-file %s/.tmux.conf\n' "$project_dir" > "$target"
  ln -s "$target" "$HOME/.tmux.conf"
  run ./bin/nvim-config --no-log install tmux
  [ "$status" -eq 0 ]
  [[ "$output" == *"already sources"* ]]
}

@test "install tmux still appends to a regular ~/.tmux.conf" {
  printf 'set -g mouse on\n' > "$HOME/.tmux.conf"
  run ./bin/nvim-config --no-log install tmux
  [ "$status" -eq 0 ]
  run grep -c "source-file" "$HOME/.tmux.conf"
  [ "$output" -eq 1 ]
}

# ---------------------------------------------------------------------------
# doctor lists the language servers Neovim will not install without npm
# ---------------------------------------------------------------------------

# A directory holding only the few tools doctor itself needs, to be used as the
# whole PATH: npm, and every other tool, is then absent. Prints the directory.
_minimal_tools_dir() {
  local dir="$BATS_TEST_TMPDIR/minimal_bin" tool
  mkdir -p "$dir"
  for tool in bash env readlink dirname date head grep paste sed tr cat awk; do
    ln -sf "$(type -P "$tool")" "$dir/$tool"
  done
  printf '%s' "$dir"
}

@test "doctor lists the language servers Neovim will not install when npm is missing, with the way to get them" {
  local tools; tools="$(_minimal_tools_dir)"
  PATH="$tools" run ./bin/nvim-config --no-log --no-color doctor
  [[ "$output" == *"=== Language servers that need npm ==="* ]]
  [[ "$output" == *"[!!]  npm not found"*"jsonls"*"ts_ls"*"pyright"*"bashls"*"yamlls"*"dockerls"*"nvim-config install deps --with-node"* ]]
}

@test "doctor says the same language servers are installed on demand when npm is there" {
  local tools; tools="$(_minimal_tools_dir)"
  printf '#!/bin/sh\nexit 0\n' > "$tools/npm"; chmod +x "$tools/npm"
  PATH="$tools" run ./bin/nvim-config --no-log --no-color doctor
  [[ "$output" == *"=== Language servers that need npm ==="* ]]
  [[ "$output" == *"[ok]  npm found"*"jsonls"*"bashls"*"dockerls"* ]]
  [[ "$output" != *"npm not found"* ]]
}

@test "doctor reads the npm language servers from lua/lsp_requirements.lua, the one list Neovim uses" {
  local tools proj="$BATS_TEST_TMPDIR/proj"; tools="$(_minimal_tools_dir)"
  mkdir -p "$proj/bin" "$proj/lua"
  cp bin/nvim-config "$proj/bin/"; cp VERSION "$proj/"; cp lua/lsp_requirements.lua "$proj/lua/"
  sed -i "s|^    jsonls .*|&\n    brand_new_server = 'npm',|" "$proj/lua/lsp_requirements.lua"
  PATH="$tools" run "$proj/bin/nvim-config" --no-log --no-color doctor
  [[ "$output" == *"npm not found"*"brand_new_server"* ]]
}

@test "doctor does not list a server that needs nothing special (only the npm ones)" {
  local tools; tools="$(_minimal_tools_dir)"
  PATH="$tools" run ./bin/nvim-config --no-log --no-color doctor
  [[ "$output" != *"lua_ls"* ]]
  [[ "$output" != *"rust_analyzer"* ]]
}

@test "doctor leaves the section out on Termux, where Neovim installs no language server" {
  local tools; tools="$(_minimal_tools_dir)"
  TERMUX_VERSION=0.118 PATH="$tools" run ./bin/nvim-config --no-log --no-color doctor
  [[ "$output" != *"Language servers that need npm"* ]]
}

@test "doctor still completes, with a warning, when the list of npm language servers cannot be read" {
  local tools proj="$BATS_TEST_TMPDIR/proj"; tools="$(_minimal_tools_dir)"
  mkdir -p "$proj/bin"
  cp bin/nvim-config "$proj/bin/"; cp VERSION "$proj/"
  PATH="$tools" run "$proj/bin/nvim-config" --no-log --no-color doctor
  [[ "$output" == *"could not read the npm language servers"* ]]
  [[ "$output" == *"=== Build tools (optional) ==="* ]]
}

# ---------------------------------------------------------------------------
# .nvim-profile may name several profiles ("web,php"), as Neovim reads it
# ---------------------------------------------------------------------------

# Runs the CLI from a throwaway project directory that holds the given
# .nvim-profile (exact bytes, via printf). Usage: _cli_in_project '<printf format>' args...
_cli_in_project() {
  local content="$1"; shift
  local cli; cli="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/bin/nvim-config"
  PROJECT="$BATS_TEST_TMPDIR/pinned"; mkdir -p "$PROJECT"
  if [ -n "$content" ]; then printf "$content" > "$PROJECT/.nvim-profile"; fi
  cd "$PROJECT"
  run "$cli" --no-log --no-color "$@"
}

@test "profile info shows every profile named in .nvim-profile, with its own language servers" {
  _cli_in_project 'web,php\n' profile info
  [ "$status" -eq 0 ]
  [[ "$output" == *"Active profile: web"* ]]
  [[ "$output" == *"Active profile: php"* ]]
  [[ "$output" == *"ts_ls"* ]]
  [[ "$output" == *"intelephense"* ]]
  [[ "$output" != *"not found"* ]]
}

@test "profile info reads the file the way Neovim does: first line only, spaces around names ignored, empty names dropped" {
  _cli_in_project ' web , ,php \nrust\n' profile info
  [ "$status" -eq 0 ]
  [[ "$output" == *"Active profile: web"* ]]
  [[ "$output" == *"Active profile: php"* ]]
  [[ "$output" != *"rust"* ]]
}

@test "a profile named twice in .nvim-profile is shown once by profile info (Neovim keeps it once too)" {
  _cli_in_project 'web,web, web\n' profile info
  [ "$status" -eq 0 ]
  [ "$(grep -c 'Active profile: web' <<< "$output")" -eq 1 ]
}

@test "profile info with a single name prints what it always did" {
  _cli_in_project 'web\n' profile info
  [ "$status" -eq 0 ]
  [[ "$output" == *"Active profile: web"* ]]
  [[ "$output" == *"LSP servers:"* ]]
  [[ "$output" == *"DAP packages:"* ]]
}

@test "profile info names the one profile of the list that has no file, and still shows the others" {
  _cli_in_project 'web,wbe\n' profile info
  [ "$status" -eq 1 ]
  [[ "$output" == *"Active profile: web"* ]]
  [[ "$output" == *"ts_ls"* ]]
  [[ "$output" == *"Profile file not found"*"/lua/profiles/wbe.lua"* ]]
  [[ "$output" != *"web,wbe"* ]]
}

@test "profile list marks every profile named in .nvim-profile" {
  _cli_in_project 'web,php\n' profile list
  [ "$status" -eq 0 ]
  [[ "$output" == *"* web"* ]]
  [[ "$output" == *"* php"* ]]
  [[ "$output" != *"* rust"* ]]
  [[ "$output" != *"no active profile"* ]]
}

@test "update dap-adapters lists the debug adapters of every pinned profile, once each" {
  _cli_in_project 'web,php,web\n' --dry-run update dap-adapters
  [ "$status" -eq 0 ]
  [[ "$output" == *"js-debug-adapter"* ]]
  [[ "$output" == *"php-debug-adapter"* ]]
  [ "$(grep -c 'js-debug-adapter' <<< "$output")" -eq 1 ]
}

@test "update dap-adapters stops with the missing profile's name when one of the pinned names has no file" {
  _cli_in_project 'web,wbe\n' --dry-run update dap-adapters
  [ "$status" -eq 1 ]
  [[ "$output" == *"Profile file not found"*"/lua/profiles/wbe.lua"* ]]
  [[ "$output" != *"web,wbe"* ]]
}

@test "status shows the pinned profiles as one normalised list" {
  _cli_in_project ' web , php \n' status
  [[ "$output" == *"Profile : web,php"* ]]
}

@test "profile set writes a list of profiles without spaces or duplicates" {
  _cli_in_project '' profile set 'web, php,web'
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT/.nvim-profile")" = "web,php" ]
}

@test "profile set with one name writes it as before" {
  _cli_in_project '' profile set rust
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT/.nvim-profile")" = "rust" ]
}

@test "profile set refuses an unknown profile with exit 2, names the valid ones, and writes nothing" {
  _cli_in_project '' profile set wbe
  [ "$status" -eq 2 ]
  [[ "$output" == *"Unknown profile 'wbe'"* ]]
  [[ "$output" == *"available:"*"devops"*"php"*"web"* ]]
  [ ! -e "$PROJECT/.nvim-profile" ]
}

@test "profile set refuses a list that contains an unknown profile and leaves the existing file alone" {
  _cli_in_project 'rust\n' profile set web,wbe
  [ "$status" -eq 2 ]
  [[ "$output" == *"Unknown profile 'wbe'"* ]]
  [ "$(cat "$PROJECT/.nvim-profile")" = "rust" ]
}

@test "profile set --dry-run refuses an unknown profile too" {
  _cli_in_project '' --dry-run profile set wbe
  [ "$status" -eq 2 ]
  [[ "$output" == *"Unknown profile 'wbe'"* ]]
}

@test "profile set --dry-run shows the normalised list it would write, and writes nothing" {
  _cli_in_project '' --dry-run profile set 'web , php'
  [ "$status" -eq 0 ]
  [[ "$output" == *"'web,php'"* ]]
  [ ! -e "$PROJECT/.nvim-profile" ]
}

@test "profile set refuses an empty list" {
  _cli_in_project '' profile set ' , '
  [ "$status" -eq 2 ]
  [[ "$output" == *"no profile name"* ]]
  [ ! -e "$PROJECT/.nvim-profile" ]
}

@test "profile set does not take the profile manager or the picker for profiles" {
  _cli_in_project '' profile set init
  [ "$status" -eq 2 ]
  _cli_in_project '' profile set picker
  [ "$status" -eq 2 ]
}

@test "profile set accepts every profile that profile list shows" {
  local cli; cli="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/bin/nvim-config"
  local names; names="$("$cli" --no-log --no-color profile list | sed 's/^.*\] //' | grep -v '^(' | tr -d '* ' | paste -sd, -)"
  [ -n "$names" ]
  _cli_in_project '' profile set "$names"
  [ "$status" -eq 0 ]
  [ "$(cat "$PROJECT/.nvim-profile")" = "$names" ]
}
