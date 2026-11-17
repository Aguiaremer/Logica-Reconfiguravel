# Lógica Reconfigurável

Repositório com exercícios, laboratórios e trabalhos desenvolvidos na disciplina de **Lógica Reconfigurável**. A maior parte dos projetos usa VHDL e ferramentas do fluxo Intel/Altera, como Quartus, Platform Designer (Qsys) e ModelSim.

## Conteúdo

| Pasta | Projeto / assunto | O que há no diretório |
| --- | --- | --- |
| [`T1/`](T1/) | Contador binário de 4 bits | Implementação VHDL, testbench e arquivos do projeto Quartus. Há uma cópia do exercício dentro de `T1/tarefa1/`. |
| [`T2/`](T2/) | Contador BCD de 00 a 89 | Contadores de 4 bits encadeados, testbench e scripts/arquivos de simulação. O `README.txt` registra resultados RTL e gate-level no ModelSim. |
| [`T3/`](T3/) | Cronômetro | Projeto VHDL com contadores, divisor de clock, tratamento dos botões e decodificação BCD para displays de sete segmentos. |
| [`T4/`](T4/) | Contagem de bits iguais a 1 | Implementações para contar os bits de uma entrada de 5 bits usando diferentes construções VHDL; inclui também um totalizador serial e testbenches. |
| [`T5/`](T5/) | BRAM, FIFO e controle de fluxo | Memórias e FIFO, lógica de transferência entre elas, testbenches, scripts, imagens de simulação e relatório em PDF. O README local registra os resultados do trabalho. |
| [`T6/`](T6/) | Sistema Nios II com barramento Avalon | Configuração Platform Designer (`SNios_new/HSys.qsys`), arquivos de descrição e suporte de simulação para um sistema com CPU Nios II, memória, JTAG UART e componente Avalon. |

## Tecnologias e arquivos

- **VHDL** para lógica digital e testbenches (`.vhd`).
- **Quartus** para projetos FPGA (`.qpf` e `.qsf`) e megafunções Intel/Altera.
- **ModelSim** para simulações RTL e gate-level; alguns diretórios contêm scripts `.do`.
- **Platform Designer/Qsys** no sistema baseado em Nios II de `T6`.

## Como explorar

1. Comece pelo diretório do trabalho desejado e leia o `README.txt` ou relatório local, quando houver.
2. Abra no Quartus o arquivo `.qpf` correspondente, quando presente.
3. Para simular, confira os testbenches (`*_tb.vhd` ou `tb_*.vhd`) e os scripts `.do` do próprio diretório. As megafunções de BRAM/FIFO podem exigir as bibliotecas de simulação da Intel/Altera.

Os arquivos `.bak`, capturas de tela, relatórios e saídas geradas pelas ferramentas foram mantidos junto dos projetos de origem. Nem todo diretório contém um fluxo de compilação completo ou instruções independentes para reproduzir a simulação.

## Observação sobre T6

`T6/SNios_new/HSys.qsys` descreve o sistema Qsys e o diretório `HSys/` inclui arquivos gerados, entre eles suporte de testbench. No estado atual do repositório não há um projeto Quartus completo (`.qpf`/`.qsf`) visível nessa pasta; portanto, os arquivos disponíveis podem não ser suficientes para recompilar ou executar o sistema sem os fontes e componentes originais.
