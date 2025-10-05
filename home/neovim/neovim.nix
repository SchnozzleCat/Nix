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
      src = pkgs.fetchFromGitHub {
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
    gh
    postgresql_16
  ];

  programs.nixvim = {
    enable = true;
    nixpkgs.config.allowUnfree = true;
    # package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
    extraPackages = with pkgs; [
      imagemagick
      # nodePackages.ijavascript
      python312Packages.jupytext
      nodejs
      goose-cli
      quarto
      typescript
      jq
      fd
      ripgrep
      zf
      jdk
      imv
      (buildDotnetGlobalTool {
        pname = "csharpier";
        version = "1.0.0";
        executables = "csharpier";

        nugetHash = "sha256-wj+Sjvtr4/zqBdxXMM/rYHykzcn+jQ3AVakYpAa3sNU=";

        meta = with lib; {
          description = "Opinionated code formatter for C#";
          homepage = "https://csharpier.com/";
          changelog = "https://github.com/belav/csharpier/blob/main/CHANGELOG.md";
          license = licenses.mit;
          maintainers = with maintainers; [zoriya];
          mainProgram = "csharpier";
        };
      })
      (pkgs.buildEnv {
        name = "combinedSdk";
        paths = [
          (
            with pkgs.dotnetCorePackages;
            combinePackages [
              sdk_9_0
              sdk_8_0
            ]
          )
        ];
      })
    ];
    extraLuaPackages = ps: [
      pkgs.luajitPackages.magick
    ];
    extraPython3Packages = python-pkgs:
      with python-pkgs; [
        pytest
        prompt-toolkit
        pyperclip
      ];
    extraPlugins = parsedPlugins;

    highlight = {
      "@type.qualifier.c_sharp".fg = "#7AA8fF";
      "@type.c_sharp".fg = "#98cb6C";
      "@struct_declaration".fg = "#aaff9C";
      "@attribute".fg = "#cb6fe2";
      "@return_statement".fg = "#eb6f92";
    };
    highlightOverride = {
      TreesitterContext.bg = "none";
      TroubleNormal.bg = "none";
      TroubleNormalNC.bg = "none";
      MiniFilesNormal.bg = "none";
      WhichKeyNormal.bg = "none";
      GrappleNormal.bg = "none";
      Pmenu = {
        fg = "#61AAC3";
        bg = "none";
      };
      Float.bg = "none";
      NormalFloat.bg = "none";
      NotifyBackground.bg = "#000000";
    };
    extraConfigVim = ''
      autocmd FileType nix setlocal commentstring=#\ %s
      autocmd FileType gdscript setlocal commentstring=#\ %s
      sign define DiagnosticSignError text= numhl=DiagnosticDefaultErro
      sign define DiagnosticSignWarn text= numhl=DiagnosticDefaultWarn
      sign define DiagnosticSignInfo text= numhl=DiagnosticDefaultInfo
      sign define DiagnosticSignHint text= numhl=DiagnosticDefaultHint
      let &t_TI = "\<Esc>[>4;2m"
      let &t_TE = "\<Esc>[>4;m"

      let g:VM_maps = {}
      let g:VM_maps['Find Under']         = '<C-s>'
      let g:VM_maps['Find Subword Under'] = '<C-s>'
    '';
    extraConfigLua = ''
      if vim.fn.filereadable(vim.fn.getcwd() .. "/project.godot") == 1 then
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

      -- Required: Enable the language server
      -- vim.lsp.enable('ty')
      -- vim.lsp.enable('pyrefly')

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
      autoindent = true;
      smartindent = false;
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
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        transparent_background = true;
        flavor = "mocha";
      };
    };
  };
}
