{pkgs}:
with pkgs.vimPlugins; [
  {
    name = "dstein64/vim-startuptime";
    pkg = vim-startuptime;
  }
  {
    name = "A7Lavinraj/fyler.nvim";
    pkg = fyler-nvim;
    spec.after = ''
      function()
        require('fyler').setup({})
      end
    '';
  }
  {
    name = "mason-org/mason.nvim";
    pkg = mason-nvim;
    spec.event = "DeferredUIEnter";
    spec.after = ''
      function()
        require('mason').setup {
          registries = {
            'github:mason-org/mason-registry',
            'github:crashdummyy/mason-registry',
            'github:nvim-java/mason-registry'
          },
        }
      end
    '';
  }
  {
    name = "abecodes/tabout.nvim";
    pkg = tabout-nvim;
    spec.event = "DeferredUIEnter";
    spec.after = ''
      function()
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
      end
    '';
  }
  {
    name = "SchnozzleCat/hover.nvim";
    version = "da68e79bb2779b653696fad537d21541dfd8b0bd";
    hash = "sha256-KaOB5ov2Ie1sNElkkjIS6MmX6dj9f81hM5sMXblF3bs=";
    spec.event = "DeferredUIEnter";
    spec.after = ''
      function()
        require("hover").config({
          providers = {
            'hover.providers.diagnostic',
            'hover.providers.lsp',
            'hover.providers.dap',
            'hover.providers.man',
            'hover.providers.dictionary',
            'hover.providers.gh',
            'hover.providers.gh_user',
          },
          preview_opts = {
            border = 'single'
          },
          preview_window = false,
          title = true,
        })
        vim.api.nvim_set_hl(0, 'HoverSourceLine', { bg = 'none' })
        vim.api.nvim_set_hl(0, 'HoverBorder', { bg = 'none' })
      end
    '';
  }
  {
    name = "alex-popov-tech/store.nvim";
    version = "8be846e09ed4a857f13b9e6b7f4ed5354ae38056";
    hash = "sha256-CYNaM+qFcv0M5nj0aT7hhK8FAkV4mLovGnVS4Fo7x/U=";
    spec = {
      cmd = "Store";
      after = ''
        function()
        end
      '';
    };
  }
  {
    name = "aaronik/treewalker.nvim";
    pkg = treewalker-nvim;
    spec = {
      after = ''
        function()
          require('treewalker').setup({
            highlight = true,
            highlight_duration = 250,
            highlight_group = 'CursorLine',
            jumplist = true,
          })
        end
      '';
    };
  }
  {
    name = "Wansmer/symbol-usage.nvim";
    version = "e07c07dfe7504295a369281e95a24e1afa14b243";
    hash = "sha256-zWT6ZGYGpWLwuUrMlmyTIE5UZtPLX2FnywhycTxUaRQ=";
    spec = {
      after = ''
        function()
          require('symbol-usage').setup({
             vt_position = 'end_of_line'
          })
        end
      '';
    };
  }
  {
    name = "xzbdmw/clasp.nvim";
    version = "25442429aae1b1de0627f358740613f77ec57410";
    hash = "sha256-xHYEalIW54xrmqYaav9QgCqINu+Il7H9VuUEYadmJIE=";
    spec = {
      after = ''
        function()
          require("clasp").setup({
              pairs = { ["{"] = "}", ['"'] = '"', ["'"] = "'", ["("] = ")", ["["] = "]" },
          })
          vim.keymap.set({ "n", "i" }, "<c-l>",function()
              require("clasp").wrap('next')
          end)
          vim.keymap.set({ "n", "i" }, "<c-;>",function()
              require("clasp").wrap('prev')
          end)
        end
      '';
    };
  }
  {
    name = "seblyng/roslyn.nvim";
    version = "0c4a6f5b64122b51a64e0c8f7aae140ec979690e";
    hash = "sha256-tZDH6VDRKaRaoSuz3zyeN/omoAwOf5So8PGUXHt2TLk=";
    spec.after = ''
      function()
        require("roslyn").setup({})
        vim.lsp.config("roslyn", {
            filetypes = { "cs" },
            settings = {
                ["csharp|projects"] = {
                    dotnet_enable_file_based_programs = true,
                },
                ["csharp|inlay_hints"] = {
                    csharp_enable_inlay_hints_for_implicit_object_creation = true,
                    csharp_enable_inlay_hints_for_implicit_variable_types = true,
                },
                ["csharp|code_lens"] = {
                    dotnet_enable_references_code_lens = true,
                },
            },
        })
      end
    '';
  }
  {
    name = "tris203/rzls.nvim";
    pkg = rzls-nvim;
    spec.enabled = false;
  }
  {
    name = "dmmulroy/tsc.nvim";
    pkg = tsc-nvim;
    spec.cmd = "TSC";
    spec.after = ''
      function()
        require('tsc').setup()
      end
    '';
  }
  {
    name = "2KAbhishek/nerdy.nvim";
    pkg = nerdy-nvim;
    spec.cmd = "Nerdy";
  }
]
