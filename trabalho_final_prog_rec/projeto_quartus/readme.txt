======================================================
       GUIA DE EXECUÇÃO - PROJETO WEB SERVER
======================================================

------------------------------------------------------
PASSO 1: CONFIGURAR O HARDWARE (FPGA)
------------------------------------------------------
1. Conecte a placa ao computador.
2. Abra o Quartus Programmer.
3. Clique em "Add File..." e navegue até a pasta:
   -> /output_files/
4. Selecione o arquivo ".sof" gerado pela compilação 
   (ex: lab7_time_limited.sof).
5. Clique em "Start" para carregar o hardware na placa.
   (Nota: não a feche a janela do OpenCore Plus,
   ou a rede irá parar de funcionar).

------------------------------------------------------
PASSO 2: EXECUTAR O SOFTWARE (NIOS II ECLIPSE)
------------------------------------------------------
1. Abra o Nios II SBT for Eclipse.
2. Importe o projeto "lab7" que está localizado na pasta:
   -> /software/
3. Compile o projeto (Build Project).
4. Carregue o binário ELF na placa usando Run as 
   Nios II Hardware,
   (Run As > Nios II Hardware).
   se necessário recarregue as conexões
   (Target Connection > Refresh Connections).
5. INSIRA UM MAC VÁLIDO.

Apartir daqui o web server está pronto para ser usado
por qualquer cliente HTTP,
caso consiga receber um IP do servidor DHCP.

------------------------------------------------------
PASSO 3: TESTAR A APLICAÇÃO CLIENTE
------------------------------------------------------
1. Após executar o software, observe o "Nios II Console" 
   no Eclipse.
2. Aguarde a inicialização da rede. O servidor irá obter 
   um endereço IP automaticamente via DHCP. 
3. Anote o IP exibido no console.
4. Abra o arquivo "client.html" em um editor de texto 
   (Bloco de Notas, VS Code, etc).
5. Localize o IP antigo configurado no arquivo e 
   SUBSTITUA pelo novo IP recebido via DHCP 
   (Um é exibido na pagina e outro está localizado na
   seção <script></script> que altera de fato o 
   comportamento do cliente).
6. Salve o arquivo "client.html" e abra-o em um 
   navegador de internet para testar a comunicação.
