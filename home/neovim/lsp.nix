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
