require('lspconfig').nixd.setup{
  cmd = { 'nixd' },
  filetypes = { 'nix' },
  settings = {
    nixd = {
      nixpkgs = {
      	expr = "import <nixpkgs> {}",
      },
      formatting = {
      	command = {"nixpkgs-fmt"},
      }
    },
  },
}


