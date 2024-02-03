{
  inputs,
  outputs,
  lib,
  config,
  nix-colors,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    netcoredbg
  ];

  home.file.".config/nvim/after/queries/c_sharp/highlights.scm".text = ''
    ;; extends
    (struct_declaration
      name: (identifier) @struct_declaration)

    "return" @return_statement
  '';

  programs.nixvim = {
    enable = true;
    package = pkgs.neovim-nightly;
    extraPython3Packages = python-pkgs: [
      python-pkgs.pytest
      python-pkgs.python-dotenv
      python-pkgs.pynvim
      python-pkgs.prompt-toolkit
      python-pkgs.requests
    ];
    extraPlugins = with pkgs; [
      vimPlugins.vim-move
      vimPlugins.lazygit-nvim
      vimPlugins.ltex_extra-nvim
      vimPlugins.vim-visual-multi
      vimPlugins.neotest
      vimPlugins.neotest-python
      vimPlugins.telescope-dap-nvim
      vimPlugins.tabout-nvim
      vimPlugins.friendly-snippets
      obsidian-nvim
      roslyn-nvim
      copilotchat-nvim
    ];
    extraConfigVim = ''
      autocmd BufWritePre * lua vim.lsp.buf.format()
      autocmd FileType nix setlocal commentstring=#\ %s
      autocmd FileType gdscript setlocal commentstring=#\ %s
      sign define DiagnosticSignError text= numhl=DiagnosticDefaultErro
      sign define DiagnosticSignWarn text= numhl=DiagnosticDefaultWarn
      sign define DiagnosticSignInfo text= numhl=DiagnosticDefaultInfo
      sign define DiagnosticSignHint text= numhl=DiagnosticDefaultHint
      highlight NotifyBackground guibg=#000000
      let &t_TI = "\<Esc>[>4;2m"
      let &t_TE = "\<Esc>[>4;m"

      highlight @type.qualifier.c_sharp guifg=#7AA8fF guibg=none
      highlight @type.c_sharp guifg=#98cb6C guibg=none
      highlight @struct_declaration guifg=#aaff9C guibg=none
      highlight @attribute guifg=#cb6fe2 guibg=none
      highlight @return_statement guifg=#eb6f92 guibg=none

    '';
    extraConfigLua = ''
      vim.opt.pumheight = 10

      require("roslyn").setup({
          dotnet_cmd = "dotnet", -- this is the default
          roslyn_version = "4.9.0-3.23604.10", -- this is the default
          on_attach = __lspOnAttach,
          capabilities = __lspCapabilities(),
      })

      require("tabout").setup({
        ignore_beginning = false;
        tabouts = {
          {open = "'", close = "'"},
          {open = '"', close = '"'},
          {open = '`', close = '`'},
          {open = '(', close = ')'},
          {open = '[', close = ']'},
          {open = '{', close = '}'},
          {open = '<', close = '>'}
        }
      })

      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false }
          })
        }
      })
      require("obsidian").setup({
        workspaces = {
          {
            name = "work",
            path = "~/Repositories/ObsidianVault",
          },
        },
      })
      require("CopilotChat").setup({
        mode = "split",
        show_help = "yes",
        prompts = {
          Explain = "Explain how it works.",
          Review = "Review the following code and provide concise suggestions.",
          Tests = "Briefly explain how the selected code works, then generate unit tests.",
          Refactor = "Refactor the code to improve clarity and readability.",
        },
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
      # SnipRun
      {
        mode = "n";
        key = "<leader>rs";
        action = "<cmd> SnipRun <cr>";
        options.desc = "Run Snippet";
      }
      {
        mode = "v";
        key = "<leader>rs";
        action = ":SnipRun <cr>";
        options.desc = "Run Snippet";
      }
      {
        mode = "n";
        key = "<leader>p";
        action = '':lua vim.fn.jobstart("dotnet build", {cwd = vim.loop.cwd(), on_exit = function(job_id, data, event) print(data == 0 and "Build Succeeded" or "Build Failed") end}) <CR>'';
        options.desc = "Run Snippet";
      }
      # DAP
      {
        mode = "n";
        key = "<leader>dc";
        action = "<cmd> DapContinue <cr>";
        options.desc = "DAP Continue";
      }
      {
        mode = "n";
        key = "<leader>db";
        action = "<cmd> DapToggleBreakpoint <cr>";
        options.desc = "Toggle Breakpoint";
      }
      {
        mode = "n";
        key = "<leader>dv";
        action = ''<cmd> lua require("dapui").toggle() <cr>'';
        options.desc = "Toggle DAP UI";
      }
      {
        mode = "n";
        key = "<leader>do";
        action = "<cmd> DapStepOver <cr>";
        options.desc = "Step Over";
      }
      {
        mode = "n";
        key = "<leader>d<s-o>";
        action = "<cmd> DapStepOut <cr>";
        options.desc = "Step Out";
      }
      {
        mode = "n";
        key = "<leader>di";
        action = "<cmd> DapStepInto <cr>";
        options.desc = "Step Into";
      }
      {
        mode = "n";
        key = "<leader>dx";
        action = "<cmd> DapTerminate <cr>";
        options.desc = "DAP Terminate";
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
        options.desc = "Next Terminal";
      }
      {
        mode = "t";
        key = "<a-[>";
        action = "<cmd> FloatermPrev <cr>";
        options.desc = "Previous Terminal";
      }
      {
        mode = "t";
        key = "<a-d>";
        action = "<cmd> FloatermKill <cr>";
        options.desc = "Kill Terminal";
      }
      {
        mode = "t";
        key = "<a-n>";
        action = "<cmd> FloatermNew <cr>";
        options.desc = "New Terminal";
      }
      {
        mode = "n";
        key = "<leader>n";
        action = "<cmd> FloatermNew --height=0.8 --width=0.8 --wintype=float --name=Files lf <cr>";
        options.desc = "LF";
      }
      # Oil
      {
        mode = "n";
        key = "<leader>o";
        action = "<cmd> Oil <cr>";
        options.desc = "Oil";
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
      {
        key = "<leader>X";
        action = "<cmd> bd! <cr>";
        options.desc = "Close Buffer";
      }
      # Bufferline
      {
        mode = "n";
        key = "<c-Tab>";
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
      {
        mode = "n";
        key = "<leader>fu";
        action = "<cmd> Telescope undo <cr>";
        options.desc = "Find Undo";
      }
      {
        mode = "n";
        key = "<leader>fr";
        action = "<cmd> Telescope lsp_references <cr>";
        options.desc = "Find References";
      }
      {
        mode = "n";
        key = "<leader>fi";
        action = "<cmd> Telescope lsp_implementations <cr>";
        options.desc = "Find Implementations";
      }
      {
        mode = "n";
        key = "<leader>fd";
        action = "<cmd> Telescope lsp_definitions <cr>";
        options.desc = "Find Definitions";
      }
      {
        mode = "n";
        key = "<leader>fci";
        action = "<cmd> Telescope lsp_incoming_calls <cr>";
        options.desc = "Find Incoming Calls";
      }
      {
        mode = "n";
        key = "<leader>fco";
        action = "<cmd> Telescope lsp_outgoing_calls <cr>";
        options.desc = "Find Outgoing Calls";
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
      # NeoTest
      {
        mode = ["n"];
        key = "<leader>td";
        action = ''<cmd> lua require("neotest").run.run({strategy = "dap"}) <cr>'';
        options.desc = "debug nearest test";
      }
      {
        mode = ["n"];
        key = "<leader>tr";
        action = ''<cmd> lua require("neotest").run.run() <cr>'';
        options.desc = "debug nearest test";
      }
      {
        mode = ["n"];
        key = "<leader>tf";
        action = ''<cmd> lua require("neotest").run.run(vim.fn.expand("%")) <cr>'';
        options.desc = "debug nearest test";
      }
      # Undotree
      {
        mode = ["n"];
        key = "<leader>u";
        action = "<cmd> UndotreeToggle <cr>";
        options.desc = "Undo Tree";
      }
      # Gitsigns
      {
        mode = ["n"];
        key = "<leader>gd";
        action = "<cmd> Gitsigns diffthis <cr>";
        options.desc = "Git Diff";
      }

      # Copilot
      {
        mode = ["v"];
        key = "<leader>cc";
        action = ":CopilotChatInPlace <cr>";
        options.desc = "Copilot Chat";
      }
      {
        mode = ["n"];
        key = "<leader>ce";
        action = "<cmd> CopilotChatExplain <cr>";
        options.desc = "Copilot Explain";
      }
      {
        mode = ["n"];
        key = "<leader>cr";
        action = "<cmd> CopilotChatRefactor <cr>";
        options.desc = "Copilot Refactor";
      }
      {
        mode = ["n"];
        key = "<leader>cq";
        action = ":CopilotChat ";
        options.desc = "Copilot Question";
      }
      {
        mode = ["n"];
        key = "<leader>ct";
        action = "<cmd> CopilotChatTests <cr>";
        options.desc = "Copilot Tests";
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
        key = "<leader>ra";
        action = "<cmd> Lspsaga rename <cr>";
        options.desc = "Rename";
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
      {
        mode = ["n"];
        key = "gd";
        action = "<cmd> Trouble lsp_definitions <cr>";
        options.desc = "LSP Definition";
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
        key = "gi";
        action = "<cmd> Trouble lsp_implementations <cr>";
        options.desc = "LSP Implementations";
      }
      {
        mode = ["n"];
        key = "gr";
        action = "<cmd> Trouble lsp_references <cr>";
        options.desc = "LSP References";
      }
      {
        mode = ["n"];
        key = "]t";
        action = ''<cmd> lua require("trouble").next({skip_groups=true,jump=true}) <cr>'';
        options.desc = "Next Trouble";
      }
      {
        mode = ["n"];
        key = "[t";
        action = ''<cmd> lua require("trouble").previous({skip_groups=true,jump=true}) <cr>'';
        options.desc = "Previous Trouble";
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
        extraOptions = {
          defaults = {
            mappings.__raw = ''
              {
                i = { ["<c-t>"] = require("trouble.providers.telescope").open_with_trouble },
                n = { ["<c-t>"] = require("trouble.providers.telescope").open_with_trouble },
              }
            '';
          };
        };
        extensions = {
          undo = {
            enable = true;
          };
        };
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
      nvim-autopairs = {
        enable = true;
      };
      # cmp_luasnip.enable = true;
      nvim-cmp = {
        enable = true;
        window.completion.border = ["╭" "─" "╮" "│" "╯" "─" "╰" "│"];
        window.documentation.border = ["╭" "─" "╮" "│" "╯" "─" "╰" "│"];
        sources = [
          {
            name = "nvim_lsp";
            groupIndex = 2;
          }
          # {
          #   name = "copilot";
          #   groupIndex = 2;
          # }
          {
            name = "path";
            groupIndex = 2;
          }
          {
            name = "luasnip";
            groupIndex = 2;
          }
        ];
        snippet.expand = "luasnip";
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<C-Space>" = {
            action = "cmp.mapping.complete()";
            modes = ["i" "s"];
          };
          "<Tab>" = {
            action = ''
              function(fallback)
                      luasnip = require("luasnip")
                      if cmp.visible() then
                        cmp.select_next_item()
                      elseif luasnip.expandable() then
                        luasnip.expand()
                      elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
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
      fugitive.enable = true;
      lspsaga = {
        enable = true;
        lightbulb.enable = false;
      };
      floaterm.enable = true;
      copilot-lua = {
        enable = true;
        # panel.enabled = false;
        suggestion = {
          enabled = true;
          autoTrigger = true;
          keymap = {
            accept = "<C-f>";
          };
        };
      };
      # copilot-cmp.enable = true;
      notify.enable = true;
      oil.enable = true;
      nvim-colorizer.enable = true;
      sniprun.enable = true;
      flash.enable = true;
      harpoon = {
        enable = true;
        keymaps = {
          addFile = "<leader>hy";
          toggleQuickMenu = "<leader>hh";
          navFile = {
            "1" = "<leader><leader>a";
            "2" = "<leader><leader>s";
            "3" = "<leader><leader>d";
            "4" = "<leader><leader>f";
            "5" = "<leader><leader>j";
            "6" = "<leader><leader>k";
            "7" = "<leader><leader>l";
            "8" = "<leader><leader>;";
          };
        };
      };
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
        adapters = {
          servers = {
            "godot" = {
              host = "127.0.0.1";
              port = 6006;
            };
          };
          executables = {
            "php" = {
              command = "node";
              args = ["/home/linus/Repositories/pina-checkout-integration-exploration/vscode-php-debug/out/phpDebug.js"];
            };
            "cppdbg" = {
              command = "${pkgs.vscode-extensions.ms-vscode.cpptools}/bin/OpenDebugAD7";
            };
            "coreclr" = {
              command = "${pkgs.netcoredbg}/bin/netcoredbg";
              args = ["--interpreter=vscode"];
            };
          };
        };
        configurations = {
          php = [
            {
              type = "php";
              request = "launch";
              name = "Listen for Xdebug";
              port = 9003;
              pathMappings = {
                "/var/www/html" = ''''${workspaceFolder}'';
              };
            }
          ];
          gdscript = [
            {
              type = "godot";
              request = "launch";
              name = "Launch scene";
              project = ''''${workspaceFolder}'';
              launch_scene = true;
            }
          ];
          cpp = [
            {
              name = "Launch default file";
              type = "cppdbg";
              request = "launch";
              program.__raw = ''
                function()
                  return vim.fn.getcwd() .. "/" .. vim.fn.system "cat debug_entry"
                end
              '';
              cwd = ''''${workspaceFolder}'';
              stopAtEntry = true;
            }
            {
              name = "Launch file";
              type = "cppdbg";
              request = "launch";
              program.__raw = ''
                function()
                  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end
              '';
              cwd = ''''${workspaceFolder}'';
              stopAtEntry = true;
            }
            {
              name = "Attach to gdbserver :1234";
              type = "cppdbg";
              request = "launch";
              MIMode = "gdb";
              miDebuggerServerAddress = "localhost:1234";
              miDebuggerPath = "${pkgs.gdb}/bin/gdb";
              cwd = ''''${workspaceFolder}'';
              program.__raw = ''
                function()
                  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end
              '';
            }
          ];
          cs = [
            {
              type = "coreclr";
              name = "launch - netcoredbg";
              request = "launch";
              program.__raw = ''
                function()
                    local cwd = vim.fn.getcwd()
                    local debugPath = cwd .. '/bin/Debug/'
                    local highestVersionFolder = ""
                    local highestVersion = 0

                    -- Scan the directory for .NET version folders using ipairs
                    for _, folder in ipairs(vim.fn.readdir(debugPath)) do
                        -- Adjusted pattern matching to handle missing minor or patch versions
                        local major, minor, patch = string.match(folder, "net(%d+)%.*(%d*)%.*(%d*)")
                        major, minor, patch = tonumber(major), tonumber(minor) or 0, tonumber(patch) or 0

                        if major then
                            local version = major * 10000 + minor * 100 + patch
                            if version > highestVersion then
                                highestVersion = version
                                highestVersionFolder = folder
                            end
                        end
                    end

                    if highestVersionFolder == "" then
                        error("No .NET version folder found in " .. debugPath)
                    end

                    return debugPath .. highestVersionFolder .. '/csharp.dll'
                end
              '';
            }
            {
              name = "Godot";
              request = "launch";
              type = "coreclr";
              program = ''${pkgs.godot-4-mono}/bin/godot4-mono'';
              stopAtEntry = false;
              args = [
                "--path"
                ''''${workspaceFolder}''
              ];
            }
            # {
            #   type = "coreclr";
            #   request = "attach";
            #   name = "Attach";
            #   processId.__raw = ''require('dap.utils').pick_process({filter="godot"})'';
            # }
          ];
        };
        signs = {
          dapBreakpoint = {
            text = "";
            texthl = "DiagnosticSignError";
          };
          dapStopped = {
            text = "";
            texthl = "DiagnosticSignInfo";
          };
        };
        extensions = {
          dap-python = {
            enable = true;
          };
          dap-ui = {
            enable = true;
          };
          dap-virtual-text = {
            enable = true;
          };
        };
      };
      luasnip = {
        enable = true;
        fromVscode = [
          {
            # paths = ./friendly-snippets;
            # include = ["python"];
          }
        ];
      };
      none-ls = {
        enable = true;
        sourcesItems = [
          {__raw = ''require("null-ls").builtins.formatting.csharpier'';}
          {__raw = ''require("null-ls").builtins.formatting.gdformat'';}
        ];
        sources = {
          code_actions = {
            gitsigns.enable = true;
          };
          diagnostics = {
            luacheck.enable = true;
            flake8.enable = true;
            cppcheck.enable = true;
          };
          formatting = {
            alejandra.enable = true;
            black.enable = true;
            isort.enable = true;
            jq.enable = true;
            markdownlint.enable = true;
            prettier = {
              enable = true;
              disableTsServerFormatter = true;
            };
            phpcbf.enable = true;
            stylua.enable = true;
          };
        };
      };
      lsp = {
        enable = true;
        postConfig = ''
          _G["__lspCapabilities"] = __lspCapabilities
          _G["__lspOnAttach"] = __lspOnAttach
        '';
        onAttach = ''
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        '';
        capabilities = ''
          capabilities.textDocument.completion.completionItem = {
            documentationFormat = { "markdown", "plaintext" },
              snippetSupport = true,
              preselectSupport = true,
              insertReplaceSupport = true,
              labelDetailsSupport = true,
              deprecatedSupport = true,
              commitCharactersSupport = true,
              tagSupport = { valueSet = { 1 } },
              resolveSupport = {
                properties = {
                  "documentation",
                  "detail",
                  "additionalTextEdits",
                },
              }
          }
        '';
        servers = {
          ltex = {
            enable = true;
            filetypes = ["tex" "markdown"];
            autostart = false;
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
          # omnisharp.enable = true;
          clangd.enable = true;
          gdscript.enable = true;
          svelte.enable = true;
          lua-ls.enable = true;
          pyright.enable = true;
          cssls.enable = true;
          html.enable = true;
          java-language-server.enable = true;
          phpactor.enable = true;
          tsserver.enable = true;
          eslint.enable = true;
        };
      };
      treesitter = {
        enable = true;
        indent = true;
      };
    };
  };
}
