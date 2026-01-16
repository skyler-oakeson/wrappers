{
  config,
  wlib,
  lib,
  ...
}:
let
  plugin = lib.types.submodule (
    { ... }: 
    {
      options = {
        src = lib.mkOption {
          type = lib.types.path;
        };
        name = lib.mkOption {
          type = lib.types.str;
        };
        file = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        completions = lib.mkOption {
          default = [ ];
          type = lib.types.listOf lib.types.str;
        };
      };
    });

    # init = lib.strings.concatMapStringsSep "; " (
    #   plugin: 
    #     if plugin.file != null
    #     then "${toString plugin.src}/${plugin.file}"
    #     else "source ${toString plugin.src}/share/zsh-${plugin.name}/${plugin.name}.plugin.zsh"
    # ) config.plugins ;

   zshKeyValueFormat = config.pkgs.formats.keyValue {
    listsAsDuplicateKeys = true;
    mkKeyValue = lib.generators.mkKeyValueDefault { } " ";
   };
  in
{
  options = {

    settings = lib.mkOption {
      type = zshKeyValueFormat.type;
      default = { };
      description = ''
        Configurations for .zshrc.
      '';
    };

    extraSettings = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra lines can be appended to the .zshrc file.
        This can be used to maintain order for settings.
      '';
    };

    ".zshenv" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.content = "";
      description = ''
        Sourced on all invocations of the shell, unless the -f option is set
        Sets environment variables
        See <https://zsh.sourceforge.io/Intro/intro_3.html>
      '';
    };

    ".zprofile" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.content = "";
      description = ''
        Executes commands in login shells
        An alternative to .zlogin, not intended to be used together
        See <https://zsh.sourceforge.io/Intro/intro_3.html>
      '';
    };

    ".zshrc" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.path =
      let
        fileName = ".zshrc";
        base = zshKeyValueFormat.generate fileName config.settings;
      in
      if config.extraSettings != "" then
        config.pkgs.concatText fileName [
          base
          (config.pkgs.writeText "extraSettings" config.extraSettings)
        ]
        else
        config.pkgs.concatText fileName [
         base
        ];
      default.content = "";
      description = ''
        Contains commands to set up aliases, functions, options, key bindings,
        etc.
        See <https://zsh.sourceforge.io/Doc/Release/zsh_toc.html>
      '';
    };

    ".zlogin" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.content = "";
      description = ''
        Executes commands in login shells
        An alternative to .zprofile, not intended to be used together
        See <https://zsh.sourceforge.io/Doc/Release/zsh_toc.html>
      '';
    };

    ".zlogout" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.content = "";
      description = ''
        Executes commands on login shells exiting
        See <https://zsh.sourceforge.io/Doc/Release/zsh_toc.html>
      '';
    };

    plugins = lib.mkOption {
      type = lib.types.listOf plugin;
      default = [];
      description = ''
      '';
    };

    test = ( map (plg: {name = plg.name; path = plg.src;}) config.plugins);
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

    FPATH = lib.strings.concatMapStringsSep ":" (
        plugin: lib.strings.concatMapStringsSep ":" (
          path: (toString plugin.src + "/") + path
      ) plugin.completions
    ) config.plugins;

  };

  config.flags = {
    # "-c" = "${init}; zsh -i";
  };

  meta.maintainers = [
    {
      name = "Skyler Oakeson";
      github = "skyler-oakeson";
    }
  ];
}
