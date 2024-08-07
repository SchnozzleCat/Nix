{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    netcoredbg
    roslyn-ls
    gh
    postgresql_16
  ];

  programs.nixvim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
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
      vimPlugins.telescope-dap-nvim
      vimPlugins.tabout-nvim
      vimPlugins.friendly-snippets
      vimPlugins.octo-nvim
      vimPlugins.plenary-nvim
      vimPlugins.lsp_signature-nvim
      vimPlugins.vim-dadbod
      vimPlugins.vim-dadbod-ui
      vimPlugins.vim-dadbod-completion

      (pkgs.vimUtils.buildVimPlugin {
        pname = "roslyn.nvim";
        version = "";
        src = pkgs.fetchFromGitHub {
          owner = "seblj";
          repo = "roslyn.nvim";
          rev = "100aab1f43bf15e2b9066452ea665eca94ee8888";
          sha256 = "sha256-Cq4gQbhar9GLjYt/YJBZ9OainqyxQrklYtgUVCHEQH4=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "copilotchat-nvim";
        version = "main";
        src = pkgs.fetchFromGitHub {
          owner = "jellydn";
          repo = "CopilotChat.nvim";
          rev = "4b2e631dfd7e08507dd083a18480fe71a7bf8717";
          sha256 = "sha256-ft42fmJ4sJqo8P60JO41zTyTarNGL2anpNXrHpDFbbk=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "tsc-nvim";
        version = "main";
        src = pkgs.fetchFromGitHub {
          owner = "dmmulroy";
          repo = "tsc.nvim";
          rev = "c37d7b3ed954e4db13814f0ed7aa2a83b2b7e9dd";
          sha256 = "sha256-ifJXtYCA04lt0z+JDWSesCPBn6OLpqnzJarK+wuo9m8=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "tetris-nvim";
        version = "main";
        src = pkgs.fetchFromGitHub {
          owner = "alec-gibson";
          repo = "nvim-tetris";
          rev = "d17c99fb527ada98ffb0212ffc87ccda6fd4f7d9";
          sha256 = "sha256-+69Fq5aMMzg9nV05rZxlLTFwQmDyN5/5HmuL2SGu9xQ=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "vim-mtg";
        version = "main";
        src = pkgs.fetchFromGitHub {
          owner = "yoshi1123";
          repo = "vim-mtg";
          rev = "89de946e8204f18a9c991af026223295f06633ed";
          sha256 = "sha256-qTUPXmBEHqE99I51cLfLd/3n1k2zDDy6XOoIi6CwQuU=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "cellular-nvim";
        version = "main";
        src = pkgs.fetchFromGitHub {
          owner = "Eandrju";
          repo = "cellular-automaton.nvim";
          rev = "b7d056dab963b5d3f2c560d92937cb51db61cb5b";
          sha256 = "sha256-szbd6m7hH7NFI0UzjWF83xkpSJeUWCbn9c+O8F8S/Fg=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "nerdy.nvim";
        version = "main";
        src = pkgs.fetchFromGitHub {
          owner = "2KAbhishek";
          repo = "nerdy.nvim";
          rev = "b467d6609b78d6a5f1e12cbc08fcc1ac87af20f5";
          sha256 = "sha256-k5ZmhUHGHlFuGWiviEYeHGCbXLZHY61pUnvpZgSJhPs=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "pantran.nvim";
        version = "main";
        src = pkgs.fetchFromGitHub {
          owner = "potamides";
          repo = "pantran.nvim";
          rev = "250b1d8e81f83e6aff061f4c75db008c684f5971";
          sha256 = "sha256-Dtp/bIK+FA2x09xWTwIW24fY0oT+rV202YiVUwBKlpk=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "sunglasses.nvim";
        version = "main";
        src = pkgs.fetchFromGitHub {
          owner = "miversen33";
          repo = "sunglasses.nvim";
          rev = "11896b982f39743b169bfeac9a034040bf19a2eb";
          sha256 = "sha256-PK/9yiHBg1PN8m8hc73buwHtXlGr8b6ZqnNhlAGsusE=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "yazi.nvim";
        version = "main";
        src = pkgs.fetchFromGitHub {
          owner = "mikavilpas";
          repo = "yazi.nvim";
          rev = "e239f048b8fa00e0c04d8694296855b66d2770b0";
          sha256 = "sha256-3Jx5goTfYaicljTiNCwOlw4mbDZQQ92Pql7TieqQVzY=";
        };
      })
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
      highlight TroubleNormal guibg=clear
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
          settings = {
            inlay_hints = {
              dotnet_enable_inlay_hints_for_parameters = true,
              csharp_enable_inlay_hints_for_types = true,
            }
          },
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
      require("CopilotChat").setup({
        mode = "split",
        show_help = "yes",
        prompts = {
          Explain = "Explain how it works.",
          Review = "Review the following code and provide concise suggestions.",
          Tests = "Briefly explain how the selected code works, then generate unit tests.",
          Refactor = "Refactor the code to improve clarity and readability.",
          Documentation = "Create a docstring for the code in the appropriate format.",
          CommitStaged = {
            prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
            selection = function(source)
              return require("CopilotChat.select").gitdiff(source, true)
            end,
          },
        },
      })
      require("octo").setup({
        mappings = {
          review_diff = {
            toggle_viewed = { lhs = "<leader><space><space>", desc = "toggle viewer viewed state"}
          }
        }
      })
      require("lsp_signature").setup({
        hint_enable = false
      })
      require("tsc").setup()
      require("sunglasses").setup({
          filter_percent = 0.25,
      })
      require("custom")
    '';
    opts = {
      relativenumber = true;
      number = true;
      undofile = true;
      shiftwidth = 2;
      tabstop = 2;
      conceallevel = 1;
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
      settings = {
        enable = {
          legacy_highlights = true;
          migrations = true;
          terminal = false;
        };
        dark_variant = "moon";
        styles = {
          italic = false;
          transparency = true;
        };
      };
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
        options.desc = "Dotnet Build";
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
        key = "<leader>N";
        action = "<cmd> NvimTreeToggle <cr>";
        options.desc = "LF";
      }
      {
        mode = "n";
        key = "<leader>n";
        action = ''<cmd>lua require("yazi").yazi()<cr>'';
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
        action = "<cmd> DiffviewOpen <cr>";
        options.desc = "Git Diff";
      }
      {
        mode = ["n"];
        key = "<leader>gh";
        action = "<cmd> DiffviewFileHistory <cr>";
        options.desc = "Git File History";
      }
      {
        mode = ["n"];
        key = "<leader>gfh";
        action = "<cmd> DiffviewFileHistory % <cr>";
        options.desc = "Git Current File History";
      }
      {
        mode = ["n"];
        key = "]h";
        action = "<cmd> Gitsigns next_hunk <cr> <cmd> Gitsigns preview_hunk_inline <cr>";
        options.desc = "Next Hunk";
      }
      {
        mode = ["n"];
        key = "[h";
        action = "<cmd> Gitsigns prev_hunk <cr> <cmd> Gitsigns preview_hunk_inline <cr>";
        options.desc = "Previous Hunk";
      }
      {
        mode = ["n"];
        key = "<leader>hs";
        action = "<cmd> Gitsigns stage_hunk <cr>";
        options.desc = "Stage Hunk";
      }
      {
        mode = ["n"];
        key = "<leader>hr";
        action = "<cmd> Gitsigns reset_hunk <cr>";
        options.desc = "Reset Hunk";
      }
      {
        mode = ["n"];
        key = "<leader>hu";
        action = "<cmd> Gitsigns undo_stage_hunk <cr>";
        options.desc = "Undo Stage Hunk";
      }
      # Copilot
      {
        mode = ["v"];
        key = "<leader>cc";
        action = ":CopilotChatInPlace <cr>";
        options.desc = "Copilot Chat";
      }
      {
        mode = ["v"];
        key = "<leader>cd";
        action = ":CopilotChatVsplitVisual write documentation in correct format and nothing else<cr><c-l>";
        options.desc = "Write Documentation";
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
        key = "]]";
        action = "<cmd> Lspsaga diagnostic_jump_next <cr>";
        options.desc = "Next Diagnostic";
      }
      {
        mode = ["n"];
        key = "[[";
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
        action = ''<cmd> lua require("trouble").prev({skip_groups=true,jump=true}) <cr>'';
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
      # Obsidian
      {
        mode = ["n"];
        key = "<leader>ft";
        action = "<cmd> ObsidianTags <cr>";
        options.desc = "Obsidian Tags";
      }
      {
        mode = ["n"];
        key = "<leader>fn";
        action = "<cmd> ObsidianQuickSwitch <cr>";
        options.desc = "Obsidian Quick Switch";
      }
      {
        mode = ["n"];
        key = "<leader>fzw";
        action = "<cmd> ObsidianSearch <cr>";
        options.desc = "Obsidian Search";
      }
      {
        mode = ["n"];
        key = "<leader>zn";
        action = "<cmd> ObsidianNew <cr>";
        options.desc = "Obsidian New";
      }
      {
        mode = ["n"];
        key = "<leader>zo";
        action = "<cmd> ObsidianOpen <cr>";
        options.desc = "Obsidian Open";
      }
      {
        mode = ["n"];
        key = "<leader>zl";
        action = "<cmd> ObsidianLinks <cr>";
        options.desc = "Obsidian Links";
      }
      {
        mode = ["n"];
        key = "<leader>zt";
        action = "<cmd> ObsidianTemplate <cr>";
        options.desc = "Obsidian Template";
      }
      {
        mode = ["n"];
        key = "<leader>zd";
        action = "<cmd> ObsidianToday <cr>";
        options.desc = "Obsidian Today";
      }
      # Misc
      {
        mode = ["n"];
        key = "<leader>hi";
        action = "lua vim.lsp.inlay_hint.enable(0, vim.lsp.inlay_hint.is_enabled()) <cr>";
        options.desc = "Toggle Inlay Hints";
      }
    ];
    plugins = {
      dressing.enable = true;
      noice = {
        enable = true;
        presets = {
          bottom_search = true;
          command_palette = true;
        };
        lsp.signature.enabled = false;
      };
      telescope = {
        enable = true;
        settings = {
          defaults = {
            mappings.__raw = ''
              {
                i = { ["<c-t>"] = require("trouble.sources.telescope").open },
                n = { ["<c-t>"] = require("trouble.sources.telescope").open },
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
            options = {
              desc = "Find Files";
            };
          };
          "<leader>fw" = {
            action = "live_grep";
            options = {
              desc = "Find Word";
            };
          };
          "<leader>fk" = {
            action = "keymaps";
            options = {
              desc = "Find Keymaps";
            };
          };
          "<leader>fs" = {
            action = "lsp_dynamic_workspace_symbols";
            options = {
              desc = "Find Symbols";
            };
          };
          "<leader>fb" = {
            action = "buffers";
            options = {
              desc = "Find Buffers";
            };
          };
          "<leader>fm" = {
            action = "marks";
            options = {
              desc = "Find Marks";
            };
          };
          "<leader>fo" = {
            action = "oldfiles";
            options = {
              desc = "Find Recent";
            };
          };
          "<leader>gs" = {
            action = "git_status";
            options = {
              desc = "Git Status";
            };
          };
          "<leader>gb" = {
            action = "git_branches";
            options = {
              desc = "Git Branches";
            };
          };
          "<leader>gc" = {
            action = "git_commits";
            options = {
              desc = "Git Commits";
            };
          };
        };
      };
      # vimtex = {
      #   enable = true;
      #   viewMethod = "zathura";
      # };
      nvim-autopairs = {
        enable = true;
      };
      # cmp_luasnip.enable = true;
      cmp = {
        enable = true;
        settings = {
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
            {
              name = "vim-dadbod-completion";
              groupIndex = 2;
            }
          ];
          snippet.expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-e>" = "cmp.mapping.close()";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          };
        };
      };
      bufferline.enable = true;
      markdown-preview.enable = true;
      surround.enable = true;
      trouble = {
        enable = true;
        settings = {
          signs = {
            error = "";
            warning = " ";
            hint = "";
            information = " ";
            other = " ";
          };
          auto_refresh = false;
        };
      };
      undotree.enable = true;
      commentary.enable = true;
      fugitive.enable = true;
      neogen.enable = true;
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
      nvim-tree.enable = true;
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
      lualine = {
        enable = true;
        sections = {
          lualine_x = [
            {
              name.__raw = ''require("noice").api.statusline.mode.get'';
              extraConfig = {cond.__raw = ''require("noice").api.statusline.mode.has'';};
              color = {fg = "#ff9e64";};
            }
          ];
        };
      };
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
        settings = {
          indent = {
            char = "▏";
          };
        };
      };
      fidget.enable = true;
      neotest = {
        enable = true;
        adapters = {
          python.enable = true;
          dotnet.enable = true;
          jest.enable = true;
          playwright.enable = true;
        };
      };
      dap = {
        enable = true;
        adapters = {
          servers = {
            "godot" = {
              host = "127.0.0.1";
              port = 6006;
            };
            "python" = {
              host = "127.0.0.1";
              port = 5678;
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
            "node" = {
              command = "node";
              args = ["/home/linus/Repositories/pina-checkout-integration-exploration/vscode-node-debug2/out/src/nodeDebug.js"];
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
                  return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
                end'';
            }
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
              program.__raw = ''
                function()
                  local path = '/home/linus/.nix-profile/bin/godot4-mono-schnozzlecat'
                  vim.notify(path)
                  return path
                end
              '';
            }
            {
              type = "coreclr";
              request = "attach";
              name = "Attach";
              processId.__raw = ''
                function()
                  return require('dap.utils').pick_process()
                end'';
            }
          ];
          python = [
            {
              name = "Attach";
              type = "python";
              request = "attach";
              port = 5678;
              host = "localhost";
              pathMappings = [
                {
                  localRoot = "\${workspaceFolder}";
                  remoteRoot = ".";
                }
              ];
            }
            {
              name = "Launch";
              request = "launch";
              type = "python";
              program.__raw = ''
                function()
                  local path = '/home/linus/.nix-profile/bin/godot4-mono-schnozzlecat'
                  vim.notify(path)
                  return path
                end
              '';
            }
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
          dapBreakpointRejected = {
            text = "";
            texthl = "DiagnosticSignError";
          };
        };
        extensions = {
          # dap-python = {
          #   enable = true;
          #   adapterPythonPath = "/home/linus/Repositories/pina-simulation-api/backend/.venv/bin/python";
          #   customConfigurations = [
          #     {
          #       name = "Attach";
          #       type = "python";
          #       request = "attach";
          #       port = 5678;
          #       host = "localhost";
          #       pathMappings = [
          #         {
          #           localRoot = "\${workspaceFolder}";
          #           remoteRoot = ".";
          #         }
          #       ];
          #     }
          #   ];
          # };
          dap-ui.enable = true;
          dap-virtual-text.enable = true;
        };
      };
      rustaceanvim = {
        enable = true;
        settings.server.on_attach = ''__lspOnAttach'';
      };
      obsidian = {
        enable = true;
        settings = {
          note_id_func = ''
            function(title)
              -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
              -- In this case a note with the title 'My new note' will be given an ID that looks
              -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
              local suffix = ""
              if title ~= nil then
                -- If title is given, transform it into valid file name.
                suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
              else
                -- If title is nil, just add 4 random uppercase letters to the suffix.
                for _ = 1, 4 do
                  suffix = suffix .. string.char(math.random(65, 90))
                end
              end
              return tostring(os.time()) .. "-" .. suffix
            end
          '';
          ui = {
            enable = true;
          };
        };
        settings = {
          workspaces = [
            {
              name = "Obsidian Vault";
              path = "~/Repositories/ObsidianVault";
            }
          ];
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
      diffview.enable = true;
      lsp-format.enable = true;
      none-ls = {
        enable = true;
        sources = {
          code_actions = {
            gitsigns.enable = true;
          };
          diagnostics = {
            cppcheck.enable = true;
          };
          formatting = {
            alejandra.enable = true;
            black.enable = true;
            csharpier.enable = true;
            gdformat.enable = true;
            isort.enable = true;
            markdownlint.enable = true;
            prisma_format.enable = true;
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
          nil-ls.enable = true;
          # omnisharp.enable = true;
          clangd.enable = true;
          gdscript.enable = true;
          svelte.enable = true;
          tailwindcss.enable = true;
          lua-ls.enable = true;
          pyright.enable = true;
          cssls.enable = true;
          html.enable = true;
          java-language-server.enable = true;
          phpactor.enable = true;
          tsserver = {
            enable = true;
            extraOptions = {
              init_options = {
                preferences = {
                  includeInlayParameterNameHints = "all";
                  includeInlayParameterNameHintsWhenArgumentMatchesName = true;
                  includeInlayFunctionParameterTypeHints = true;
                  includeInlayVariableTypeHints = true;
                  includeInlayPropertyDeclarationTypeHints = true;
                  includeInlayFunctionLikeReturnTypeHints = true;
                  includeInlayEnumMemberValueHints = true;
                  importModuleSpecifierPreference = "non-relative";
                };
              };
            };
          };
          eslint.enable = true;
        };
      };
      treesitter = {
        settings = {
          indent.enable = true;
          highlight = {
            enable = true;
          };
        };
        enable = true;
      };
      treesitter-context = {
        enable = true;
      };
    };
  };
}
