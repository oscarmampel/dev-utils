{...}: {
  flake.templates = {
    ruby = {
      path = ../templates/ruby;
      description = "Ruby with MySQL and shared development utilities";
    };
    python = {
      path = ../templates/python;
      description = "Python with shared development utilities";
    };
    go = {
      path = ../templates/go;
      description = "Go with shared development utilities";
    };
    rust = {
      path = ../templates/rust;
      description = "Rust with shared development utilities";
    };
  };
}
