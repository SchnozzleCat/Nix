{
  inputs,
  pkgs,
  lib,
  ...
}: let
  toLzSpec = p: let
    split = builtins.filter (e: !builtins.isList e) (builtins.split "/" p.name);
    plugin = builtins.elemAt split 1;
    spec = p.spec;
  in
    if spec ? __raw
    then {__raw = spec.__raw;}
    else builtins.removeAttrs ({__unkeyed-1 = plugin;} // spec) [];
in {
  programs.nixvim.plugins = {
    lz-n = {
      enable = true;
      plugins = map toLzSpec (
        builtins.filter (p: p ? spec) (import ./extraPlugins.nix {inherit pkgs;})
      );
    };
    easy-dotnet.enable = true;
    visual-multi.enable = true;
    tiny-inline-diagnostic = {
      enable = true;
      settings = {
        virt_text = {
          priority = 8096;
        };
      };
    };
    hunk = {
      enable = true;
      autoLoad = true;
    };
    arrow = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        hide_handbook = true;
        show_icons = true;
        leader_key = "'";
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
      settings = {
        legacy_computing_symbols_support = true;
      };
      lazyLoad.settings.event = "DeferredUIEnter";
    };
    vim-dadbod.enable = true;
    vim-dadbod-ui.enable = true;
    vim-dadbod-completion.enable = true;
    fugitive.enable = true;
    dotnet = {
      enable = true;
      lazyLoad.settings.cmd = "DotnetUI";
    };
    grug-far = {
      enable = true;
      lazyLoad.settings.cmd = "GrugFar";
    };
    transparent = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };
    dressing.enable = true;
    notify = {
      enable = true;
      settings = {
        timeout = 1500;
        stages = "static";
      };
    };

    noice = {
      enable = true;
      settings = {
        notify.enabled = true;
        background_colour = "#000000";
        lsp.signature.enabled = false;
      };
    };
    otter = {
      enable = true;
    };
    blink-emoji.enable = true;
    blink-ripgrep.enable = true;
    blink-cmp = {
      enable = true;
      settings = {
        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];
        };
        signature = {
          enabled = true;
          window.border = "rounded";
        };

        cmdline = {
          completion = {
            ghost_text.enabled = false;
            menu.auto_show = false;
          };
          keymap = {
            "<C-e>" = [
              "hide"
            ];
            "<C-n>" = [
              "scroll_documentation_down"
              "fallback"
            ];
            "<C-p>" = [
              "scroll_documentation_up"
              "fallback"
            ];
            "<C-space>" = [
              "show"
              "show_documentation"
              "hide_documentation"
            ];
            "<CR>" = [
              "accept"
              "fallback"
            ];
            "<Down>" = [
              "select_next"
              "fallback"
            ];
            "<S-Tab>" = [
              "snippet_backward"
              "select_prev"
              "fallback"
            ];
            "<Tab>" = [
              "show"
              "snippet_forward"
              "select_next"
              "fallback"
            ];
            "<Up>" = [
              "select_prev"
              "fallback"
            ];
          };
        };
        completion = {
          trigger = {
            prefetch_on_insert = false;
          };
          menu = {
            border = "rounded";
          };
          documentation = {
            auto_show_delay_ms = 500;
            window.border = "rounded";
          };
          list = {
            selection = {
              preselect = false;
              auto_insert = true;
            };
          };
        };
        appearance = {
          kind_icons = {
            Text = "";
            Method = "󰡱";
            Function = "󰊕";
            Constructor = "";
            Enum = "";
            Class = "";
            Struct = "";
            Variable = "";
            Keyword = "󰄛";
            Field = "";
            Property = "";
            Snippet = "";
            Value = "";
          };
        };
        keymap = {
          "<C-e>" = [
            "hide"
          ];
          "<C-n>" = [
            "scroll_documentation_down"
            "fallback"
          ];
          "<C-p>" = [
            "scroll_documentation_up"
            "fallback"
          ];
          "<C-space>" = [
            "show"
            "show_documentation"
            "hide_documentation"
          ];
          "<CR>" = [
            "accept"
            "fallback"
          ];
          "<Down>" = [
            "select_next"
            "fallback"
          ];
          "<S-Tab>" = [
            "snippet_backward"
            "select_prev"
            "fallback"
          ];
          "<Tab>" = [
            "snippet_forward"
            "select_next"
            "fallback"
          ];
          "<Up>" = [
            "select_prev"
            "fallback"
          ];
        };
      };
    };
    copilot-chat = {
      enable = true;
      settings = {
        window = {
          border = "rounded";
          width = 0.3;
        };
        mappings = {
          accept_diff = {
            insert = "<C-y>";
            normal = "<C-y>";
          };
          close = {
            insert = "<C-c>";
            normal = "q";
          };
          jump_to_diff = {
            normal = "gj";
          };
          quickfix_diffs = {
            normal = "gq";
          };
          reset = {
            insert = "<C-n";
            normal = "<C-n>";
          };
          show_context = {
            normal = "gc";
          };
          show_diff = {
            normal = "gd";
          };
          show_help = {
            normal = "gh";
          };
          show_info = {
            normal = "gi";
          };
          submit_prompt = {
            insert = "<C-s>";
            normal = "<CR>";
          };
          toggle_sticky = {
            detail = "Makes line under cursor sticky or deletes sticky line.";
            normal = "gr";
          };
          yank_diff = {
            normal = "gy";
            register = "\"";
          };
        };
        model = "claude-3.7-sonnet";
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
    neotest = {
      enable = true;
      adapters = {
        java.enable = true;
        python.enable = true;
        dotnet.enable = true;
        jest.enable = true;
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
        providers = {
          copilot = {
            model = "gpt-4.1";
          };
        };
        system_prompt.__raw = ''
          [[
          ${import ./systemPrompt.nix}
          ]]
        '';
        behaviour = {
          auto_suggestions = false;
        };
        # rag_service = {
        #   enabled = true;
        #   host_mount.__raw = ''os.getenv("HOME")'';
        #   provider = "ollama";
        #   endpoint = "http://192.168.200.20:11434";
        # };
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
    fastaction.enable = true;
    copilot-lua = {
      enable = true;
      settings.suggestion = {
        enabled = true;
        auto_trigger = true;
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
      settings = {
        picker = {
          enabled = true;
          layout.preset = "ivy";
          formatters.file.truncate = 1000;
        };
        explorer = {
          enabled = true;
          replace_netrw = true;
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
          content = {
            filter.__raw = ''
              function(file)
                return not string.match(file.name, "%.uid$")
              end
            '';
          };
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
    gitsigns.enable = true;
    nvim-lightbulb.enable = true;
    lualine = {
      enable = true;
      lazyLoad.settings.event = "BufEnter";
      settings = {
        winbar = {
          lualine_a = [
            {
              __unkeyed-1 = "filename";
              file_status = true;
              path = 1;
            }
          ];
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
                added = {
                  fg = "#98be65";
                };
                modified = {
                  fg = "#FF8800";
                };
                removed = {
                  fg = "#ec5f67";
                };
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
                added = {
                  fg = "#98be65";
                };
                modified = {
                  fg = "#FF8800";
                };
                removed = {
                  fg = "#ec5f67";
                };
              };
            }
          ];
          lualine_z = [""];
        };
        sections = {
          lualine_a = [
            {
              __raw = ''
                {
                  function()
                    return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
                  end
                }
              '';
            }
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
                            if not string.find(filename, '.otter') then
                              local icon = MiniIcons.get("file", filename)
                              statusline = string.format("%s %s %s", statusline, icon, filename)
                            end
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
      lazyLoad.settings.ft = [
        "markdown"
        "Avante"
        "quarto"
      ];
      settings = {
        file_types = [
          "markdown"
          "Avante"
          "quarto"
        ];
      };
    };
    quarto = {
      enable = true;
      lazyLoad.settings.ft = [
        "quarto"
        "markdown"
      ];
      settings = {
        codeRunner = {
          enabled = true;
          default_method = "molten";
          never_run = ["yaml"];
        };
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
          "pwa-node" = {
            host = "localhost";
            port = "\${port}";
            executable = {
              command = "node";
              args = [
                "${pkgs.vscode-js-debug}/lib/node_modules/js-debug/dist/src/dapDebugServer.js"
                "\${port}"
              ];
            };
          };
        };
        executables = {
          "php" = {
            command = "node";
            args = [
              "/home/linus/Repositories/pina-checkout-integration-exploration/vscode-php-debug/out/phpDebug.js"
            ];
          };
          "cppdbg" = {
            id = "cppdbg";
            command = "${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7";
            options = {
              detached = false;
            };
          };
          "coreclr" = {
            command = "${pkgs.netcoredbg}/bin/netcoredbg";
            args = ["--interpreter=vscode"];
          };
          "netcoredbg" = {
            command = "${pkgs.netcoredbg}/bin/netcoredbg";
            args = ["--interpreter=vscode"];
          };
          "node" = {
            command = "node";
            args = [
              "/home/linus/Repositories/pina-checkout-integration-exploration/vscode-node-debug2/out/src/nodeDebug.js"
            ];
          };
          "debugpy" = {
            command = ".venv/bin/python";
            args = [
              "-m"
              "debugpy.adapter"
            ];
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
        typescript = [
          {
            type = "pwa-node";
            request = "launch";
            name = "Launch file";
            program = "\${file}";
            cwd = "\${workspaceFolder}";
          }
          {
            type = "pwa-node";
            request = "attach";
            name = "Attach";
            address = "localhost";
            port = 9229;
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
            stopAtEntry = false;
            args = [
              "--editor"
              "--path"
              "~/Repositories/dev"
            ];
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
    };
    dap-virtual-text.enable = true;
    dap-view.enable = true;
    rest = {
      enable = true;
      lazyLoad.settings.cmd = "Rest";
    };
    obsidian = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        legacy_commands = false;
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
    lsp-format = {
      enable = true;
      settings = {
        "csharp" = {
          exclude = [
            "roslyn"
          ];
        };
      };
    };
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
          astyle = {
            enable = true;
            settings.disabled_filetypes = ["cs"];
          };
          csharpier.enable = true;
          gdformat.enable = true;
          isort.enable = true;
          markdownlint.enable = true;
          htmlbeautifier.enable = true;
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
        vim.filetype.add {
          extension = {
            razor = 'razor',
            cshtml = 'razor',
          },
        }
        require('rzls').setup {}
        require("roslyn").setup({
          settings = {
            ["csharp|projects"] = {
                dotnet_enable_file_based_programs = true,
            },
        },
        })
      '';
      onAttach = ''
        vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave' }, {
            buffer = bufnr,
            callback = function()
              vim.defer_fn(function(timer)
                if vim.api.nvim_buf_is_valid(bufnr) then
                  vim.lsp.codelens.refresh()
                end
              end, 250)
            end
        })
        vim.lsp.codelens.refresh()
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
          filetypes = [
            "tex"
            "markdown"
          ];
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
              "en-US" = [
                "Neovim"
                "ltex-ls"
              ];
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
        jdtls.enable = true;
        svelte.enable = true;
        # tailwindcss.enable = true;
        lua_ls.enable = true;
        pyright.enable = true;
        cssls.enable = true;
        html.enable = true;
        phpactor.enable = true;
        eslint.enable = true;
      };
    };
    # java = {
    #   enable = true;
    #   settings = {
    #     jdk = {
    #       auto_install = false;
    #     };
    #     mason = {
    #       registries = {
    #       };
    #     };
    #   };
    # };
    jdtls = {
      enable = true;
      settings = {
        cmd = [
          "${pkgs.jdt-language-server}/bin/jdtls"
          "-data /home/linus/.cache/jdtls/workspace"
          "-configuration /home/linus/.cache/jdtls/config"
        ];
        rootDir.__raw = ''vim.fs.dirname(vim.fs.find({'pom.xml'}, { upward = true })[1])'';
        initOptions = {
          bundles = [
            "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-0.50.0.jar"
          ];
        };
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
