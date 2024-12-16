{
  inputs,
  pkgs,
  lib,
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
    # package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
    extraPackages = with pkgs; [
      imagemagick
      nodePackages.ijavascript
      quarto
      typescript
      jq
      zf
      (pkgs.buildEnv {
        name = "combinedSdk";
        paths = [
          (with pkgs.dotnetCorePackages;
            combinePackages [
              sdk_9_0
              sdk_8_0
            ])
        ];
      })
    ];
    extraLuaPackages = ps: [
      pkgs.luajitPackages.magick
    ];
    extraPython3Packages = python-pkgs:
      with python-pkgs; [
        pytest
        prompt-toolkit
        pyperclip
      ];
    extraPlugins = with pkgs.vimPlugins;
      [
        lazygit-nvim
        ltex_extra-nvim
        vim-visual-multi
        telescope-dap-nvim
        tabout-nvim
        plenary-nvim
        vim-dadbod
        vim-dadbod-ui
        vim-dadbod-completion
        grug-far-nvim
        tiny-inline-diagnostic-nvim
        img-clip-nvim
        hover-nvim
        lsp-overloads-nvim
        grapple-nvim
        telescope-zf-native-nvim
        csv-vim
      ]
      ++ (with pkgs.vimUtils; [
        (buildVimPlugin rec {
          pname = "let-it-snow.nvim";
          version = "7ff767f7b6e787989ca73ebcdcd0dd5ea483811a";
          src = pkgs.fetchFromGitHub {
            owner = "marcussimonsen";
            repo = pname;
            rev = version;
            sha256 = "sha256-w8bNUclsaQg/fwzFLfNM4WXZwb6efnLaUYasbIxjElY=";
          };
        })
        (buildVimPlugin rec {
          pname = "roslyn.nvim";
          version = "ec4d74f55377954fb12ea038253f64db8596a741";
          src = pkgs.fetchFromGitHub {
            owner = "seblj";
            repo = pname;
            rev = version;
            sha256 = "sha256-7Nlwwu15/Ax3FpgG4/oPG4CdZfmUDK7xVv0dx+PZT1o=";
          };
        })
        (buildVimPlugin {
          pname = "tsc-nvim";
          version = "main";
          src = pkgs.fetchFromGitHub {
            owner = "dmmulroy";
            repo = "tsc.nvim";
            rev = "c37d7b3ed954e4db13814f0ed7aa2a83b2b7e9dd";
            sha256 = "sha256-ifJXtYCA04lt0z+JDWSesCPBn6OLpqnzJarK+wuo9m8=";
          };
        })
        (buildVimPlugin {
          pname = "tetris-nvim";
          version = "main";
          src = pkgs.fetchFromGitHub {
            owner = "alec-gibson";
            repo = "nvim-tetris";
            rev = "d17c99fb527ada98ffb0212ffc87ccda6fd4f7d9";
            sha256 = "sha256-+69Fq5aMMzg9nV05rZxlLTFwQmDyN5/5HmuL2SGu9xQ=";
          };
        })
        (buildVimPlugin {
          pname = "cellular-nvim";
          version = "main";
          src = pkgs.fetchFromGitHub {
            owner = "Eandrju";
            repo = "cellular-automaton.nvim";
            rev = "b7d056dab963b5d3f2c560d92937cb51db61cb5b";
            sha256 = "sha256-szbd6m7hH7NFI0UzjWF83xkpSJeUWCbn9c+O8F8S/Fg=";
          };
        })
        (buildVimPlugin {
          pname = "nerdy.nvim";
          version = "main";
          src = pkgs.fetchFromGitHub {
            owner = "2KAbhishek";
            repo = "nerdy.nvim";
            rev = "b467d6609b78d6a5f1e12cbc08fcc1ac87af20f5";
            sha256 = "sha256-k5ZmhUHGHlFuGWiviEYeHGCbXLZHY61pUnvpZgSJhPs=";
          };
        })
        (buildVimPlugin {
          pname = "pantran.nvim";
          version = "main";
          src = pkgs.fetchFromGitHub {
            owner = "potamides";
            repo = "pantran.nvim";
            rev = "250b1d8e81f83e6aff061f4c75db008c684f5971";
            sha256 = "sha256-Dtp/bIK+FA2x09xWTwIW24fY0oT+rV202YiVUwBKlpk=";
          };
        })
        (buildVimPlugin {
          pname = "easy-dotnet.nvim";
          version = "main";
          src = pkgs.fetchFromGitHub {
            owner = "GustavEikaas";
            repo = "easy-dotnet.nvim";
            rev = "db189911961d1c0644af5c5dfd5209d9869e75f7";
            sha256 = "sha256-sm9++CBRJyzz8hWqrlMEMnIN4/vuTyOG7GBeOUCNT6A=";
          };
        })
        (buildVimPlugin {
          pname = "workspace-diagnostics.nvim";
          version = "main";
          src = pkgs.fetchFromGitHub {
            owner = "artemave";
            repo = "workspace-diagnostics.nvim";
            rev = "29ed948a84076e9bed63ce298b5cc5264b72b341";
            sha256 = "sha256-i+gyx6iThmBgOoscZjhhL7HxciSwV2jsHDOo7mYDSKA=";
          };
        })
        (buildVimPlugin {
          pname = "nvim-dap-repl-highlights";
          version = "main";
          src = pkgs.fetchFromGitHub {
            owner = "LiadOz";
            repo = "nvim-dap-repl-highlights";
            rev = "a7512fc0a0de0c0be8d58983939856dda6f72451";
            sha256 = "sha256-HfIP1ZfD85l5V+Sh75CJRTQQ+HwmeAvFcjkdu8lpd4o=";
          };
        })
        (buildVimPlugin rec {
          pname = "portal.nvim";
          version = "77d9d53fec945bfa407d5fd7120f1b4f117450ed";
          src = pkgs.fetchFromGitHub {
            owner = "cbochs";
            repo = pname;
            rev = version;
            sha256 = "sha256-QCdyJ5in3Dm4IVlBUtbGWRZxl87gKHhRiGmZcIGEHm0=";
          };
        })
        (buildVimPlugin rec {
          pname = "vessel.nvim";
          version = "0110bd4527963b7c245a325bd871ed0fac4a951b";
          src = pkgs.fetchFromGitHub {
            owner = "gcmt";
            repo = pname;
            rev = version;
            sha256 = "sha256-luiklWgajULhCns1qoDGWKanuTd+zeBQmakmhrfqQDc=";
          };
        })
        (buildVimPlugin rec {
          pname = "dooing";
          version = "d2b307668a78c194350c8f03dbf8ef57622a765b";
          src = pkgs.fetchFromGitHub {
            owner = "atiladefreitas";
            repo = pname;
            rev = version;
            sha256 = "sha256-ZtBBOhwb9HssbOcnyv3TQ6rZ0xEZkSUMa4ckgnoRfzk=";
          };
        })
        (buildVimPlugin rec {
          pname = "smear-cursor.nvim";
          version = "76e9331f3c4cf2cc0b634d08a2438d1b40d0e424";
          src = pkgs.fetchFromGitHub {
            owner = "sphamba";
            repo = pname;
            rev = version;
            sha256 = "sha256-D1DL8gL0MTSlHnXG6+OhQRjPSwx623CVyBfY3zrU4p0=";
          };
        })
        (buildVimPlugin rec {
          pname = "focushere.nvim";
          version = "28c40c7e3481d6cd9e4c7b8005c36a18b5db7ac6";
          src = pkgs.fetchFromGitHub {
            owner = "kelvinauta";
            repo = pname;
            rev = version;
            sha256 = "sha256-2BK8oRj4Ki1aHCOlAz05y3+LMIZcJ2iVUrEdB4UrkNE=";
          };
        })
      ]);
    highlight = {
      "@type.qualifier.c_sharp".fg = "#7AA8fF";
      "@type.c_sharp".fg = "#98cb6C";
      "@struct_declaration".fg = "#aaff9C";
      "@attribute".fg = "#cb6fe2";
      "@return_statement".fg = "#eb6f92";
    };
    highlightOverride = {
      TreesitterContext.bg = "none";
      TroubleNormal.bg = "none";
      TroubleNormalNC.bg = "none";
      MiniFilesNormal.bg = "none";
      WhichKeyNormal.bg = "none";
      GrappleNormal.bg = "none";
      Pmenu = {
        fg = "#61AAC3";
        bg = "none";
      };
      Float.bg = "none";
      NormalFloat.bg = "none";
      NotifyBackground.bg = "#000000";
    };
    extraConfigVim = ''
      autocmd BufWritePre * lua vim.lsp.buf.format()
      autocmd FileType nix setlocal commentstring=#\ %s
      autocmd FileType gdscript setlocal commentstring=#\ %s
      sign define DiagnosticSignError text= numhl=DiagnosticDefaultErro
      sign define DiagnosticSignWarn text= numhl=DiagnosticDefaultWarn
      sign define DiagnosticSignInfo text= numhl=DiagnosticDefaultInfo
      sign define DiagnosticSignHint text= numhl=DiagnosticDefaultHint
      let &t_TI = "\<Esc>[>4;2m"
      let &t_TE = "\<Esc>[>4;m"

      let g:VM_maps = {}
      let g:VM_maps['Find Under']         = '<C-s>'
      let g:VM_maps['Find Subword Under'] = '<C-s>'
    '';
    extraConfigLua = ''

      require("hover").setup {
        init = function()
            -- Require providers
            require("hover.providers.lsp")
            require('hover.providers.gh')
            require('hover.providers.gh_user')
            require('hover.providers.dap')
            require('hover.providers.fold_preview')
            require('hover.providers.diagnostic')
            require('hover.providers.man')
            require('hover.providers.dictionary')
        end,
        preview_opts = {
            border = 'single'
        },
        -- Whether the contents of a currently open hover window should be moved
        -- to a :h preview-window when pressing the hover keymap.
        preview_window = false,
        title = true,
      }
      require("tsc").setup()

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
      local logPath = vim.fn.stdpath "data" .. "/easy-dotnet/build.log"
      local function populate_quickfix_from_file(filename)
        -- Open the file for reading
        local file = io.open(filename, "r")
        if not file then
          print("Could not open file " .. filename)
          return
        end

        -- Table to hold quickfix list entries
        local quickfix_list = {}

        -- Iterate over each line in the file
        for line in file:lines() do
          -- Match the pattern in the line
          local filepath, lnum, col, text = line:match("^(.+)%((%d+),(%d+)%)%: (.+)$")

          if filepath and lnum and col and text then
            -- Remove project file details from the text
            text = text:match("^(.-)%s%[.+$")

            -- Add the parsed data to the quickfix list
            table.insert(quickfix_list, {
              filename = filepath,
              lnum = tonumber(lnum),
              col = tonumber(col),
              text = text,
            })
          end
        end

        -- Close the file
        file:close()

        -- Set the quickfix list
        vim.fn.setqflist(quickfix_list)

        -- Open the quickfix window
        vim.cmd("Trouble qflist")
      end
      require("easy-dotnet").setup({
        terminal = function(path, action)
          local commands = {
            run = function()
              return "dotnet run --project " .. path
            end,
            test = function()
              return "dotnet test " .. path
            end,
            restore = function()
              return "dotnet restore " .. path
            end,
            build = function()
              return "dotnet build " .. path .. " /flp:v=q /flp:logfile=" .. logPath
            end
          }
          if action == "build" then
            local command = commands[action]() .. "\r"
            vim.notify("Build started")
            vim.fn.jobstart(command, {
              on_exit = function(_, b, _)
                if b == 0 then
                  vim.notify("Built successfully")
                else
                  vim.notify("Build failed")
                  populate_quickfix_from_file(logPath)
                end
              end,
            })
          else
            local command = commands[action]() .. "\r"
            vim.cmd("vsplit")
            vim.cmd("term " .. command)
          end
        end,
      })
      require("workspace-diagnostics").setup()
      require('nvim-dap-repl-highlights').setup()
      vim.api.nvim_create_user_command('Otter',function()
        require("otter").activate()
      end,{})
      -- See: https://github.com/jmbuhr/otter.nvim/issues/179
      -- vim.treesitter.language.register("markdown", { "quarto", "rmd" })
      require('img-clip').setup ({
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
        }
      })
      if vim.fn.filereadable(vim.fn.getcwd() .. "/project.godot") == 1 then
        local addr = "/tmp/godot.pipe"
        vim.fn.serverstart(addr)
      end
      require("vessel").setup({
        create_commands = true
      })
      require("portal").setup()
      require("grapple").setup()
      require("smear_cursor").setup({
        distance_stop_animating = 0.7,
        legacy_computing_symbols_support = true,
      })
      require('dooing').setup({
        save_path = '/home/linus/.nixos/home/todo.json'
      })
      require("grug-far").setup()
      require("focushere").setup()
      require("tiny-inline-diagnostic").setup({
        options = {
          multilines = true
        }
      })
      vim.diagnostic.config({ virtual_text = false })
      require("let-it-snow").setup({
        delay = 100
      })
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
      pumheight = 10;
      laststatus = 3;
    };
    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };
    globals = {
      mapleader = " ";
      maplocalleader = "  ";
    };
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        transparent_background = true;
        flavor = "mocha";
      };
    };
    keymaps = [
      # Misc
      {
        mode = ["n"];
        key = "<c-space>";
        action = ''<cmd>lua require("hover").hover() <cr>'';
        options.desc = "Show Hover Doc";
      }
      {
        mode = ["n"];
        key = "K";
        action = ''<cmd> lua require("hover").hover() <cr>'';
        options.desc = "Show Hover Doc";
      }
      {
        mode = ["n"];
        key = "<c-p>";
        action = ''<cmd> lua require("hover").hover_switch("next") <cr>'';
        options.desc = "Show Next Hover Doc";
      }
      {
        mode = ["n"];
        key = "<c-n>";
        action = ''<cmd> lua require("hover").hover_switch("previous") <cr>'';
        options.desc = "Show Previous Hover Doc";
      }
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
      # Focus Here
      {
        mode = "v";
        key = "<leader>zf";
        action = ":FocusHere<cr>";
      }
      {
        mode = "n";
        key = "<leader>zf";
        action = ":FocusClear<cr>";
      }
      # Rest
      {
        mode = "n";
        key = "<leader>rr";
        action = "<cmd>Rest run<cr>";
        options.desc = "Rest Run";
      }
      {
        mode = "n";
        key = "<leader>rl";
        action = "<cmd>Rest last<cr>";
        options.desc = "Rest Last";
      }
      # Grapple
      {
        mode = "n";
        key = "<leader>k";
        action = "<cmd>Grapple toggle_tags<cr>";
      }
      {
        mode = "n";
        key = "<leader>K";
        action = "<cmd>Grapple toggle<cr>";
      }
      {
        mode = "n";
        key = "<leader><leader>a";
        action = "<cmd>Grapple select index=1<cr>";
      }
      {
        mode = "n";
        key = "<leader><leader>s";
        action = "<cmd>Grapple select index=2<cr>";
      }
      {
        mode = "n";
        key = "<leader><leader>d";
        action = "<cmd>Grapple select index=3<cr>";
      }
      {
        mode = "n";
        key = "<leader><leader>f";
        action = "<cmd>Grapple select index=4<cr>";
      }
      {
        mode = "n";
        key = "<leader><leader>j";
        action = "<cmd>Grapple select index=5<cr>";
      }
      {
        mode = "n";
        key = "<leader><leader>k";
        action = "<cmd>Grapple select index=6<cr>";
      }
      {
        mode = "n";
        key = "<leader><leader>l";
        action = "<cmd>Grapple select index=7<cr>";
      }
      {
        mode = "n";
        key = "<leader><leader>;";
        action = "<cmd>Grapple select index=8<cr>";
      }
      # Portal
      {
        mode = "n";
        key = "<leader><leader>o";
        action = "<cmd>Portal jumplist backward<cr>";
      }
      {
        mode = "n";
        key = "<leader><leader>i";
        action = "<cmd>Portal jumplist forward<cr>";
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
      # Quarto
      {
        mode = "n";
        key = "<leader>qa";
        action = "<cmd> QuartoSendAbove <cr>";
        options.desc = "Quarto Send Above";
      }
      {
        mode = "n";
        key = "<leader>qA";
        action = "<cmd> QuartoSendAll <cr>";
        options.desc = "Quarto Send All";
      }
      {
        mode = "n";
        key = "<leader>qb";
        action = "<cmd> QuartoSendBelow <cr>";
        options.desc = "Quarto Send Below";
      }
      {
        mode = "n";
        key = "<leader>qq";
        action = "<cmd> QuartoSend <cr>";
        options.desc = "Quarto Send";
      }
      {
        mode = "n";
        key = "<leader>qp";
        action = "<cmd> QuartoPreview <cr>";
        options.desc = "Quarto Preview";
      }
      # Molten
      {
        mode = "n";
        key = "<leader>mi";
        action = "<cmd> MoltenInit <cr>";
        options.desc = "Molten Init";
      }
      {
        mode = "n";
        key = "<leader>me";
        action = "<cmd> MoltenEvaluateOperator <cr>";
        options.desc = "Molten Evaluate Operator";
      }
      {
        mode = "v";
        key = "<leader>me";
        action = ":<C-u>MoltenEvaluateVisual<CR>gv";
        options.desc = "Molten Evaluate Visual";
      }
      {
        mode = "n";
        key = "<leader>mr";
        action = "<cmd> MoltenReevaluateCell <cr>";
        options.desc = "Molten Reevaluate Cell";
      }
      {
        mode = "n";
        key = "<leader>mR";
        action = "<cmd> MoltenReevaluateAll <cr>";
        options.desc = "Molten Reevaluate All";
      }
      {
        mode = "n";
        key = "<leader>[m";
        action = "<cmd> MoltenNext <cr>";
        options.desc = "Molten Next Cell";
      }
      {
        mode = "n";
        key = "<leader>[m";
        action = "<cmd> MoltenPrevious <cr>";
        options.desc = "Molten Previous Cell";
      }
      {
        mode = "n";
        key = "<leader>md";
        action = "<cmd> MoltenDelete <cr>";
        options.desc = "Molten Delete";
      }
      {
        mode = "n";
        key = "<leader>mo";
        action = ":noautocmd MoltenEnterOutput<CR>";
        options.desc = "Molten Enter Output";
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
        action = ''<cmd>Dotnet build<CR>'';
        options.desc = "Dotnet Build";
      }
      {
        mode = "n";
        key = "<leader>P";
        action = ''<cmd>Dotnet run<CR>'';
        options.desc = "Dotnet Run";
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
      # Mini Files
      {
        mode = "n";
        key = "<leader>o";
        action = "<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0), false) <cr>";
        options.desc = "Mini Files";
      }
      {
        mode = "n";
        key = "<leader>O";
        action = "<cmd>lua MiniFiles.open(nil, false) <cr>";
        options.desc = "Mini Files Working Directory";
      }
      # Vessel
      {
        mode = "n";
        key = "<leader>j";
        action = "<cmd>lua require('vessel').view_buffers()<cr>";
        options.desc = "Vessel Buffers";
      }
      # Buffers
      {
        mode = "n";
        key = "<leader>B";
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
      # Telescope
      {
        mode = "n";
        key = "<leader>fa";
        action = "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <cr>";
        options.desc = "Find All";
      }
      {
        mode = "v";
        key = "<leader>gc";
        action = "<cmd>Telescope git_bcommits_range <cr>";
        options.desc = "Git Buffer Commits in Range";
      }
      {
        mode = "n";
        key = "<leader>fi";
        action = "<cmd> Telescope lsp_dynamic_workspace_symbols symbols={'Interface'} <cr>";
        options.desc = "Find Interfaces";
      }
      {
        mode = "n";
        key = "<leader>fm";
        action = "<cmd> Telescope lsp_dynamic_workspace_symbols symbols={'Method','Function'} <cr>";
        options.desc = "Find Methods";
      }
      {
        mode = "n";
        key = "<leader>fv";
        action = "<cmd> Telescope lsp_dynamic_workspace_symbols symbols='Variable' <cr>";
        options.desc = "Find Variables";
      }
      {
        mode = "n";
        key = "<leader>fu";
        action = "<cmd> Telescope undo <cr>";
        options.desc = "Find Undo";
      }
      {
        mode = "n";
        key = "<leader>fcc";
        action = "<cmd> Telescope lsp_dynamic_workspace_symbols symbols='Class' <cr>";
        options.desc = "Find Classes";
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
        key = "<leader>gH";
        action = "<cmd> DiffviewFileHistory <cr>";
        options.desc = "Git File History";
      }
      {
        mode = ["n"];
        key = "<leader>gh";
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
        action = "<cmd> Trouble diagnostics<cr>";
        options.desc = "Workspace Trouble";
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
      {
        mode = ["n"];
        key = "<leader>D";
        action.__raw = ''
          function()
            for _, client in ipairs(vim.lsp.get_clients()) do
              if vim.tbl_get(client.config, "filetypes") then
                print("loading for" .. client.name)
                require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
              end
            end
          end
        '';
        options.desc = "Populate Workspace Diagnostics";
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
        action = ":lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) <cr>";
        options.desc = "Toggle Inlay Hints";
      }
    ];
    plugins = {
      transparent.enable = true;
      dressing.enable = true;
      notify.enable = true;
      noice = {
        enable = true;
        settings = {
          notify.enabled = true;
          background_colour = "#000000";
          presets = {
            bottom_search = true;
          };
          lsp.signature.enabled = false;
        };
      };
      telescope = {
        enable = true;
        luaConfig.post = ''
          require("telescope").load_extension("zf-native")
          require('telescope').load_extension('dap')
        '';
        settings = {
          layout_strategy = "bottom_pane";
          defaults = {
            sorting_strategy = "ascending";
            layout_strategy = "bottom_pane";
            layout_config = {
              height = 25;
            };
            border = true;
            borderchars = {
              prompt = ["─" " " " " " " "─" "─" " " " "];
              results = [" "];
              preview = ["─" "│" "─" "│" "╭" "╮" "╯" "╰"];
            };
            mappings.__raw = ''
              {
                i = { ["<c-t>"] = require("trouble.sources.telescope").open },
                n = { ["<c-t>"] = require("trouble.sources.telescope").open },
              }
            '';
          };
        };
        extensions = {
          undo.enable = true;
        };
        keymaps = {
          "<leader>ff" = {
            action = "find_files";
            options = {
              desc = "Find Files";
            };
          };
          "<leader>fdv" = {
            action = "dap variables";
            options = {
              desc = "Find DAP Variables";
            };
          };
          "<leader>fdb" = {
            action = "dap list_breakpoints";
            options = {
              desc = "Find DAP Breakpoints";
            };
          };
          "<leader>fdf" = {
            action = "dap frames";
            options = {
              desc = "Find DAP Frames";
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
            action = "git_bcommits";
            mode = "n";
            options = {
              desc = "Git Buffer Commits";
            };
          };
          "<leader>gC" = {
            action = "git_commits";
            options = {
              desc = "Git Commits";
            };
          };
        };
      };
      toggleterm.enable = true;
      otter = {
        enable = true;
        settings.buffers = {
          set_filetype = true;
        };
      };
      cmp_luasnip.enable = true;
      cmp-calc.enable = true;
      cmp-dap.enable = true;
      cmp = {
        enable = true;
        settings = {
          window.completion.border = ["╭" "─" "╮" "│" "╯" "─" "╰" "│"];
          window.documentation.border = ["╭" "─" "╮" "│" "╯" "─" "╰" "│"];
          formatting = {
            format = ''
              function(entry, vim_item)
                 local kind_icons = {
                   Text = "",
                   Method = "󰡱",
                   Function = "󰊕",
                   Constructor = "",
                   Enum = "",
                   Class = "",
                   Struct = "",
                   Variable = "",
                   Keyword = "󰄛",
                   Field = "",
                   Property = "",
                   Snippet = "",
                   Value = "",
                 }
                 local lspkind_ok, lspkind = pcall(require, "lspkind")
                 if not lspkind_ok then
                   vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatenates the icons with the name of the item kind
                   return vim_item
                 else
                   return lspkind.cmp_format()(entry, vim_item)
                 end
               end
            '';
          };
          sources = [
            {
              name = "luasnip";
              groupIndex = 2;
            }
            {
              name = "nvim_lsp";
              groupIndex = 2;
            }
            {
              name = "path";
              groupIndex = 2;
            }
            {
              name = "calc";
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
            "<CR>" = "cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace })";
            "<S-Tab>" = ''
              function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
              end
            '';
            "<Tab>" = ''
              function(fallback)
                  luasnip = require("luasnip")
                  if cmp.visible() then
                      cmp.select_next_item()
                  elseif luasnip.expand_or_locally_jumpable() then
                      luasnip.expand_or_jump()
                  else
                      fallback()
                  end
              end
            '';
          };
        };
      };
      octo = {
        enable = true;
      };
      copilot-chat = {
        enable = true;
        settings = {
          prompts = {
            Explain = "Explain how it works.";
            Review = "Review the following code and provide concise suggestions.";
            Tests = "Briefly explain how the selected code works, then generate unit tests.";
            Refactor = "Refactor the code to improve clarity and readability.";
            Documentation = "Create a docstring for the code in the appropriate format.";
            CommitStaged = {
              prompt = ''Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.'';
              selection = ''
                function(source)
                  return require("CopilotChat.select").gitdiff(source, true)
                end,
              '';
            };
          };
        };
      };
      markdown-preview.enable = true;
      web-devicons.enable = true;
      vim-surround.enable = true;
      trouble = {
        enable = true;
        settings = {
          modes = {
            lsp_references = {
              auto_refresh = false;
            };
          };
        };
      };
      undotree.enable = true;
      avante = {
        enable = true;
        settings = {
          provider = "copilot";
          copilot = {
            model = "claude-3.5-sonnet";
          };
          behaviour = {
            auto_suggestions = false;
          };
        };
      };
      neogen.enable = true;
      molten = {
        enable = true;
        settings = {
          virt_text_output = true;
        };
        python3Dependencies = p:
          with p; [
            pynvim
            jupyter-client
            cairosvg
            ipython
            nbformat
            pillow
            plotly
            ipykernel
            requests
            pnglatex
          ];
      };
      lspsaga = {
        enable = true;
        symbolInWinbar.enable = false;
        lightbulb.enable = false;
      };
      floaterm.enable = true;
      copilot-lua = {
        enable = true;
        suggestion = {
          enabled = true;
          autoTrigger = true;
          keymap = {
            accept = "<C-f>";
          };
        };
      };
      codesnap = {
        enable = true;
        settings = {
          mac_window_bar = false;
          watermark = "hello";
        };
      };
      nvim-tree.enable = true;
      snacks = {
        enable = true;
        settings = {
          bigfile = {
            enabled = true;
          };
        };
      };
      mini = {
        enable = true;
        modules = {
          ai = {};
          files = {
            mappings = {
              go_in_plus = "<CR>";
            };
          };
          extra = {};
          icons = {};
          comment = {};
          move = {};
          operators = {
            replace = {
              prefix = "gp";
            };
          };
          pairs = {
            mappings = {
              "<" = {
                action = "open";
                pair = "<>";
                neigh_pattern = "[^\\].";
              };
              ">" = {
                action = "close";
                pair = "<>";
                neigh_pattern = "[^\\].";
              };
            };
          };
        };
      };
      nvim-colorizer.enable = true;
      flash.enable = true;
      which-key.enable = true;
      gitsigns.enable = true;
      nvim-lightbulb.enable = true;
      lualine = {
        enable = true;
        settings = {
          tabline = {
            lualine_a = [
              {
                __raw = ''
                  {
                    function()
                      local statusline = "󱐋"
                      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                          if vim.api.nvim_buf_get_option(buf, 'modified') then
                              local filename = vim.api.nvim_buf_get_name(buf):match("^.+/(.+)$")
                              local icon = MiniIcons.get("file", filename)
                              statusline = string.format("%s %s %s", statusline, icon, filename)
                          end
                      end
                      return statusline
                    end
                  }
                '';
              }
            ];
            lualine_b = [""];
            lualine_c = [""];
            lualine_x = [""];
            lualine_y = [""];
            lualine_z = [
              "filename"
            ];
          };
          sections = {
            lualine_a = [
              "branch"
            ];
            lualine_b = [
              {
                __raw = ''
                  {
                    function()
                      local on = {
                       "󰎤", "󰎧", "󰎪","󰎭","󰎱","󰎳", "󰎶", "󰎹"
                      }
                      local off = {
                       "󰎦", "󰎩", "󰎬", "󰎮", "󰎰","󰎵", "󰎸", "󰎻"
                      }
                      local grapple = require("grapple")
                      local tags = grapple.tags()
                      local current = grapple.find({ buffer = 0 })

                      local statusline = ""
                      for i, tag in ipairs(tags) do
                        local filename = tag.path:match("^.+/(.+)$")
                        local icon = MiniIcons.get("file", filename)
                        if current and current.path == tag.path then
                          statusline = string.format("%s %s 󰜴 %s %s", statusline, on[i], icon, filename)
                        else
                          statusline = string.format("%s %s 󰜴 %s %s", statusline, off[i], icon, filename)
                        end
                      end
                      return statusline
                    end
                  }
                '';
              }
            ];
            lualine_c = [""];
            lualine_x = [""];
          };
        };
      };
      yazi = {
        enable = true;
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
      # fidget.enable = true;
      render-markdown = {
        enable = true;
        settings = {
          file_types = ["markdown" "Avante" "quarto"];
        };
      };
      quarto = {
        enable = true;
        settings = {
          codeRunner = {
            enabled = true;
            default_method = "molten";
            never_run = ["yaml"];
          };
        };
      };
      neotest = {
        enable = true;
        adapters = {
          python.enable = true;
          dotnet.enable = true;
          jest.enable = true;
          playwright.enable = true;
        };
      };
      image = {
        enable = true;
        backend = "ueberzug";
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
            "debugpy" = {
              command = ".venv/bin/python";
              args = ["-m" "debugpy.adapter"];
            };
          };
        };
        configurations = {
          java = [
            {
              type = "java";
              request = "attach";
              name = "Debug (Attach) - Remote";
              hostName = "0.0.0.0";
              port = 63773;
            }
          ];
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
                  return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
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
              request = "attach";
              name = "Attach Godot";
              processId.__raw = ''
                function()
                  return require('dap.utils').pick_process({
                    filter = function(proc) 
                      local is_match = string.find(proc.name, "godot4", 1, true) and string.find(proc.name, "editor-pid", 1, true)
                      if is_match then
                        if string.find(proc.name, "server", 1, true) then
                          proc.name = "Godot Server"
                        end
                        if string.find(proc.name, "client", 1, true) then
                          proc.name = "Godot Client"
                        end
                      end

                      return is_match
                    end
                  })
                end'';
            }
            {
              type = "coreclr";
              name = "Launch DLL";
              request = "launch";
              program.__raw = ''
                function()
                  return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
                end'';
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
              name = "Launch";
              request = "launch";
              type = "debugpy";
              program = ''''${file}'';
              pythonPath.__raw = ''
                function()
                  local cwd = vim.fn.getcwd()
                  if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
                    return cwd .. '/venv/bin/python'
                  elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
                    return cwd .. '/.venv/bin/python'
                  else
                    return '/usr/bin/python'
                  end
                end
              '';
            }
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
          dap-ui.enable = true;
          dap-virtual-text.enable = true;
        };
      };
      rustaceanvim = {
        enable = true;
        settings.server.on_attach = ''__lspOnAttach'';
      };
      rest.enable = true;
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
            enable = false;
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
        settings = {
          region_check_events = "InsertEnter";
          delete_check_events = "InsertLeave";
        };
      };
      friendly-snippets.enable = true;
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
          require("roslyn").setup({
            config = {
              on_attach = _M.lspOnAttach,
              capabilities = __lspCapabilities(),
              filetypes = {"cs"},
              filewatching = true,
              settings = {
                ["csharp|inlay_hints"] = {
                    csharp_enable_inlay_hints_for_implicit_object_creation = true,
                    csharp_enable_inlay_hints_for_implicit_variable_types = true,
                    csharp_enable_inlay_hints_for_lambda_parameter_types = true,
                    csharp_enable_inlay_hints_for_types = true,
                    dotnet_enable_inlay_hints_for_indexer_parameters = true,
                    dotnet_enable_inlay_hints_for_literal_parameters = true,
                    dotnet_enable_inlay_hints_for_object_creation_parameters = true,
                    dotnet_enable_inlay_hints_for_other_parameters = true,
                    dotnet_enable_inlay_hints_for_parameters = true,
                    dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
                    dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
                    dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
                },
                ["csharp|background_analysis"] = {
                  dotnet_compiler_diagnostics_scope = "fullSolution"
                },
                ["csharp|code_lens"] = {
                  dotnet_enable_references_code_lens = true,
                },
              },
            }
          })
        '';
        onAttach = ''
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          if client.server_capabilities.signatureHelpProvider then
           require('lsp-overloads').setup(client, {
            ui = {
                border = {
                "╭",
                "─",
                "╮",
                "╎",
                "╯",
                "─",
                "╰",
                "│"
                },
                offset_x = 0,
                offset_y = 0,
                floating_window_above_cur_line = true
            }
           })
           vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave' }, {
                buffer = bufnr,
                callback = vim.lsp.codelens.refresh,
            })
           vim.lsp.codelens.refresh()
          end
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
          dockerls.enable = true;
          digestif.enable = true;
          nil_ls.enable = true;
          clangd.enable = true;
          gdscript = {
            enable = true;
            package = null;
          };
          gdshader_lsp = {
            enable = true;
            package = null;
          };
          ts_ls = {
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
          svelte.enable = true;
          tailwindcss.enable = true;
          lua_ls.enable = true;
          basedpyright.enable = true;
          cssls.enable = true;
          html.enable = true;
          java_language_server.enable = true;
          phpactor.enable = true;
          eslint.enable = true;
        };
      };
      nvim-jdtls = {
        enable = true;
        data = "/home/linus/.cache/jdtls/workspace";
        configuration = "/home/linus/.cache/jdtls/config";
        initOptions = {
          bundles = [
            "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-0.50.0.jar"
          ];
        };
      };
      todo-comments = {
        enable = true;
      };
      # typescript-tools = {
      #   enable = true;
      # };
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
        settings = {
          separator = "-";
        };
      };
      zen-mode = {
        enable = true;
        settings = {
          window = {
            height = 1;
            width = 0.50;
          };
        };
      };
    };
  };
}
