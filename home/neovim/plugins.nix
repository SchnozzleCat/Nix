{
  inputs,
  pkgs,
  lib,
  ...
}: {
  programs.nixvim.plugins = {
    lz-n = {
      enable = true;
    };
    arrow = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        hide_handbook = true;
        show_icons = true;
        leader_key = ";";
        buffer_leader_key = "m";
        mappings = {
          edit = "e";
          delete_mode = "D";
          clear_all_items = "C";
          toggle = "'";
          open_vertical = "v";
          open_horizontal = "h";
          quit = "q";
          remove = "x";
          next_item = "]";
          prev_item = "[";
        };
        index_keys = "asdfjkl;1234567890";
      };
    };
    smear-cursor = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };
    vim-dadbod.enable = true;
    vim-dadbod-ui.enable = true;
    vim-dadbod-completion.enable = true;
    dotnet = {
      enable = true;
      lazyLoad.settings.cmd = "DotnetUI";
    };
    csvview.enable = true;
    grug-far = {
      enable = true;
      lazyLoad.settings.cmd = "GrugFar";
    };
    transparent = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };
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
    octo = {
      enable = true;
      lazyLoad.settings.cmd = "Octo";
    };
    markdown-preview.enable = true;
    web-devicons.enable = true;
    vim-surround.enable = true;
    trouble = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
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
      lazyLoad.settings.cmd = "CodeSnap";
      settings = {
        mac_window_bar = false;
        watermark = "hello";
      };
    };
    snacks = {
      enable = true;
      package = pkgs.vimPlugins.snacks-nvim.overrideAttrs (oldAttrs: {
        doCheck = false;
        src = pkgs.fetchFromGitHub {
          owner = "folke";
          repo = "snacks.nvim";
          rev = "715104d180da92c489adaa2e4f8f42941b9e4aac";
          sha256 = "sha256-HzF35jB/T0N2bQ8E3pDNl4vzrlv4q4zEiwhM+1rW8Xw=";
        };
      });
      settings = {
        picker = {
          enabled = true;
          layout.preset = "ivy";
        };
        words.enabled = true;
        zen.enabled = true;
        lazygit.enabled = true;
        indent.enabled = true;
        input.enabled = true;
        scratch.enabled = true;
        bigfile.enabled = true;
        bufdelete.enabled = true;
      };
    };
    mini = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
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
    colorizer.enable = true;
    flash = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };
    which-key = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };
    gitsigns = {
      enable = true;
      lazyLoad.settings.cmd = "Gitsigns";
    };
    nvim-lightbulb.enable = true;
    lualine = {
      enable = true;
      lazyLoad.settings.event = "BufEnter";
      settings = {
        winbar = {
          lualine_a = ["filename"];
          lualine_b = [""];
          lualine_c = [""];
          lualine_x = [""];
          lualine_y = [
            {
              __unkeyed-1 = "diff";
              symbols = {
                added = " ";
                modified = "󰝤 ";
                removed = " ";
              };
              diff_color = {
                added = {fg = "#98be65";};
                modified = {fg = "#FF8800";};
                removed = {fg = "#ec5f67";};
              };
            }
          ];
          lualine_z = [""];
        };
        inactive_winbar = {
          lualine_a = ["filename"];
          lualine_b = [""];
          lualine_c = [""];
          lualine_x = [""];
          lualine_y = [
            {
              __unkeyed-1 = "diff";
              symbols = {
                added = " ";
                modified = "󰝤 ";
                removed = " ";
              };
              diff_color = {
                added = {fg = "#98be65";};
                modified = {fg = "#FF8800";};
                removed = {fg = "#ec5f67";};
              };
            }
          ];
          lualine_z = [""];
        };
        sections = {
          lualine_a = [
            "branch"
            {
              __raw = ''
                {
                  function()
                    return " " .. #vim.fn.getbufinfo { buflisted = 1 }
                  end
                }
              '';
            }
          ];
          lualine_b = [
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
          lualine_c = [""];
          lualine_x = ["diagnostics"];
        };
      };
    };
    yazi.enable = true;
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
    # fidget.enable = true;
    render-markdown = {
      enable = true;
      lazyLoad.settings.ft = ["markdown" "Avante" "quarto"];
      settings = {
        file_types = ["markdown" "Avante" "quarto"];
      };
    };
    quarto = {
      enable = true;
      lazyLoad.settings.ft = ["quarto" "markdown"];
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
      lazyLoad.settings.cmd = "Neotest";
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
      lazyLoad.settings.ft = "rust";
      settings.server.on_attach = ''__lspOnAttach'';
    };
    rest = {
      enable = true;
      lazyLoad.settings.cmd = "Rest";
    };
    obsidian = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
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
      lazyLoad.settings.event = "DeferredUIEnter";
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
      lazyLoad.settings.event = "DeferredUIEnter";
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
      lazyLoad.settings.event = "DeferredUIEnter";
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
        # ts_ls = {
        #   enable = true;
        #   extraOptions = {
        #     init_options = {
        #       preferences = {
        #         includeInlayParameterNameHints = "all";
        #         includeInlayParameterNameHintsWhenArgumentMatchesName = true;
        #         includeInlayFunctionParameterTypeHints = true;
        #         includeInlayVariableTypeHints = true;
        #         includeInlayPropertyDeclarationTypeHints = true;
        #         includeInlayFunctionLikeReturnTypeHints = true;
        #         includeInlayEnumMemberValueHints = true;
        #         importModuleSpecifierPreference = "non-relative";
        #       };
        #     };
        #   };
        # };
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
      lazyLoad.settings.event = "DeferredUIEnter";
    };
    typescript-tools = {
      enable = true;
    };
    treesitter = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        indent.enable = true;
        highlight = {
          enable = true;
        };
      };
    };
    treesitter-context = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        separator = "-";
      };
    };
  };
}
