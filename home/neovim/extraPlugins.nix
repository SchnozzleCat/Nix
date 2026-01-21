{pkgs}:
with pkgs.vimPlugins; [
  {
    name = "dstein64/vim-startuptime";
    pkg = vim-startuptime;
  }
  {
    name = "itaranto/preview.nvim";
    version = "b97da7fb9444701afb30f0949a35bdf01a8c5c28";
    src = pkgs.fetchFromGitLab {
      owner = "itaranto";
      repo = "preview.nvim";
      rev = "b97da7fb9444701afb30f0949a35bdf01a8c5c28";
      hash = "sha256-oY/vjythAKaOjlLNTil0uooDrhW2dakvpCpgnRsCLGc=";
    };
    spec.after = ''
      function()
        require('preview').setup {
          previewers_by_ft = {
              plantuml = {
                name = 'plantuml_svg',
                renderer = { type = 'command', opts = { cmd = { 'imv' } } },
              },
            },
            render_on_write = true,
          }
      end
    '';
  }
  {
    name = "serhez/teide.nvim";
    version = "c8df92c32cd8f9741858241474c9069af74c20ca";
    hash = "sha256-dKsLTckHL4l7h4gNbYaAfKBNXS9+4JHT23hP1ZwRVF4=";
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
    name = "iofq/dart.nvim";
    version = "0.1.4";
    hash = "sha256-ULrZW4b8SKRvPpJPt8/jkqqc/blQiIWUriNWVXA33so=";
    spec.after = ''
      function()
        require('dart').setup({
          marklist = { 'a', 's', 'd', 'f', 'j', 'k', 'l', ';' },
          buflist = { 'q', 'w', 'e', 'r' },
          mappings = {
            mark = "'''", -- Mark current buffer
            jump = "'", -- Jump to buffer marked by next character i.e `;a`
            pick = "<leader>'", -- Open Dart.pick
            next = "<S-u>", -- Cycle right through the tabline
            prev = "<S-i>", -- Cycle left through the tabline
            unmark_all = "'=", -- Close all marked and recent buffers
          },
          tabline = {
            order = function()
              local order = {}
              for i, key in ipairs(vim.list_extend(vim.deepcopy(Dart.config.marklist), Dart.config.buflist)) do
                order[key] = i
              end
              return order
            end,
          }
        })
        vim.api.nvim_create_autocmd('ColorScheme', {
          callback = function()
            vim.api.nvim_set_hl(0, 'DartMarkedLabel', { fg = '#4EA4CC', bold = true })
            vim.api.nvim_set_hl(0, 'DartMarkedCurrent', { fg = '#4EA4CC',  bold = true })
            vim.api.nvim_set_hl(0, 'DartMarkedCurrentLabel', { fg = '#4EA4CC', bold = true })
            vim.api.nvim_set_hl(0, 'DartMarkedModified', { fg = '#315572' })
            vim.api.nvim_set_hl(0, 'DartMarkedLabelModified', { fg = '#315572' })
            vim.api.nvim_set_hl(0, 'DartMarkedCurrentModified', { fg = '#8FB2CF', bold = true })
            vim.api.nvim_set_hl(0, 'DartMarkedCurrentLabelModified', { fg = '#8FB2CF', bold = true })

            vim.api.nvim_set_hl(0, 'DartCurrent', { fg = 'orange', bg = 'none', bold = true })
            vim.api.nvim_set_hl(0, 'DartVisibleLabel', { fg = 'orange' })
            vim.api.nvim_set_hl(0, 'DartVisibleLabelModified', { fg = '#6f4d15' })
            vim.api.nvim_set_hl(0, 'DartVisibleModified', { fg = '#6f4d15' })
            vim.api.nvim_set_hl(0, 'DartCurrentModified', { fg = '#E3B66E' })
            vim.api.nvim_set_hl(0, 'DartCurrentLabelModified', { fg = '#E3B66E' })
          end
        })
        function pick_dart()
          local files = {}
          for _, item in ipairs(Dart.state()) do
            table.insert(files, {
              file = item.filename,
              text = item.mark .. " " .. item.filename,
              label = item.mark,
            })
          end
          Snacks.picker.pick {
            source = 'dart.nvim',
            items = files,
            format = 'file',
            title = 'dart.nvim buffers',
          }
        end
      end
    '';
  }
  {
    name = "tidalcycles/vim-tidal";
    version = "e440fe5bdfe07f805e21e6872099685d38e8b761";
    hash = "sha256-8gyk17YLeKpLpz3LRtxiwbpsIbZka9bb63nK5/9IUoA=";
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
