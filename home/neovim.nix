{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.nixvim = {
    enable = true;
    options = {
      number = true;
      undofile = true;
    };
    globals = {
      mapleader = " ";
    };
    colorschemes.catppuccin.enable = true;
    keymaps = [
      {
        mode = "n";
        key = "<leader>b";
        action = "<cmd> enew <CR>";
        options.desc = "New Buffer";
      }
      {
        mode = "n";
        key = "<leader>fa";
        action = "Telescope find_files follow=true no_ignore=true hidden=true";
        options.desc = "Find All";
      }
      {
        mode = "n";
        key = "<leader>fv";
        action = "Telescope dap variables";
        options.desc = "Find DAP Variables";
      }
    ];
    plugins = {
      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = {
            action = "find_files";
            desc = "Find Files";
          };
          "<leader>fw" = {
            action = "live_grep";
            desc = "Find Word";
          };
          "<leader>fk" = {
            action = "find_keymaps";
            desc = "Find Keymaps";
          };
          "<leader>fs" = {
            action = "lsp_dynamic_workspace_symbols";
            desc = "Find Symbols";
          };
          "<leader>fb" = {
            action = "buffers";
            desc = "Find Buffers";
          };
          "<leader>fm" = {
            action = "marks";
            desc = "Find Marks";
          };
          "<leader>fo" = {
            action = "oldfiles";
            desc = "Find Recent";
          };
        };
      };
      which-key = {
        enable = true;
      };
      vimtex = {
        enable = true;
        viewMethod = "zathura";
      };
      lsp = {
        servers = {
          ltex = {
            enable = true;
          };
        };
      };
    };
  };
}
