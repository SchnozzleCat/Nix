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
            on_attach = function()
            end,
            settings = {
              ["csharp|inlay_hints"] = {
                  csharp_enable_inlay_hints_for_implicit_object_creation = true,
                  csharp_enable_inlay_hints_for_implicit_variable_types = true,
              },
              ["csharp|code_lens"] = {
                  dotnet_enable_references_code_lens = true,
              },
            },
        })
      '';
    };
    rzls = {
      enable = true;
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
        separator = "─";
      };
      luaConfig.post = ''
        vim.api.nvim_set_hl(0, 'TreesitterContextSeparator', { bg = 'none' })
      '';
    };
  };
}
