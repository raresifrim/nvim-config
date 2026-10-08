-- ~/.config/nvim/init.lua
-- Requires Neovim 0.12+ (for vim.pack) and git.

---------------------------------------------------------------------------
-- Early settings (must run before plugins load)
---------------------------------------------------------------------------
-- Disable netrw so nvim-tree handles directories
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- True-color support (needed for catppuccin to look right)
vim.opt.termguicolors = true

---------------------------------------------------------------------------
-- Indentation
---------------------------------------------------------------------------
vim.opt.expandtab = true  -- insert spaces instead of tab characters
vim.opt.shiftwidth = 4    -- one indent level = 4 spaces
vim.opt.tabstop = 4       -- display width of a real tab character

---------------------------------------------------------------------------
-- Plugins (Neovim 0.12+ built-in manager)
---------------------------------------------------------------------------
vim.pack.add({
  'https://github.com/catppuccin/nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/nvim-tree/nvim-tree.lua',
})

---------------------------------------------------------------------------
-- Colorscheme
---------------------------------------------------------------------------
require('catppuccin').setup({
  flavour = 'mocha', -- latte, frappe, macchiato, mocha
  transparent_background = false,
})
vim.cmd.colorscheme('catppuccin')

---------------------------------------------------------------------------
-- File tree (nvim-tree)
---------------------------------------------------------------------------
require('nvim-tree').setup({
  view = {
    width = 32,
    side = 'left',
  },
  renderer = {
    group_empty = true,        -- collapse empty folders like a/b/c into one row
    highlight_git = true,
    icons = {
      show = { file = true, folder = true, folder_arrow = true, git = true },
    },
  },
  filters = {
    dotfiles = false,          -- show hidden files; press 'H' inside the tree to toggle
  },
  update_focused_file = {
    enable = true,             -- highlight the file you're currently editing
    update_root = false,
  },
  git = {
    enable = true,
    ignore = false,            -- still show git-ignored files (dimmed)
  },
  actions = {
    open_file = {
      quit_on_open = false,    -- keep tree open after opening a file
    },
  },
})

-- Auto-open the tree when launched on a directory (e.g. `nvim .`)
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('NvimTreeAutoOpen', { clear = true }),
  callback = function()
    local arg = vim.fn.argv(0)
    if arg ~= '' and vim.fn.isdirectory(arg) == 1 then
      vim.cmd.cd(arg)
      require('nvim-tree.api').tree.open()
    end
  end,
})

---------------------------------------------------------------------------
-- C / C++: don't indent inside namespaces or extern "C" blocks
---------------------------------------------------------------------------
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('CppNamespaceIndent', { clear = true }),
  pattern = { 'c', 'cpp' },
  callback = function()
    vim.opt_local.cinoptions:append('N-s,E-s')
  end,
})

---------------------------------------------------------------------------
-- Auto-indent the whole file on save
---------------------------------------------------------------------------
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('AutoIndentOnSave', { clear = true }),
  callback = function(args)
    -- Only run for these filetypes (edit the list to taste)
    local allowed = { lua = true, c = true, cpp = true, verilog = true, systemverilog = true }
    if not allowed[vim.bo[args.buf].filetype] then
      return
    end

    local view = vim.fn.winsaveview()          -- remember cursor + scroll position
    vim.cmd('silent! keepjumps normal! gg=G')  -- re-indent the entire file
    vim.fn.winrestview(view)                   -- put cursor + scroll back
  end,
})

---------------------------------------------------------------------------
-- Keymaps
---------------------------------------------------------------------------
-- File tree
vim.keymap.set('n', '<C-b>', '<Cmd>NvimTreeToggle<CR>', { desc = 'Toggle file tree' })
vim.keymap.set('n', '<leader>e', '<Cmd>NvimTreeFocus<CR>', { desc = 'Focus file tree' })

-- Save with Ctrl+S (Linux/Windows) or Cmd+S (macOS GUI, or terminal remapped to send Ctrl+S)
vim.keymap.set({ 'n', 'i', 'v' }, '<C-s>', '<Cmd>write<CR>', { desc = 'Save file' })
vim.keymap.set({ 'n', 'i', 'v' }, '<D-s>', '<Cmd>write<CR>', { desc = 'Save file' })
