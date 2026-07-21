===============================================================================
                       SISTEMA DE FILTRAGEM DE ÁUDIO DSP
===============================================================================

Este projeto consiste em um sistema de processamento digital de sinais (DSP) 
embarcado em um processador Nios II (FPGA Cyclone 10LP), que se comunica via 
rede com clientes em C++ (CLI) ou Python (Interface Gráfica) para filtragem 
de áudio em tempo real.

-------------------------------------------------------------------------------
1. PASSO A PASSO: CONFIGURAÇÃO DO HARDWARE E EMBARCADO (QUARTUS & NIOS II)
-------------------------------------------------------------------------------

Siga os passos rigorosamente na ordem descrita abaixo:

[Passo 1] - Compilação do Hardware
  * Abra o projeto no Intel Quartus Prime 18.1.
  * Execute a compilação completa (Full Compilation) para gerar o arquivo .sof.

[Passo 2] - Configuração do Software (Eclipse)
  * Abra o Eclipse embedded Tools integrado ao Nios II.
  * Importe o projeto de software e o respectivo BSP (Board Support Package).
  * Compile o projeto no Eclipse (Build Project).

[Passo 3] - Gravando a FPGA
  * Abra o Quartus Programmer.
  * Carregue o arquivo .sof gerado e programe a placa Cyclone 10LP.

[Passo 4] - Executando o Firmware Nios II
  * No Eclipse, vá em "Run Configurations...".
  * Certifique-se de selecionar a placa detectada no JTAG Chain.
  * NOTA: Se a placa não aparecer, clique no botão "Refresh Connections".
  * Execute o programa (Run).

[Passo 5] - Inicialização da Rede na Placa
  * Com o programa rodando, abra o terminal do Nios II (Nios II Console).
  * O sistema solicitará o Endereço MAC da placa.
  * Digite o endereço MAC exatamente como consta no adesivo embaixo da placa.
  * Aguarde a mensagem confirmando que o servidor TCP foi aberto com sucesso.

-------------------------------------------------------------------------------
2. CLIENTES: OPERAÇÃO E EXECUÇÃO
-------------------------------------------------------------------------------

Assim que o servidor na placa estiver ativo, você poderá interagir com ele 
utilizando qualquer uma das duas interfaces abaixo:

A. CLI (Interface de Linha de Comando em C++)
   * Desenvolvido e testado exclusivamente no Linux.
   * Requisito: Compilador compatível com o padrão C++23 (ex: GCC 13+ ou Clang 17+).

B. Interface Gráfica (Front-End em Python)
   * Permite selecionar o arquivo .wav, o tipo de filtro, ajustar frequências,
     escutar o áudio em memória e salvar o resultado.

   * No Linux (Arch/Ubuntu/Debian):
     Execute o script automatizado para criar o ambiente virtual, instalar 
     as dependências e rodar o app:
     $ chmod +x run.sh
     $ ./run.sh

   * No Windows:
     O processo detalhado de configuração do ambiente, políticas do PowerShell
     e execução está descrito no arquivo: "windows_front_end.txt".

===============================================================================
