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
  [[ "$output" == *"sudo apt install curl ripgrep fd-find xsel xclip lolcat"* ]]
}

@test "install deps dry-run installs apt packages" {
  run ./bin/nvim-config --dry-run install deps
  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo apt update"* ]]
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
  run grep -n "apt install neovim" bin/nvim-config
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
  [[ "$output" == *"nvim"* ]]
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
