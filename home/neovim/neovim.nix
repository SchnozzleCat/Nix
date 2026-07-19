{
  inputs,
  pkgs,
  lib,
  ...
}: let
  buildPlugin = p: let
    split = builtins.filter (e: !builtins.isList e) (builtins.split "/" p.name);
    owner = builtins.elemAt split 0;
    plugin = builtins.elemAt split 1;
  in
    pkgs.vimUtils.buildVimPlugin {
      pname = plugin;
      version = p.version;
      doCheck = false;
      src =
        if p ? src
        then p.src
        else
          pkgs.fetchFromGitHub {
            owner = owner;
            repo = plugin;
            rev = p.version;
            sha256 = p.hash;
          };
    };

  parsedPlugins = map (p:
    if p ? pkg
    then p.pkg
    else buildPlugin p) (
    import ./extraPlugins.nix {inherit pkgs;}
  );
in {
  imports = [
    ./plugins.nix
    ./keymaps.nix
    ./lsp.nix
  ];

  home.packages = with pkgs; [
    netcoredbg
  ];

  programs.nixvim = {
    enable = true;
    nixpkgs.config.allowUnfree = true;
    # package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
    extraPackages = with pkgs; [
      imagemagick
      # nodePackages.ijavascript
      (python312Packages.jupytext.overridePythonAttrs (old: {doCheck = false;}))
      nodejs
      #quarto
      typescript
      jq
      lsof
      fd
      (haskellPackages.ghcWithPackages (pkgs: with pkgs; [tidal]))
      supercollider-with-sc3-plugins
      ripgrep
      zf
      plantuml
      jdk
      imv
      (buildDotnetGlobalTool {
        pname = "EasyDotnet";
        version = "3.1.3";
        executables = "dotnet-easydotnet";

        nugetHash = "sha256-MasiP8L7t/wvUX2azAqG9DxLezr2nNl2DA0ZUKbnPD8=";

        meta = with lib; {
          description = "C# JSON-RPC server powering the easy-dotnet.nvim Neovim plugin";
          homepage = "https://github.com/GustavEikaas/easy-dotnet.nvim";
          license = licenses.mit;
          maintainers = with maintainers; [];
          mainProgram = "dotnet-easydotnet";
        };
      })
      (pkgs.buildEnv {
        name = "combinedSdk";
        paths = [
          (
            with pkgs.dotnetCorePackages;
              combinePackages [
                sdk_10_0
                sdk_9_0
                sdk_8_0
              ]
          )
        ];
      })
    ];
    extraPython3Packages = python-pkgs:
      with python-pkgs; [
        pytest
        prompt-toolkit
        pyperclip
      ];
    extraPlugins = parsedPlugins;

    extraConfigVim = ''
      autocmd FileType nix setlocal commentstring=#\ %s
      autocmd FileType gdscript setlocal commentstring=#\ %s
      autocmd FileType gdshader setlocal commentstring=//\ %s
      let &t_TI = "\<Esc>[>4;2m"
      let &t_TE = "\<Esc>[>4;m"

      let g:VM_maps = {}
      let g:VM_maps['Find Under']         = '<C-s>'
      let g:VM_maps['Find Subword Under'] = '<C-s>'
    '';
    extraConfigLua = ''
      if vim.fn.filereadable(vim.fn.getcwd() .. "/project.godot") == 1 then
        -- Use 'nvim --server /tmp/godot.pipe --remote-send "<C-\><C-N>:n {file}<CR>{line}G{col}|"' to connect
        local addr = "/tmp/godot.pipe"
        vim.fn.serverstart(addr)
      end

      function pick_buffers()
        Snacks.picker.buffers({current=false})
        -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'i', true)
      end

      function explorer()
        Snacks.explorer({win={list={keys={["<ESC>"] = ""}}}, exclude={'*.uid'}})
      end

      function lsp_format(bufnr)
          vim.lsp.buf.format({
              filter = function(client)
                  -- apply whatever logic you want (in this example, we'll only use null-ls)
                  return client.name == "null-ls"
              end,
              bufnr = bufnr,
          })
      end

      vim.diagnostic.config({
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = "",
                [vim.diagnostic.severity.WARN] = "",
                [vim.diagnostic.severity.INFO] = "",
                [vim.diagnostic.severity.HINT] = "",
            },
          },
      })

      vim.opt.fillchars = {
        diff = '╱',
      }

      vim.opt.diffopt = {
        'internal',
        'filler',
        'closeoff',
        'context:12',
        'algorithm:histogram',
        'linematch:200',
        'indent-heuristic',
      }

      -- vim.cmd([[highlight @lsp.type.struct.cs guifg=#98cb6C]])

      -- require('matugen').setup()

      -- Force transparency after the teide-dark colorscheme loads.
      -- transparent.nvim gets overridden when the colorscheme reapplies.
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          local transparent_groups = {
            "Normal",
            "NormalNC",
            "NormalFloat",
            "FloatBorder",
            "SignColumn",
            "LineNr",
            "CursorLine",
            "CursorLineNr",
            "StatusLine",
            "StatusLineNC",
            "TabLine",
            "TabLineFill",
            "TabLineSel",
            "Pmenu",
            "PmenuSbar",
            "PmenuThumb",
            "WinSeparator",
            "VertSplit",
            "EndOfBuffer",
            "TreesitterContext",
            "TreesitterContextBottom",
            "TreesitterContextLineNumber",
            "TreesitterContextSeparator",
            "BlinkCmpMenu",
            "BlinkCmpMenuBorder",
            "BlinkCmpMenuSelection",
            "BlinkCmpScrollBarThumb",
            "BlinkCmpScrollBarGutter",
            "BlinkCmpLabel",
            "BlinkCmpLabelDeprecated",
            "BlinkCmpKind",
            "BlinkCmpSource",
          }
          for _, group in ipairs(transparent_groups) do
            local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
            if hl.bg then
              hl.bg = nil
              vim.api.nvim_set_hl(0, group, hl)
            end
          end

          vim.api.nvim_set_hl(0, "lualine_a_normal", { fg = "cyan" })

          -- dart.nvim tabline highlights.
          for _, name in ipairs(vim.fn.getcompletion("Dart", "highlight")) do
            local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
            if hl.bg then
              hl.bg = nil
              vim.api.nvim_set_hl(0, name, hl)
            end
          end
        end,
      })

      -- lualine creates its highlight groups lazily; force them transparent
      -- as a fallback in case the theme doesn't cover every section.
      local function clear_lualine_bg()
        for _, name in ipairs(vim.fn.getcompletion("lualine_", "highlight")) do
          local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
          if hl.bg then
            hl.bg = nil
            vim.api.nvim_set_hl(0, name, hl)
          end
        end
      end
      vim.api.nvim_create_autocmd("ColorScheme", { callback = clear_lualine_bg })
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.defer_fn(clear_lualine_bg, 100)
        end,
      })

      vim.cmd([[colorscheme teide-dark]])
      vim.api.nvim_exec_autocmds("ColorScheme", { modeline = false })
      vim.defer_fn(clear_lualine_bg, 200)
    '';
    opts = {
      showtabline = 0;
      relativenumber = true;
      number = true;
      undofile = true;
      shiftwidth = 2;
      tabstop = 2;
      conceallevel = 1;
      expandtab = true;
      autoindent = false;
      smartindent = true;
      cursorline = true;
      pumheight = 10;
      laststatus = 3;
    };
    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };
    globals = {
      mapleader = " ";
      maplocalleader = "  ";
    };
  };
}
