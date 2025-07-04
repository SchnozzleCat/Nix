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
      nodejs
      goose-cli
      quarto
      typescript
      jq
      fd
      ripgrep
      zf
      jdk
      plantuml
      imv
      (
        buildDotnetGlobalTool {
          pname = "csharpier";
          version = "1.0.0";
          executables = "csharpier";

          nugetHash = "sha256-wj+Sjvtr4/zqBdxXMM/rYHykzcn+jQ3AVakYpAa3sNU=";

          meta = with lib; {
            description = "Opinionated code formatter for C#";
            homepage = "https://csharpier.com/";
            changelog = "https://github.com/belav/csharpier/blob/main/CHANGELOG.md";
            license = licenses.mit;
            maintainers = with maintainers; [zoriya];
            mainProgram = "csharpier";
          };
        }
      )
      (pkgs.buildEnv {
        name = "combinedSdk";
        paths = [
          (with pkgs.dotnetCorePackages;
            combinePackages [
              sdk_10_0
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
        mason-nvim
        ltex_extra-nvim
        vim-visual-multi
        tabout-nvim
        plenary-nvim
        tiny-inline-diagnostic-nvim
        img-clip-nvim
        hover-nvim
        csv-vim
      ]
      ++ (with pkgs.vimUtils; [
        (buildVimPlugin rec {
          pname = "goose.nvim";
          version = "5a72d3b3f7a2a01d174100c8c294da8cd3a2aeeb";
          doCheck = false;
          src = pkgs.fetchFromGitHub {
            owner = "azorng";
            repo = pname;
            rev = version;
            sha256 = "sha256-jVWggPmdINFNVHJSCpbTZq8wKwGjldu6PNSkb7naiQE=";
          };
        })
        (buildVimPlugin rec {
          pname = "treewalker.nvim";
          version = "dbe096c40fa899487c51c56049cfaaa0e60b00f7";
          src = pkgs.fetchFromGitHub {
            owner = "aaronik";
            repo = pname;
            rev = version;
            sha256 = "sha256-wtX9ysrkfI4JWgRYZT0YQD973hGjANhm0eBn9k0b364=";
          };
        })
        (buildVimPlugin rec {
          pname = "clasp.nvim";
          version = "c3bebd9e1c4588b68dff8fff11e60874030b5170";
          src = pkgs.fetchFromGitHub {
            owner = "xzbdmw";
            repo = pname;
            rev = version;
            sha256 = "sha256-YfWhl+wrbik+hkz7lRydeoWpTTEhloOs0AgaiuT705I=";
          };
        })
        (buildVimPlugin rec {
          pname = "nvim-soil";
          version = "e0719b680f48838a749e720d23f32cc1ad906b92";
          src = pkgs.fetchFromGitHub {
            owner = "javiorfo";
            repo = pname;
            rev = version;
            sha256 = "sha256-hmp8FPRYuykfDXizyASF1x9qD+lNdcXP5ERbrCYTE98=";
          };
        })
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
          version = "21c8ff60d6e36b3938c88d81cc98096e2156d77f";
          src = pkgs.fetchFromGitHub {
            owner = "seblyng";
            repo = pname;
            rev = version;
            sha256 = "sha256-RP7FUedwfZPhEFcoE/HKqQxdbH4bVLQlE1vhj6g4lQI=";
          };
        })
        (buildVimPlugin rec {
          pname = "rzls.nvim";
          version = "f521bb17bc3be1065bc1c82b4d98ef3c473374fe";
          src = pkgs.fetchFromGitHub {
            owner = "tris203";
            repo = pname;
            rev = version;
            sha256 = "sha256-vYu1CQuAi9PX1NQIyxF2GmmFjzNpmuCArHPBMOciy50=";
          };
        })
        (buildVimPlugin {
          pname = "tsc-nvim";
          version = "main";
          doCheck = false;
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
          doCheck = false;
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
          doCheck = false;
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
          pname = "focushere.nvim";
          version = "28c40c7e3481d6cd9e4c7b8005c36a18b5db7ac6";
          src = pkgs.fetchFromGitHub {
            owner = "kelvinauta";
            repo = pname;
            rev = version;
            sha256 = "sha256-2BK8oRj4Ki1aHCOlAz05y3+LMIZcJ2iVUrEdB4UrkNE=";
          };
        })
        # (buildVimPlugin rec {
        #   pname = "quicker.nvim";
        #   version = "e4fb0b1862284757561d1d51091cdee907585948";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "stevearc";
        #     repo = pname;
        #     rev = version;
        #     sha256 = "sha256-IRE/K8gWRbLe1WWmNYklwrfBKmE+0rQs+PbAhcIIrnw=";
        #   };
        # })
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
      require("portal").setup()
      require("focushere").setup()
      require("tiny-inline-diagnostic").setup({
        options = {
          multilines = true
        }
      })
      vim.diagnostic.config({ virtual_text = false })
      require("let-it-snow").setup({
        delay = 75
      })
      -- require("quicker").setup({
      --   keys = {
      --     {
      --       ">",
      --       function()
      --         require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
      --       end,
      --       desc = "Expand quickfix context",
      --     },
      --     {
      --       "<",
      --       function()
      --         require("quicker").collapse()
      --       end,
      --       desc = "Collapse quickfix context",
      --     },
      --   },
      -- })
      require('mason').setup {
        registries = {
          'github:mason-org/mason-registry',
          'github:crashdummyy/mason-registry',
          'github:nvim-java/mason-registry'
        },
      }

      require("clasp").setup({
          pairs = { ["{"] = "}", ['"'] = '"', ["'"] = "'", ["("] = ")", ["["] = "]" },
      })

      require("soil").setup({
         image = {
            darkmode = false, -- Enable or disable darkmode
            format = "png", -- Choose between png or svg

            -- This is a default implementation of using nsxiv to open the resultant image
            -- Edit the string to use your preferred app to open the image (as if it were a command line)
            -- Some examples:
            -- return "feh " .. img
            -- return "xdg-open " .. img
            execute_to_open = function(img)
                return "imv " .. img
            end
        }
      })

      require("goose").setup({})

      require('treewalker').setup({
        highlight = true,
        highlight_duration = 250,
        highlight_group = 'CursorLine',
        jumplist = true,
      })

      -- jumping from smallest region to largest region
      vim.keymap.set({ "n", "i" }, "<c-;>",function()
          require("clasp").wrap('next')
      end)

      -- jumping from largest region to smallest region
      vim.keymap.set({ "n", "i" }, "<c-;>",function()
          require("clasp").wrap('prev')
      end)

      function pick_buffers()
        Snacks.picker.buffers({current=false})
        -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'i', true)
      end

      function explorer()
        Snacks.explorer({win={list={keys={["<ESC>"] = ""}}}, exclude={'*.uid'}})
      end

      function lsp_format(bufnr)
          vim.lsp.buf.format({
              filter = function(client)
                  -- apply whatever logic you want (in this example, we'll only use null-ls)
                  return client.name == "null-ls"
              end,
              bufnr = bufnr,
          })
      end

      vim.opt.fillchars = {
        diff = '╱',
      }

      vim.opt.diffopt = {
        'internal',
        'filler',
        'closeoff',
        'context:12',
        'algorithm:histogram',
        'linematch:200',
        'indent-heuristic',
      }
    '';
    opts = {
      showtabline = 0;
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
