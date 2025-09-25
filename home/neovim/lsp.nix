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
    # postConfig = ''
    #   _G["__lspCapabilities"] = __lspCapabilities
    #   _G["__lspOnAttach"] = __lspOnAttach
    #   vim.filetype.add {
    #     extension = {
    #       razor = 'razor',
    #       cshtml = 'razor',
    #     },
    #   }
    #   require('rzls').setup {}
    #   require("roslyn").setup({
    #     settings = {
    #       ["csharp|projects"] = {
    #           dotnet_enable_file_based_programs = true,
    #       },
    #   },
    #   })
    # '';
    # onAttach = ''
    #   vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave' }, {
    #       buffer = bufnr,
    #       callback = function()
    #         vim.defer_fn(function(timer)
    #           if vim.api.nvim_buf_is_valid(bufnr) then
    #             vim.lsp.codelens.refresh()
    #           end
    #         end, 250)
    #       end
    #   })
    #   vim.lsp.codelens.refresh()
    # '';
    # capabilities = ''
    #   capabilities.textDocument.completion.completionItem = {
    #     documentationFormat = { "markdown", "plaintext" },
    #       snippetSupport = true,
    #       preselectSupport = true,
    #       insertReplaceSupport = true,
    #       labelDetailsSupport = true,
    #       deprecatedSupport = true,
    #       commitCharactersSupport = true,
    #       tagSupport = { valueSet = { 1 } },
    #       resolveSupport = {
    #         properties = {
    #           "documentation",
    #           "detail",
    #           "additionalTextEdits",
    #         },
    #       }
    #   }
    # '';
    servers = {
      dockerls.enable = true;
      docker_compose_language_service.enable = true;
      ruff.enable = true;
      ltex = {
        enable = true;
        settings = {
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
      # ts_ls = {
      #   enable = true;
      #   settings = {
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
      #   roslyn_ls = {
      #     enable = true;
      #     settings = {
      #       filetypes = [
      #         "cs"
      #         "csharp"
      #       ];
      #       settings.__raw = ''
      #         {
      #                       ["csharp|projects"] = {
      #                           dotnet_enable_file_based_programs = true,
      #                       };
      #                       ["csharp|inlay_hints"] = {
      #                           csharp_enable_inlay_hints_for_implicit_object_creation = true,
      #                           csharp_enable_inlay_hints_for_implicit_variable_types = true,
      #                       },
      #                       ["csharp|code_lens"] = {
      #                           dotnet_enable_references_code_lens = true,
      #                       },
      #                   }'';
      #       cmd.__raw = ''
      #         {
      #             vim.fn.stdpath('data') .. "/mason/bin/roslyn",
      #             '--logLevel',
      #             'Information',
      #             '--extensionLogDirectory',
      #             vim.fs.joinpath(vim.uv.os_tmpdir(), 'roslyn_ls/logs'),
      #             '--stdio',
      #           }'';
      #     };
      #   };
    };
  };
  programs.nixvim.plugins = {
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
        separator = "-";
      };
    };
  };
}
