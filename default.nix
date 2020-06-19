let
  pkgs = import <nixpkgs> {};
  tooling = [
    pkgs.exa
    pkgs.xsv
    pkgs.git
    pkgs.ruby_2_7
  ];

in
  pkgs.mkShell {
    LANG = "en_GB.UTF-8";
    EDITOR="vim";
    buildInputs = tooling ++ [
    ];

    shellHook = ''
      set -o vi
      local pink='\e[1;35m'
      local yellow='\e[1;33m'
      local blue='\e[1;36m'
      local white='\e[0;37m'
      local reset='\e[0m'

      function git_branch {
        git rev-parse --abbrev-ref HEAD 2>/dev/null
      }

      export PS1="\[$pink\]nix \[$blue\]\W \[$yellow\]\$(git_branch)\[$white\] ∙ \[$reset\]"

      alias ls=exa

      source ${pkgs.git}/share/bash-completion/completions/git
    '';
  }
