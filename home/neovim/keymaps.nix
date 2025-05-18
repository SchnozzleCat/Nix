{
  inputs,
  pkgs,
  lib,
  ...
}: {
  programs.nixvim.keymaps = [
    # Misc
    {
      mode = ["n"];
      key = "<leader>dd";
      action = ''<cmd>NoiceDismiss<cr>'';
      options.desc = "Noice Dismiss";
    }
    {
      mode = ["n"];
      key = "<c-space>";
      action = ''<cmd>lua require("hover").hover() <cr>'';
      options.desc = "Show Hover Doc";
    }
    {
      mode = ["n"];
      key = "K";
      action = ''<cmd> lua require("hover").hover() <cr>'';
      options.desc = "Show Hover Doc";
    }
    {
      mode = ["n"];
      key = "<c-p>";
      action = ''<cmd> lua require("hover").hover_switch("next") <cr>'';
      options.desc = "Show Next Hover Doc";
    }
    {
      mode = ["n"];
      key = "<c-n>";
      action = ''<cmd> lua require("hover").hover_switch("previous") <cr>'';
      options.desc = "Show Previous Hover Doc";
    }
    {
      mode = "n";
      key = "<esc>";
      action = "<cmd> noh <cr>";
    }
    {
      mode = "i";
      key = "<c-j>";
      action = "<down>";
    }
    {
      mode = "i";
      key = "<c-k>";
      action = "<up>";
    }
    {
      mode = "i";
      key = "<c-h>";
      action = "<left>";
    }
    {
      mode = "i";
      key = "<c-l>";
      action = "<right>";
    }
    # Quickfix
    {
      mode = "n";
      key = "[[";
      action = "<cmd>cprev<cr>";
      options.desc = "Previous Word";
    }
    {
      mode = "n";
      key = "]]";
      action = "<cmd>cnext<cr>";
      options.desc = "Next Word";
    }
    # Picker
    {
      mode = "n";
      key = "<leader>e";
      action = ''<cmd>lua explorer()<cr>'';
      options.desc = "Pick Explorer";
    }
    {
      mode = "n";
      key = "<leader>ff";
      action = "<cmd>lua Snacks.picker.files() <cr>";
      options.desc = "Pick Files";
    }
    {
      mode = "n";
      key = "<leader>fF";
      action = "<cmd>lua Snacks.picker.files() <cr>";
      options.desc = "Pick Files";
    }
    {
      mode = "n";
      key = "<leader>fa";
      action = "<cmd>lua Snacks.picker.files({ hidden = true, ignored = true }) <cr>";
      options.desc = "Pick All Files";
    }
    {
      mode = "n";
      key = "<leader>fw";
      action = "<cmd>lua Snacks.picker.grep() <cr>";
      options.desc = "Pick Grep";
    }
    {
      mode = "n";
      key = "<leader>j";
      action = "<cmd>lua pick_buffers()<cr>";
      options.desc = "Pick Buffers";
    }
    {
      mode = "v";
      key = "<leader>gc";
      action = "<cmd>lua Snacks.picker.git_log_line()<cr>";
      options.desc = "Pick Git Line Log";
    }
    {
      mode = "n";
      key = "<leader>gc";
      action = "<cmd>lua Snacks.picker.git_log_file()<cr>";
      options.desc = "Pick Git File Log";
    }
    {
      mode = "n";
      key = "<leader>fo";
      action = "<cmd>lua Snacks.picker.recent()<cr>";
      options.desc = "Pick Recent";
    }
    {
      mode = "n";
      key = "<leader>fs";
      action = "<cmd>lua Snacks.picker.lsp_symbols({layout = {preset = 'vscode', preview = 'main'}})<cr>";
      options.desc = "Pick Symbols";
    }
    {
      mode = "n";
      key = "<leader>fS";
      action = "<cmd>lua Snacks.picker.lsp_workspace_symbols({filter={default=true}})<cr>";
      options.desc = "Pick Symbols";
    }
    {
      mode = "n";
      key = "<leader>fc";
      action = "<cmd>lua Snacks.picker.lsp_workspace_symbols({filter={default={'Class', 'Struct', 'Enum'}}})<cr>";
      options.desc = "Pick Class";
    }
    {
      mode = "n";
      key = "<leader>fi";
      action = "<cmd>lua Snacks.picker.lsp_workspace_symbols({filter={default={'Interface'}}})<cr>";
      options.desc = "Pick Interface";
    }
    {
      mode = "n";
      key = "<leader>fm";
      action = "<cmd>lua Snacks.picker.lsp_workspace_symbols({filter={default={'Method', 'Function'}}})<cr>";
      options.desc = "Pick Method";
    }
    {
      mode = "n";
      key = "<leader>fv";
      action = "<cmd>lua Snacks.picker.lsp_workspace_symbols({filter={default={'Field', 'Property'}}})<cr>";
      options.desc = "Pick Variable";
    }
    # Focus Here
    {
      mode = "v";
      key = "<leader>zf";
      action = ":FocusHere<cr>";
    }
    {
      mode = "n";
      key = "<leader>zf";
      action = ":FocusClear<cr>";
    }
    # Rest
    {
      mode = "n";
      key = "<leader>rr";
      action = "<cmd>Rest run<cr>";
      options.desc = "Rest Run";
    }
    {
      mode = "n";
      key = "<leader>rl";
      action = "<cmd>Rest last<cr>";
      options.desc = "Rest Last";
    }
    # Windows
    {
      mode = "n";
      key = "<c-j>";
      action = "<c-w>j";
    }
    {
      mode = "n";
      key = "<c-k>";
      action = "<c-w>k";
    }
    {
      mode = "n";
      key = "<c-h>";
      action = "<c-w>h";
    }
    {
      mode = "n";
      key = "<c-l>";
      action = "<c-w>l";
    }
    # Quarto
    {
      mode = "n";
      key = "<leader>qa";
      action = "<cmd> QuartoSendAbove <cr>";
      options.desc = "Quarto Send Above";
    }
    {
      mode = "n";
      key = "<leader>qA";
      action = "<cmd> QuartoSendAll <cr>";
      options.desc = "Quarto Send All";
    }
    {
      mode = "n";
      key = "<leader>qb";
      action = "<cmd> QuartoSendBelow <cr>";
      options.desc = "Quarto Send Below";
    }
    {
      mode = "n";
      key = "<leader>qq";
      action = "<cmd> QuartoSend <cr>";
      options.desc = "Quarto Send";
    }
    {
      mode = "n";
      key = "<leader>qp";
      action = "<cmd> QuartoPreview <cr>";
      options.desc = "Quarto Preview";
    }
    # Molten
    {
      mode = "n";
      key = "<leader>mi";
      action = "<cmd> MoltenInit <cr>";
      options.desc = "Molten Init";
    }
    {
      mode = "n";
      key = "<leader>me";
      action = "<cmd> MoltenEvaluateOperator <cr>";
      options.desc = "Molten Evaluate Operator";
    }
    {
      mode = "v";
      key = "<leader>me";
      action = ":<C-u>MoltenEvaluateVisual<CR>gv";
      options.desc = "Molten Evaluate Visual";
    }
    {
      mode = "n";
      key = "<leader>mr";
      action = "<cmd> MoltenReevaluateCell <cr>";
      options.desc = "Molten Reevaluate Cell";
    }
    {
      mode = "n";
      key = "<leader>mR";
      action = "<cmd> MoltenReevaluateAll <cr>";
      options.desc = "Molten Reevaluate All";
    }
    {
      mode = "n";
      key = "<leader>[m";
      action = "<cmd> MoltenNext <cr>";
      options.desc = "Molten Next Cell";
    }
    {
      mode = "n";
      key = "<leader>[m";
      action = "<cmd> MoltenPrevious <cr>";
      options.desc = "Molten Previous Cell";
    }
    {
      mode = "n";
      key = "<leader>md";
      action = "<cmd> MoltenDelete <cr>";
      options.desc = "Molten Delete";
    }
    {
      mode = "n";
      key = "<leader>mo";
      action = ":noautocmd MoltenEnterOutput<CR>";
      options.desc = "Molten Enter Output";
    }
    # SnipRun
    {
      mode = "n";
      key = "<leader>rs";
      action = "<cmd> SnipRun <cr>";
      options.desc = "Run Snippet";
    }
    {
      mode = "v";
      key = "<leader>rs";
      action = ":SnipRun <cr>";
      options.desc = "Run Snippet";
    }
    {
      mode = "n";
      key = "<leader>p";
      action = ''<cmd>Dotnet build<CR>'';
      options.desc = "Dotnet Build";
    }
    {
      mode = "n";
      key = "<leader>P";
      action = ''<cmd>Dotnet run<CR>'';
      options.desc = "Dotnet Run";
    }
    # DAP
    {
      mode = "n";
      key = "<leader>dc";
      action = "<cmd> DapContinue <cr>";
      options.desc = "DAP Continue";
    }
    {
      mode = "n";
      key = "<leader>db";
      action = "<cmd> DapToggleBreakpoint <cr>";
      options.desc = "Toggle Breakpoint";
    }
    {
      mode = "n";
      key = "<leader>dv";
      action = ''<cmd> lua require("dapui").toggle() <cr>'';
      options.desc = "Toggle DAP UI";
    }
    {
      mode = "n";
      key = "<leader>do";
      action = "<cmd> DapStepOver <cr>";
      options.desc = "Step Over";
    }
    {
      mode = "n";
      key = "<leader>d<s-o>";
      action = "<cmd> DapStepOut <cr>";
      options.desc = "Step Out";
    }
    {
      mode = "n";
      key = "<leader>di";
      action = "<cmd> DapStepInto <cr>";
      options.desc = "Step Into";
    }
    {
      mode = "n";
      key = "<leader>dx";
      action = "<cmd> DapTerminate <cr>";
      options.desc = "DAP Terminate";
    }
    # Floaterm
    {
      mode = "n";
      key = "<a-i>";
      action = "<cmd> FloatermToggle <cr>";
    }
    {
      mode = "t";
      key = "<a-i>";
      action = "<c-\\><c-n><cmd> FloatermToggle <cr>";
    }
    {
      mode = "t";
      key = "<C-x>";
      action = "<c-\\><c-n>";
    }
    {
      mode = "t";
      key = "<a-]>";
      action = "<cmd> FloatermNext <cr>";
      options.desc = "Next Terminal";
    }
    {
      mode = "t";
      key = "<a-[>";
      action = "<cmd> FloatermPrev <cr>";
      options.desc = "Previous Terminal";
    }
    {
      mode = "t";
      key = "<a-d>";
      action = "<cmd> FloatermKill <cr>";
      options.desc = "Kill Terminal";
    }
    {
      mode = "t";
      key = "<a-n>";
      action = "<cmd> FloatermNew <cr>";
      options.desc = "New Terminal";
    }
    {
      mode = "n";
      key = "<leader>N";
      action = "<cmd> NvimTreeToggle <cr>";
      options.desc = "LF";
    }
    {
      mode = "n";
      key = "<leader>n";
      action = ''<cmd>lua require("yazi").yazi()<cr>'';
      options.desc = "LF";
    }
    # Mini Files
    {
      mode = "n";
      key = "<leader>o";
      action = "<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0), false) <cr>";
      options.desc = "Mini Files";
    }
    {
      mode = "n";
      key = "<leader>O";
      action = "<cmd>lua MiniFiles.open(nil, false) <cr>";
      options.desc = "Mini Files Working Directory";
    }
    # Buffers
    {
      mode = "n";
      key = "<leader>b";
      action = "<cmd>lua Snacks.scratch() <cr>";
      options.desc = "Toggle Scratch Buffer";
    }
    {
      mode = "n";
      key = "<leader>B";
      action = "<cmd>lua Snacks.scratch.select() <cr>";
      options.desc = "Select Scratch Buffer";
    }
    {
      key = "<leader>x";
      action = "<cmd>lua Snacks.bufdelete() <cr>";
      options.desc = "Delete Buffer";
    }
    # Flash
    {
      mode = ["n" "x" "o"];
      key = "s";
      action = ''<cmd> lua require("flash").jump() <cr>'';
      options.desc = "Flash Jump";
    }
    {
      mode = ["n" "x" "o"];
      key = "S";
      action = ''<cmd> lua require("flash").treesitter() <cr>'';
      options.desc = "Flash Treesitter";
    }
    {
      mode = ["o"];
      key = "r";
      action = ''<cmd> lua require("flash").remote() <cr>'';
      options.desc = "Flash Remote";
    }
    {
      mode = ["x" "o"];
      key = "R";
      action = ''<cmd> lua require("flash").treesitter_search({ remote_op={restore=true,motion=true}}) <cr>'';
      options.desc = "Flash Treesitter Search";
    }
    # NeoTest
    {
      mode = ["n"];
      key = "<leader>td";
      action = ''<cmd> lua require("neotest").run.run({strategy = "dap"}) <cr>'';
      options.desc = "debug nearest test";
    }
    {
      mode = ["n"];
      key = "<leader>tr";
      action = ''<cmd> lua require("neotest").run.run() <cr>'';
      options.desc = "debug nearest test";
    }
    {
      mode = ["n"];
      key = "<leader>tf";
      action = ''<cmd> lua require("neotest").run.run(vim.fn.expand("%")) <cr>'';
      options.desc = "debug nearest test";
    }
    # Undotree
    {
      mode = ["n"];
      key = "<leader>u";
      action = "<cmd> UndotreeToggle <cr>";
      options.desc = "Undo Tree";
    }
    # Gitsigns
    {
      mode = ["n"];
      key = "<leader>gd";
      action = "<cmd> DiffviewOpen <cr>";
      options.desc = "Git Diff";
    }
    {
      mode = ["n"];
      key = "<leader>gH";
      action = "<cmd> DiffviewFileHistory <cr>";
      options.desc = "Git File History";
    }
    {
      mode = ["n"];
      key = "<leader>gh";
      action = "<cmd> DiffviewFileHistory % <cr>";
      options.desc = "Git Current File History";
    }
    {
      mode = ["n"];
      key = "]h";
      action = "<cmd> Gitsigns next_hunk <cr> <cmd> Gitsigns preview_hunk_inline <cr>";
      options.desc = "Next Hunk";
    }
    {
      mode = ["n"];
      key = "[h";
      action = "<cmd> Gitsigns prev_hunk <cr> <cmd> Gitsigns preview_hunk_inline <cr>";
      options.desc = "Previous Hunk";
    }
    {
      mode = ["n"];
      key = "<leader>hs";
      action = "<cmd> Gitsigns stage_hunk <cr>";
      options.desc = "Stage Hunk";
    }
    {
      mode = ["n"];
      key = "<leader>hr";
      action = "<cmd> Gitsigns reset_hunk <cr>";
      options.desc = "Reset Hunk";
    }
    {
      mode = ["n"];
      key = "<leader>hu";
      action = "<cmd> Gitsigns undo_stage_hunk <cr>";
      options.desc = "Undo Stage Hunk";
    }
    # Copilot
    {
      mode = ["v"];
      key = "<leader>cc";
      action = ":CopilotChat<cr>";
      options.desc = "Copilot Chat";
    }
    {
      mode = ["n"];
      key = "<leader>cc";
      action = "<cmd>CopilotChat<cr>";
      options.desc = "Copilot Chat";
    }
    {
      mode = ["v"];
      key = "<leader>cd";
      action = ":CopilotChatDocs<cr>";
      options.desc = "Write Documentation";
    }
    {
      mode = ["n"];
      key = "<leader>ce";
      action = "<cmd> CopilotChatExplain <cr>";
      options.desc = "Copilot Explain";
    }
    {
      mode = ["n"];
      key = "<leader>cr";
      action = "<cmd> CopilotChatRefactor <cr>";
      options.desc = "Copilot Refactor";
    }
    {
      mode = ["n"];
      key = "<leader>cq";
      action = ":CopilotChat ";
      options.desc = "Copilot Question";
    }
    {
      mode = ["n"];
      key = "<leader>ct";
      action = "<cmd> CopilotChatTests <cr>";
      options.desc = "Copilot Tests";
    }
    # LSP Saga
    {
      mode = ["n"];
      key = "<leader>ra";
      action = "<cmd> Lspsaga rename <cr>";
      options.desc = "Rename";
    }
    {
      mode = ["n"];
      key = "<leader>ca";
      action = "<cmd>lua require('fastaction').code_action()<CR>";
      options.desc = "Show Code Actions";
    }
    {
      mode = ["n"];
      key = "gs";
      action = "<cmd>lua Snacks.picker.lsp_symbols()<cr>";
      options.desc = "LSP Symbols";
    }
    {
      mode = ["n"];
      key = "gd";
      action = "<cmd>lua Snacks.picker.lsp_definitions()<cr>";
      options.desc = "LSP Definition";
    }
    # Trouble
    {
      mode = ["n"];
      key = "<leader>tt";
      action = "<cmd> TroubleToggle <cr>";
      options.desc = "Toggle Trouble";
    }
    {
      mode = ["n"];
      key = "gi";
      action = "<cmd>lua Snacks.picker.lsp_implementations() <cr>";
      options.desc = "LSP Implementations";
    }
    {
      mode = ["n"];
      key = "gr";
      action = "<cmd>lua Snacks.picker.lsp_references() <cr>";
      options.desc = "LSP References";
    }
    {
      mode = ["n"];
      key = "]t";
      action = ''<cmd> lua require("trouble").next({skip_groups=true,jump=true}) <cr>'';
      options.desc = "Next Trouble";
    }
    {
      mode = ["n"];
      key = "[t";
      action = ''<cmd> lua require("trouble").prev({skip_groups=true,jump=true}) <cr>'';
      options.desc = "Previous Trouble";
    }
    {
      mode = ["n"];
      key = "<leader>tw";
      action = "<cmd> Trouble diagnostics<cr>";
      options.desc = "Workspace Trouble";
    }
    {
      mode = ["n"];
      key = "<leader>tq";
      action = "<cmd> TroubleToggle quickfix<cr>";
      options.desc = "Toggle Trouble Quickfix";
    }
    {
      mode = ["n"];
      key = "<leader>tl";
      action = "<cmd> TroubleToggle loclist<cr>";
      options.desc = "Toggle Trouble Loclist";
    }
    {
      mode = ["n"];
      key = "<leader>D";
      action.__raw = ''
        function()
          for _, client in ipairs(vim.lsp.get_clients()) do
            if vim.tbl_get(client.config, "filetypes") then
              print("loading for" .. client.name)
              require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
            end
          end
        end
      '';
      options.desc = "Populate Workspace Diagnostics";
    }
    # Lazygit
    {
      mode = ["n"];
      key = "<leader>G";
      action = "<cmd>lua Snacks.lazygit() <cr>";
      options.desc = "LazyGit";
    }
    # Zen Mode
    {
      mode = ["n"];
      key = "<leader>Z";
      action = "<cmd>lua Snacks.zen() <cr>";
      options.desc = "Zen";
    }
    # Obsidian
    {
      mode = ["n"];
      key = "<leader>ft";
      action = "<cmd> ObsidianTags <cr>";
      options.desc = "Obsidian Tags";
    }
    {
      mode = ["n"];
      key = "<leader>zb";
      action = "<cmd> ObsidianBacklinks <cr>";
      options.desc = "Obsidian Backlinks";
    }
    {
      mode = ["n"];
      key = "<leader>fn";
      action = "<cmd> ObsidianQuickSwitch <cr>";
      options.desc = "Obsidian Quick Switch";
    }
    {
      mode = ["n"];
      key = "<leader>fzw";
      action = "<cmd> ObsidianSearch <cr>";
      options.desc = "Obsidian Search";
    }
    {
      mode = ["n"];
      key = "<leader>zn";
      action = "<cmd> ObsidianNew <cr>";
      options.desc = "Obsidian New";
    }
    {
      mode = ["n"];
      key = "<leader>zo";
      action = "<cmd> ObsidianOpen <cr>";
      options.desc = "Obsidian Open";
    }
    {
      mode = ["n"];
      key = "<leader>zl";
      action = "<cmd> ObsidianLinks <cr>";
      options.desc = "Obsidian Links";
    }
    {
      mode = ["v"];
      key = "<leader>zl";
      action = "<cmd> ObsidianLink <cr>";
      options.desc = "Obsidian Link";
    }
    {
      mode = ["n"];
      key = "<leader>zt";
      action = "<cmd> ObsidianTemplate <cr>";
      options.desc = "Obsidian Template";
    }
    {
      mode = ["n"];
      key = "<leader>zd";
      action = "<cmd> ObsidianToday <cr>";
      options.desc = "Obsidian Today";
    }
    # Misc
    {
      mode = ["n"];
      key = "<leader>hi";
      action = ":lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) <cr>";
      options.desc = "Toggle Inlay Hints";
    }
  ];
}
