{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.nixvim = {
    enable = true;
    extraPlugins = with pkgs.vimPlugins; [
      vim-move
      lazygit-nvim
      ChatGPT-nvim
      ltex_extra-nvim
    ];
    extraConfigVim = ''
      autocmd BufWritePre * lua vim.lsp.buf.format()
      autocmd FileType nix setlocal commentstring=#\ %s
      sign define DiagnosticSignError text= numhl=DiagnosticDefaultErro
      sign define DiagnosticSignWarn text= numhl=DiagnosticDefaultWarn
      sign define DiagnosticSignInfo text= numhl=DiagnosticDefaultInfo
      sign define DiagnosticSignHint text= numhl=DiagnosticDefaultHint
      highlight NotifyBackground guibg=#000000
    '';
    extraConfigLua = ''
      vim.opt.pumheight = 10

      require("chatgpt").setup({
        api_key_cmd = "gpg --decrypt ${../secrets/keys/openapi.gpg}"
      })
    '';
    options = {
      number = true;
      undofile = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      autoindent = true;
      smartindent = false;
      cursorline = true;
      clipboard = "unnamedplus";
    };
    globals = {
      mapleader = " ";
    };
    colorschemes.rose-pine = {
      enable = true;
      transparentBackground = true;
      transparentFloat = true;
      style = "moon";
      disableItalics = true;
    };
    keymaps = [
      # Misc
      {
        mode = "n";
        key = "<esc>";
        action = "<cmd> noh <cr>";
      }
      {
        mode = "i";
        key = "<c-j>";
        action = "<down>";
      }
      {
        mode = "i";
        key = "<c-k>";
        action = "<up>";
      }
      {
        mode = "i";
        key = "<c-h>";
        action = "<left>";
      }
      {
        mode = "i";
        key = "<c-l>";
        action = "<right>";
      }
      # Windows
      {
        mode = "n";
        key = "<c-j>";
        action = "<c-w>j";
      }
      {
        mode = "n";
        key = "<c-k>";
        action = "<c-w>k";
      }
      {
        mode = "n";
        key = "<c-h>";
        action = "<c-w>h";
      }
      {
        mode = "n";
        key = "<c-l>";
        action = "<c-w>l";
      }
      # Floaterm
      {
        mode = "n";
        key = "<a-i>";
        action = "<cmd> FloatermToggle <cr>";
      }
      {
        mode = "t";
        key = "<a-i>";
        action = "<c-\\><c-n><cmd> FloatermToggle <cr>";
      }
      {
        mode = "t";
        key = "<C-x>";
        action = "<c-\\><c-n>";
      }
      {
        mode = "t";
        key = "<a-]>";
        action = "<cmd> FloatermNext <cr>";
      }
      {
        mode = "t";
        key = "<a-[>";
        action = "<cmd> FloatermPrev <cr>";
      }
      {
        mode = "t";
        key = "<a-d>";
        action = "<cmd> FloatermKill <cr>";
      }
      {
        mode = "t";
        key = "<a-n>";
        action = "<cmd> FloatermNew <cr>";
      }
      {
        mode = "n";
        key = "<c-n>";
        action = "<cmd> FloatermNew --height=0.8 --width=0.8 --wintype=float --name=Files lf <cr>";
      }
      # LSP
      {
        mode = "n";
        key = "gr";
        action = "<cmd> lua vim.lsp.buf.references() <cr>";
        options.desc = "LSP References";
      }
      {
        mode = "n";
        key = "gd";
        action = "<cmd> lua vim.lsp.buf.implementation() <cr>";
        options.desc = "LSP Definition";
      }
      # Buffers
      {
        mode = "n";
        key = "<leader>b";
        action = "<cmd> enew <cr>";
        options.desc = "New Buffer";
      }
      {
        key = "<leader>x";
        action = "<cmd> bd <cr>";
        options.desc = "Close Buffer";
      }
      # Bufferline
      {
        mode = "n";
        key = "<Tab>";
        action = "<cmd> BufferLineCycleNext <cr>";
        options.desc = "Next Buffer";
      }
      {
        mode = "n";
        key = "<s-Tab>";
        action = "<cmd> BufferLineCyclePrev <cr>";
        options.desc = "Previous Buffer";
      }
      # Telescope
      {
        mode = "n";
        key = "<leader>fa";
        action = "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <cr>";
        options.desc = "Find All";
      }
      {
        mode = "n";
        key = "<leader>fv";
        action = "<cmd> Telescope dap variables <cr>";
        options.desc = "Find DAP Variables";
      }
      # Move
      {
        mode = ["n" "v"];
        key = "<A-j>";
        action = "<cmd> MoveLine(1) <cr>";
        options.desc = "Move Down";
      }
      {
        mode = ["n" "v"];
        key = "<A-k>";
        action = "<cmd> MoveLine(-1) <cr>";
        options.desc = "Move Up";
      }
      # Flash
      {
        mode = ["n" "x" "o"];
        key = "s";
        action = ''<cmd> lua require("flash").jump() <cr>'';
        options.desc = "Flash Jump";
      }
      {
        mode = ["n" "x" "o"];
        key = "S";
        action = ''<cmd> lua require("flash").treesitter() <cr>'';
        options.desc = "Flash Treesitter";
      }
      {
        mode = ["o"];
        key = "r";
        action = ''<cmd> lua require("flash").remote() <cr>'';
        options.desc = "Flash Remote";
      }
      {
        mode = ["x" "o"];
        key = "R";
        action = ''<cmd> lua require("flash").treesitter_search({ remote_op={restore=true,motion=true}}) <cr>'';
        options.desc = "Flash Treesitter Search";
      }
      # Undotree
      {
        mode = ["n"];
        key = "<leader>u";
        action = "<cmd> UndotreeToggle <cr>";
        options.desc = "Flash Treesitter";
      }
      # Gitsigns
      {
        mode = ["n"];
        key = "<leader>gd";
        action = "<cmd> Gitsigns diffthis <cr>";
        options.desc = "Git Diff";
      }
      # LSP Saga
      {
        mode = ["n"];
        key = "<c-space>";
        action = "<cmd> Lspsaga hover_doc <cr>";
        options.desc = "Show Hover Doc";
      }
      {
        mode = ["n"];
        key = "<leader>ca";
        action = "<cmd> Lspsaga code_action <cr>";
        options.desc = "Show Code Actions";
      }
      {
        mode = ["n"];
        key = "]d";
        action = "<cmd> Lspsaga diagnostic_jump_next <cr>";
        options.desc = "Next Diagnostic";
      }
      {
        mode = ["n"];
        key = "[d";
        action = "<cmd> Lspsaga diagnostic_jump_prev <cr>";
        options.desc = "Previous Diagnostic";
      }
      # Trouble
      {
        mode = ["n"];
        key = "<leader>tt";
        action = "<cmd> TroubleToggle <cr>";
        options.desc = "Toggle Trouble";
      }
      {
        mode = ["n"];
        key = "<leader>tw";
        action = "<cmd> TroubleToggle workspace_diagnostics<cr>";
        options.desc = "Workspace Trouble";
      }
      {
        mode = ["n"];
        key = "<leader>td";
        action = "<cmd> TroubleToggle document_diagnoostics<cr>";
        options.desc = "Document Trouble";
      }
      {
        mode = ["n"];
        key = "<leader>tq";
        action = "<cmd> TroubleToggle quickfix<cr>";
        options.desc = "Toggle Trouble Quickfix";
      }
      {
        mode = ["n"];
        key = "<leader>tl";
        action = "<cmd> TroubleToggle loclist<cr>";
        options.desc = "Toggle Trouble Loclist";
      }
      # Lazygit
      {
        mode = ["n"];
        key = "<leader>gg";
        action = "<cmd> LazyGit <cr>";
        options.desc = "LazyGit";
      }
    ];
    plugins = {
      noice = {
        enable = true;
      };
      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = {
            action = "find_files";
            desc = "Find Files";
          };
          "<leader>fw" = {
            action = "live_grep";
            desc = "Find Word";
          };
          "<leader>fk" = {
            action = "keymaps";
            desc = "Find Keymaps";
          };
          "<leader>fs" = {
            action = "lsp_dynamic_workspace_symbols";
            desc = "Find Symbols";
          };
          "<leader>fb" = {
            action = "buffers";
            desc = "Find Buffers";
          };
          "<leader>fm" = {
            action = "marks";
            desc = "Find Marks";
          };
          "<leader>fo" = {
            action = "oldfiles";
            desc = "Find Recent";
          };
          "<leader>gs" = {
            action = "git_status";
            desc = "Git Status";
          };
          "<leader>gb" = {
            action = "git_branches";
            desc = "Git Branches";
          };
          "<leader>gc" = {
            action = "git_commits";
            desc = "Git Commits";
          };
        };
      };
      vimtex = {
        enable = true;
        viewMethod = "zathura";
      };
      nvim-autopairs.enable = true;
      nvim-cmp = {
        enable = true;
        sources = [
          {name = "nvim_lsp";}
          {name = "luasnip";}
          {name = "path";}
          {name = "buffer";}
        ];
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<C-Space>" = {
            action = "cmp.mapping.complete()";
            modes = ["i" "s"];
          };
          "<Tab>" = {
            action = ''
                          function(fallback)
                            if cmp.visible() then
                              if #cmp.get_entries() == 1 then
                                cmp.confirm({ select = true })
                              else
                                cmp.select_next_item()
                              end
                            else
                              fallback()
              end
                          end
            '';
            modes = ["i" "s"];
          };
          "<S-Tab>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                end
              end
            '';
            modes = ["i" "s"];
          };
        };
      };
      bufferline.enable = true;
      surround.enable = true;
      trouble = {
        enable = true;
        signs = {
          error = "";
          warning = " ";
          hint = "";
          information = " ";
          other = " ";
        };
      };
      undotree.enable = true;
      commentary.enable = true;
      lspsaga = {
        enable = true;
        lightbulb.enable = false;
      };
      floaterm.enable = true;
      notify.enable = true;
      nvim-colorizer.enable = true;
      flash.enable = true;
      which-key.enable = true;
      gitsigns.enable = true;
      nvim-lightbulb.enable = true;
      lualine.enable = true;
      alpha = {
        enable = true;
        layout = [
          {
            type = "padding";
            val = 5;
          }
          {
            opts = {
              hl = "Type";
              position = "center";
            };
            type = "text";
            val = [
              ''؜   ___       ___       ___       ___       ___       ___       ___       ___       ___    ''
              ''؜  /\  \     /\  \     /\__\     /\__\     /\  \     /\  \     /\  \     /\__\     /\  \   ''
              ''؜ /::\  \   /::\  \   /:/__/_   /:| _|_   /::\  \   _\:\  \   _\:\  \   /:/  /    /::\  \  ''
              ''؜/\:\:\__\ /:/\:\__\ /::\/\__\ /::|/\__\ /:/\:\__\ /::::\__\ /::::\__\ /:/__/    /::\:\__\ ''
              ''؜\:\:\/__/ \:\ \/__/ \/\::/  / \/|::/  / \:\/:/  / \::;;/__/ \::;;/__/ \:\  \    \:\:\/  / ''
              ''؜ \::/  /   \:\__\     /:/  /    |:/  /   \::/  /   \:\__\    \:\__\    \:\__\    \:\/  /  ''
              ''؜  \/__/     \/__/     \/__/     \/__/     \/__/     \/__/     \/__/     \/__/     \/__/   ''
              ''؜                                ___       ___       ___                                   ''
              ''؜                               /\  \     /\  \     /\  \                                  ''
              ''؜                              /::\  \   /::\  \    \:\  \                                 ''
              ''؜                             /:/\:\__\ /::\:\__\   /::\__\                                ''
              ''؜                             \:\ \/__/ \/\::/  /  /:/\/__/                                ''
              ''؜                              \:\__\     /:/  /  / /  /                                   ''
              ''؜                               \/__/     \/__/   \/__/                                    ''
              ''؜                                                                                          ''
              ''؜                                 _                                                        ''
              ''؜                                 \`*-.                                                    ''
              ''؜                                  )  _`-.                                                 ''
              ''؜                                 .  : `. .                                                ''
              ''؜                                 : _   '  \                                               ''
              ''؜                                 ; *` _.   `*-._                                          ''
              ''؜                                 `-.-'          `-.                                       ''
              ''؜                                   ;       `       `.                                     ''
              ''؜                                   :.       .        \                                    ''
              ''؜                                   . \  .   :   .-'   .                                   ''
              ''؜                                   '  `+.;  ;  '                                          ''
              ''؜                                   :  '  |    ;       ;-.                                 ''
              ''؜                                   ; '   : :`-:     _.`* ;                                ''
              ''؜                          [bug] .*' /  .*' ; .*`- +'  `*'                                 ''
              ''؜                                `*-*   `*-*  `*-*'                                        ''
            ];
          }
          {
            type = "padding";
            val = 2;
          }
        ];
      };
      indent-blankline = {
        enable = true;
        indent = {
          char = "▏";
        };
      };
      fidget.enable = true;
      dap = {
        enable = true;
      };
      luasnip = {
        enable = true;
      };
      none-ls = {
        enable = true;
        sources = {
          code_actions = {
            gitsigns.enable = true;
          };
          diagnostics = {
            luacheck.enable = true;
            flake8.enable = true;
            eslint.enable = true;
            cppcheck.enable = true;
          };
          formatting = {
            alejandra.enable = true;
            black.enable = true;
            eslint.enable = true;
            isort.enable = true;
            jq.enable = true;
            markdownlint.enable = true;
            prettier.enable = true;
            stylua.enable = true;
          };
        };
      };
      lsp = {
        enable = true;
        servers = {
          ltex = {
            enable = true;
            onAttach = {
              function = ''
                require("ltex_extra").setup {
                  load_langs = { "en-US" },
                  path = "ltex",
                  init_check = true,
                }
              '';
            };
            settings = {
              language = "en-US";
              dictionary = {
                "en-US" = ["Neovim" "ltex-ls"];
              };
              checkFrequency = "save";
            };
          };
          digestif.enable = true;
          nil_ls.enable = true;
          omnisharp.enable = true;
          clangd.enable = true;
          lua-ls.enable = true;
          pyright.enable = true;
          cssls.enable = true;
          html.enable = true;
          java-language-server.enable = true;
          tsserver.enable = true;
          eslint.enable = true;
        };
      };
      treesitter.enable = true;
    };
  };
}
