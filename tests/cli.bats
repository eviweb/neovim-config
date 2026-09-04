#!/usr/bin/env bats

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
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
  [[ "$output" == *"sudo apt install -y curl ripgrep fd-find xsel xclip lolcat"* ]]
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
  [ -f "$HOME/.zfunc/_nvim-config" ]
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

@test "install nvim explicit --snap flag requires the snap command" {
  run grep -n "snap is required" bin/nvim-config
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

@test "install nvim auto mode offers to install missing mise prerequisites via apt in the same prompt" {
  run grep -n -- "+ mise now" bin/nvim-config
  [ "$status" -eq 0 ]
}

@test "install nvim auto mode reuses the mise prerequisite check (no duplicated logic)" {
  run grep -c "_mise_missing_deps" bin/nvim-config
  [ "$status" -eq 0 ]
  [ "$output" -ge 3 ]
}

@test "install nvim via mise requires mise to be installed" {
  run grep -n "mise is required" bin/nvim-config
  [ "$status" -eq 0 ]
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
