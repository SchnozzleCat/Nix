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
    keymaps = [
      {
        mode = "n";
        key = "<leader>b";
        action = "<cmd> enew <CR>";
        options.desc = "New Buffer";
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
          "<leader>fv" = {
            action = "dap variables";
            desc = "Find DAP Variables";
          };
          "<leader>fk" = {
            action = "find_keymaps";
            desc = "Find Keymaps";
          };
          "<leader>fs" = {
            action = "lsp_dynamic_workspace_symbols";
            desc = "Find Symbols";
          };
          "<leader>fa" = {
            action = "find_files follow=true no_ignore=true hidden=true";
            desc = "Find All";
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
