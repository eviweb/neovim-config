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

@test "null-ls config does not reference invalid luasnip formatter" {
  run grep -n "null_ls\\.builtins\\.formatting\\.luasnip" lua/config/null-ls.lua
  [ "$status" -eq 1 ]
}

@test "nvim-tree config does not use removed open_on_setup option" {
  run grep -rn "open_on_setup" lua/config/
  [ "$status" -eq 1 ]
}

@test "plugins list loads the dedicated luasnip plugin module" {
  run grep -n "require('plugins\\.luasnip')" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "nvim-cmp config does not lazy-load vscode snippets directly" {
  run grep -n "luasnip\\.loaders\\.from_vscode" lua/config/nvim-cmp.lua
  [ "$status" -eq 1 ]
}

@test "lsp plugin does not depend on nvim-lsp-installer" {
  run grep -n "nvim-lsp-installer" lua/plugins/lsp.lua
  [ "$status" -eq 1 ]
}

@test "lsp plugin uses mason and mason-lspconfig" {
  run grep -n "williamboman/mason.nvim" lua/plugins/lsp.lua
  [ "$status" -eq 0 ]

  run grep -n "williamboman/mason-lspconfig.nvim" lua/plugins/lsp.lua
  [ "$status" -eq 0 ]
}

@test "lsp config does not use deprecated capability helper" {
  run grep -n "update_capabilities" lua/config/lsp.lua
  [ "$status" -eq 1 ]
}

@test "lsp config does not use deprecated formatting call" {
  run grep -n "vim\\.lsp\\.buf\\.formatting(" lua/config/lsp.lua
  [ "$status" -eq 1 ]
}

@test "lsp config does not depend on global lsp server list" {
  run grep -n "vim\\.g\\.lsp_servers" lua/config/lsp.lua
  [ "$status" -eq 1 ]
}

@test "lsp config defines explicit default servers" {
  run grep -n "lua_ls" lua/config/lsp.lua
  [ "$status" -eq 0 ]

  run grep -n "jsonls" lua/config/lsp.lua
  [ "$status" -eq 0 ]
}

@test "plugin declarations do not use the legacy kyazdani42 namespace" {
  run grep -R -n "kyazdani42/" lua/plugins
  [ "$status" -eq 1 ]
}

@test "null-ls plugin uses the maintained none-ls repository" {
  run grep -n "nvimtools/none-ls.nvim" lua/plugins/null-ls.lua
  [ "$status" -eq 0 ]

  run grep -n "jose-elias-alvarez/null-ls.nvim" lua/plugins/null-ls.lua
  [ "$status" -eq 1 ]
}

@test "treesitter config does not install every parser indiscriminately" {
  run grep -n "ensure_installed = 'all'" lua/config/treesitter.lua
  [ "$status" -eq 1 ]
}

@test "treesitter config does not enable rainbow without a declared plugin" {
  run grep -n "rainbow =" lua/config/treesitter.lua
  [ "$status" -eq 1 ]
}

@test "treesitter config does not reference undefined custom captures" {
  run grep -n "@custom-capture" lua/config/treesitter.lua
  [ "$status" -eq 1 ]
}

@test "readme has a getting started section" {
  run grep -n "Getting Started" README.md
  [ "$status" -eq 0 ]
}

@test "readme documents snap as recommended neovim install method" {
  run grep -n "snap install nvim" README.md
  [ "$status" -eq 0 ]
}

@test "readme has an updating section covering plugins" {
  run grep -n "Lazy" README.md
  [ "$status" -eq 0 ]
  run grep -n "Updating\|update" README.md
  [ "$status" -eq 0 ]
}

@test "readme documents neovim dependencies and plugin managers" {
  run grep -n "lazy.nvim" README.md
  [ "$status" -eq 0 ]

  run grep -n "mason.nvim" README.md
  [ "$status" -eq 0 ]
}

@test "keymaps cheatsheet exists and documents leader key" {
  [ -f "docs/keymaps.md" ]
  run grep -n "Leader" docs/keymaps.md
  [ "$status" -eq 0 ]
}

@test "keymaps cheatsheet covers lsp and completion sections" {
  run grep -n "LSP" docs/keymaps.md
  [ "$status" -eq 0 ]
  run grep -n "nvim-cmp" docs/keymaps.md
  [ "$status" -eq 0 ]
}

@test "readme links to keymaps cheatsheet" {
  run grep -n "docs/keymaps.md" README.md
  [ "$status" -eq 0 ]
}

@test "readme documents sandbox and snap limitations" {
  run grep -n "Snap" README.md
  [ "$status" -eq 0 ]

  run grep -n "sandbox" README.md
  [ "$status" -eq 0 ]
}

@test "keymaps do not expose diaglist commands anymore" {
  run grep -n "diaglist" lua/keymaps.lua
  [ "$status" -eq 1 ]
}

@test "lsp plugin does not depend on diaglist anymore" {
  run grep -n "diaglist.nvim" lua/plugins/lsp.lua
  [ "$status" -eq 1 ]
}

@test "telescope plugin does not include unused tele-tabby extension" {
  run grep -n "tele-tabby" lua/plugins/telescope.lua
  [ "$status" -eq 1 ]
}

@test "telescope plugin does not include unused live-grep-raw extension" {
  run grep -n "live-grep-raw" lua/plugins/telescope.lua
  [ "$status" -eq 1 ]
}

@test "telescope plugin does not include unused symbols extension" {
  run grep -n "telescope-symbols" lua/plugins/telescope.lua
  [ "$status" -eq 1 ]
}

@test "telescope config does not configure or load removed extensions" {
  run grep -n "tele_tabby" lua/config/telescope.lua
  [ "$status" -eq 1 ]
}

@test "plugins list does not load archived nvim-gps" {
  run grep -n "nvim-gps" lua/plugins.lua
  [ "$status" -eq 1 ]
}

@test "lualine config does not reference nvim-gps" {
  run grep -n "nvim-gps\|nvim_gps" lua/config/lualine.lua
  [ "$status" -eq 1 ]
}

@test "lualine config uses nvim-navic for breadcrumb" {
  run grep -n "nvim-navic" lua/config/lualine.lua
  [ "$status" -eq 0 ]
}

@test "lualine config guards nvim-navic with pcall" {
  run grep -n "pcall(require, 'nvim-navic')" lua/config/lualine.lua
  [ "$status" -eq 0 ]
}

@test "nvim-cmp config does not use deprecated mapping.close" {
  run grep -n "cmp.mapping.close" lua/config/nvim-cmp.lua
  [ "$status" -eq 1 ]
}

@test "nvim-cmp tab mappings declare insert and select modes" {
  run grep -n "{ 'i', 's' }" lua/config/nvim-cmp.lua
  [ "$status" -eq 0 ]
}

@test "lsp config defines on_attach and passes it to server setup" {
  run grep -n "on_attach" lua/config/lsp.lua
  [ "$status" -eq 0 ]
}

@test "lsp config does not use removed setup_handlers API" {
  run grep -n "setup_handlers" lua/config/lsp.lua
  [ "$status" -eq 1 ]
}

@test "lsp config uses vim.lsp.config for global server defaults" {
  run grep -n "vim.lsp.config('\*'" lua/config/lsp.lua
  [ "$status" -eq 0 ]
}

@test "lsp config does not call deprecated vim.lsp.with" {
  run grep -n "= vim\.lsp\.with(" lua/config/lsp.lua
  [ "$status" -eq 1 ]
}

@test "lsp config calls vim.diagnostic.config" {
  run grep -n "vim.diagnostic.config" lua/config/lsp.lua
  [ "$status" -eq 0 ]
}

@test "lsp config attaches nvim-navic in on_attach" {
  run grep -n "navic.attach" lua/config/lsp.lua
  [ "$status" -eq 0 ]
}

@test "trouble plugin does not declare lsp-colors" {
  run grep -n "lsp-colors" lua/plugins/trouble.lua
  [ "$status" -eq 1 ]
}

@test "plugins list loads neo-tree instead of nvim-tree" {
  run grep -n "require('plugins.neo-tree')" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "plugins list does not load nvim-tree" {
  run grep -n "require('plugins.nvim-tree')" lua/plugins.lua
  [ "$status" -eq 1 ]
}

@test "keymaps use Neotree command instead of NvimTreeToggle" {
  run grep -n "NvimTreeToggle" lua/keymaps.lua
  [ "$status" -eq 1 ]
}

@test "keymaps do not use trouble v1 workspace_diagnostics" {
  run grep -n "workspace_diagnostics" lua/keymaps.lua
  [ "$status" -eq 1 ]
}

@test "keymaps do not use trouble v1 document_diagnostics" {
  run grep -n "document_diagnostics" lua/keymaps.lua
  [ "$status" -eq 1 ]
}

@test "keymaps do not use trouble v1 quickfix command" {
  run grep -n "Trouble quickfix" lua/keymaps.lua
  [ "$status" -eq 1 ]
}

@test "telescope config loads fzf extension" {
  run grep -n "load_extension('fzf')" lua/config/telescope.lua
  [ "$status" -eq 0 ]
}

@test "telescope config guards node_modules extension with pcall" {
  run grep -n "pcall(telescope.load_extension, 'node_modules')" lua/config/telescope.lua
  [ "$status" -eq 0 ]
}

@test "telescope config does not use trouble v1 open_with_trouble" {
  run grep -n "open_with_trouble" lua/config/telescope.lua
  [ "$status" -eq 1 ]
}

@test "which-key config uses wk.add for group registration" {
  run grep -n "wk.add" lua/config/which-key.lua
  [ "$status" -eq 0 ]
}

@test "which-key config registers Leader f group as Find" {
  run grep -n "Leader>f" lua/config/which-key.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"Find"* ]]
}

@test "which-key config registers Leader d group as Diagnostics" {
  run grep -n "Leader>d" lua/config/which-key.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"Diagnostics"* ]]
}

@test "keymaps cheatsheet documents leader key and how to change it" {
  run grep -n "mapleader" docs/keymaps.md
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader? for telescope keymaps picker" {
  run grep -n 'Leader>?' lua/keymaps.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"telescope.builtin"* ]]
  [[ "$output" == *"keymaps"* ]]
}

@test "keymaps cheatsheet documents Leader?" {
  run grep -n 'Leader>?' docs/keymaps.md
  [ "$status" -eq 0 ]
}

@test "bufferline config uses neo-tree filetype offset" {
  run grep -n "neo-tree" lua/config/bufferline.lua
  [ "$status" -eq 0 ]
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

@test "readme documents tmux config role for neovim in byobu" {
  run grep -in "byobu\|tmux" README.md
  [ "$status" -eq 0 ]
}

@test "readme documents install tmux command" {
  run grep -n "install tmux" README.md
  [ "$status" -eq 0 ]
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

@test "readme documents node as managed via nvm" {
  run grep -n "nvm" README.md
  [ "$status" -eq 0 ]
}

@test "readme documents --with-node flag for node bootstrap" {
  run grep -n "\-\-with-node" README.md
  [ "$status" -eq 0 ]
}
