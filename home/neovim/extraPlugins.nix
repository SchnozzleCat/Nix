{ pkgs }:
with pkgs.vimPlugins;
[
  {
    name = "dstein64/vim-startuptime";
    pkg = vim-startuptime;
  }
  {
    name = "A7Lavinraj/fyler.nvim";
    pkg = fyler-nvim;
    spec.cmd = "Fyler";
    spec.after = ''
      function()
        require('fyler').setup {}
      end
    '';
  }
  {
    name = "mason-org/mason.nvim";
    pkg = mason-nvim;
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
    spec.cmd = "Mason";
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
    name = "chrisbra/csv.vim";
    pkg = csv-vim;
  }
  {
    name = "lewis6991/hover.nvim";
    pkg = hover-nvim;
    spec.event = "DeferredUIEnter";
    spec.after = ''
      function()
        require("hover").setup {
          init = function()
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
          preview_window = false,
          title = true,
        }
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
    name = "azorng/goose.nvim";
    version = "ada7651562bbcd0601d08896741cf7b4862178a8";
    hash = "sha256-u7NabwnlwNixc0Axu50Kr81TkHMNbWKvCTTsPQascbA=";
    spec = {
      after = ''
        function()
          require("goose").setup()
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
    pkg = roslyn-nvim;
    spec.enabled = false;
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
  {
    name = "LiadOz/nvim-dap-repl-highlights";
    version = "c6d5dfb8e9ce55f60d5fe2a950d3b8f484237226";
    hash = "sha256-UPgZ+GRCPFj4UjzZYaOVjzlZdf46gCucj0SHakyiDEY=";
    spec.after = ''
      function()
        require('nvim-dap-repl-highlights').setup()
      end
    '';
  }
]
