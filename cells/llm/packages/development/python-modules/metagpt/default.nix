{ python3Packages
, sources
}:
let
  # faiss-cpu = python3Packages.buildPythonPackage {
  #   inherit (sources.faiss-cpu) pname version src;
  #   pyproject = true;
  #   pythonRelaxDeps = true;
  #   build-system = with python3Packages; [ setuptools-scm setuptools ];
  #   preCheck = ''
  #     export HOME=$(mktemp -d)
  #   '';
  #   dependencies = with python3Packages; [ numpy ];

  # };

  metagpt = python3Packages.buildPythonPackage {
    inherit (sources.metagpt) pname version src;
    pyproject = true;
    build-system = with python3Packages; [ setuptools-scm setuptools ];
    preCheck = ''
      export HOME=$(mktemp -d)
    '';
    doCheck = false;
    pythonRelaxDeps = true;
    # pythonRemoveDeps = [ "faiss-cpu" ];
    propagatedBuildInputs = with python3Packages; [ faiss ];
    dependencies = with python3Packages; [
      aiohttp
      channels

      faiss-cpu

      faiss #-cpu
      # ta
      # semantic-kernel
      # zhipuai
      # qianfan
      # dashscope

      fire
      typer
      lancedb
      loguru
      meilisearch
      numpy
      openai
      openpyxl
      beautifulsoup4
      pandas
      pydantic
      python-docx
      pyyaml
      setuptools
      tenacity
      tiktoken
      tqdm
      anthropic
      typing-inspect
      libcst
      qdrant-client
      wrapt
      aioredis
      websocket-client
      aiofiles
      gitpython
      rich
      nbclient
      nbformat
      ipython
      ipykernel
      scikit-learn
      typing-extensions
      socksio
      gitignore-parser
      websockets
      networkx
      google-generativeai
      playwright
      anytree
      ipywidgets
      pillow
      imap-tools
      rank-bm25
      jieba
    ];

    # propagatedBuildInputs = with python3Packages; [
    # ];

    # makeWrapperArgs = [ "--prefix PYTHONPATH : $PYTHONPATH" ];

    # doCheck = false;

    meta = {
      description = "🌟 The Multi-Agent Framework: First AI Software Company, Towards Natural Language Programming";
      homepage = "https://github.com/geekan/MetaGPT";
    };
  };
in
metagpt
