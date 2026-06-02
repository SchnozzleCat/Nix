{
  inputs,
  pkgs,
  lib,
  ...
}: {
  programs.nixvim.plugins.lspconfig = {
    enable = true;
  };
  programs.nixvim.lsp = {
    inlayHints.enable = true;
    keymaps = [
      {
        action = "<CMD>LspRestart<Enter>";
        key = "<leader>lr";
      }
    ];
    servers = {
      dockerls.enable = true;
      docker_compose_language_service.enable = true;
      ruff.enable = true;
      ltex = {
        enable = true;
        config = {
          filetypes = [
            "tex"
            "markdown"
          ];

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
      };
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
      terraformls.enable = true;
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
  programs.nixvim.plugins = {
    roslyn = {
      enable = true;
      luaConfig.post = ''
        vim.lsp.config("roslyn", {
            settings = {
            },
        })

        -- Workaround for seblyng/roslyn.nvim#358: roslyn-ls 5.7+ replaced the
        -- custom `sourceGeneratedDocument/_roslyn_getText` request with the
        -- standard LSP 3.18 `workspace/textDocumentContent` method. The plugin
        -- still calls the old name, so we replace its BufReadCmd autocmd.
        vim.api.nvim_create_autocmd("VimEnter", {
            once = true,
            callback = function()
                local existing = vim.api.nvim_get_autocmds({
                    group = "roslyn.nvim",
                    event = "BufReadCmd",
                    pattern = "roslyn-source-generated://*",
                })
                for _, c in ipairs(existing) do
                    vim.api.nvim_del_autocmd(c.id)
                end
                vim.api.nvim_create_autocmd("BufReadCmd", {
                    group = "roslyn.nvim",
                    pattern = "roslyn-source-generated://*",
                    callback = function(args)
                        vim.bo[args.buf].modifiable = true
                        vim.bo[args.buf].swapfile = false
                        vim.bo[args.buf].filetype = "cs"
                        local client = vim.lsp.get_clients({ name = "roslyn", bufnr = args.buf })[1]
                            or vim.lsp.get_clients({ name = "roslyn" })[1]
                        if not client then
                            vim.wait(5000, function()
                                return next(vim.lsp.get_clients({ name = "roslyn", bufnr = args.buf })) ~= nil
                            end)
                            client = vim.lsp.get_clients({ name = "roslyn", bufnr = args.buf })[1]
                        else
                            vim.lsp.buf_attach_client(args.buf, client.id)
                        end
                        assert(client, "Must have a `roslyn` client to load roslyn source generated file")

                        local content
                        client:request("workspace/textDocumentContent", { uri = args.match }, function(err, result)
                            assert(not err, vim.inspect(err))
                            content = (result and result.text) or ""
                            if content == vim.NIL then content = "" end
                            local normalized = string.gsub(content, "\r\n", "\n")
                            local source_lines = vim.split(normalized, "\n", { plain = true })
                            vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, source_lines)
                            vim.bo[args.buf].modifiable = false
                            vim.bo[args.buf].modified = false
                        end, args.buf)
                        vim.wait(1000, function() return content ~= nil end)
                    end,
                })
            end,
        })
      '';
    };
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
            "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-0.53.1.jar"
          ];
        };
      };
    };
    typescript-tools = {
      enable = true;
    };
    treesitter = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        # indent.enable = true;
        highlight = {
          enable = true;
        };
      };
    };
    treesitter-context = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        separator = "─";
      };
      luaConfig.post = ''
        vim.api.nvim_set_hl(0, 'TreesitterContextSeparator', { bg = 'none' })
      '';
    };
  };
}
