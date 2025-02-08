{ inputs, cell, ... }:

{
  amdgpu = { pkgs, ... }:
    {
      # ISSUE: https://github.com/ROCm/ROCm/issues/2216#issuecomment-1637054248
      hardware.amdgpu.opencl.enable = true;

      # ISSUE: https://github.com/ollama/ollama/pull/6282#issue-2457641055
      # services.ollama.enable = true;
      services.ollama.user = "ollama";
      services.ollama.group = "ollama";
      services.ollama.acceleration = "rocm";
      services.ollama.rocmOverrideGfx = "9.0.0";
      services.ollama.loadModels = [
        "deepseek-r1"
        "deepseek-coder-v2"
        "llama3.3"
        "llama3.3"
        "dolphincoder"
        "qwen2.5-coder"
      ];

      environment.systemPackages = with pkgs.rocmPackages; [
        rccl
        rocm-smi
        rocm-core
        rocm-runtime
        rocm-device-libs

        hip-common

        pkgs.clinfo
      ];
    };
}
