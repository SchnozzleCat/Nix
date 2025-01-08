{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./plugins.nix
    ./keymaps.nix
  ];

  home.packages = with pkgs; [
    netcoredbg
    gh
    postgresql_16
  ];

  programs.nixvim = {
    enable = true;
    # package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
    extraPackages = with pkgs; [
      imagemagick
      # nodePackages.ijavascript
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
          version = "47d97e0a3f81b778409e742877b8b03fdf6c762d";
          src = pkgs.fetchFromGitHub {
            owner = "seblj";
            repo = pname;
            rev = version;
            sha256 = "sha256-EwVG0mLQ+Uf2MLbjUpDGC5Z76xzEorKTkAWcnnwIG8c=";
          };
        })
        # (buildVimPlugin {
        #   pname = "tsc-nvim";
        #   version = "main";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "dmmulroy";
        #     repo = "tsc.nvim";
        #     rev = "c37d7b3ed954e4db13814f0ed7aa2a83b2b7e9dd";
        #     sha256 = "sha256-ifJXtYCA04lt0z+JDWSesCPBn6OLpqnzJarK+wuo9m8=";
        #   };
        # })
        # (buildVimPlugin {
        #   pname = "tetris-nvim";
        #   version = "main";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "alec-gibson";
        #     repo = "nvim-tetris";
        #     rev = "d17c99fb527ada98ffb0212ffc87ccda6fd4f7d9";
        #     sha256 = "sha256-+69Fq5aMMzg9nV05rZxlLTFwQmDyN5/5HmuL2SGu9xQ=";
        #   };
        # })
        # (buildVimPlugin {
        #   pname = "cellular-nvim";
        #   version = "main";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "Eandrju";
        #     repo = "cellular-automaton.nvim";
        #     rev = "b7d056dab963b5d3f2c560d92937cb51db61cb5b";
        #     sha256 = "sha256-szbd6m7hH7NFI0UzjWF83xkpSJeUWCbn9c+O8F8S/Fg=";
        #   };
        # })
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
          version = "7240dcc47abcd2468d8ad1c479215301ec6c20cd";
          src = pkgs.fetchFromGitHub {
            owner = "sphamba";
            repo = pname;
            rev = version;
            sha256 = "sha256-0wRfsv34DkHiLumOSfA0EG7YZOqXnoFmyn72qxvUf0U=";
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
      -- require("tsc").setup()

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
      require("portal").setup()
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
  };
}
