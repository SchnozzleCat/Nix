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
    ];
    extraLuaPackages = ps: [
      pkgs.luajitPackages.magick
    ];
    extraPython3Packages = python-pkgs: [
      python-pkgs.pytest
      python-pkgs.python-dotenv
      python-pkgs.pynvim
      python-pkgs.prompt-toolkit
      python-pkgs.requests
      python-pkgs.jupyter_client
      python-pkgs.ipython
      python-pkgs.cairosvg
      python-pkgs.pnglatex
      python-pkgs.plotly
      python-pkgs.pyperclip
      python-pkgs.nbformat
      python-pkgs.pillow
      python-pkgs.pandas
      python-pkgs.numpy
      python-pkgs.matplotlib
      python-pkgs.packaging
      python-pkgs.jupyter
      python-pkgs.ipykernel
      python-pkgs.kaleido
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
      vimPlugins.vim-dadbod
      vimPlugins.vim-dadbod-ui
      vimPlugins.vim-dadbod-completion
      vimPlugins.quarto-nvim
      # vimPlugins.render-markdown
      avante-nvim

      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "img-clip.nvim";
        version = "28a32d811d69042f4fa5c3d5fa35571df2bc1623";
        src = pkgs.fetchFromGitHub {
          owner = "HakonHarnes";
          repo = pname;
          rev = version;
          sha256 = "sha256-TTfRow1rrRZ3+5YPeYAQc+2fsb42wUxTMEr6kfUiKXo=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "roslyn.nvim";
        version = "ec4d74f55377954fb12ea038253f64db8596a741";
        src = pkgs.fetchFromGitHub {
          owner = "seblj";
          repo = pname;
          rev = version;
          sha256 = "sha256-7Nlwwu15/Ax3FpgG4/oPG4CdZfmUDK7xVv0dx+PZT1o=";
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
      (pkgs.vimUtils.buildVimPlugin {
        pname = "easy-dotnet.nvim";
        version = "main";
        src = pkgs.fetchFromGitHub {
          owner = "GustavEikaas";
          repo = "easy-dotnet.nvim";
          rev = "db189911961d1c0644af5c5dfd5209d9869e75f7";
          sha256 = "sha256-sm9++CBRJyzz8hWqrlMEMnIN4/vuTyOG7GBeOUCNT6A=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "workspace-diagnostics.nvim";
        version = "main";
        src = pkgs.fetchFromGitHub {
          owner = "artemave";
          repo = "workspace-diagnostics.nvim";
          rev = "29ed948a84076e9bed63ce298b5cc5264b72b341";
          sha256 = "sha256-i+gyx6iThmBgOoscZjhhL7HxciSwV2jsHDOo7mYDSKA=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "nvim-dap-repl-highlights";
        version = "main";
        src = pkgs.fetchFromGitHub {
          owner = "LiadOz";
          repo = "nvim-dap-repl-highlights";
          rev = "a7512fc0a0de0c0be8d58983939856dda6f72451";
          sha256 = "sha256-HfIP1ZfD85l5V+Sh75CJRTQQ+HwmeAvFcjkdu8lpd4o=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "telescope-dap.nvim";
        version = "main";
        src = pkgs.fetchFromGitHub {
          owner = "nvim-telescope";
          repo = "telescope-dap.nvim";
          rev = "8c88d9716c91eaef1cdea13cb9390d8ef447dbfe";
          sha256 = "sha256-P+ioBtupRvB3wcGKm77Tf/51k6tXKxJd176uupeW6v0=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        pname = "hover.nvim";
        version = "main";
        src = pkgs.fetchFromGitHub {
          owner = "lewis6991";
          repo = "hover.nvim";
          rev = "4339cbbcb572b1934c53dcb66ad4bf6a0abb7918";
          sha256 = "sha256-Q1k4ddyMlPSp2rX5CjxS70JJmRDbBHCowlu2CTuq0No=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "lsp-overloads.nvim";
        version = "v1.5.0";
        src = pkgs.fetchFromGitHub {
          owner = "Issafalcon";
          repo = "lsp-overloads.nvim";
          rev = version;
          sha256 = "sha256-6X1NC7ShT5eTpFQDUmDnsKLZV68Zwmx/NhypjjV3xZw=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "quarto-nvim";
        version = "v1.0.1";
        src = pkgs.fetchFromGitHub {
          owner = "quarto-dev";
          repo = pname;
          rev = version;
          sha256 = "sha256-o9pXTN6XSq+6VywxWxp8pE0TCjzi8Gnn7tM9gCNwtAA=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "quarto-vim";
        version = "216247339470794e74a5fda5e5515008d6dc1057";
        src = pkgs.fetchFromGitHub {
          owner = "quarto-dev";
          repo = pname;
          rev = version;
          sha256 = "sha256-HTqvZQY6TmVOWzI5N4LEaYfLg1AxWJZ6IjHhwuYQwI8=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "portal.nvim";
        version = "77d9d53fec945bfa407d5fd7120f1b4f117450ed";
        src = pkgs.fetchFromGitHub {
          owner = "cbochs";
          repo = pname;
          rev = version;
          sha256 = "sha256-QCdyJ5in3Dm4IVlBUtbGWRZxl87gKHhRiGmZcIGEHm0=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "grapple.nvim";
        version = "b41ddfc1c39f87f3d1799b99c2f0f1daa524c5f7";
        src = pkgs.fetchFromGitHub {
          owner = "cbochs";
          repo = pname;
          rev = version;
          sha256 = "sha256-Dz60583Qic2TqO3BPSHME4Q7CiweB1gQCdFNtjNoN3U=";
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

      let g:VM_maps = {}
      let g:VM_maps['Find Under']         = '<C-s>'
      let g:VM_maps['Find Subword Under'] = '<C-s>'
    '';
    extraConfigLua = ''
      vim.opt.pumheight = 10
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

      vim.keymap.set("n", "<leader>P", function()
            local clients = vim.lsp.get_clients()
            for _, value in ipairs(clients) do
              if value.name == "roslyn" then
                vim.notify("roslyn client found")
                value.rpc.request("workspace/diagnostic", { previousResultIds = {} }, function(err, result)
                  if err ~= nil then
                    print(vim.inspect(err))
                  end
                  if result ~= nil then
                    local diags = {}
                    local seen = {}
                    for _, diag in ipairs(result.items) do
                      local filepath = diag.uri:gsub("file:///", "")
                      if #diag.items > 0 then
                        for _, diag_line in ipairs(diag.items) do
                          if diag_line.severity == 1 then
                            local hash = diag_line.message .. diag_line.range.start.line .. diag_line.range.start.character
                            if seen[hash] == nil then
                              local s = {
                                text = diag_line.message,
                                lnum = diag_line.range.start.line,
                                col = diag_line.range.start.character,
                                filename = filepath
                              }
                              table.insert(diags, s)
                              seen[hash] = true
                            end
                          end
                        end
                      end
                    end
                    vim.fn.setqflist(diags)
                    vim.cmd("copen")
                  end
                end)
              end
            end
          end, { noremap = true, silent = true })

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
      require("octo").setup({
        mappings = {
          review_diff = {
            toggle_viewed = { lhs = "<leader><space><space>", desc = "toggle viewer viewed state"}
          }
        }
      })
      require("tsc").setup()
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
      require('telescope').load_extension('dap')
      vim.g.molten_image_provider = "image.nvim"
      vim.g.auto_open_output = false
      vim.g.molten_output_virt_lines = true
      vim.g.molten_virt_text_output = true
      vim.api.nvim_create_user_command('Otter',function()
        require("otter").activate()
      end,{})
      require('quarto').setup{
        lspFeatures = {
          enabled = false,
        },
        codeRunner = {
          enabled = true,
          default_method = "molten",
          never_run = { "yaml" },
        },
      }
      require('img-clip').setup ({
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
        }
      })
      --require('render-markdown').setup ({
      --  file_types = { "markdown", "Avante" },
      --})
      require('avante_lib').load()
      require('avante').setup ({
        behaviour = {
          auto_suggestions = false,
        },
        provider = "copilot",
      })
      if vim.fn.filereadable(vim.fn.getcwd() .. "/project.godot") == 1 then
        local addr = "/tmp/godot.pipe"
        vim.fn.serverstart(addr)
      end
      vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "none" })
      require("portal").setup()
      require("grapple").setup()
    '';
    opts = {
      relativenumber = true;
      number = true;
      undofile = true;
      shiftwidth = 2;
      tabstop = 2;
      # conceallevel = 1;
      expandtab = true;
      autoindent = true;
      smartindent = false;
      cursorline = true;
    };
    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };
    globals = {
      mapleader = " ";
    };
    colorschemes.nightfox = {
      enable = true;
      flavor = "duskfox";
      settings = {
        options = {
          transparent = true;
        };
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
      # Grapple
      {
        mode = "n";
        key = "<leader><leader>h";
        action = "<cmd>Grapple toggle_tags<cr>";
      }
      {
        mode = "n";
        key = "<leader>ht";
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
      cmp_luasnip.enable = true;
      toggleterm.enable = true;
      otter = {
        enable = true;
        package = pkgs.vimUtils.buildVimPlugin rec {
          pname = "otter.nvim";
          version = "v2.5.0";
          src = pkgs.fetchFromGitHub {
            owner = "jmbuhr";
            repo = pname;
            rev = version;
            sha256 = "sha256-euHwoK2WHLF/hrjLY2P4yGrIbYyBN38FL3q4CKNZmLY=";
          };
        };
        settings.buffers = {
          set_filetype = true;
        };
      };
      cmp = {
        enable = true;
        settings = {
          window.completion.border = ["╭" "╌" "╮" "╎" "╯" "╌" "╰" "╎"];
          window.documentation.border = ["╭" "╌" "╮" "╎" "╯" "╌" "╰" "╎"];
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
                   Variable = "",
                   Keyword = "󰄛"
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
              name = "nvim_lsp";
              groupIndex = 2;
            }
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
      # cmp-nvim-lsp-signature-help.enable = true;
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
      bufferline.enable = true;
      markdown-preview.enable = true;
      web-devicons.enable = true;
      vim-surround.enable = true;
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
        };
      };
      undotree.enable = true;
      commentary.enable = true;
      fugitive.enable = true;
      neogen.enable = true;
      magma-nvim = {
        enable = true;
        package = pkgs.vimPlugins.molten-nvim;
      };
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
      which-key.enable = true;
      gitsigns.enable = true;
      nvim-lightbulb.enable = true;
      lualine = {
        enable = true;
        settings.sections = {
          lualine_b.__raw = ''
            {
              {
                "grapple"
              }
            }
          '';
          lualine_x.__raw = ''
            {
              {
                require("noice").api.statusline.mode.get,
                cond = require("noice").api.statusline.mode.has,
                color = {fg = "#ff9e64"}
              }
            }
          '';
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
              request = "attach";
              name = "Attach Godot";
              processId.__raw = ''
                function()
                  return require('dap.utils').pick_process({
                    filter = function(proc) 
                      if string.match(proc.name, "godot") then
                        vim.print(proc)
                      end
                      return string.match(proc.name, "godot4") and string.match(proc.name, "--game")
                    end
                  })
                end'';
            }
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
      cmp-dap.enable = true;

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
          if client.server_capabilities.signatureHelpProvider then
           require('lsp-overloads').setup(client, {
            ui = {
                border = {
                "╭",
                "╌",
                "╮",
                "╎",
                "╯",
                "╌",
                "╰",
                "╎"
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
          ts-ls = {
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
