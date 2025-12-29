{
  config,
  wlib,
  lib,
  ...
}:
{
  options = {
    ".zshenv" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.content="";
      description = ''
        Sourced on all invocations of the shell, unless the -f option is set
        Sets environment variables
        See <https://zsh.sourceforge.io/Intro/intro_3.html>
      '';
    };
    ".zprofile" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.content="";
      description = ''
        Executes commands in login shells
        An alternative to .zlogin, not intended to be used together
        See <https://zsh.sourceforge.io/Intro/intro_3.html>
      '';
    };
    ".zshrc" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.content="";
      description = ''
        Contains commands to set up aliases, functions, options, key bindings,
        etc.
        See <https://zsh.sourceforge.io/Doc/Release/zsh_toc.html>
      '';
    };
    ".zlogin" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.content="";
      description = ''
        Executes commands in login shells
        An alternative to .zprofile, not intended to be used together
        See <https://zsh.sourceforge.io/Doc/Release/zsh_toc.html>
      '';
    };
    ".zlogout" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.content="";
      description = ''
        Executes commands on login shells exiting
        See <https://zsh.sourceforge.io/Doc/Release/zsh_toc.html>
      '';
    };
    plugins = lib.mkOption {
      type = lib.types.listOf plugin;
      default = [];
      description = ''
        Sources plugins on zsh startup through the -c flag
      '';
    };
  };

  config.package = config.pkgs.zsh;
  config.env = {
    ZDOTDIR = toString (
      config.pkgs.linkFarm "zsh-config" [
          { name = ".zshenv"; path = config.".zshenv".path; }
          { name = ".zshrc"; path = config.".zshrc".path; }
          { name = ".zprofile"; path = config.".zprofile".path; }
          { name = ".zlogin"; path = config.".zlogin".path; }
          { name = ".zlogout"; path = config.".zlogout".path; }
      ]
    );
  };
  meta.maintainers = [
    {
      name = "Skyler Oakeson";
      github = "skyler-oakeson";
    }
  ];
}
