{
  pkgs,
  self,
}:

let
  zshWrapped =
    (self.wrapperModules.zsh.apply {
      inherit pkgs;
      ".zshrc".content = ''
        export PROMPT='%n @ %~ %#'
      '';
    }).wrapper;
in
pkgs.runCommand "zsh-test" { } ''
  "${zshWrapped}/bin/zsh" --version | grep -q "zsh"
  touch $out
''
