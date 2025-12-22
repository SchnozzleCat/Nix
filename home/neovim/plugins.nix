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

  neotest-old = import (builtins.fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/0a1284dba699a615315997d15b49e687eac3492f.tar.gz";
    sha256 = "1zna95ji1fgfinnmxv4k4j64mpg4nhi7fgmb9q2h3sbphdx6x22v";
  }) {system = pkgs.system;};
in {
  programs.nixvim.plugins = {
    lz-n = {
      enable = true;
      plugins = map toLzSpec (
        builtins.filter (p: p ? spec) (import ./extraPlugins.nix {inherit pkgs;})
      );
    };
    csvview.enable = true;
    easy-dotnet = {
      enable = true;
      settings = {
        lsp.enabled = false;
      };
    };
    visual-multi.enable = true;
    tiny-inline-diagnostic = {
      enable = true;
      settings = {
        virt_text = {
          priority = 8096;
        };
      };
    };
    quickmath.enable = true;
    hunk = {
      enable = true;
      autoLoad = true;
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
      settings = {
        buffers = {
          write_to_disk = true;
          set_filetype = true;
        };
        extensions = {
          asm = "asm";
          bash = "sh";
          bib = "bib";
          c = "c";
          clojure = "clj";
          cpp = "cpp";
          cs = "cs";
          css = "css";
          dot = "dot";
          elixir = "ex";
          fish = "fish";
          fsharp = "fs";
          gleam = "gleam";
          go = "go";
          haskell = "hs";
          htmldjango = "htmldjango";
          html = "html";
          javascript = "js";
          json = "json";
          julia = "jl";
          lua = "lua";
          markdown = "md";
          nim = "nim";
          nix = "nix";
          ocaml = "ml";
          ojs = "js";
          php = "php";
          pyodide = "py";
          python = "py";
          roc = "roc";
          r = "R";
          ruby = "rb";
          rust = "rs";
          sh = "sh";
          sql = "sql";
          svelte = "svelte";
          swift = "swift";
          tex = "tex";
          typescript = "ts";
          typst = "typ";
          vim = "vim";
          webc = "webc";
          webr = "R";
          yaml = "yml";
          zig = "zig";
        };
      };
    };
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
          per_filetype = {
            sql = [
              "snippets"
              "dadbod"
              "buffer"
            ];
          };
          providers = {
            dadbod = {
              name = "Dadbod";
              module = "vim_dadbod_completion.blink";
            };
          };
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
    neotest = {
      enable = true;
      package = neotest-old.pkgs.vimPlugins.neotest;
      adapters = {
        java.enable = true;
        python.enable = true;
        # dotnet.enable = true;
        jest.enable = true;
      };
    };
    octo = {
      enable = true;
      lazyLoad.settings.cmd = "Octo";
    };
    markdown-preview = {
      enable = true;
      settings = {
        filetypes = [
          "markdown"
          "quarto"
          "mermaid"
        ];
      };
    };
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
    neogen.enable = true;
    molten = {
      enable = true;
      settings = {
        virt_text_output = true;
        auto_open_output = false;
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
    fastaction.enable = true;
    treesitter-textobjects.enable = true;
    sidekick = {
      enable = true;
      package = pkgs.vimPlugins.sidekick-nvim.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "folke";
          repo = "sidekick.nvim";
          rev = "v2.1.0";
          sha256 = "sha256-DsDJPDIm07Uxxah7AP2GR7D+jxya9fnsJ1OS/ia5ipw=";
        };
      });
      settings = {
        cli = {
          win = {
            keys = {
              hide_n = [
                "<c-w><c-w>"
                "blur"
              ];
            };
          };
          mux = {
            backend = "zellij";
            enabled = true;
          };
        };
      };
    };
    # lsp-signature.enable = true;
    copilot-lua = {
      enable = true;
      settings = {
        suggestion = {
          enabled = true;
          auto_trigger = true;
          keymap = {
            accept = "<C-f>";
          };
        };
      };
    };
    snacks = {
      enable = true;
      package = pkgs.vimUtils.buildVimPlugin {
        pname = "snacks.nvim";
        version = "2025-11-17";
        doCheck = false;
        src = pkgs.fetchFromGitHub {
          owner = "folke";
          repo = "snacks.nvim";
          rev = "836e07336ba523d4da480cd66f0241815393e98e";
          sha256 = "sha256-SjZIYC8X4tr0RhgNu87wQRhY6hUm2hpXoyu+snJJdL8=";
        };
      };
      settings = {
        gh = {
          enabled = true;
        };
        picker = {
          enabled = true;
          layout.preset = "ivy";
          formatters.file.truncate = 1000;
          sources = {
            gh_pr.layout.preset = "default";
            gh_diff.layout.preset = "left";
          };
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
        layout.enabled = true;
      };
      luaConfig.post = ''
        vim.api.nvim_create_autocmd('ColorScheme', {
          callback = function()
            vim.api.nvim_set_hl(0, 'SnacksPickerBorder', { bg = 'none' })
          end
        })
      '';
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
        sessions = {
          hooks = {
            pre = {
              write.__raw = ''
                function(session)
                  Dart.write_session(session["name"])
                end
              '';
            };
            post = {
              read.__raw = ''
                function(session)
                  Dart.read_session(session["name"])
                end
              '';
            };
          };
        };
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
    yazi.enable = true;
    alpha = {
      enable = true;
      settings.layout = [
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
        force = true;
        sync = true;
      };
      lspServersToEnable = [
        "null-ls"
      ];
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
    todo-comments = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };

    lualine = {
      enable = true;
      lazyLoad.settings.event = "BufEnter";
      settings = {
        winbar = {
          lualine_a = [""];
          lualine_b = [""];
          lualine_c = [""];
          lualine_x = [""];
          lualine_y = [""];
          lualine_z = [""];
        };
        inactive_winbar = {
          lualine_a = [""];
          lualine_b = [""];
          lualine_c = [""];
          lualine_x = [""];
          lualine_y = [""];
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
          lualine_c = [
            {
              __unkeyed-1 = "filename";
              file_status = true;
              path = 1;
            }
          ];

          lualine_x = ["diagnostics"];
          lualine_z = ["tabs"];
        };
      };
    };
  };
}
