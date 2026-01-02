# ============================================================
# AI / ML - INTELIGÊNCIA ARTIFICIAL E MACHINE LEARNING
# ============================================================
# CUDA, PyTorch, TensorFlow, Ollama e ferramentas de IA.
#
# Autor: Allan Farias

{ config, pkgs, lib, ... }:

{
  # ============================================================
  # CUDA E COMPUTE
  # ============================================================
  
  # Permitir pacotes unfree (CUDA é proprietário)
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
  };

  environment.systemPackages = with pkgs; [
    # ----------------------
    # CUDA Toolkit
    # ----------------------
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    cudaPackages.cutensor
    
    # NCCL para multi-GPU
    # cudaPackages.nccl
    
    # ----------------------
    # Python para ML
    # ----------------------
    (python312.withPackages (ps: with ps; [
      # Core ML
      numpy
      scipy
      pandas
      matplotlib
      seaborn
      
      # PyTorch
      torch
      torchvision
      torchaudio
      
      # TensorFlow
      # tensorflow
      # keras
      
      # Transformers e LLMs
      transformers
      datasets
      tokenizers
      accelerate
      peft              # Parameter-Efficient Fine-Tuning
      bitsandbytes      # Quantização
      
      # Computer Vision
      opencv4
      pillow
      
      # NLP
      nltk
      spacy
      
      # Utilities
      tqdm
      wandb             # Experiment tracking
      tensorboard
      
      # Notebooks
      jupyter
      jupyterlab
      ipywidgets
      
      # Gradio para demos
      gradio
      
      # Hugging Face
      huggingface-hub
    ]))
    
    # ----------------------
    # Ollama
    # ----------------------
    # LLMs locais
    ollama
    
    # ----------------------
    # Ferramentas CLI
    # ----------------------
    # GPU monitoring
    nvtopPackages.nvidia
    
    # CUDA samples e tools
    cudaPackages.cuda_nvcc
    
    # ============================================================
    # FERRAMENTAS DE IA
    # ============================================================
    
    # ----------------------
    # Stable Diffusion
    # ----------------------
    # Para geração de imagens, use ComfyUI ou Automatic1111
    # via git clone (não disponível no nixpkgs)
    
    # ----------------------
    # Whisper
    # ----------------------
    # Transcrição de áudio
    # openai-whisper  # Via pip
    
    # ----------------------
    # LLM Chat
    # ----------------------
    # Use Ollama + Open WebUI
    # open-webui  # Via container
  ];

  # ============================================================
  # SERVIÇO OLLAMA
  # ============================================================
  
  services.ollama = {
    enable = true;
    acceleration = "cuda";  # ou "rocm" para AMD
    
    # Modelos para baixar automaticamente (opcional)
    # loadModels = [ "llama2" "codellama" ];
    
    # Configuração de GPU
    # environmentVariables = {
    #   OLLAMA_CUDA_VISIBLE_DEVICES = "0";
    # };
  };

  # ============================================================
  # VARIÁVEIS DE AMBIENTE
  # ============================================================
  
  environment.sessionVariables = {
    # CUDA paths
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
    
    # Para PyTorch encontrar CUDA
    LD_LIBRARY_PATH = lib.mkForce "${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cudnn}/lib:$LD_LIBRARY_PATH";
    
    # Hugging Face cache
    HF_HOME = "$HOME/.cache/huggingface";
    TRANSFORMERS_CACHE = "$HOME/.cache/huggingface/transformers";
    
    # Torch settings
    TORCH_HOME = "$HOME/.cache/torch";
  };

  # ============================================================
  # JUPYTER SERVICE (OPCIONAL)
  # ============================================================
  # Descomente para ter Jupyter como serviço do sistema
  
  # services.jupyter = {
  #   enable = true;
  #   user = "allan";
  #   group = "users";
  #   port = 8888;
  #   notebook_dir = "~/notebooks";
  # };

  # ============================================================
  # NOTAS AI/ML
  # ============================================================
  #
  # 1. PRIMEIRO SETUP:
  #    - Após rebuild, teste CUDA:
  #      python -c "import torch; print(torch.cuda.is_available())"
  #
  # 2. OLLAMA:
  #    - Baixar modelo: ollama pull llama2
  #    - Chat: ollama run llama2
  #    - API: http://localhost:11434
  #
  # 3. OPEN WEBUI (GUI para Ollama):
  #    podman run -d -p 8080:8080 \
  #      -v open-webui:/app/backend/data \
  #      --add-host=host.containers.internal:host-gateway \
  #      ghcr.io/open-webui/open-webui:cuda
  #
  # 4. STABLE DIFFUSION (ComfyUI):
  #    cd ~/ai && git clone https://github.com/comfyanonymous/ComfyUI
  #    cd ComfyUI && pip install -r requirements.txt
  #    python main.py
  #
  # 5. HUGGING FACE:
  #    - Login: huggingface-cli login
  #    - Download model: huggingface-cli download meta-llama/Llama-2-7b
  #
  # 6. VRAM LIMITADA:
  #    - Use quantização: bitsandbytes (8-bit, 4-bit)
  #    - Modelos menores: 7B ao invés de 70B
  #    - CPU offloading: accelerate
}
